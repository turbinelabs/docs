---
layout: page
title: Advanced Routing
time_to_complete: 5 minutes
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

[//]: # (Advanced Routing)

This guide walks you through using aadvanced request routing to the
all-in-one-demo application. Review the [Quickstart](../reference/quickstart.html) before
getting started. This guide starts after the incremental release
example, in order to show what other release routing capabilities are possible
with tbnproxy deployed. The all-in-one-demo client and server should now be
running in your enviroment.

## Browser overrides

Let’s test our yellow dev version before we release it to customers. tbnproxy
allows you to route to service instances based on headers set in the request.
Navigate to [app.turbinelabs.io](https://app.turbinelabs.io), log in and select
the zone you’re working with (all-in-one-demo by default). Click "Settings" ->
"Edit Routes", and select all-in-one-demo:80/api from the top left dropdown. You
should see the following screen

<img src="../assets/all-in-one_edit_route.png"/>

Click “Add Rule” from the top right, and enter the following values:

IF `Header: X-Tbn-Version & version` Send `1 to all-in-one-server`.

<img src="../assets/all-in-one_add_rule.png"/>

This tells the proxy to look for a header called `X-Tbn-Version`. If the proxy
finds that header, it uses the value to find servers in the all-in-one-server
cluster that have a matching version tag. For example, setting `X-Tbn-Version:
blue` on a request would match blue production servers, and `X-Tbn-Version:
yellow` would match yellow dev servers.

The all-in-one client converts a `X-Tbn-Version` query parameter into a header
in calls to the backend; if you navigate to
[localhost?X-Tbn-Version=yellow](http://localhost?X-Tbn-Version=yellow) you
should see all yellow boxes. Meanwhile going to [localhost](http://localhost)
without that parameter still shows blue or green based on the release state of
previous steps in this guide.

<img src="https://d16co4vs2i1241.cloudfront.net/uploads/tutorial_image/file/619233248442058713/9e580867275ee1a7fd6b502c8b5c8e6fbc24ea8ec31759ac5b2326ea7fdc264c/column_sized_Screen_Shot_2016-10-28_at_10.43.02_AM.png" height="50%" width="50%"/>

This technique is extremely powerful. New software was tested in
production without customers being affected. You were able to test the new
software on the live site before releasing to customers. In a real world
scenario your testers can perform validation, you can load test, and you can
demo to stakeholders without running through a complicated multi-environment
scenario, even during another release.

{% include guides/testing_latency_and_error_rates.md %}

## Driving synthetic traffic

If you'd like to drive steady traffic to your all-in-one server without keeping
a browser window open, you can add `ALL_IN_ONE_DRIVER=1` to the environment
variables in your `docker run` invocation. You can also add error rates and
latencies for various using environment variables:

```console
$ docker run -p 80:80 \
  -e "TBNPROXY_API_KEY=<signed_token>" \
  -e "TBNPROXY_API_ZONE_NAME=all-in-one-demo" \
  -e "TBNPROXY_PROXY_NAME=all-in-one-demo-proxy" \
  -e "ALL_IN_ONE_DRIVER=1" \
  -e "ALL_IN_ONE_DRIVER_LATENCIES=blue:50ms,green:20ms" \
  -e "ALL_IN_ONE_DRIVER_ERROR_RATES=blue:0.01,green:0.005" \
  turbinelabs/all-in-one:0.13.0
```

## Conclusion

These examples show some of the many ways the Envoy-based tbnproxy can help
your team release, observe, and iterate your software. If you still have
questions, or have a proxy idea that you want to implement, [let us know](mailto:support@turbinelabs.io)!
