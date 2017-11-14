---
layout: page
title: Introduction
print_order: 1
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

## Introducing Houston, by Turbine Labs

Launching an observable and easily manageable Envoy proxy is an important part
of modern infrastructure. With Houston, our production tool for running and
observing an Envoy fleet, you can confidently test your code in production,
release it incrementally, or rebuild your infrastructure, with no visible impact
to customers.

## Observability made easy

Modern architecture like Kubernetes and Envoy give you unprecedented
expressiveness, but they are complex to implement and difficult to instrument;
it’s hard to connect the dots from what you’ve built to what your customer
sees. Houston bridges the gap, easily installing Envoy, and combining a
customer-centric approach to monitoring and observation with insight into
changes to your infrastructure.

Houston provides a concise, consistent set of metrics that let you understand
your customer’s experience at any level of granularity, from the entire domain
to a single endpoint. You can slice those same metrics by service or software
version to understand how your changes affect that experience. Houston keeps a
record of these change, making it easy to correlate them with incidents,
compare customer experience across multiple software versions, and measure the
quality and pace of your software releases.
