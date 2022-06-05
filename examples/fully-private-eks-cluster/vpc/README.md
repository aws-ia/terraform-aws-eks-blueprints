## How to deploy the example

This example deploys the following :
 - Creates a new VPC with 3 Private Subnets and 3 Public Subnets
 - VPC Endpoints for various services and S3 VPC Endpoint gateway


### Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply
1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps
#### Step1: Clone the repo using the command below

```shell script
git clone git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step2: Review and update the base.tfvars
Review base.tfvars and update the values for the variable "default_vpc_ipv4_cidr". 
```shell script
default_vpc_ipv4_cidr = "172.31.0.0/16"
```

#### Step3: Run Terraform INIT
Initialize a working directory with configuration files


```shell script
cd examples/fully-private-eks-cluster/vpc
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

 
## How to Destroy
The following command destroys the resources created by `terraform apply`

```shell script
cd examples/fully-private-eks-cluster/vpc
terraform destroy -var-file base.tfvars -auto-approve  
```    

## Manual activity

1. Create a VPC Peer between the default VPC and the EKS VPC.

   Reference : https://docs.aws.amazon.com/vpc/latest/peering/create-vpc-peering-connection.html
2. Configure the Route tables for both the VPCs to route traffic from the default VPC to the EKS VPC.

   Reference : https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-routing.html


