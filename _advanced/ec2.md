---
layout: page
title: Install in EC2
time_to_complete: 15  minutes
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

[//]: # (Integrating Houston with Your EC2 Environment)

## Intro

This guide discusses best practices for installing Houston in your EC2
cluster. It covers deploying the various services to EC2, as well as tagging
your existing services to be discovered by Houston.

Before you start, make sure you’ve gone through the
[Quickstart](../introduction/#quickstart) for Houston, and have a working Docker
installation on EC2.

You will also need one EC2 instance running Docker, assigned to a security group
with the following inbound ports open:

 - HTTP/80 from the local VPC network (probably 10.0.0.0/8, 172.16.0.0/12, or
   192.168.0.0/16)
 - SSH/22 from the Internet (or from your bastion if you have one)
 - The ID of the instance
 - The ID of the VPC in which the instance is running

## Deploying Rotor

Note: if you’ve finished the Quickstart, all of this section is already done. If
you deployed Rotor on an EC2 instance, you can skip to
[Deploying Envoy](#deploying-envoy). If not, you may want to deploy it again on
the same machine you’re planning to deploy Envoy.

First, SSH into your EC2 instance, and run Rotor, with your environment
variables defined inside of the docker command, including the signed_token you
obtained with tbnctl as the API key:

```console
$ {% include_relative examples/ec2/rotor.sh %}
```

## Labeling your EC2 services

Rotor discovers clusters by looking for EC2 instances and grouping them based on
their instance tags and ports. Cluster membership on a port is declared with a
tag, of the form:

```
<namespace>:<cluster-name>:<port>=""
```

An EC2 instance may belong to multiple clusters, serving traffic on multiple
ports. The port must be numeric, and the cluster name cannot contain the
delimiter. The delimiter is ":" and the default namespace is `"tbn:cluster"`.

For example, to add a single instance to two clusters (`your-service-name` and
`your-other-service`, exposing ports 8080 and 8081), you could run:

```console
aws ec2 create-tags \
  --resources <your instance id> \
  --tags \
    Key=tbn:cluster:your-service-name:8080,Value= \
    Key=tbn:cluster:your-other-service:8081,Value=
```

You can specify additional tags on the Instance in the appropriate Cluster as
`<key>`=`<value>`. These tags can be used to define routing rules in Houston.

```
<namespace>:<cluster-name>:<port>:<key>=<value>
```

If key/value tags are included, the cluster membership tag is optional.

Tags without the namespaced cluster/port prefix will be added to all Instances
in all Clusters to which the EC2 Instance belongs.

By default, all EC2 Instances in the VPC are examined, but additional filters
can be specified (see `-filters`).

## Deploying Envoy

There is quite a bit of flexibility to deploying Envoy on EC2. In this section,
we’ll assume you’ll use Application Load Balancers to terminate SSL and route
traffic to Envoy, which then routes to your services.

The only configuration Envoy needs is a simple bootstrap to read from Rotor. You
can do this with
[`envoy-simple`](https://hub.docker.com/r/turbinelabs/envoy-simple/), an Envoy
Docker image from Turbine Labs that can be configured via environment variables.

Envoy does not have to run on the same machine as Rotor, as it does in this
example, but it does need to be able to pull its configuration from it over the
host and port set in `ENVOY_XDS_HOST` and `ENVOY_XDS_PORT`.

To create this deployment, use Docker to launch it from an SSH session to the
EC2 instance:

```console
$ {% include_relative examples/ec2/envoy.sh %}
```

With your instance running both Rotor and Envoy, create an Application Load
Balancer through the AWS management console to send traffic through to your
Envoy node on the appropriate ports—in this example, TCP port 80. Next, apply
the security group: ALBGroup.

Ensure that these containers started correctly by running:

```console
$ docker ps
```

```shell
CONTAINER ID        IMAGE                             COMMAND                  CREATED                  STATUS              PORTS                                                 NAMES
6561ec86fc11        turbinelabs/envoy-simple:0.15.1   "/sbin/my_init -- /u…"   Less than a second ago   Up 4 seconds        0.0.0.0:80->80/tcp, 0.0.0.0:9999->9999/tcp, 443/tcp   gracious_shannon
```

To test that all this worked, locate your ALB’s external IP, and curl it. Please
note that Envoy requires the Host header be present, so add a header for a
configured domain. This should match a domain and route you have configured in
Houston.

```console
$ curl  -h 'Host: example.com' 10.3.241.247
```

## Scaling Envoy and Rotor

Once you have Envoy deployed as a load balancer (or "front proxy") in your
cluster, you can also deploy it as part of each service ("service mesh"
architecture). The example above colocates the Envoy process with the Envoy API
server (Rotor), so the only change to make is to disable Rotors calls to the AWS
API. In this mode, Rotor will only serve the configuration it pulls from the
Houston API, resulting in fewer overall calls to the AWS API. Rotor will also
batch metrics locally every minute and return them to the Houston API, rather
than sending raw request logs over your network to Rotor.

You should still run at least one Rotor instance in "aws" mode, to make sure
Houston has an up-to-date view of your services.

To run Rotor in xDS-only mode, run:

```console
$ {% include_relative examples/ec2/rotor-xds-only.sh %}
```

## Customizing

### Custom deployment settings

The EC2 collector, by default, looks for tags in the namespace `tbn:cluster`
across all instances. You can customize the format of the tags and which
instances are collected by using environment variables, described below.

You can see which flags are available:

```console
$ docker run -e "ROTOR_CMD=aws" -e "ROTOR_HELP=true" turbinelabs/rotor:0.15.1
```

Environment variables corresponding to flags are derived from those flags by
first prefixing with the command and subcommand (in this case `ROTOR_AWS_`), and
then converting the flag name to uppercase and replacing any non-alphanumeric
characters with `_`. So for example, `--aws.access-key-id=string` becomes
`ROTOR_AWS_AWS_ACCESS_KEY_ID=string`.

#### ROTOR_AWS_AWS_ACCESS_KEY_ID=string

*REQUIRED* The AWS API access key ID

#### ROTOR_AWS_AWS_REGION=string

*REQUIRED* The AWS region in which the binary is running

#### ROTOR_AWS_AWS_SECRET_ACCESS_KEY=string

*REQUIRED* The AWS API secret access key

#### ROTOR_AWS_CLUSTER_TAG_NAMESPACE=string

(default: "tbn:cluster")
The namespace for cluster tags

#### ROTOR_AWS_FILTERS=&lt;key&gt;=&lt;value&gt;, ...

A comma-delimited list of key/value pairs, used to specify additional EC2
Instances filters. Of the form `<key>=<value>,...`. See [AWS'
documentation](http://awsdocs.s3.amazonaws.com/EC2/ec2-clt.pdf) for a discussion
of available filters.

#### ROTOR_AWS_VPC_ID=string

*REQUIRED* The ID of the VPC in which Rotor is running

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
