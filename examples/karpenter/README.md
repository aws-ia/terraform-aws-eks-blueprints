# EKS Cluster with Karpenter Cluster Autoscaler

Karpenter is an open-source node provisioning project built for Kubernetes. Karpenter automatically launches just the right compute resources to handle your cluster's applications. It is designed to let you take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters.

This example shows how to deploy and leverage Karpenter for Autoscaling. The following resources will be deployed by this example.

- Creates a new VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with one Managed node group with Max ASG of 1
- Deploys Karpenter Helm Chart
- Deploys default Karpenter Provisioner (with dedicated node labels ant taint)
- Deploys default-lt Karpenter Provisioner using Launch Template (with dedicated node labels ant taint)

# How to Deploy

## Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deployment Steps

#### Step 1: Clone the repo using the command below

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step 2: Run Terraform INIT

to initialize a working directory with configuration files

```sh
cd examples/karpenter/
terraform init
```

#### Step 3: Run Terraform PLAN

to verify the resources created by this execution

```sh
export AWS_REGION=<ENTER-YOUR-REGION>   # Select your own region
terraform plan
```

#### Step 4: Finally, Terraform APPLY

**Deploy the pattern**

```sh
terraform apply
```

Enter `yes` to apply.

### Configure kubectl and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 5: Run update-kubeconfig command.

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region <Enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 6: List all the worker nodes by running the command below

You should see one managed node up and running

    $ kubectl get nodes

#### Step 7: List all the pods running in karpenter namespace

    $ kubectl get pods -n karpenter

    # Output should look like below
      NAME                                    READY   STATUS    RESTARTS   AGE
      karpenter-68f999967f-m4t4n  1/1     Running   0          31m

#### Step 8: List all karpenter provisioners deployed

    $  kubectl get provisioners

    # Output should look like below
    NAME         AGE
    default      88s
    default-lt   90s

#### Step 8: Deploy workload on Karpenter provisioners

Terraform has configured 2 provisioners : `default` and `default-lt` and we have 2 deployment examples, to be deployed using thoses provisioners.

Deploy workload on `default` provisioner:

    $ kubectl apply -f provisioners/sample_deployment.yaml


Deploy workload on `default-lt` provisioner:

    $ kubectl apply -f provisioners/sample_deployment_lt.yaml

After few times you should see 2 new nodes (one created by each provisioner)

    $ kubectl get node -L karpenter.sh/provisioner-name

    # Output should look like below
    NAME                                        STATUS   ROLES    AGE     VERSION               PROVISIONER-NAME
    ip-10-0-10-14.us-west-2.compute.internal    Ready    <none>   11m     v1.22.9-eks-810597c   default
    ip-10-0-11-16.us-west-2.compute.internal    Ready    <none>   70m     v1.22.9-eks-810597c  
    ip-10-0-12-138.us-west-2.compute.internal   Ready    <none>   4m57s   v1.22.9-eks-810597c   default-lt

We now have :
- 1 Managed node group instance
- 1 instance from the default provisioner
- 1 instance from the default-lt provisioner

# How to Destroy

NOTE: Make sure you delete all the deployments which clean up the nodes spun up by Karpenter Autoscaler
Ensure no nodes are running created by Karpenter before running the `Terraform Destroy`. Otherwise, EKS Cluster will be cleaned up however this may leave some nodes running in EC2.


To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```
