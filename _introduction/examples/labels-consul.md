
Consul nodes are grouped based on the `tbn-cluster` tag.

```json
{
  "Datacenter": "dc1",
  "Node": "node-name",
  "Service": {
    "Service": "service-name",
    "Tags": ["tbn-cluster"],
    "Port": 8080
  }
}
```
