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

Houston, by Turbine Labs, consists of several components. Our Envoy-based proxy
is installed in your environment, along with a service discovery collector
configured for your infrastructure. Our hosted API, web application, and
analytics backend provide a control plane to observe and manage your
application.

<img src="/assets/arch_lm.png"/>

## In your environment

### Rotor – Service discovery made easy

Rotor is an agent that scans your environment for running service clusters
and instance labels. It has integrations with Kubernetes, DC/OS, Consul, ECS,
and EC2. It can also poll a YAML or JSON file, for static or custom
integrations. Changes to your environment are mirrored to the Turbine Labs API.

### tbnproxy – Envoy-based, fast, and GUI configurable

Our Envoy-based proxy is responsible for receiving customer requests and
dispatching them to appropriate service instances. An admin server runs
alongside the proxy, and is responsible for managing its configuration and
forwarding request/response metrics to the Turbine Labs API. When it detects
changes in your environment, it updates the proxy configuration.

## Hosted by Turbine Labs

### API

Our public API provides a central, hosted management service for environment
configuration and metrics. It maintains a catalog of the zones, domains,
routes, service clusters and instances, and proxies in your environment. It
also provides a detailed log of changes to these objects, with a query
interface for request/response metrics dimensionalization.

### Management web app

The UI, built on top of our public API, provides a simple, intuitive
interface for managing and observing the state of your environment. Create and
modify Envoy configurations without modifying YAML, instantly. Also, view
customer-based metrics, rich changelogs to triage incidents, and ensure the
smooth running of your services all in a single, consistent interface. From a
top-level view, to any level of granularity, Houston gives you data and
flexible observability.


### Supported deployment platforms
While the Turbine Labs software will run on a wide variety of architectures,
we've built specific integrations with [Kubernetes]({{ "/guides/kubernetes.html" | relative_url }}), [DC/OS]({{ "/guides/dcos.html" | relative_url }}), [Consul]({{ "/guides/consul.html" | relative_url }}), [EC2]({{ "/guides/ec2.html" | relative_url }}), and
[ECS]({{ "/guides/ecs.html" | relative_url }}). We plan to add more integrations in the future, and our YAML/JSON
file polling mechanism provides extensibility if you wish to create your own.
