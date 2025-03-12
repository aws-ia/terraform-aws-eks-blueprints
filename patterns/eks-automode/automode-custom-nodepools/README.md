
EKS AutoMode using custom nodeclass and nodepool
---

This pattern deploys an EKS AutoMode cluster and shows how to use custom nodeclass and nodepool objects.

**Main features of this pattern**
- Creates EKS AutoMode cluster
	- Default nodepools are disabled
- Deploys different custom nodeclass and nodepool objects, which allows fine-grained configuration of compute parameters for different use cases
- Creates node IAM role and EKS Access Entry for custom nodes
- Installs default configuration to enable EBS and ELB provisioning
	- EBS storage class
	- AWS LB ingress class
- Installs common EKS addons:
	- metrics-server
	- Prometheus
	- Grafana
	- Fluent-bit

**Custom Nodepool and Nodeclass**

Nodeclass and Nodepool yaml manifests are provided under folder `eks-automode-config/`

Nodeclass:
- "nodeclass-simple.yaml" - minimum (default) EBS configuration
- "nodeclass-ebs.yaml" - optimized EBS configuration for IOPS, Size, and Throughput

Nodepool
- "nodepool-simple.yaml" - default EC2 instance type configuration. Includes instance categories "c","m", and "r", and allows AutoMode to choose the right and most cost efficient instance type
- "nodepool-compute-optimized.yaml" - instance family and size optimized for compute
- "nodepool-memory-optimized.yaml" - instance family and size optimized for memory
- "nodepool-graviton-memory-optimized.yaml" - graviton instance types

Terraform file `eks-automode-config.tf` applies nodeclass and nodepool objects. It also creates the node IAM role and EKS Access Entry for custom nodes and applies default EBS storage class and AWS LB ingress class.

Deploy
---
Check file variables.tf for available configuration options such as region, version, etc.
Then, execute install.sh script
```
./install.sh
```

Validate
---
Deploy the a sample application to show how different nodepools create nodes with optimized parameters
```
kubectl apply -f sample-app.yaml
```
This application creates a  shopping website by deploying multiple microservices. You can get more details in the app documentation - https://github.com/aws-containers/retail-store-sample-app

Note that pods "catalog" and "ui" are running on different nodes than other pods.
- Catalog yaml was updated to select Compute Optimized nodes
- Ui yaml was updated to select Graviton Optimized nodes
- Other pods don't define any selector or toleration, therefore AutoMode uses the simple Nodepool to provision nodes
```
$ kubectl get pod -n default -o wide
NAME                              READY   STATUS              RESTARTS      AGE   IP          NODE                  NOMINATED NODE   READINESS GATES
carts-75df8554fc-6bsvg            1/1     Running             1 (34m ago)   35m   10.1.0.34   i-0d522bf16edfa1169   <none>           <none>
carts-dynamodb-5948dcbf5d-x99n6   1/1     Running             0             35m   10.1.0.41   i-0d522bf16edfa1169   <none>           <none>
catalog-5799dccc9d-rdq9d          0/1     ContainerCreating   0             5s    <none>      i-056ace536886a0ca0   <none>           <none>
catalog-mysql-0                   1/1     Running             0             35m   10.1.0.40   i-0d522bf16edfa1169   <none>           <none>
checkout-f48668cc4-pvrxk          1/1     Running             0             35m   10.1.0.29   i-0d522bf16edfa1169   <none>           <none>
checkout-redis-669c468b68-s9kb7   1/1     Running             0             35m   10.1.0.42   i-0d522bf16edfa1169   <none>           <none>
orders-695cc77456-mmrt6           1/1     Running             2 (34m ago)   35m   10.1.0.11   i-0d522bf16edfa1169   <none>           <none>
orders-postgresql-0               1/1     Running             0             35m   10.1.0.53   i-0d522bf16edfa1169   <none>           <none>
orders-rabbitmq-0                 1/1     Running             0             35m   10.1.0.52   i-0d522bf16edfa1169   <none>           <none>
ui-698c7b7d76-gnzdn               1/1     Running             0             35m   10.1.0.9    i-07862b2b9de1a0ec0   <none>           <none>
```

See below the different instance types used by worker nodes:
```
$ kubectl describe node | egrep 'Name:|instance-type=|nodepool='
Name:               i-056ace536886a0ca0
                    beta.kubernetes.io/instance-type=c6a.2xlarge
                    karpenter.sh/nodepool=compute-optimized
                    node.kubernetes.io/instance-type=c6a.2xlarge
Name:               i-07862b2b9de1a0ec0
                    beta.kubernetes.io/instance-type=r6gd.xlarge
                    karpenter.sh/nodepool=graviton-memory-optimized
                    node.kubernetes.io/instance-type=r6gd.xlarge
Name:               i-0d522bf16edfa1169
                    beta.kubernetes.io/instance-type=c6a.large
                    karpenter.sh/nodepool=simple
                    node.kubernetes.io/instance-type=c6a.large
```


Destroy
---
Delete the sample app.
```
kubectl delete -f sample-app.yaml
```

Execute script ./cleanup to delete the infrastructure
```
./cleanup.sh
```

