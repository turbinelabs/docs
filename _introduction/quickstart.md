---
layout: page
title: Quickstart
print_order: 4
time_to_complete: 10 minutes
---

[//]: # ( Copyright 2018 Turbine Labs, Inc.  )
[//]: # ( you may not use this file except in compliance with the License.  )
[//]: # ( You may obtain a copy of the License at )
[//]: # ( )
[//]: # ( http://www.apache.org/licenses/LICENSE-2.0 )
[//]: # ( )
[//]: # ( Unless required by applicable law or agreed to in writing, software )
[//]: # ( distributed under the License is distributed on an "AS IS" BASIS, )
[//]: # ( WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or )
[//]: # ( implied. See the License for the specific language governing )
[//]: # ( permissions and limitations under the License.  )

This guide walks you through setting up Houston in your environment, in order to
unlock traffic management superpowers for all of your teams.

## Prerequisites

In order to use this guide, you’ll need an installation of
[Go](https://golang.org/dl/), and either
[`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl)
or [`docker`](https://docs.docker.com/install/) depending on your
platform. You’ll also need network access to your service discovery—Kubernetes,
Consul, or EC2.

## Setup tbnctl

First, run `setup_tbnctl.sh`, which installs `tbnctl`, logs you in, creates a
zone and proxy for Houston, and creates an access token for Rotor.

```console
$ curl https://docs.turbinelabs.io/introduction/examples/setup_tbn.sh | bash
```

You’ll need the value of `signed_token` to start Rotor below.

##  Rotor

The Rotor project is a fast, lightweight bridge between your service discovery
and [Envoy’s](https://envoyproxy.github.io) configuration APIs. Instances are
gathered directly from your service discovery registry, and clusters are created
by grouping together instances under a common tag or label.

Services and instances are stored in the Houston API, mirroring the state of
your environment, which is the source of truth for service discovery. You can
view them from Houston but they are read-only.

## Installing Rotor

First, install and run Rotor:

{% include_relative examples/rotor-tabs.html %}

To customize or change your installation, you can run the following command to
determine which environmental variables you can use and modify. For more
information about customizing values for your platform, visit the
[Kubernetes](../advanced/kubernetes.html), [Consul](../advanced/consul.html), or
[EC2](../advanced/ec2.html) guides.

## Label your clusters

By default, Rotor will collect endpoints (containers or hosts) with a specific
label or tag. Add this label to any endpoints that you want to appear in
Rotor. Houston will group endpoints by the value of this label (typically the
service name).

{% include_relative examples/labels-tabs.html %}

## List your clusters

Check that Rotor has picked up your services with:

```console
$ tbnctl list --format=summary cluster
```

If you have multiple zones set up, this will give you results from all zones. To
filter to a specific zone, first find the zone key, then filter by it:

```bash
$ tbnctl list zone
...
$ tbnctl list --format=summary cluster --zone_key=<zone_key_here>
```

## View your clusters in Houston

Visit [app.turbinelabs.io](https://app.turbinelabs.io) and login with your
username and password to view the zone you created at the start of this
guide. Any clusters you labeled previously will now appear in the list.

## Next Steps

To have Envoy serve traffic, there are two more steps:

1. Set up routing rules [in the app](https://app.turbinelabs.com#starttourx);
   then
2. Deploy Envoy to serve these routes. See our guides for
   - [Kubernetes](../advanced/kubernetes.html)
   - [Consul](../advanced/consul.html)
   - [EC2](../advanced/ec2.html)
