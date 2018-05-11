---
layout: page
title: Customizing Rotor
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

[//]: # (Customizing Rotor For Your Kubernetes Environment)


## Prerequisites

This guide assumes you have read our
[guide to setting up Houston on Kubernetes](../guides/kubernetes.html), and have an
existing Kubernetes deployment.

## Custom deployment settings

In the previous Kubernetes guide, we instructed users to setup Rotor using
our [pre-baked yaml file](examples/advanced/custom_rotor_spec.yaml), but
this file makes a few assumptions about your environment. First of all, it
assumes you have a named http port, then a label named `tbn_cluster`, as well
as a few more settings.

Additionally, Rotor command-line flags can be specified in the yaml config
using environment variables. Environment variables corresponding to flags are
derived from those flags by first prefixing with the command and subcommand
(in this case `ROTOR_KUBERNETES_`), and then converting the flag name to
uppercase and replacing any non-alphanumeric characters with `_`. So for example,
the `--port-name` flag becomes `ROTOR_KUBERNETES_PORT_NAME`.

These settings are likely different on your existing Kubernetes cluster, so
it's important to configure your Rotor yaml file to match your environment.

*[example custom_rotor_spec.yaml](../guides/examples/kubernetes/rotor_spec.yaml)*

```yaml
{% include_relative examples/custom_rotor_spec.yaml %}
```

Note the values near the bottom of the yaml file—these are a few of the values
you can set either in your CLI or in a yaml file, and the rest may be found in
your CLI by running:

```console
$ rotor kubernetes --help
```

*Please note that any flags set explicitly in the CLI invocation will
override values set in a yaml file.*

## Explanation of custom values

### run: Rotor

Early in the file, you'll need to run Rotor, and add whatever labels or
namespaces are appropriate to your installation.

### ROTOR_KUBERNETES_NAMESPACE

This value sets which Kubernetes cluster namespace Rotor will watch to
gather pods. The default value is: `default`

### ROTOR_KUBERNETES_CLUSTER_LABEL

This value specifies to which Kubernetes cluster a pod belongs. The default
label is `tbn_cluster`.

### ROTOR_KUBERNETES_SELECTOR

This value selects which pods are polled from the pods in your cluster and
namespace. The default is no selector.

### ROTOR_KUBERNETES_PORT_NAME

The named container port assigned to your Kubernetes cluster instances. The
default port name is `http`.

### Custom Cert Values:

If your cluster needs custom keys in
order to be accessed, these are the values to set in order to enable a
connection to your cluster.

`ROTOR_KUBERNETES_CA_CERT`
`ROTOR_KUBERNETES_CLIENT_CERT`
`ROTOR_KUBERNETES_CLIENT_KEY`

### ROTOR_KUBERNETES_HOST

The host name for the Kubernetes API server. This is required if Rotor
is running outside of the Kubernetes cluster it will poll.

### ROTOR_KUBERNETES_TIMEOUT

The timeout used for Kubernetes API requests (converted to seconds). The
default value is 2m0s.

### ROTOR_KUBERNETES_CONSOLE_LEVEL

The default level is: "info". Other values are: "debug", "info", "error", or
"none".

For testing purposes, you may want to run Rotor with the console level set
to debug. This will help you determine if Rotor is correctly polling and
recognizing your cluster and pods.

## Running your custom Rotor

With your environment variables correctly set, you can run Rotor with the
following command:

```console
$ kubectl create -f <filename of customized rotor_spec.yaml>
```

## Service Discovery

Once Rotor is running, and assuming your clusters and selectors are set up
appropriately, it should begin reporting your services to the Turbine Labs API.
You should see them in the Changelog in the [Houston app](https://app.turbinelabs.io/). If you are not seeing your clusters in the
changelog, it's likely one of the settings above is not correctly configured.
Take a look through them, then test again with the modified values, or reach
out to support@turbinelabs.io and we can help you get things configured.
