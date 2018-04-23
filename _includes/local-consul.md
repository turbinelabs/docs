
```console
$ docker run -d \
  -e "TBNCOLLECT_API_KEY=<your signed_token>" \
  -e "TBNCOLLECT_API_ZONE_NAME=<your zone name>" \
  -e "TBNCOLLECT_CMD=consul" \
  -e "TBNCOLLECT_CONSUL_DC=dc1" \
  -e "TBNCOLLECT_CONSUL_HOSTPORT=<your ip address>:8500" \
  turbinelabs/tbncollect:0.15.1
```
