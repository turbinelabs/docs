
```console
$ docker run -d \
  -e 'ROTOR_API_KEY=<your signed_token>' \
  -e 'ROTOR_API_ZONE_NAME=testbed' \
  -e 'ROTOR_AWS_AWS_ACCESS_KEY_ID=<your aws access key>' \
  -e 'ROTOR_AWS_AWS_REGION=<your aws region>' \
  -e 'ROTOR_AWS_AWS_SECRET_ACCESS_KEY=<your secret access key>' \
  -e 'ROTOR_AWS_VPC_ID=<your vpc id>' \
  -e 'ROTOR_CMD=aws' \
  -p 50000:50000 \
  turbinelabs/rotor:0.16.0
```
