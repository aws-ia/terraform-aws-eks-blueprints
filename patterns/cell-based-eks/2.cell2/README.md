# Cell-Based Architecture for Amazon EKS

This example shows how to provision a cell based Amazon EKS cluster.

* Deploy EKS Cluster with one managed node group in a VPC and AZ
* Deploy Fargate profiles to run `coredns`, `aws-load-balancer-controller`, and `karpenter` addons
* Deploy Karpenter `Provisioner` and `AWSNodeTemplate` resources and configure them to run in AZ2
* Deploy sample deployment `inflate` with 0 replicas

Refer to the [AWS Solution Guidance](https://aws.amazon.com/solutions/guidance/cell-based-architecture-for-amazon-eks/) for more details.

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the deployment.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. List the nodes running currently

```sh
kubectl get node -o custom-columns='NODE_NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,AZ:.metadata.labels.topology\.kubernetes\.io/zone,VERSION:.status.nodeInfo.kubeletVersion,OS-IMAGE:.status.nodeInfo.osImage,INTERNAL-IP:.metadata.annotations.alpha\.kubernetes\.io/provided-node-ip'
```

```
# Output should look like below
NODE_NAME                                           READY   INSTANCE-TYPE   AZ           VERSION               OS-IMAGE         INTERNAL-IP
fargate-ip-10-0-22-6.us-west-2.compute.internal     True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-23-139.us-west-2.compute.internal   True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-23-59.us-west-2.compute.internal    True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-24-236.us-west-2.compute.internal   True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-25-116.us-west-2.compute.internal   True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-31-31.us-west-2.compute.internal    True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
ip-10-0-30-113.us-west-2.compute.internal           True    m5.large        us-west-2b   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.30.113
ip-10-0-31-158.us-west-2.compute.internal           True    m5.large        us-west-2b   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.31.158
```

3. List out the pods running currently:

```sh
kubectl get pods,svc -n kube-system
```

```
# Output should look like below
NAME                                               READY   STATUS    RESTARTS   AGE
pod/aws-load-balancer-controller-8758bf745-grj9s   1/1     Running   0          3h42m
pod/aws-load-balancer-controller-8758bf745-j5m5j   1/1     Running   0          3h42m
pod/aws-node-crst2                                 2/2     Running   0          3h42m
pod/aws-node-dbs2f                                 2/2     Running   0          3h42m
pod/coredns-5c9679c87-fsxtt                        1/1     Running   0          3h42m
pod/coredns-5c9679c87-fttcc                        1/1     Running   0          3h42m
pod/kube-proxy-lrsd9                               1/1     Running   0          3h42m
pod/kube-proxy-rc49k                               1/1     Running   0          3h42m

NAME                                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
service/aws-load-balancer-webhook-service   ClusterIP   172.20.134.154   <none>        443/TCP         3h42m
service/kube-dns                            ClusterIP   172.20.0.10      <none>        53/UDP,53/TCP   3h52m
```

4. Verify all the helm releases installed:

```sh
helm list -A
```

```
# Output should look like below
NAME                        	NAMESPACE  	REVISION	UPDATED                             	STATUS  	CHART                             	APP VERSION
aws-load-balancer-controller	kube-system	1       	2023-10-19 09:01:45.053426 -0400 EDT	deployed	aws-load-balancer-controller-1.6.1	v2.6.1
karpenter                   	karpenter  	4       	2023-10-19 09:56:07.225133 -0400 EDT	deployed	karpenter-v0.30.0                 	0.30.0
```

## Test

1. Verify both Fargate nodes and EKS Managed Nodegroup worker nodes are deployed to single AZ

```sh
kubectl get node -o custom-columns='NODE_NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,AZ:.metadata.labels.topology\.kubernetes\.io/zone,VERSION:.status.nodeInfo.kubeletVersion,OS-IMAGE:.status.nodeInfo.osImage,INTERNAL-IP:.metadata.annotations.alpha\.kubernetes\.io/provided-node-ip'
```

```
NODE_NAME                                           READY   INSTANCE-TYPE   AZ           VERSION               OS-IMAGE         INTERNAL-IP
fargate-ip-10-0-22-6.us-west-2.compute.internal     True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-23-139.us-west-2.compute.internal   True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-23-59.us-west-2.compute.internal    True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-24-236.us-west-2.compute.internal   True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-25-116.us-west-2.compute.internal   True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-31-31.us-west-2.compute.internal    True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
ip-10-0-30-113.us-west-2.compute.internal           True    m5.large        us-west-2b   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.30.113
ip-10-0-31-158.us-west-2.compute.internal           True    m5.large        us-west-2b   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.31.158
```

2. Scale the `inflate` deployment to 20 replicas and watch for Karpenter to launch EKS worker nodes in correct AZ.

```sh
kubectl scale deployment inflate --replicas 20
```

```
deployment.apps/inflate scaled
```

3. Wait for the pods become ready

```sh
kubectl wait --for=condition=ready pods --all --timeout 2m
```

```
pod/inflate-75d744d4c6-26nfh condition met
pod/inflate-75d744d4c6-4hfxf condition met
pod/inflate-75d744d4c6-4tvzr condition met
pod/inflate-75d744d4c6-5jkdp condition met
pod/inflate-75d744d4c6-5lpkg condition met
pod/inflate-75d744d4c6-6kv28 condition met
pod/inflate-75d744d4c6-7k5k5 condition met
pod/inflate-75d744d4c6-b7mm4 condition met
pod/inflate-75d744d4c6-kq9z7 condition met
pod/inflate-75d744d4c6-kslkq condition met
pod/inflate-75d744d4c6-mfps6 condition met
pod/inflate-75d744d4c6-s6h2j condition met
pod/inflate-75d744d4c6-s9db9 condition met
pod/inflate-75d744d4c6-sbmlz condition met
pod/inflate-75d744d4c6-slqhw condition met
pod/inflate-75d744d4c6-t9z27 condition met
pod/inflate-75d744d4c6-tqrjd condition met
pod/inflate-75d744d4c6-w9w8b condition met
pod/inflate-75d744d4c6-wk2jb condition met
pod/inflate-75d744d4c6-z54wg condition met
```

4. Check all the nodes are in the correct AZ

```sh
kubectl get node -o custom-columns='NODE_NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,AZ:.metadata.labels.topology\.kubernetes\.io/zone,VERSION:.status.nodeInfo.kubeletVersion,OS-IMAGE:.status.nodeInfo.osImage,INTERNAL-IP:.metadata.annotations.alpha\.kubernetes\.io/provided-node-ip'
```
```
NODE_NAME                                           READY   INSTANCE-TYPE   AZ           VERSION               OS-IMAGE         INTERNAL-IP
fargate-ip-10-0-22-6.us-west-2.compute.internal     True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-23-139.us-west-2.compute.internal   True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-23-59.us-west-2.compute.internal    True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-24-236.us-west-2.compute.internal   True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-25-116.us-west-2.compute.internal   True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-31-31.us-west-2.compute.internal    True    <none>          us-west-2b   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
ip-10-0-27-134.us-west-2.compute.internal           True    c6g.8xlarge     us-west-2b   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.27.134
ip-10-0-30-113.us-west-2.compute.internal           True    m5.large        us-west-2b   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.30.113
ip-10-0-31-158.us-west-2.compute.internal           True    m5.large        us-west-2b   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.31.158
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -auto-approve
```
