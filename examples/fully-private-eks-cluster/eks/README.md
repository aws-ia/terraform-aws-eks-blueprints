## How to deploy the example

This example deploys the following :
 - A private EKS cluster.


Please see this [document](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html) for more details on configuring fully private EKS Clusters


### Prerequisites:
We will deploy the EKS cluster from the bastion host/Jenkins server that is running on the default VPC. In the "vpc stack" we manually configured VPC peering between the default subnet and the new subnet provisioned for eks and we also updated the route tables manually. This will ensure the bastion host/Jenkins server can interact with the new vpc that was provisioned for EKS.

1. Ensure that you have installed the following tools in the bastion host/Jenkins server before start working with this module and run Terraform Plan and Apply
  1.1 [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
  1.2 [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
  1.3 [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. [Important] Ensure that the default VPC is connected to the EKS VPC using VPC Peering and the Route tables are updated to allow network traffic from the bastion-host/EC2 instance running in the default VPC to the EKS VPC. This is required to ensure that we can provision a private EKS cluster.

### Deployment Steps
#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step2: Review and update the base.tfvars
Review base.tfvars and update the values for the variable "cluster_security_group_additional_rules". This rule configures ingress traffic from the bastion host/Jenkins server to the EKS cluster.
Here is an example that creates an ingress rule to allow traffic from the the cidr block "172.31.0.0/16" to the EKS cluster.

```shell script
cluster_security_group_additional_rules = {
    ingress_from_jenkins_host = {
      description                = "Ingress from Jenkins/Bastion Host"
      protocol                   = "-1"
      from_port                  = 0
      to_port                    = 0
      type                       = "ingress"
      cidr_blocks                = ["172.31.0.0/16"]
    }
  }
```
#### Step3: Run Terraform INIT
Initialize a working directory with configuration files

```shell script
cd examples/fully-private-eks-cluster/eks
terraform init 
```

#### Step4: Run Terraform PLAN
Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan -var-file base.tfvars
```

#### Step5: Terraform APPLY
to create resources

```shell script
terraform apply -var-file base.tfvars
```
Enter `yes` to apply

### Configure `kubectl` and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step6: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step7: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step8: List all the pods running in `kube-system` namespace

    $ kubectl get pods -n kube-system

 

## How to Destroy
The following command destroys the resources created by `terraform apply`

```shell script
cd examples/fully-private-eks-cluster/vpc
terraform destroy -var-file base.tfvars -auto-approve  
``` 

