docker run -d \
  -e "ROTOR_API_KEY=<your signed_token>" \
  -e "ROTOR_API_ZONE_NAME=<your zone name>" \
  -e "ROTOR_CMD=xds-only" \
  turbinelabs/rotor:0.15.1
