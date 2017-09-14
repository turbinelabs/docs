---
layout: page
title: Kubernetes Guide
time_to_complete: 10 minutes
---

[//]: # ( Copyright 2017 Turbine Labs, Inc.                                   )
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

[//]: # (Integrating Houston with Kubernetes)

{%
  include guides/prerequisites.md
  platform="Kubernetes"
  quick_start_name="GKE quick start guide"
  quick_start_url="https://cloud.google.com/container-engine/docs/quickstart"
%}

## Adding your API key to Kubernetes

To avoid having your API key visible in environment variables (which can
inadvertently be exposed in logs and the command line) we recommend you store it
as a [Kubernetes secret](https://kubernetes.io/docs/user-guide/secrets/).
Running the following command will create a new secret with the `signed_token`
AccessToken you obtained from `tbnctl`, which can then be referenced by other
Kubernetes specs.

```console
$ kubectl create secret generic tbnsecret --from-literal=apikey=<value of signed_token>
```

## Setting up service discovery

The tbncollect binary scans your Kubernetes cluster for pods and groups
them into clusters in the Turbine Labs API. To deploy tbncollect to your
Kubernetes cluster, run

```console
$ kubectl create -f https://docs.turbinelabs.io/guides/examples/kubernetes/tbncollect_spec.yaml
```

[Customizing tbncollect For Your Kubernetes Environment](./kubernetes_customizing_tbncollect.html)

## The all-in-one demo

We'll use the same client application described in our [quickstart]({{
"/reference/#quick-start" | relative_url }}) for these examples. To deploy the
all-in-one client, run

```console
$ kubectl create -f https://docs.turbinelabs.io/guides/examples/kubernetes/all-in-one-client.yaml
```

Next, deploy the all-in-one server by running

```console
kubectl create -f https://docs.turbinelabs.io/guides/examples/kubernetes/all-in-one-server-blue.yaml
```

Ensure that these pods have started correctly by running:

```console
$ kubectl get pods
```

```shell
NAME                                       READY     STATUS    RESTARTS   AGE
all-in-one-client-680519093-jdx7g          1/1       Running   0          2m
all-in-one-server-1015810482-rgf8f         1/1       Running   0          1m
tbncollect-3235735371-f594t                1/1       Running   0          3m
```

{% include guides/verify_tbncollect.md %}

{% include guides/adding_a_domain.md %}

## Deploying tbnproxy

Now we're ready to deploy tbnproxy to Kubernetes:

```console
$ kubectl create -f https://docs.turbinelabs.io/guides/examples/kubernetes/tbnproxy_spec.yaml
```

## Expose tbnproxy to the external network

This is environment specific. If you're running in GKE you can use the following
path. First, expose the deployment on a NodePort to make it accessible outside
the local Kubernetes network:

```console
$ kubectl expose deployment tbnproxy --target-port=80 --type=LoadBalancer
```

Then wait for an external IP address to be created (this may take some time)

```console
$ kubectl get services --watch
```

```shell
NAME           CLUSTER-IP     EXTERNAL-IP       PORT(S)   AGE
Kubernetes     10.3.240.1     <none>            443/TCP   24m
tbnproxy       10.3.241.247   104.198.110.237   80/TCP    5m
```

{% include guides/configure_routes.md %}

## Verifying your deploy

Now visit your load balancer, and you should see the all-in-one client running.
To get the IP address for your deployment you can run

```console
kubectl get service
```

copy the `EXTERNAL-IP` field for the tbnproxy service, and paste that into the
address bar of your browser.

{%
  include guides/demo_exercises_whats_going_on.md
  platform="Kubernetes"
%}

{% include guides/deployed_state.md %}

{% include guides/setup_initial_route.md %}

### Deploying a new version

Now we'll deploy a new version of the server that returns green as the color to
paint blocks.

```console
kubectl create -f https://docs.turbinelabs.io/guides/examples/kubernetes/all-in-one-server-green.yaml
```

if you run

```console
$ kubectl get pods
```

```shell
NAME                                       READY     STATUS    RESTARTS   AGE
all-in-one-client-680519093-jdx7g          1/1       Running   0          2m
all-in-one-server-1015810482-rgf8f         1/1       Running   0          1m
all-in-one-server-green-3537570873-7npmx   1/1       Running   0          22s
tbncollect-3235735371-f594t                1/1       Running   0          3m
```

{% include guides/your_environment.md %}

{% include guides/testing_before_release.md %}

{% include guides/incremental_release.md %}

{% include guides/testing_latency_and_error_rates.md %}

### Driving synthetic traffic

If you'd like to drive steady traffic to your all-in-one server without keeping
a browser window open, you can run the all-in-one-driver image in your
kubernetes environment. You can use the template below, filling in the value for
`ALL_IN_ONE_DRIVER_HOST` with the `EXTERNAL-IP` field from your tbnproxy
service. You can also add error rates and latencies for various using
environment variables.

```yaml
{% include_relative examples/kubernetes/all-in-one-driver.yaml %}
```

Now start your traffic driver with:

```console
$ kubectl create -f all-in-one-driver.yaml
```

{% include guides/conclusion.md
   platform="Kubernetes"
%}
