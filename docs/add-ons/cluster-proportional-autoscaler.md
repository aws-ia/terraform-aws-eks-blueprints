# Horizontal cluster-proportional-autoscaler container

Horizontal cluster-proportional-autoscaler watches over the number of schedulable nodes and cores of the cluster and resizes the number of replicas for the required resource. This functionality may be desirable for applications that need to be autoscaled with the size of the cluster, such as CoreDNS and other services that scale with the number of nodes/pods in the cluster.

The [cluster-proportional-autoscaler](https://github.com/kubernetes-sigs/cluster-proportional-autoscaler) helps to scale the applications using deployment or replicationcontroller or replicaset. This is an alternative solution to Horizontal Pod Autoscaling.
It is typically installed as a **Deployment** in your cluster.

## Usage

This add-on requires both `enable_coredns_autoscaler` and `coredns_autoscaler_helm_config` as mandatory fields.

[cluster-proportional-autoscaler](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/cluster-proportional-autoscaler) can be deployed by enabling the add-on via the following.

The example shows how to enable `cluster-proportional-autoscaler` for `CoreDNS Deployment`. CoreDNS deployment is not configured with HPA. So, this add-on helps to scale CoreDNS Add-on according to the size of the nodes and cores.

This Add-on can be used to scale any application with Deployment objects.

```hcl
enable_coredns_autoscaler = true
coredns_autoscaler_helm_config = {
  name        = "cluster-proportional-autoscaler"
  chart       = "cluster-proportional-autoscaler"
  repository  = "https://kubernetes-sigs.github.io/cluster-proportional-autoscaler"
  version     = "1.0.0"
  namespace   = "kube-system"
  timeout     = "300"
  values = [
    <<-EOT
    nameOverride: kube-dns-autoscaler

     # Formula for controlling the replicas. Adjust according to your needs
     #  replicas = max( ceil( cores * 1/coresPerReplica ) , ceil( nodes * 1/nodesPerReplica ) )
    config:
      linear:
      coresPerReplica: 256
      nodesPerReplica: 16
      min: 1
      max: 100
      preventSinglePointFailure: true
      includeUnschedulableNodes: true

    # Target to scale. In format: deployment/*, replicationcontroller/* or replicaset/* (not case sensitive).
    options:
      target: deployment/coredns # Notice the target as `deployment/coredns`

    serviceAccount:
      create: true
      name: kube-dns-autoscaler

    podSecurityContext:
      seccompProfile:
      type: RuntimeDefault
      supplementalGroups: [ 65534 ]
      fsGroup: 65534

    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 100m
        memory: 128Mi

    tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"
        description = "Cluster Proportional Autoscaler for CoreDNS Service"
    EOT
  ]
}
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
corednsAutoscaler = {
  enable = true
}
```
