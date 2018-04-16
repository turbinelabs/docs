{% if include.title %}
### {{ include.title }}
{% else %}
### Testing before release
{% endif %}

Let’s test our green version before we release it to customers. tbnproxy allows
you to route to service instances based on headers set in the request. Navigate
to [app.turbinelabs.io](https://app.turbinelabs.io), log in and select the zone
you’re working with (testbed by default). Click the "Route Groups" tab
below the top-line charts, then click the pencil icon in the "all-in-one-server"
row. This will take you to the Route Group editor.

In the "Request-Specific Overrides" section, click "Add an Override". Fill in
the values as below:

<img src="/assets/rge_header_rule.png" />

This tells the proxy to look for a header called `X-Tbn-Version`. If the proxy
finds that header, it uses the value to find servers in the all-in-one-client
cluster that have a matching version label. For example, setting `X-Tbn-Version:
blue` on a request would match blue servers, and `X-Tbn-Version: green` would
match green servers.

Click "Save Changes" in the top right. Now click "More..." and then "View
Charts" to go back to the chart view.

The demo app converts a `X-Tbn-Version` query parameter into a header in calls
to the backend; if you navigate to `http://<your external IP>?X-Tbn-Version=green`
you should see all green boxes. Meanwhile going to `http://<your-client>`
without that parameter still shows blue.

This technique is extremely powerful. New software was previewed in production
without customers being affected. You were able to test the new software on the
live site before releasing to customers. In a real world scenario your testers
can perform validation, you can load test, and you can demo to stakeholders
without running through a complicated multi-environment scenario, even during
another release.
