
Kubernetes clusters are defined by labels on Pods. You will have to add two pieces of
information to have Rotor recognize it (generally as part of a Deployment, in the Pod spec):

1. A `tbn_cluster: <name>` label to name the service to which the Pod belongs.
2. An exposed port named `http`

You can update the Deployment/Pod definitions, or add these to an existing deployment with:

```yaml
metadata:
  labels:
    tbn_cluster: all-in-one-server
spec:
  containers:
  - image: your/image:1.0
    ports:
    - containerPort: 8080
      name: http
      protocol: TCP
```
