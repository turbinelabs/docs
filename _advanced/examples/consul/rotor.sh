docker run -d \
  -e "ROTOR_API_KEY=<your signed_token>" \
  -e "ROTOR_API_ZONE_NAME=<your zone name>" \
  -e "ROTOR_CMD=consul" \
  -e "ROTOR_CONSUL_DC=dc1" \
  -e "ROTOR_CONSUL_HOSTPORT=<consul ip address>:8500" \
  turbinelabs/rotor:0.16.0-rc1
