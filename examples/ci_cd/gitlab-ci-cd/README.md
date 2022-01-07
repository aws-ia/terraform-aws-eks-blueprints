# gitlab CI/CD example

This pattern shows the example to dpeloy the EKS Clusters using gitlab CI/CD

### Step1: Clone this repo

```
git@github.com:aws-samples/aws-eks-accelerator-for-terraform.git
```

## Step2: Create a new gitlab repo

Copy this folder(`gitlab-ci-cd`) to your new gitlab repo. Rename the folder according to your naming convention.


    cd examples/advanced/gitlab-ci-cd
    gitlab-ci-cd

## Step3: Update CI/CD settings config

 - Login to gitlab console, click on your repo and navigate to `settings/ci_cd`
 - Add the following variables before triggering the pipeline

        AWS_ACCESS_KEY_ID           e.g., access key from devops admin iam role
        AWS_SECRET_ACCESS_KEY       e.g., secret key from devops admin iam role
        AWS_REGION                  e.g., eu-west-1
        GITLAB_BASE_URL             e.g., https://gitlab.aws.dev/api/v4/
        GITLAB_TOKEN                e.g., gitlab access token  

## Step5: Commit changes to verify the pipeline


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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.66.0 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | 3.7.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.6.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.66.0 |
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | 3.7.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.6.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-eks-accelerator-for-terraform"></a> [aws-eks-accelerator-for-terraform](#module\_aws-eks-accelerator-for-terraform) | github.com/aws-samples/aws-eks-accelerator-for-terraform | n/a |
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | v3.2.0 |

## Resources

| Name | Type |
|------|------|
| [gitlab_group_cluster.aws_cluster](https://registry.terraform.io/providers/gitlabhq/gitlab/3.7.0/docs/resources/group_cluster) | resource |
| [kubernetes_cluster_role_binding.gitlab-admin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_secret.gitlab-admin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account.gitlab-admin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.my-cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.my-auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [gitlab_group.gitops-eks](https://registry.terraform.io/providers/gitlabhq/gitlab/3.7.0/docs/data-sources/group) | data source |
| [gitlab_projects.ssp-amazon-eks](https://registry.terraform.io/providers/gitlabhq/gitlab/3.7.0/docs/data-sources/projects) | data source |
| [kubernetes_secret.gitlab-admin-token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret) | data source |

## Inputs

No inputs.

## Outputs

No outputs.

<!--- END_TF_DOCS --->
