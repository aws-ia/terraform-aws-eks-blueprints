EKS AutoMode using custom nodeclass and nodepool
---

This pattern deploys an EKS AutoMode cluster and shows how to use custom nodeclass and nodepool objects.

**Main features of this pattern**

- Creates an EKS AutoMode cluster
  - Default AutoMode nodepools are disabled
- Deploys different custom nodeclass and nodepool objects, which allow fine-grained configuration of compute parameters for different use cases
- Creates node IAM role and EKS Access Entry for custom nodes
- Installs default configuration to enable EBS and ELB provisioning in AutoMode
  - EBS storage class
  - AWS LB ingress class
- Installs common EKS addons
  - Metrics-server
  - Prometheus
  - Grafana
  - Fluent-bit
  - Kubecost

**Custom Nodepool and Nodeclass**

Nodeclass and Nodepool yaml manifests are provided under folder `eks-automode-config/`

Nodeclass:

- `nodeclass-simple.yaml` - minimum (default) EBS configuration
- `nodeclass-ebs.yaml` - optimized EBS configuration for IOPS, Size, and Throughput

Nodepool:

- `nodepool-simple.yaml` - default EC2 instance type configuration. Includes instance categories "c","m", and "r", and allows AutoMode to choose the most cost efficient instance type
- `nodepool-compute-optimized.yaml` - instance family and size optimized for compute
- `nodepool-memory-optimized.yaml` - instance family and size optimized for memory
- `nodepool-graviton-memory-optimized.yaml` - graviton instance family

Terraform file `eks-automode-config.tf` applies nodeclass and nodepool objects. It also creates the node IAM role and EKS Access Entry for custom nodes, and applies default EBS storage class and AWS LB ingress class.

Deploy
---
Check file variables.tf for available configuration options such as region, version, etc.
Then, execute `install.sh` script:

```bash
./install.sh
```

Validate
---
Deploy the sample application provided in this pattern to show how different nodepools create different nodes with optimized parameters

```bash
kubectl create ns sample-app
kubectl apply -n sample-app -f sample-app.yaml
```

This application creates a retail shopping website by deploying multiple microservices. You can get more details in the [retail app github page](https://github.com/aws-containers/retail-store-sample-app)

Note that pods "catalog" and "ui" are running on different nodes than other pods.

- Catalog yaml was updated to select Compute Optimized nodes
- Ui yaml was updated to select Graviton Optimized nodes
- Other pods don't define any selector or toleration, therefore AutoMode uses the simple Nodepool to provision nodes

```bash
$ kubectl get pod -n sample-app -o wide
NAME                              READY   STATUS    RESTARTS       AGE     IP           NODE                  NOMINATED NODE   READINESS GATES
carts-75df8554fc-bfcx6            1/1     Running   2 (2m9s ago)   5m18s   10.1.0.48    i-0603e15b5e90a7522   <none>           <none>
carts-dynamodb-5948dcbf5d-5pcj9   1/1     Running   0              5m18s   10.1.0.19    i-0603e15b5e90a7522   <none>           <none>
catalog-5799dccc9d-dxbm7          1/1     Running   5 (109s ago)   5m18s   10.1.0.80    i-0bf725cda2be38a93   <none>           <none>
catalog-mysql-0                   1/1     Running   0              5m14s   10.1.0.4     i-0603e15b5e90a7522   <none>           <none>
checkout-f48668cc4-jpd95          1/1     Running   0              5m18s   10.1.0.16    i-0603e15b5e90a7522   <none>           <none>
checkout-redis-669c468b68-lvw7s   1/1     Running   0              5m18s   10.1.0.32    i-0603e15b5e90a7522   <none>           <none>
orders-695cc77456-zdc8f           1/1     Running   2 (2m8s ago)   5m18s   10.1.0.18    i-0603e15b5e90a7522   <none>           <none>
orders-postgresql-0               1/1     Running   0              5m17s   10.1.0.51    i-0603e15b5e90a7522   <none>           <none>
orders-rabbitmq-0                 1/1     Running   0              5m17s   10.1.0.46    i-0603e15b5e90a7522   <none>           <none>
ui-698c7b7d76-bwcpq               1/1     Running   0              5m18s   10.1.0.119   i-0c0d754c90f4e1627   <none>           <none>
```

Check node descriptions to see the instance type used for each node:

```bash
$ kubectl describe node | egrep 'Name:|instance-type=|nodepool='
Name:               i-0603e15b5e90a7522
                    beta.kubernetes.io/instance-type=c6a.large
                    karpenter.sh/nodepool=simple
                    node.kubernetes.io/instance-type=c6a.large
Name:               i-0bf725cda2be38a93
                    beta.kubernetes.io/instance-type=c6a.2xlarge
                    karpenter.sh/nodepool=compute-optimized
                    node.kubernetes.io/instance-type=c6a.2xlarge
Name:               i-0c0d754c90f4e1627
                    beta.kubernetes.io/instance-type=r6gd.xlarge
                    karpenter.sh/nodepool=graviton-memory-optimized
                    node.kubernetes.io/instance-type=r6gd.xlarge
```


Destroy
---
Execute `cleanup.sh` script to delete the infrastructure

```bash
./cleanup.sh
```
