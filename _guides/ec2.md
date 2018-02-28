---
layout: page
title: EC2 Guide
time_to_complete: 10 minutes
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

[//]: # (Integrating Houston with Docker on EC2)

{%
  include guides/prerequisites.md
  platform="Docker on EC2"
  quick_start_name="Docker Basics"
  quick_start_url="http://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html"
  install_extra="
### The AWS command line interface (CLI)
You'll need access to the
[AWS command-line interface](http://docs.aws.amazon.com/cli/latest/userguide/installing.html).
  "
%}

##  Installing on EC2

You will need:

- One EC2 micro instance running Docker on the Linux of your choice.
- A security group assigned to the instance, with the following inbound ports
  open:
  - HTTP/80 from the local VPC network (probably 10.0.0.0/8, 172.16.0.0/12, or
    192.168.0.0/16)
  - SSH/22 from the Internet (or from your bastion if you have one)
- The ID of the instance
- The ID of the VPC in which the instance is running

## Setting up service discovery

SSH into your EC2 instance, and run tbncollect, with your environment variables
defined inside of the docker command, including the `signed_token` you obtained
with `tbnctl` as the API key:

```console
$ docker run -d \
  -e "TBNCOLLECT_API_KEY=<your signed_token>"
  -e "TBNCOLLECT_API_ZONE_NAME=<your zone name>" \
  -e "TBNCOLLECT_AWS_AWS_ACCESS_KEY_ID=<your aws access key>" \
  -e "TBNCOLLECT_AWS_AWS_REGION=<your aws region>" \
  -e "TBNCOLLECT_AWS_AWS_SECRET_ACCESS_KEY=<your secret access key>" \
  -e "TBNCOLLECT_AWS_VPC_ID=<your vpc id>" \
  -e "TBNCOLLECT_CMD=aws" \
  turbinelabs/tbncollect:0.15.0
```

## The all-in-one demo

Now you will install the all-in-one client and server on different ports of the
same instance; the tags are used to let the collector know which app is running
on which port, and with what metadata.

### Running the all-in-one-client

First, run the all-in-one-client on port 8080, in the SSH session to the EC2
instance:

```console
$ docker run -p 8080:8080 -d turbinelabs/all-in-one-client:0.15.0
```

Once all-in-one-client is running, add the cluster tag using the aws command-
line tool or the ECS Console, taking care to replace `<your instance id>` with
the ID of your EC2 instance:

```console
$ aws ec2 create-tags \
  --resources <your instance id> \
  --tags Key=tbn:cluster:all-in-one-client:8080,Value=
```

### Running the all-in-one-server

Now run the all-in-one-server on port 8081, in the SSH session to the EC2
instance:

```console
$ docker run -d \
  -p 8081:8080 \
  -e "TBN_COLOR=1B9AE4" \
  -e "TBN_NAME=blue" \
  turbinelabs/all-in-one-server:0.15.0
```

Once the all-in-one-server is running, add the version tag using the aws
command-line tool or the ECS Console, taking care to replace
`<your instance id>` with the ID of your EC2 instance (Note that since the
version tag includes the cluster name and port, you do not need to declare it
with a separate tag):

```console
$ aws ec2 create-tags \
  --resources <your instance id> \
  --tags \
    Key=tbn:cluster:all-in-one-server:8081:version,Value=blue \
    Key=tbn:cluster:all-in-one-server:8081:stage,Value=prod
```

{% include guides/adding_a_domain.md %}

## Deploying tbnproxy

Now we're ready to deploy tbnproxy on the same instance as the collector with
ports forwarded appropriate to your service or site. In the SSH session to the
EC2 instance, type:

```console
$ docker run -d \
  -p 80:80 \
  -e "TBNPROXY_API_KEY=<your signed_token" \
  -e "TBNPROXY_API_ZONE_NAME=<your zone name>" \
  -e "TBNPROXY_PROXY_NAME=<your proxy name>" \
  turbinelabs/tbnproxy:0.15.0
```

### Mapping an ELB to expose tbnproxy

With your instance running both tbncollect and tbnproxy, create an Elastic Load
Balancer through the AWS management console to send traffic through to your
tbncollect and tbnproxy node on the appropriate ports—in this example, TCP
port 80. Next, apply the security group: ELBGroup.

{% include guides/configure_routes.md %}

## Verifying your deploy

With your ELB running, locate its external IP, and visit it in your browser.
You should be able to see blue boxes in a grid, blinking in and out, as they
represent responses from the blue version of the all-in-one-server we launched
previously.

{%
  include guides/demo_exercises_whats_going_on.md
  platform="EC2"
%}

{% include guides/deployed_state.md %}

{% include guides/setup_initial_route.md %}

## Deploying a new version

Now we'll deploy a new version of the server that returns green as the color to
paint blocks. SSH into the instance that is running your current all-in-one-
client, then run a new Docker container with this command, in the SSH session to
the EC2 instance:

```console
$ docker run -d \
  -p 8082:8080 \
  -e "TBN_COLOR=83D061" \
  -e "TBN_NAME=green" \
  turbinelabs/all-in-one-server:0.15.0
```

Once the instance is running, add the version tag using the aws
command-line tool or the ECS Console, taking care to replace
`<your instance id>` with the ID of your EC2 instance:

```console
$ aws ec2 create-tags \
  --resources <your instance id> \
  --tags \
    Key=tbn:cluster:all-in-one-server:8082:version,Value=green \
    Key=tbn:cluster:all-in-one-server:8082:stage,Value=prod
```

Note that your EC2 instance is now running multiple versions of the same service, on separate ports.

{% include guides/your_environment.md %}

{% include guides/testing_before_release.md %}

{% include guides/incremental_release.md %}

{% include guides/testing_latency_and_error_rates.md %}

### Driving synthetic traffic

If you'd like to drive steady traffic to your all-in-one server without keeping
a browser window open, you can run the all-in-one-driver image on the same
instance as the collector and proxy. If you are running tbnproxy on a port other
than 80, you'll need to specify it using the `ALL_IN_ONE_DRIVER_HOST`
environment variable. You can also add error rates and latencies for various
using environment variables:

```console
$ docker run -d \
  -e "ALL_IN_ONE_DRIVER_LATENCIES=blue:50ms,green:20ms" \
  -e "ALL_IN_ONE_DRIVER_ERROR_RATES=blue:0.01,green:0.005" \
  turbinelabs/all-in-one-driver:0.10.1
```

{% include guides/conclusion.md
   platform="EC2"
%}
