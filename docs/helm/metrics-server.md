## Metrics Server

The Kubernetes Metrics Server is used to gather metrics such as cluster CPU and memory usage over time, is not deployed by default in EKS clusters.

[Metrics Server](helm/metrics_server/README.md) can be deployed by specifying the following line in `base.tfvars` file.

```
metrics_server_enable = true
```