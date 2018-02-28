---
layout: page
title: Advanced Routing
time_to_complete: 5 minutes
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

[//]: # (Advanced Routing)

This guide walks you through using aadvanced request routing to the
all-in-one-demo application. Review the [Quickstart](../reference/quickstart.html) before
getting started. This guide starts after the incremental release
example, in order to show what other release routing capabilities are possible
with tbnproxy deployed. The all-in-one-demo client and server should now be
running in your enviroment.

{%
  include guides/testing_before_release.md
  title="Browser overrides"
%}

{% include guides/testing_latency_and_error_rates.md %}

### Driving synthetic traffic

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
  turbinelabs/all-in-one:0.15.0
```

## Conclusion

These examples show some of the many ways the Envoy-based tbnproxy can help
your team release, observe, and iterate your software. If you still have
questions, or have a proxy idea that you want to implement, [let us know](mailto:support@turbinelabs.io)!
