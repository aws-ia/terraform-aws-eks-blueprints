
## CLuster Autoscaler 

The Kubernetes Cluster Autoscaler automatically adjusts the number of nodes in your cluster when pods fail or are rescheduled onto other nodes. It's not deployed by default in EKS clusters. That is, the AWS Cloud Provider implementation within the Kubernetes  Cluster Autoscaler controls the **DesiredReplicas** field of Amazon EC2 Auto Scaling groups.

The Cluster Autoscaler is typically installed as a **Deployment** in your cluster. It uses leader election to ensure high availability, but scaling is one done by a single replica at a time.

Cluster Autoscaler can be deployed by specifying the following line in `base.tfvars` file.

```hcl
cluster_autoscaler_enable = true
```