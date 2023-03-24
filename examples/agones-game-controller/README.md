# Amazon EKS Deployment with Agones Gaming Kubernetes Controller

This example shows how to deploy and run Gaming applications on Amazon EKS with Agones Kubernetes Controller

- Deploy Private VPC, Subnets and all the required VPC endpoints
- Deploy EKS Cluster with one managed node group in an VPC
- Deploy Agones Kubernetes Controller using Helm Providers
- Deploy a simple gaming server and test the application

# What is Agones

Agones is an Open source Kubernetes Controller with custom resource definitions and is used to create, run, manage and scale dedicated game server processes within Kubernetes clusters using standard Kubernetes tooling and APIs.
This model also allows any matchmaker to interact directly with Agones via the Kubernetes API to provision a dedicated game server

# What is GameLift

Amazon GameLift enables developers to deploy, operate, and scale dedicated, low-cost servers in the cloud for session-based, multiplayer games.
Built on AWS global computing infrastructure, GameLift helps deliver high-performance, high-reliability, low-cost game servers while dynamically scaling your resource usage to meet worldwide player demand.

## How to Deploy

### Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step 1: Clone the repo using the command below

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step 2: Run Terraform INIT

Initialize a working directory with configuration files

```sh
cd examples/game-tech/agones-game-controller
terraform init
```

#### Step 3: Run Terraform PLAN

Verify the resources created by this execution

```sh
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 4: Finally, Terraform APPLY

**Deploy the pattern**

```sh
terraform apply
```

Enter `yes` to apply.

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step 7: List all the pods running in `agones-system` namespace

    $ kubectl get pods -n agones-system

## Step 8: Install K9s

This step is to install K9s client tool to interact with EKS Cluster

     curl -sS https://webinstall.dev/k9s | bash

Just type k9s after the installation and then you will see the output like this

         k9s

![Alt Text](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/9c6f8ea3e710f7b0137be07835653a2bf4f9fdfe/images/k9s-agones-cluster.png "K9s")

## Step 9: Add EKS Workshop IAM role as EKS Cluster Administrator

    $ aws sts get-caller-identity

    ROLE="    - rolearn: arn:aws:iam::${ACCOUNT_ID}:role/TeamRole\n      username: admin\n      groups:\n        - system:masters"

    kubectl get -n kube-system configmap/aws-auth -o yaml | awk "/mapRoles: \|/{print;print \"$ROLE\";next}1" > /tmp/aws-auth-patch.yml

    kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yml)"

## Step 10: Deploying the Sample game server

    kubectl create -f https://raw.githubusercontent.com/googleforgames/agones/release-1.15.0/examples/simple-game-server/gameserver.yaml

    kubectl get gs

Output looks like below

    NAME                       STATE   ADDRESS         PORT   NODE                                        AGE
    simple-game-server-7r6jr   Ready   34.243.345.22   7902   ip-10-1-23-233.eu-west-1.compute.internal   11h

## Step 11: Testing the Sample Game Server

    sudo yum install netcat

    nc -u <ADDRESS> <PORT>

    e.g.,  nc -u 34.243.345.22 7902

Output looks like below

    TeamRole:~/environment/eks-blueprints (main) $ echo -n "UDP test - Hello Workshop" | nc -u 34.243.345.22 7902
    Hello Workshop
    ACK: Hello Workshop
    EXIT
    ACK: EXIT

# Deploy GameLift FleetIQ

Amazon GameLift FleetIQ optimizes the use of low-cost Spot Instances for cloud-based game hosting with Amazon EC2. With GameLift FleetIQ, you can work directly with your hosting resources in Amazon EC2 and Auto Scaling while taking advantage of GameLift optimizations to deliver inexpensive, resilient game hosting for your players and makes the use of low-cost Spot Instances viable for game hosting

This [blog](https://aws.amazon.com/blogs/gametech/introducing-the-gamelift-fleetiq-adapter-for-agones/) will go through the details of deploying EKS Cluster using eksctl and deploy Agones with GameLift FleetIQ

Download the sh and execute

    curl -O https://raw.githubusercontent.com/awslabs/fleetiq-adapter-for-agones/master/Agones_EKS_FleetIQ_Integration_Package%5BBETA%5D/quick_install/fleet_eks_agones_quickinstall.sh

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```
