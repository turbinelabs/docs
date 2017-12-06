---
layout: page
title: Quickstart
print_order: 4
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

[//]: # (Quick Start)

This guide walks you through setting up Houston, including the Envoy-based
tbnproxy, customer-centric stats segmented by service, and a log of all changes
to routing configuration.

## Signing up for an account

To get started with Houston, you'll need a Turbine Labs
account. [Click here to get started.](https://turbinelabs.io/contact/)

{% include guides/access_token.md %}

## What's in the All-In-One image?

### tbnproxy and tbncollect

These two applications will run in a real-world deployment, connected to Turbine
Labs' API.

- **tbnproxy**: The Envoy-based Turbine Labs reverse proxy, and an admin agent
that that maintains proxy configuration and sends metrics to the Turbine
Labs Service. The metrics are then segmented and exposed in the management UI.
- **tbncollect**: A service discovery agent that observes the service instances,
updating the Turbine Labs Service as services or applications come and go. In
this demo, the collector is watching for files instead of API instances.

### All-in-one server

A simple HTTP server application that returns hex color value strings. There
are three "versions" of the server, each returning a different color value:

  - blue
  - green
  - yellow

### All-in-one client

This app is used to demonstrate the use of Houston through a simple
visualization of routing and responses, but is disposable after experimenting
with this demo.

## Installing tbncollect and tbnproxy

The three environment variables you'll need to set in order to run the demo are:

- `TBNPROXY_API_KEY` - the `signed_token` you obtained with `tbnctl`
- `TBNPROXY_API_ZONE_NAME` - the zone name to use for the trial
- `TBNPROXY_PROXY_NAME` - the name of the proxy, usually the zone name with a
  "-proxy" suffix

To run the Docker container with tbnproxy, tbncollect, and the all-in-one server
and client, use the following command:

```console
$ docker run -p 80:80 \
  -e "TBNPROXY_API_KEY=<signed_token>" \
  -e "TBNPROXY_API_ZONE_NAME=all-in-one-demo" \
  -e "TBNPROXY_PROXY_NAME=all-in-one-demo-proxy" \
  turbinelabs/all-in-one:0.14.1
```

This command will:

- Pull the Turbine Labs all-in-one image from Docker Hub if you don't already
have it.
- Initialize your test zone if it doesn't already exist.
- Launch tbnproxy.
- Launch tbncollect.
- Launch the client and server instances.

_Note:_ In some cases the local Docker time may have drifted significantly  from
your host's time. If this is the case, you'll see the following message in the
`docker run` output:

```
FATAL: your docker system clock differs from actual (google) time by more
than a minute. This will cause stats and charts to behave strangely.
```

If you see this error, restart Docker and re-run the all-in-one container.

{%
  include guides/demo_exercises_whats_going_on.md
  all_in_one="true"
%}

{%
  include guides/deployed_state.md
  all_in_one="true"
%}

{% include guides/incremental_release.md %}

These examples illustrate the changelog, as well as the service-segmented stats
that you will find at [app.turbinelabs.io](http://app.turbinelabs.io) when
integrating Houston with your own apps and services. Observability is a key
component of modern software development and production environments, and by
focussing on customer-based metrics, with rich granularity, we think Houston
will greatly aid your team.

## Next steps

Now that you've seen all-in-one demo in action, you can move on to deploying
Houston in your own environment. After reading the configuration guide below,
proceed to one of the following cloud integrations:

- [Kubernetes](../guides/kubernetes.html)
- [DC/OS](../guides/dcos.html)
- [Consul](../guides/consul.html)
- [EC2](../guides/ec2.html)
- [ECS](../guides/ecs.html)
