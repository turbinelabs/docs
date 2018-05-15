---
layout: page
title: Install in Kubernetes
time_to_complete: 15 minutes
redirect_from:
  - /advanced/kubernetes_customizing_tbncollect.html
  - /advanced/kubernetes_integrating_houston.html
  - /guides/kubernetes.html
---

[//]: # ( Copyright 2018 Turbine Labs, Inc.                                   )
[//]: # ( you may not use this file except in compliance with the License.    )
[//]: # ( You may obtain a copy of the License at                             )
[//]: # (                                                                     )
[//]: # (     http://www.apache.org/licenses/LICENSE-2.0                      )
[//]: # (                                                                     )
[//]: # ( Unless required by applicable law or agreed to in writing, software )
[//]: # ( distributed under the License is distributed on an "AS IS" BASIS,   )
[//]: # ( WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or     )
[//]: # ( implied. See the License for the specific language governing        )
[//]: # ( permissions and limitations under the License.                      )

[//]: # (Integrating Houston with Your Kubernetes Environment)

## Intro

This guide discusses best practices for installing Houston in your Kubernetes
cluster. It covers deploying the various services to Kubernetes, as well as
labeling your existing services to be discovered by Houston.

Before you start, make sure you’ve gone through the
[Quickstart](../introduction#quickstart) for Houston, and have a Kubernetes
installation you can connect to via with `kubectl`.

## Deploying Rotor

Note: if you’ve finished the Quickstart, you can skip to [Deploying
Envoy](#deploying-envoy). Read on to see exactly what objects were created from
the `kubectl create -f ` command!

First, we’ll deploy Rotor as a Kubernetes Deployment and associated
Service. Rotor will both collect pod information about your Kubernetes
environment and serve the Envoy xDS APIs.

We recommend that you store your API key as a Kubernetes secret so it’s not
visible in environment variables. Running the following command will create a
new secret with the `signed_token` AccessToken you obtained from `tbnctl`, which
can then be referenced by other Kubernetes specs.

```console
$ kubectl create secret generic tbnsecret --from-literal=apikey=<value of signed_token>
```

Before creating the Deployment for Rotor, we’ll have to set up the necessary
RBAC objects. Save the YAML below into a file called `rotor-rbac.yaml`, or
download it [here](/advanced/examples/kubernetes/rotor-rbac.yaml).

```yaml
{% include_relative examples/kubernetes/rotor-rbac.yaml %}
```

To create the objects, run:

```console
$ kubectl create -f rotor-rbac.yaml
```

Next, create a Deployment spec for Rotor. Save the YAML below as `rotor.yaml`,
or download it [here](/advanced/examples/kubernetes/rotor.yaml). If you chose a
different zone name in the Quickstart, update that under `ROTOR_API_ZONE_NAME`.

```yaml
{% include_relative examples/kubernetes/rotor.yaml %}
```

Create this deployment and expose it as a service with the following commands. The service created by the second YAML definition above provides a stable IP that Envoy will read its configuration from.

```console
$ kubectl create -f rotor.yaml
```

<a name="labels"></a>
## Labeling your Kubernetes Services

Rotor discovers clusters by looking for active pods in Kubernetes and grouping
them based on their labels. You will have to add two pieces of information to
each pod to have Rotor recognize it:

1. A `tbn_cluster: <name>` label to name the service to which the Pod
   belongs. The name can be [customized](#ROTOR_KUBERNETES_CLUSTER_LABEL)
2. An exposed port named `http` or
   [a customized name.](#ROTOR_KUBERNETES_PORT_NAME)

A pod must have both the `tbn_cluster` label and a port named `http` to be
collected by Rotor.

Rotor will also collect all other labels on the Pod, which can be used for
routing. For example, Houston can use a `version` tag (e.g., version control
tag, branch, or SHA) to do blue/green releases.

Here is an example deployment with all extra labels set up:

```yaml
{% include_relative examples/kubernetes/label.yaml %}
```

## Deploying Envoy

The only configuration Envoy needs is a simple bootstrap to read from Rotor. You
can do this with
[`envoy-simple`](https://hub.docker.com/r/turbinelabs/envoy-simple/), an Envoy
Docker image from Turbine Labs that can be configured via environment variables.

To create this Deployment, download
[envoy.yaml](examples/kubernetes/envoy.yaml). Also, update `ENVOY_NODE_CLUSTER`
to match the name of the proxy you created in the Quickstart as well as the
`ENVOY_NODE_ZONE`.

```yaml
{% include_relative examples/kubernetes/envoy.yaml %}
```

To deploy Envoy into your cluster and give it a public IP, create a
[Kubernetes `LoadBalancer` deployment](https://kubernetes.io/docs/concepts/services-networking/service/#type-loadbalancer).
This will provision a Load Balancer in your cloud provider, e.g. ELB in AWS or
GLB in Google Cloud.

```console
$ kubectl create -f envoy.yaml
$ kubectl expose deployment --type=LoadBalancer --port=80 envoy-front-proxy
```

Then wait for an external IP address to be created (this may take some time)

```console
$ kubectl get services --watch
```

```shell
NAME           CLUSTER-IP     EXTERNAL-IP       PORT(S)   AGE
Kubernetes     10.3.240.1     <none>            443/TCP   24m
envoy-front-proxy      10.3.241.247   104.198.110.237   80/TCP    5m
```

To test that all this worked, curl this IP. Please note that Envoy requires the
Host header be present, so add a header for a configured domain. This should
match a domain and route you have [configured in
Houston](https://app.turbinelabs.io).

```console
$ curl  -H 'Host: example.com' http://10.3.241.247
```

## Customizing

## Scaling Envoy and Rotor

Once you have Envoy deployed as a load balancer (or "front proxy") in your
cluster, you can also deploy it as a sidecar in each Pod ("service mesh"
architecture). It’s best to run Rotor as a sidecar as well, 1-for-1 with each
sidecar Envoy. In this mode, Rotor will only serve the configuration it pulls
from the Houston API, resulting in fewer overall calls to Kubernetes API. Rotor
will also batch metrics locally every minute and return them to the Houston API,
rather than sending raw request logs over your network to a central Rotor.

You should still run at least one Rotor instance in "kubernetes" mode, to make
sure Houston has an up-to-date view of your infrastructure environment. In this
layout, Rotor still runs as its own service to collect Pod and Deployment
information from your cluster, but it is no longer the primary API server for
any sidecar Envoys.

Add Rotor to the `containers` section of your Pod spec:

```yaml
{% include_relative examples/kubernetes/rotor-xds-only.yaml %}
```

### Custom deployment settings

The Kubernetes collector, by default, will collect containers with a port named
"http" and a "tbn_cluster" label. This behavior can be overridden using
environment variables, as described below.

You can see which flags are available:

```console
$ docker run -e "ROTOR_CMD=kubernetes" -e "ROTOR_HELP=true" turbinelabs/rotor:0.16.0-rc1
```

Environment variables corresponding to command-line flags are derived from those
flags by first prefixing with the command and subcommand (in this case
`ROTOR_KUBERNETES_`), and then converting the flag name to uppercase and
replacing any non-alphanumeric characters with `_`. For example, the --port-name
flag becomes `ROTOR_KUBERNETES_PORT_NAME`. Please note that any flags set
explicitly in the CLI invocation will override values present in the
environment.

These settings are likely different on your existing Kubernetes cluster, so it's
important to configure your Rotor yaml file to match your environment.

#### ROTOR_KUBERNETES_NAMESPACE

This value sets which Kubernetes cluster namespace Rotor will watch to gather
pods. The default value is: `default`

<a name="ROTOR_KUBERNETES_CLUSTER_LABEL"></a>
#### ROTOR_KUBERNETES_CLUSTER_LABEL

This value specifies which Kubernetes cluster a pod belongs to. The default
label is `tbn_cluster`.

#### ROTOR_KUBERNETES_SELECTOR

This value selects which pods are polled from the pods in your cluster and
namespace. The default is no selector.

<a name="ROTOR_KUBERNETES_PORT_NAME"></a>
#### ROTOR_KUBERNETES_PORT_NAME

The named container port assigned to your Kubernetes cluster instances. The
default port name is `http`.

#### Custom Cert Values:

If your kubernetes cluster API needs custom keys in order to be accessed, these
are the values to set in order to enable a connection to your cluster.

 - `ROTOR_KUBERNETES_CA_CERT`
 - `ROTOR_KUBERNETES_CLIENT_CERT`
 - `ROTOR_KUBERNETES_CLIENT_KEY`

#### ROTOR_KUBERNETES_HOST

The host name for the Kubernetes API server. This is required if Rotor is
running outside of the Kubernetes cluster it will poll.

#### ROTOR_KUBERNETES_TIMEOUT

The timeout used for Kubernetes API requests (converted to seconds). The default
value is 120s.

#### ROTOR_CONSOLE_LEVEL

The default level is: "info". Other values are: "debug", "info", "error", or
"none".

For testing purposes, you may want to run Rotor with the console level set to
debug. This will help you determine if Rotor is correctly polling and
recognizing your cluster and pods.

## Conclusion

That’s it, you’re done! [Log into Houston](https://app.turbinelabs.io) to
configure routes, enable resilience features like retries and circuit breakers,
and work on migrations and releases. If you have questions or run into any
trouble, please [drop us a line](mailto:support@turbinelabs.io)—we're here to
help.
