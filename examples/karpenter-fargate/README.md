# EKS Cluster with Karpenter running on Fargate

Karpenter is an open-source node provisioning project built for Kubernetes. Karpenter automatically launches just the right compute resources to handle your cluster's applications. It is designed to let you take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters.

This example shows how to deploy and leverage Karpenter for Autoscaling and automatic nodes updating. Karpenter and other Add-ons are deployed on Fargate to avoid using any node groups. The following resources will be deployed by this example.

- VPC, 3 Private Subnets and 3 Public Subnets.
- Internet gateway for Public Subnets and NAT Gateway for Private Subnets.
- AWS EKS Cluster (control plane).
- AWS EKS Fargate Profiles for the `kube-system` namespace with Pod Labels used by the `coredns`, `karpenter`, and `aws-load-balancer-controller` addons, while additional profiles can be added as needed.
- AWS EKS managed addons `vpc-cni` and `kube-proxy`.
- Karpenter Helm Chart.
- AWS SQS Queue to enable interruption handling to gracefully cordon and drain your spot nodes when they are interrupted. Pods that require checkpointing or other forms of graceful draining, requiring the 2-mins before shutdown, will need this.
- A default Karpenter Provisioner that uses the Bottlerocket AMI and refreshes nodes every 24 hours.
- Self-managed CoreDNS addon deployed through a Helm chart. The default CoreDNS deployment provided by AWS EKS is removed and replaced with a self-managed CoreDNS deployment, while the `kube-dns` service is updated to allow Helm to assume control.
- AWS Load Balancer Controller add-on deployed through a Helm chart. The default AWS Load Balancer Controller add-on configuration is overridden so that it can be deployed on Fargate compute.
- The [game-2048](examples/karpenter-fargate/provisioners/sample_deployment.yaml) application is provided to demonstrates how Karpenter scales nodes based on workload constraints like nodeSelector, topologySpreadConstraints, and podAntiAffinity.

⚠️ The management of CoreDNS as demonstrated in this example is intended to be used on new clusters. Existing clusters with existing workloads will see downtime if the CoreDNS deployment is modified as shown here.

## How to Deploy

### Prerequisites

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step 1: Clone the repo using the command below

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step 2: Run Terraform INIT

To initialize a working directory with configuration files

```sh
cd examples/karpenter-fargate/
terraform init
```

#### Step 3: Run Terraform PLAN for the SQS Queue

To verify the resources created by this execution

```sh
terraform plan -target aws_sqs_queue.karpenter_interruption_queue
```

#### Step 4: Run Terraform APPLY for the SQS Queue

```shell
terraform apply -target aws_sqs_queue.karpenter_interruption_queue
```

Enter `yes` to apply.

#### Step 5: Run Terraform PLAN for everything

To verify the resources created by this execution

```sh
terraform plan
```

#### Step 6: Finally, Terraform APPLY for everything

```shell
terraform apply
```

Enter `yes` to apply.

### Configure kubectl and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 5: Run update-kubeconfig command.

`~/.kube/config` file gets updated with cluster details and certificate from the below command

```shell
aws eks --region us-west-2 update-kubeconfig --name karpenter-fargate
```

#### Step 6: List all the worker nodes by running the command below

You should see a multiple fargate nodes and one node provisioned by Karpenter up and running

```shell
kubectl get nodes

# Output should look like below
NAME                                                STATUS   ROLES    AGE    VERSION
fargate-ip-10-0-10-59.us-west-2.compute.internal    Ready    <none>   106s   v1.23.12-eks-1558457
fargate-ip-10-0-12-102.us-west-2.compute.internal   Ready    <none>   114s   v1.23.12-eks-1558457
fargate-ip-10-0-12-138.us-west-2.compute.internal   Ready    <none>   2m5s   v1.23.12-eks-1558457
fargate-ip-10-0-12-148.us-west-2.compute.internal   Ready    <none>   53s    v1.23.12-eks-1558457
fargate-ip-10-0-12-187.us-west-2.compute.internal   Ready    <none>   109s   v1.23.12-eks-1558457
fargate-ip-10-0-12-188.us-west-2.compute.internal   Ready    <none>   15s    v1.23.12-eks-1558457
fargate-ip-10-0-12-54.us-west-2.compute.internal    Ready    <none>   113s   v1.23.12-eks-1558457
```

#### Step 7: List all the pods running in karpenter namespace

```shell
kubectl get pods -n karpenter

# Output should look like below
NAME                        READY   STATUS    RESTARTS   AGE
karpenter-cc495bbd6-kclbd   2/2     Running   0          1m
karpenter-cc495bbd6-x6t5m   2/2     Running   0          1m

# Get the sqs queue arn from the karpenter configmap
kubectl get configmap karpenter-global-settings \
  -o=jsonpath="{.data.aws\.interruptionQueueName}" \
  -n karpenter
```

#### Step 8: List the karpenter provisioner deployed

