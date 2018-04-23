
```console
$ docker run -d \
  -e "TBNCOLLECT_API_KEY=<your signed_token>" \
  -e "TBNCOLLECT_API_ZONE_NAME=<your zone name>" \
  -e "TBNCOLLECT_CMD=kubernetes" \
  turbinelabs/tbncollect:0.15.1
```
