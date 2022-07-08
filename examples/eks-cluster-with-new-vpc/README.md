# EKS Cluster Deployment with new VPC

This example deploys the following Basic EKS Cluster with VPC

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with one managed node group

## How to Deploy

### Prerequisites

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Minimum IAM Policy

> **Note**: The policy resource is set as `*` to allow all resources, this is not a recommended practice.

```yaml
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:GetCallerIdentity",
                "s3:ListBucket",
                "s3:GetObject",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAvailabilityZones",
                "ec2:AllocateAddress",
                "ec2:CreateVpc",
                "ec2:CreateTags",
                "ec2:DescribeAddresses",
                "ec2:DescribeVpcs",
                "ec2:ModifyVpcAttribute",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcClassicLink",
                "ec2:DescribeVpcClassicLinkDnsSupport",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:CreateInternetGateway",
                "ec2:CreateRouteTable",
                "ec2:CreateSubnet",
                "ec2:AttachInternetGateway",
                "ec2:DeleteNetworkAclEntry",
                "ec2:DescribeSubnets",
                "ec2:DescribeInternetGateways",
                "ec2:ModifySubnetAttribute",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:CreateNetworkAclEntry",
                "ec2:CreateRoute",
                "ec2:AssociateRouteTable",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:CreateNatGateway",
                "ec2:DescribeNatGateways",
                "iam:GetRole",
                "kms:CreateKey",
                "iam:CreateRole",
                "ec2:CreateSecurityGroup",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:AttachRolePolicy",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "kms:EnableKeyRotation",
                "kms:GetKeyRotationStatus",
                "kms:GetKeyPolicy",
                "kms:ListResourceTags",
                "kms:DescribeKey",
                "kms:CreateAlias",
                "eks:CreateCluster",
                "iam:PassRole",
                "kms:ListAliases",
                "eks:DescribeCluster",
                "iam:CreateOpenIDConnectProvider",
                "iam:GetOpenIDConnectProvider",
                "ec2:DescribeTags",
                "iam:CreateInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:TagInstanceProfile",
                "eks:CreateNodegroup",
                "eks:DescribeNodegroup",
                "eks:DescribeAddonVersions",
                "eks:CreateAddon",
                "iam:CreatePolicy",
                "eks:DescribeAddon",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "eks:DeleteAddon",
                "iam:DetachRolePolicy",
                "iam:ListInstanceProfilesForRole",
                "iam:DeleteRole",
                "iam:ListPolicyVersions",
                "iam:DeletePolicy",
                "kms:DeleteAlias",
                "iam:DeleteOpenIDConnectProvider",
                "eks:DeleteNodegroup",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile",
                "eks:DeleteCluster",
                "kms:ScheduleKeyDeletion",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteRoute",
                "ec2:DisassociateRouteTable",
                "ec2:DeleteNatGateway",
                "ec2:DeleteSubnet",
                "ec2:DeleteRouteTable",
                "ec2:DetachInternetGateway",
                "ec2:ReleaseAddress",
                "ec2:DeleteInternetGateway",
                "ec2:DeleteVpc"
            ],
            "Resource": "*"
        }
    ]
}
```

### Deployment Steps

#### Step 1: Clone the repo using the command below

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step 2: Run Terraform INIT

Initialize a working directory with configuration files

```sh
cd examples/eks-cluster-with-new-vpc/
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

    aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 6: List all the worker nodes by running the command below

    kubectl get nodes

#### Step 7: List all the pods running in `kube-system` namespace

    kubectl get pods -n kube-system

## Cleanup

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