```shell
kubectl get provisioners

# Output should look like below
NAME      AGE
default   1m
```

#### Step 9: Deploy workload on Karpenter provisioners

Terraform has configured 1 `default` provisioner and we have 1 deployment example to be deployed using this provisioner.

Deploy sample workload on `default` provisioner:

```shell
kubectl apply -f provisioners/sample_deployment.yaml
```

> **Warning**
> Because of known limitations with topology spread, the pods might not evenly spread through availability zones.
> https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/#known-limitations

You can run this command to view the Karpenter Controller logs while the nodes are provisioned.

```shell
kubectl logs --selector app.kubernetes.io/name=karpenter -n karpenter
```

After a couple of minutes, you should see new nodes being added by Karpenter to accommodate the game-2048 application EC2 instance family, capacity type, availability zones placement, and pod anti-affinity requirements.

```shell
kubectl get node \
  --selector=type=karpenter \
  -L karpenter.sh/provisioner-name \
  -L topology.kubernetes.io/zone \
  -L karpenter.sh/capacity-type \
  -L karpenter.k8s.aws/instance-family

# Output should look like below
NAME                                        STATUS   ROLES    AGE     VERSION                PROVISIONER-NAME   ZONE         CAPACITY-TYPE   INSTANCE-FAMILY
ip-10-0-10-47.us-west-2.compute.internal    Ready    <none>   73s     v1.23.13-eks-6022eca   default            us-west-2a   spot            c5d
ip-10-0-11-132.us-west-2.compute.internal   Ready    <none>   72s     v1.23.13-eks-6022eca   default            us-west-2b   spot            c5
ip-10-0-11-161.us-west-2.compute.internal   Ready    <none>   72s     v1.23.13-eks-6022eca   default            us-west-2b   spot            c6id
ip-10-0-11-163.us-west-2.compute.internal   Ready    <none>   72s     v1.23.13-eks-6022eca   default            us-west-2b   spot            c6in
ip-10-0-12-12.us-west-2.compute.internal    Ready    <none>   73s     v1.23.13-eks-6022eca   default            us-west-2c   spot            c5d
```

Test by listing the game-2048 pods. You should see that all the pods are running on different nodes because of the pod anti-affinity rule.

```shell
kubectl get pods -o wide

# Output should look like below
NAME                               READY   STATUS    RESTARTS   AGE     IP            NODE                                        NOMINATED NODE   READINESS GATES
deployment-2048-758d5bfc75-gm97g   1/1     Running   0          2m16s   10.0.11.221   ip-10-0-11-161.us-west-2.compute.internal   <none>           <none>
deployment-2048-758d5bfc75-p9k4m   1/1     Running   0          2m16s   10.0.11.32    ip-10-0-11-132.us-west-2.compute.internal   <none>           <none>
deployment-2048-758d5bfc75-r48vx   1/1     Running   0          2m16s   10.0.12.144   ip-10-0-12-12.us-west-2.compute.internal    <none>           <none>
deployment-2048-758d5bfc75-vjxg6   1/1     Running   0          2m16s   10.0.11.11    ip-10-0-11-163.us-west-2.compute.internal   <none>           <none>
deployment-2048-758d5bfc75-vkpfc   1/1     Running   0          2m16s   10.0.10.111   ip-10-0-10-47.us-west-2.compute.internal    <none>           <none>
```

Test that the sample application is now available.

```shell
kubectl get ingress/ingress-2048

# Output should look like this
NAME           CLASS   HOSTS   ADDRESS                                                                  PORTS   AGE
ingress-2048   alb     *       k8s-default-ingress2-97b28f4dd2-1471347110.us-west-2.elb.amazonaws.com   80      2m53s
```

Open the browser to access the application via the ALB address http://k8s-default-ingress2-97b28f4dd2-1471347110.us-west-2.elb.amazonaws.com/

⚠️ You might need to wait a few minutes, and then refresh your browser.

We now have :

- 7 Fargate instances
- 5 instances from the default Karpenter provisioner

## How to Destroy

NOTE: Make sure you delete all the deployments which clean up the nodes spun up by Karpenter Autoscaler
Ensure no nodes are running created by Karpenter before running the `Terraform Destroy`. Otherwise, EKS Cluster will be cleaned up however this may leave some nodes running in EC2.

To clean up your environment, delete the sample workload and then destroy the Terraform modules in reverse order.

Delete the sample workload on `default` provisioner:

```shell
kubectl delete -f provisioners/sample_deployment.yaml
```

Destroy the Karpenter Provisioner and IAM Role, Kubernetes Add-ons, EKS cluster with Node groups and VPC

```shell
terraform destroy -target="kubectl_manifest.karpenter_provisioner" -auto-approve
# Wait for 1-2 minutes to allow Karpenter to delete the empty nodes
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -target="aws_iam_role.karpenter" -auto-approve
terraform destroy -target="aws_sqs_queue.karpenter_interruption_queue" -auto-approve
```
