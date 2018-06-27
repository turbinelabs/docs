---
layout: page
title: Rotor Guide
time_to_complete: 5 minutes
redirect_from: /guides/tbncollect.html
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

[//]: # (Rotor)

## Rotor architecture

Rotor comprises a few parts:

 - A service discovery collector, which collects to your registry (Kubernetes,
EC2, Consul, etc)
 - An xDS implementation configured via API key
 - A gRPC log sink which forwards request metrics to the Turbine Labs API,
and/or to Prometheus, statsd, dogstatsd, or Wavefront

For very large Envoy fleets, Rotor can be configured to serve as a sidecar xDS
and log sink without collecting service discovery data.

## Discovery and Management

Rotor provides instance collection, with label-based grouping. With an API key
for Houston, Rotor's embedded xDS server can be fully configured by the Turbine
Labs API, including route and listener management. This unlocks the full
capabilities of Envoy with minimal implementation effort. Tweak and configure
all your Envoy configuration settings in the Turbine Labs UI, API, or
command-line API wrapper, tbnctl.

Rotor also acts as a request log sink, and exposes request metrics to
Prometheus, statsd, dogstatsd, or Wavefront. With the addition of a Houston API
key, it also forwards these metrics to Houston.

## Adding an API key

Rotor is [open source software](https://github.com/turbinelabs/rotor). When run
in standalone mode, it collects instance information from service discovery, and
it serves a set of static domains and routes based on the services it finds.

Adding an API key unlocks full configuration and management capabilities; the
same instance and service data is served from Rotor, but is now backed by our
API instead of simply mirroring your service discovery. This unlocks:

 - Houston’s easy-to-use UI for creating and modifying routes
 - Full configuration of all of Envoy’s features: advanced load balancing,
   health checking, circuit breakers, and more
 - Automatic collection of Envoy’s metrics for routes, clusters, and more, with
   easy integration into statsd, Prometheus, and other common dashboards

Specifically, instead of the static routes described in
[Features](https://github.com/turbinelabs/rotor/#features), an API key allows
more flexible configuration of routes, domains, listeners, and clusters through
Houston. You can also run multiple Rotor processes to bridge, e.g. EC2 and
Kubernetes, allowing you configure routes that incrementally migrate traffic
from one to the other.

## Configuring Leaderboard Logging

Envoy has the ability to redirect or reject requests based on the configuration
provided by Rotor. This means it's possible to see a disconnect between stats as
reported by your service and those reported by Envoy.

If you need access to the cause of those differences but do not need the
functionality provided by a full ALS consumer Rotor can be configured to log a
leaderboard recording the top non-2xx requests. This is done through global flags:

 Flag                         | Argument / Default | Description 
------------------------------|--------------------|------------
`--xds.grpc-log-top`          | Integer, 0         | Controls how many unique response code and request path combinations are tracked. When the number of tracked combinations in the reporting period is exceeded, uncommon paths are evicted.
`--xds.grpc-log-top-interval` | Duration, 5m       | Controls the interval at which top logs are generated.

The generated logs are sent to `stdout` and requires that logging (`console.level`)
is set at `info` level or higher. They are reported in the format:

```bash
[info] <timestamp> ALS: <number of requests>: <HTTP response code> <request path>
```

## Formerly tbncollect

Before being open-sourced, Rotor was named `tbncollect`. If you were previously
using the `tbncollect` Docker image, the latest version of both Rotor and
`tbncollect` will honor environment variables prefixed with `TBNCOLLECT_` and
`ROTOR_`.

Use of tbncollect is deprecated. All future updates will go into Rotor.
