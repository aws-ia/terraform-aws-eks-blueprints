# GitLab CI/CD example

This pattern demonstrates a GitOps approach with IaC using Gitlab CI/CD.
This shows an example of how to automate the build and deployment of an IaC code for provisioning Amazon EKS Cluster using GitLab CI/CD.
Using Gitlab for Terraform state management which allows multiple engineers to work together to develop the infrastructure
Validation checks for the code
Note : This pattern needs Gitlab version 14.5 or above

### Step 1: Clone this repo

```
git@github.com:aws-ia/terraform-aws-eks-blueprints.git
```

## Step 2: Create a new git repo in your GitLab group and copy files from examples/advanced/gitlab-ci-cd folder to the root of your new GitLab repo

    cd examples/ci-cd/gitlab-ci-cd
    cp . $YOUR_GITLAB_REPO_ROOT

## Step 3: Update project settings-> CI/CD ->Variables

- Login to the GitLab console, Open your repo and navigate to `settings->ci-cd->Variables`
- Update the following variables as Key Value pairs before triggering the pipeline

       AWS_ACCESS_KEY_ID           e.g., access key from devops admin iam role
       AWS_SECRET_ACCESS_KEY       e.g., secret key from devops admin iam role
       AWS_REGION                  e.g., eu-west-1

## Step 4: Update variables in input.tfvars file

1.  Update cluster_version to any version > "1.20"
2.  Update CIDR of your VPC, vpc_cidcr = "10.2.0.0/16"

## Step 5: Commit changes and push to verify the pipeline

Manually trigger the `tf-apply` to provision the resources

## Step 6: Verify whether the state file update happened in your project (Infrastructure->Terraform-states)

## Step 7: (Optional) Manually Install, Configure and Run GitLab Agent for Kubernetes (“Agent”, for short) is your active in-cluster.

This is for or connecting Kubernetes clusters to GitLab. Refer https://docs.gitlab.com/ee/user/clusters/agent/install/index.html

## Step 8: Cleanup the deployed resources

Manually trigger the `tf-destroy` stage in the GitLab Ci/CD pipeline to destroy your deployment.

## Troubleshooting:

- ### 400 Error when creating resource

  - If the error contains `{message: {environment_scope: [cannot add duplicated environment scope]}}`, it is likely that an existing Kubernetes integration with the same environment scope was not removed. Remove any Kubernetes clusters with the same environment scope from the GitLab group before redeploying.

- ### What's gitlab-terraform?

  - `gitlab-terraform` is a thin wrapper around the `terraform` binary. as part of the [GitLab Terraform docker image](https://gitlab.com/gitlab-org/terraform-images) used in `.gitlab-ci.yml`.

- ### In case your tf-apply stage is failed in between
  - Correct the source code ,commit and push the code or ensure you manually trigger tf-destroy stage and cleanup the provisioned resources

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | 3.7.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_blueprints"></a> [eks\_blueprints](#module\_eks\_blueprints) | ../../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
