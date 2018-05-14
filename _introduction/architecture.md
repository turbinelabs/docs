---
layout: page
title: Architecture
print_order: 3
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


<img src="/assets/arch_lm.png" alt="Houston Architecture diagram"/>

## Management made easy

Houston sits on top of your Envoy deployment. If you don’t have Envoy deployed,
don’t worry! Houston works equally well to augment your existing Envoys or to
make it easy to configure a new fleet.

In its simplest form, a complete Houston deployment has three parts:

 - One or more Envoy proxies.
 - Rotor, an agent deployed in your environment
 - The Houston app, hosted at
   [app.turbinelabs.io](https://app.turbinelabs.io).

### Envoy

Envoy proxies are responsible for receiving customer requests and dispatching
them to appropriate service instances.

Envoy’s powerful configuration and metrics APIs allow Houston to work with Envoy
without a custom build. You can run the official Docker image, build it from
source, use Turbine Labs envoy-simple, or even use your own private fork.

Envoys configure themselves from the Houston Labs API via Rotor. Traffic
management configuration—routing rules, retry configurations, protocol changes,
and everything else you’d normally find in a config file—is sent to your Envoy
instances via the Envoy APIs (CDS, RDS, EDS, and LDS, collectively known as
xDS). Metrics are also streamed back over an Envoy-defined API.

### Rotor

Rotor is the bridge between everything in your environment and the Houston
API. It performs three key functions:

Collecting instance (e.g. host, container) information from service discovery.
Serving traffic management configuration to all your Envoy instances.  Receiving
Envoy request logs, forwarding derived metrics back to Houston

Rotor continuously reads instance information from your infrastructure source of
truth, which can be either be your service discovery, your cloud provider’s API,
or a custom source.  Rotor includes native integrations with Kubernetes, DC/OS,
Consul, ECS, and EC2. Rotor can also poll a YAML or JSON file, for static or
custom integrations. Changes to your environment are mirrored to the Houston
API.

Rotor includes an implementation of Envoy’s xDS APIs, which serves traffic
management configuration to Envoy and also sinks request metrics from Envoy. In
environments with many Envoy instances (e.g. a sidecar in a service mesh), it's
possible to run Rotor as a sidecar for just xDS configuration and metrics
collection. In this layout, you should still run at least one separate Rotor, to
make sure Houston has an up-to-date view of your infrastructure environment.

### Houston App

Houston provides a simple, intuitive interface for managing and observing your
Envoy fleet. Create and modify traffic management configurations instantly,
without modifying YAML. View customer-based metrics and detailed change logs to
triage incidents, and ensure the smooth running of your services all in a
single, consistent interface. From a top-level view, to any level of
granularity, Houston gives you vital data to make the right decisions and
flexible observability.

Houston keeps an up-to-date understanding of your infrastructure. It does this
by polling your service discovery for **instances** and grouping them into
**services** based on how they are tagged/labeled. (If you’re familiar with
Envoy’s APIs, these are roughly called endpoints and clusters.)

Houston also provides the interface for defining **domains** and
**routes**. These are the rules you previously would have written in your web
server’s configuration file, but with the additional flexibility to route based
on a larger number of features, such as instance tags, request headers, or using
more advanced load balancing algorithms. (If you’re familiar with Envoy’s APIs,
these would be configured with a combination of listeners and routes.)

To help manage complexity at scale, Houston provides several ways to group these
objects together.

 - **Zones** are a top-level construct, typically used to separate rules so
   traffic isn’t sent over a connection that’s slow or expensive (e.g. between
   AWS regions or physical data centers).
 - **Proxies** define a logical proxy, allowing you to define a single
   configuration shared between multiple Envoy images, such as all instances in
   a horizontally scaled load balancer.
 - **Route Groups** provide a way to manage multiple routes on the same domain
   at one time, e.g. to help releases a new version across multiple routes at
   the same time.

Log in at [app.turbinelabs.io](https://app.turbinelabs.io), or register at
[turbinelabs.io](https://www.turbinelabs.io/contact/).
