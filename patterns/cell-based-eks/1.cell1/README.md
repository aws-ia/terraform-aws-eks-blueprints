# Cell-Based Architecture for Amazon EKS

This example shows how to provision a cell based Amazon EKS cluster.

* Deploy EKS Cluster with one managed node group in a VPC and AZ
* Deploy Fargate profiles to run `coredns`, `aws-load-balancer-controller`, and `karpenter` addons
* Deploy Karpenter `Provisioner` and `AWSNodeTemplate` resources and configure them to run in AZ1
* Deploy sample deployment `inflate` with 0 replicas

Refer to the [AWS Solution Guidance](https://aws.amazon.com/solutions/guidance/cell-based-architecture-for-amazon-eks/) for more details.

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
4. [helm](https://helm.sh/docs/helm/helm_install/)

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
NODE_NAME                                          READY   INSTANCE-TYPE   AZ           VERSION               OS-IMAGE         INTERNAL-IP
fargate-ip-10-0-13-93.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-14-95.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-15-86.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-8-178.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-8-254.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-8-73.us-west-2.compute.internal    True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
ip-10-0-12-14.us-west-2.compute.internal           True    m5.large        us-west-2a   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.12.14
ip-10-0-14-197.us-west-2.compute.internal          True    m5.large        us-west-2a   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.14.197
```

3. List out the pods running currently:

```sh
kubectl get pods,svc -n kube-system
```

```
# Output should look like below
NAME                                                READY   STATUS    RESTARTS   AGE
pod/aws-load-balancer-controller-776868b4fb-2j9t6   1/1     Running   0          13h
pod/aws-load-balancer-controller-776868b4fb-bzkrr   1/1     Running   0          13h
pod/aws-node-2zhpc                                  2/2     Running   0          16h
pod/aws-node-w897r                                  2/2     Running   0          16h
pod/coredns-5c9679c87-bp6ws                         1/1     Running   0          16h
pod/coredns-5c9679c87-lw468                         1/1     Running   0          16h
pod/kube-proxy-6wp2k                                1/1     Running   0          16h
pod/kube-proxy-n8qtq                                1/1     Running   0          16h

NAME                                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
service/aws-load-balancer-webhook-service   ClusterIP   172.20.44.77   <none>        443/TCP         14h
service/kube-dns                            ClusterIP   172.20.0.10    <none>        53/UDP,53/TCP   17h
```

4. Verify all the helm releases installed:

```sh
helm list -A
```

```
# Output should look like below
NAME                        	NAMESPACE  	REVISION	UPDATED                             	STATUS  	CHART                             	APP VERSION
aws-load-balancer-controller	kube-system	2       	2023-10-18 23:07:36.089372 -0400 EDT	deployed	aws-load-balancer-controller-1.6.1	v2.6.1
karpenter                   	karpenter  	14      	2023-10-19 08:25:12.313094 -0400 EDT	deployed	karpenter-v0.30.0                 	0.30.0
```

## Test

1. Verify both Fargate nodes and EKS Managed Nodegroup worker nodes are deployed to single AZ

```sh
kubectl get node -o custom-columns='NODE_NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,AZ:.metadata.labels.topology\.kubernetes\.io/zone,VERSION:.status.nodeInfo.kubeletVersion,OS-IMAGE:.status.nodeInfo.osImage,INTERNAL-IP:.metadata.annotations.alpha\.kubernetes\.io/provided-node-ip'
```

```
NODE_NAME                                          READY   INSTANCE-TYPE   AZ           VERSION               OS-IMAGE         INTERNAL-IP
fargate-ip-10-0-13-93.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-14-95.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-15-86.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-8-178.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-8-254.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-8-73.us-west-2.compute.internal    True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
ip-10-0-12-14.us-west-2.compute.internal           True    m5.large        us-west-2a   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.12.14
ip-10-0-14-197.us-west-2.compute.internal          True    m5.large        us-west-2a   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.14.197
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
pod/inflate-75d744d4c6-5r5cv condition met
pod/inflate-75d744d4c6-775wm condition met
pod/inflate-75d744d4c6-7t225 condition met
pod/inflate-75d744d4c6-945p4 condition met
pod/inflate-75d744d4c6-b52gp condition met
pod/inflate-75d744d4c6-d99fn condition met
pod/inflate-75d744d4c6-dmnwm condition met
pod/inflate-75d744d4c6-hrvvr condition met
pod/inflate-75d744d4c6-j4hkl condition met
pod/inflate-75d744d4c6-jwknj condition met
pod/inflate-75d744d4c6-ldwts condition met
pod/inflate-75d744d4c6-lqnr5 condition met
pod/inflate-75d744d4c6-pctjh condition met
pod/inflate-75d744d4c6-qdlkc condition met
pod/inflate-75d744d4c6-qnzc5 condition met
pod/inflate-75d744d4c6-r2cwj condition met
pod/inflate-75d744d4c6-srmkb condition met
pod/inflate-75d744d4c6-wf45j condition met
pod/inflate-75d744d4c6-x9mwl condition met
pod/inflate-75d744d4c6-xlbhl condition met
```

4. Check all the nodes are in the correct AZ

```sh
kubectl get node -o custom-columns='NODE_NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,AZ:.metadata.labels.topology\.kubernetes\.io/zone,VERSION:.status.nodeInfo.kubeletVersion,OS-IMAGE:.status.nodeInfo.osImage,INTERNAL-IP:.metadata.annotations.alpha\.kubernetes\.io/provided-node-ip'
```
```
NODE_NAME                                          READY   INSTANCE-TYPE   AZ           VERSION               OS-IMAGE         INTERNAL-IP
fargate-ip-10-0-13-93.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-14-95.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-15-86.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-8-178.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-8-254.us-west-2.compute.internal   True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
fargate-ip-10-0-8-73.us-west-2.compute.internal    True    <none>          us-west-2a   v1.28.2-eks-f8587cb   Amazon Linux 2   <none>
ip-10-0-12-14.us-west-2.compute.internal           True    m5.large        us-west-2a   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.12.14
ip-10-0-14-197.us-west-2.compute.internal          True    m5.large        us-west-2a   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.14.197
ip-10-0-3-161.us-west-2.compute.internal           True    c6gn.8xlarge    us-west-2a   v1.28.1-eks-43840fb   Amazon Linux 2   10.0.3.161
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -auto-approve
```
