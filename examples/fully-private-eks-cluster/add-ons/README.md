## How to deploy the example

This example deploys the following :
 - Install ArgoCD as the GitOps tool
 - Deploys some add-ons using ArgoCD
 - Deploys a sample application using ArgoCD
 

### Prerequisites:
We will deploy the add-ons from the bastion host/Jenkins server that is running on the default VPC.
Ensure that you have installed the following tools in the bastion host/Jenkins server before start working with this module and run Terraform Plan and Apply
1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps
#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step2: Review and update the base.tfvars
Review base.tfvars and update the values for the variable "eks_cluster_id". 
```shell script
eks_cluster_id = "aws001-preprod-test-eks"
```

#### Step3: Review and updatethe backend.conf

Review backend.conf and update the values for the S3 bucket.

```shell script
bucket = "<Update the bucket name here>"
```
#### Step4: Run Terraform INIT
Initialize a working directory with configuration files

```shell script
cd examples/fully-private-eks-cluster/add-ons
terraform init -backend-config backend.conf
```

#### Step5: Run Terraform PLAN
Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan -var-file base.tfvars
```

#### Step6: Terraform APPLY
to create resources

```shell script
terraform apply -var-file base.tfvars
```

Enter `yes` to apply

## Verify the add-ons are deployed.
Pre-requisite : kubectl installed on the bastion host/Jenkins Server.

    $ kubectl get pods -A

You can see a list of all the add-ons running as pods on the EKS cluster. This also includes argocd runnings in its own namespace.
 

## How to Destroy
The following command destroys the resources created by `terraform apply`

```shell script
cd examples/fully-private-eks-cluster/vpc
terraform destroy -var-file base.tfvars -auto-approve  
``` 


<!--- BEGIN_TF_DOCS --->
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: MIT-0

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks-cluster-with-import-vpc"></a> [eks-cluster-with-import-vpc](#module\_eks-cluster-with-import-vpc) | ../../../examples/eks-cluster-with-import-vpc/eks | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes Version | `string` | `"1.21"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | n/a | yes |
| <a name="input_tf_state_vpc_s3_bucket"></a> [tf\_state\_vpc\_s3\_bucket](#input\_tf\_state\_vpc\_s3\_bucket) | Terraform state S3 Bucket Name | `string` | n/a | yes |
| <a name="input_tf_state_vpc_s3_key"></a> [tf\_state\_vpc\_s3\_key](#input\_tf\_state\_vpc\_s3\_key) | Terraform state S3 Key path | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | n/a | yes |

## Outputs

No outputs.

<!--- END_TF_DOCS --->
