
```console
kubectl create secret generic tbnsecret --from-literal=apikey=<your signed_token>
kubectl create -f https://docs.turbinelabs.io/advanced/examples/kubernetes/rotor-rbac.yaml
kubectl create -f https://docs.turbinelabs.io/advanced/examples/kubernetes/rotor.yaml
```
