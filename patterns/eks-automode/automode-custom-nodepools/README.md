EKS Auto Mode with custom NodePool and NodeClass
---

This pattern deploys an EKS Auto Mode cluster with custom NodeClass and NodePool objects. 

By default, EKS Auto Mode has two built-in NodePools to cover general compute needs. However, users often need to further customize the compute options available for different types of workloads, and segregate specific workloads onto special types of EC2 compute options (ex: amd64, arm64, GPU, etc).

This pattern provides an easy way to create EKS Auto Mode clusters with custom NodePools.

**Main features of this pattern**

- Creates an EKS Auto Mode cluster
  - Default Auto Mode NodePools are disabled
- Deploys different custom NodeClass and NodePool objects, which allow fine-grained configuration of compute parameters for different use cases
  - amd64
  - arm64
  - gpu
- Creates node IAM role and EKS Access Entry for custom NodePools
- Installs default configuration to enable EBS and ELB provisioning in Auto Mode
  - EBS storage class
  - AWS LB ingress class

**Custom NodePool and NodeClass**

NodeClass and NodePool yaml manifests are provided under folder `eks-automode-config/`

NodeClass:

- `nodeclass-basic.yaml` - minimum (default) EBS configuration
- `nodeclass-ebs-optimized.yaml` - optimized EBS configuration for IOPS, Size, and Throughput

NodePool:

- `nodepool-graviton.yaml` - instance families "c","r","m" using Graviton processors (arm64 architecture).
- `nodepool-amd64.yaml` - instance families "c","r","m" using amd64 architecture.

Terraform file `eks-automode-config.tf` applies NodeClass and NodePool objects. It also creates the node IAM role and EKS Access Entry for custom nodes, and applies default EBS storage class and AWS LB ingress class.

To add new Node Pools and Node Classes, just add theis yaml files to the folder and update file `eks-automode-config.tf` with the added yaml file names.

Deploy
---
Check file variables.tf for available configuration options such as region, version, etc.
Then, apply terraform files:

```bash
terraform apply
```

Validate
---
Deploy the sample application provided in this pattern to use custom NodePools to provision nodes in the cluster.

```bash
kubectl create ns sample-app
kubectl apply -n sample-app -f sample-app.yaml
```

This application creates StatefulSet pods using `amd64` Node Pool, and provisions EBS volumes and ALB as part of the deployment.

Note that Node Pools use label `NodeGroupType: amd64` and Taint `key: amd64`. The pod yaml definition includes relevant values for nodeSelector and Tolerations, to select the desired Node Pool that will provision nodes to run the pod.

```bash
$ kubectl get nodes,pods,pvc,ingress -n sample-app 
NAME                       STATUS   ROLES    AGE   VERSION
node/i-08347a1b1ae4f01c4   Ready    <none>   13m   v1.31.4-eks-0f56d01

NAME          READY   STATUS    RESTARTS   AGE
pod/httpd-0   1/1     Running   0          13m
pod/httpd-1   1/1     Running   0          12m

NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/httpd-logs-httpd-0   Bound    pvc-8eec1429-850a-4b7c-bc78-cd399d583091   10Gi       RWO            auto-ebs-sc    <unset>                 18m
persistentvolumeclaim/httpd-logs-httpd-1   Bound    pvc-d86f1913-49fd-4a3f-b7a5-01da69e3ac20   10Gi       RWO            auto-ebs-sc    <unset>                 12m

NAME                                      CLASS   HOSTS   ADDRESS                                                                  PORTS   AGE
ingress.networking.k8s.io/httpd-ingress   alb     *       k8s-sampleap-httpding-58bda13bc0-763023517.us-east-1.elb.amazonaws.com   80      13m
```

Destroy
---
First, remove the sample app and/or any other application that you deployed ot the cluster:

```bash
kubectl delete -n sample-app -f sample-app.yaml
```

Then, destroy the infrastructure created with terraform:

```bash
terraform destroy
```
