
EC2 instances are collected based on tags with the service name and port it
exposes. The format is`tbn:cluster:<cluster-name>:<port-name>`:

```console
aws ec2 create-tags \
  --resources <your instance id> \
  --tags \
    Key=tbn:cluster:your-service-name:8080,Value=
```
