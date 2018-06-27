
```console
kubectl create secret generic tbnsecret --from-literal=apikey=<your signed_token>
kubectl create -f https://docs.turbinelabs.io/advanced/examples/kubernetes/rotor-rbac.yaml
kubectl create -f https://docs.turbinelabs.io/advanced/examples/kubernetes/rotor.yaml
```

See [the Kubernetes section on RBAC failures](/advanced/kubernetes.html#RBAC_Failures)
if this 2nd command fails.