docker run  \
  -e 'ENVOY_XDS_IP=<your_ROTOR_IP>' \
  -e 'ENVOY_XDS_PORT=50000' \
  -e 'ENVOY_NODE_CLUSTER=testbed-proxy' \
  -e 'ENVOY_NODE_ZONE=testbed' \
  -p 9999:9999 \
  -p 80:80 \
  turbinelabs/envoy-simple:0.19.0
