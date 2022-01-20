# GitLab CI/CD example
This pattern shows an example of how to deploy an Amazon EKS Cluster using GitLab CI/CD.

### Step 1: Clone this repo

```
git@github.com:aws-samples/aws-eks-accelerator-for-terraform.git
```

## Step 2: Create a new Gitlab repo
Copy the files in the folder(`gitlab-ci-cd`) into the root of your new GitLab repo.

    cd examples/advanced/gitlab-ci-cd
    cp . $YOUR_GITLAB_REPO_ROOT

## Step 3: Update CI/CD settings config
 - Login to the GitLab console, click on your repo and navigate to `settings/ci_cd`
 - Add the following variables before triggering the pipeline

        AWS_ACCESS_KEY_ID           e.g., access key from devops admin iam role
        AWS_SECRET_ACCESS_KEY       e.g., secret key from devops admin iam role
        AWS_REGION                  e.g., eu-west-1
        GITLAB_BASE_URL             e.g., https://gitlab.example.com/api/v4/
        GITLAB_TOKEN                e.g., GitLab access token 

## Step 4: Commit changes to verify the pipeline

Start the `tf-destroy` step in the GitLab Ci/CD pipeline to destroy your deployment.

## Troubleshooting:

- ### 403 Error when creating resource gitlab_group_cluster.aws_cluster

    - Make sure the GitLab group that you're referencing in `data.gitlab_group.gitops-eks` exists and that you have access to it.

- ### 400 Error when creating resource

    - If the error contains `{message: {environment_scope: [cannot add duplicated environment scope]}}`, it is likely that an existing Kubernetes integration with the same environment scope was not removed. Remove any Kubernetes clusters with the same environment scope from the GitLab group before redeploying.

- ### What's gitlab-terraform?

    - `gitlab-terraform` is a thin wrapper around the `terraform` binary as part of the [GitLab Terraform docker image](registry.gitlab.com/gitlab-org/terraform-images/stable:latest) used in `.gitlab-ci.yml`

<!--- BEGIN_TF_DOCS --->
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
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [gitlab_group.gitops-eks](https://registry.terraform.io/providers/gitlabhq/gitlab/3.7.0/docs/data-sources/group) | data source |
| [kubernetes_secret.gitlab-admin-token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret) | data source |

## Inputs

No inputs.

## Outputs

No outputs.

<!--- END_TF_DOCS --->
