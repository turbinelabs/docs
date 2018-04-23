
```console
$ docker run -d \
  -e "TBNCOLLECT_API_KEY=<your signed_token>"
  -e "TBNCOLLECT_API_ZONE_NAME=<your zone name>" \
  -e "TBNCOLLECT_AWS_AWS_ACCESS_KEY_ID=<your aws access key>" \
  -e "TBNCOLLECT_AWS_AWS_REGION=<your aws region>" \
  -e "TBNCOLLECT_AWS_AWS_SECRET_ACCESS_KEY=<your secret access key>" \
  -e "TBNCOLLECT_AWS_VPC_ID=<your vpc id>" \
  -e "TBNCOLLECT_CMD=aws" \
  turbinelabs/tbncollect:latest
```
