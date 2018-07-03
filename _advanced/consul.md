---
layout: page
title: Install in Consul
time_to_complete: 15  minutes
redirect_from: /guides/consul.html
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

[//]: # (Integrating Houston with Your Consul Environment)

## Intro

This guide discusses how to best integrate Houston with Consul. It covers
deploying Rotor to Consul, as well as tagging your existing services to be
discovered by Houston.

Before you start, make sure you’ve gone through the
[Quickstart](../introduction/#quickstart) for Houston, have a working Docker
installation, and the host and port of an existing Consul registry.

## Deploying Rotor

Note: if you’ve finished the Quickstart, all of this section is already
done. You can skip to [Deploying Envoy](#deploying-envoy).

First, run the Rotor image on a Docker host with network access to the Consul
registry, with your environment variables defined inside of the Docker command,
using the signed_token you obtained with tbnctl:

```console
$ {% include_relative examples/consul/rotor.sh %}
```

## Labeling your Consul services

Rotor discovers clusters by looking for services in Consul and grouping them
based on their tags. You will have to tag each service with `tbn-cluster`
([customize](#ROTOR_CONSUL_CLUSTER_TAG)). Rotor also collects both tags and node
metadata, which you can use to define routes rules.

Services without this tag—e.g., Envoy nodes or Rotor itself—will be ignored.

## Deploying Envoy

The only configuration Envoy needs is a simple bootstrap to read from Rotor. You
can do this with
[`envoy-simple`](https://hub.docker.com/r/turbinelabs/envoy-simple/), an Envoy
Docker image from Turbine Labs that can be configured via environment variables.

To create this deployment, use Docker to launch it. Update `ENVOY_NODE_CLUSTER`
to match the name of the proxy you created in the Quickstart. If you have
changed the zone, update `ENVOY_NODE_ZONE` below, too.  If you followed the
Quickstart, this Docker command will be familiar.

```console
$ {% include_relative examples/consul/envoy.sh %}
```

Ensure that these containers started correctly by running:

```console
$ docker ps
```

```shell
CONTAINER ID        IMAGE                             COMMAND                  CREATED                  STATUS              PORTS                                                 NAMES
6561ec86fc11        turbinelabs/envoy-simple:0.18.0   "/sbin/my_init -- /u…"   Less than a second ago   Up 4 seconds        0.0.0.0:80->80/tcp, 0.0.0.0:9999->9999/tcp, 443/tcp   gracious_shannon
```

To test if this worked, curl the IP of your Envoy. Envoy requires the Host
header be present, so add a header for a service that exists in your cluster.
This should match a domain and route you have
[configured in Houston](https://app.turbinelabs.io).

```console
$ curl  -h 'Host: example.com' 10.3.241.247
```

## Scaling Envoy and Rotor

Once you have Envoy deployed as a load balancer (or "front proxy") in your
cluster, you can also deploy it as part of each service ("service mesh"
architecture). It’s best to run Rotor as a sidecar as well, 1-for-1 with each
sidecar Envoy. In this mode, Rotor will only serve the configuration it pulls
from the Houston API, resulting in fewer overall calls to Consul. Rotor will
also batch metrics locally every minute and return them to the Houston API,
rather than sending raw request logs over your network to a central Rotor.

You should still run at least one Rotor instance in "consul" mode, to make sure
Houston has an up-to-date view of your infrastructure environment.

Configure Rotor in xDS-only mode by changing `ROTOR_CMD` to 'xds-only' and
dropping the Consul connection information:

```console
$ {% include_relative examples/consul/rotor-xds-only.sh %}
```
## Customizing

### Custom deployment settings

The Consul collector, by default, will collect nodes belonging to services with
a "tbn-cluster" tag. This behavior can be overridden using environment
variables, as described below.

You can see which flags are available:

```console
$ docker run turbinelabs/rotor:0.18.0 rotor consul --help
```

Environment variables corresponding to flags are derived from those flags by
first prefixing with the command and subcommand (in this case `ROTOR_CONSUL_`),
and then converting the flag name to uppercase and replacing any
non-alphanumeric characters with `_`. So for example, the --dc flag becomes
`ROTOR_CONSUL_DC`.

Use the command `Rotor help consul` to determine which environmental variables you can use and modify.

<a name="ROTOR_CONSUL_CLUSTER_TAG"></a>
#### ROTOR_CONSUL_CLUSTER_TAG=string

(default: "tbn-cluster")
The tag used to indicate that a service should be imported as a
Cluster.

#### ROTOR_CONSUL_DC=string

[REQUIRED] Collect Consul services only from this DC.

#### ROTOR_CONSUL_HOSTPORT=[host]:port

(default: "localhost:8500") The [host]:port for the Consul API.

#### ROTOR_CONSUL_USE_SSL=false

(default: false) If set will instruct communications to the Consul API to be
done via SSL.

#### ROTOR_CONSOLE_LEVEL=level

(default: "info") (valid values: "debug", "info", "error", or "none") Selects
the log level for console logs messages.

For testing purposes, you may want to run Rotor with the console level set to
debug. This will help you determine if Rotor is correctly polling and
recognizing your cluster and pods.

## Conclusion

That’s it, you’re done! [Log into Houston](https://app.turbinelabs.io) to
configure routes, enable resilience features like retries and circuit breakers,
and work on migrations and releases. If you have questions or run into any
trouble, please [drop us a line](mailto:support@turbinelabs.io)—we're here to
help.
