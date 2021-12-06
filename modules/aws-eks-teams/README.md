# Teams

## Introduction

The `ssp-amazon-eks` framework provides support for onboarding and managing teams and easily configuring cluster access. We currently support two "`Team`" types: `application_teams` and `platform_teams`.  
`Application Teams` represent teams managing workloads running in cluster namespaces and `Platform Teams` represents platform administrators who have admin access (masters group) to clusters.

### ApplicationTeam

To create an `application_team` for your cluster, you will need to supply a team name, with the options to pass map of labels, map of resource quotas, existing IAM entities (user/roles), and a directory where you may optionally place any policy definitions and generic manifests for the team.  
These manifests will be applied by the platform and will be outside of the team control  

**NOTE:** When the manifests are applied, namespaces are not checked. Therefore, you are responsible for namespace settings in the yaml files.  
> As of today (2020-05-01), resource `kubernetes_manifest` can only be used (`terraform plan/apply...`) only after the cluster has been created and the cluster API can be accessed. Read ["Before you use this resource"](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest#before-you-use-this-resource) section for more information.  
To overcome this limitation, you can add/enable `manifests_dir` after you applied and created the cluster first. We are working on a better solution for this.

#### Application Team Example

```hcl
  # EKS Application Teams

  application_teams = {
    # First Team
    team-blue = {
      "labels" = {
        "appName"     = "example",
        "projectName" = "example",
        "environment" = "example",
        "domain"      = "example",
        "uuid"        = "example",
      }
      "quota" = {
        "requests.cpu"    = "1000m",
        "requests.memory" = "4Gi",
        "limits.cpu"      = "2000m",
        "limits.memory"   = "8Gi",
        "pods"            = "10",
        "secrets"         = "10",
        "services"        = "10"
      }
      manifests_dir = "./manifests"
      # Belows are examples of IAM users and roles
      users = [
        "arn:aws:iam::123456789012:user/blue-team-user",
        "arn:aws:iam::123456789012:role/blue-team-sso-iam-role"
      ]
    }

    # Second Team
    team-red = {
      "labels" = {
        "appName"     = "example2",
        "projectName" = "example2",
      }
      "quota" = {
        "requests.cpu"    = "2000m",
        "requests.memory" = "8Gi",
        "limits.cpu"      = "4000m",
        "limits.memory"   = "16Gi",
        "pods"            = "20",
        "secrets"         = "20",
        "services"        = "20"
      }
      manifests_dir = "./manifests2"
      users = [

        "arn:aws:iam::123456789012:role/other-sso-iam-role"
      ]
    }
  }
```

The `application_teams` will do the following for every provided team:

- Create a namespace
- Register quotas
- Register IAM users for cross-account access
- Create a shared role for cluster access. Alternatively, an existing role can be supplied.
- Register provided users/role in the `awsAuth` map for `kubectl` and console access to the cluster and namespace.
- (Optionally) read all additional manifests (e.g., network policies, OPA policies, others) stored in a provided directory, and applies them.

### PlatformTeam

To create an `Platform Team` for your cluster, simply use `platform_teams`. You will need to supply a team name and and all users/roles.

#### Platform Team Example

```hcl
  platform_teams = {
    admin-team-name-example = {
      users = [
        "arn:aws:iam::123456789012:user/admin-user",
        "arn:aws:iam::123456789012:role/org-admin-role"
      ]
    }
  }
```

`Platform Team` does the following:

- Registers IAM users for admin access to the cluster (`kubectl` and console)
- Registers an existing role (or create a new role) for cluster access with trust relationship with the provided/created role

## Cluster Access (`kubectl`)

The output will contain the IAM roles for every application(`application_teams_iam_role_arn`) or platform team(`platform_teams_iam_role_arn`).

To update your kubeconfig, you can run the following command:

```
aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION} --role-arn ${TEAM_ROLE_ARN}
```

Make sure to replace the `${CLUSTER_NAME}`, `${AWS_REGION}` and `${TEAM_ROLE_ARN}` with the actual values.

<!--- BEGIN_TF_DOCS --->

## Requirements

No requirements.

## Providers

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                      | n/a     |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                              | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.platform_team_eks_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                 | resource    |
| [aws_iam_role.platform_team](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                | resource    |
| [aws_iam_role.team_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                  | resource    |
| [aws_iam_role.team_sa_irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                 | resource    |
| [kubernetes_cluster_role.team](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role)                   | resource    |
| [kubernetes_cluster_role_binding.team](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding)   | resource    |
| [kubernetes_manifest.team](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest)                           | resource    |
| [kubernetes_namespace.team](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace)                         | resource    |
| [kubernetes_resource_quota.team_compute_quota](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota) | resource    |
| [kubernetes_resource_quota.team_object_quota](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota)  | resource    |
| [kubernetes_role.team](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role)                                   | resource    |
| [kubernetes_role_binding.team](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding)                   | resource    |
| [kubernetes_service_account.team](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account)             | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                     | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster)                         | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)                                 | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                       | data source |

## Inputs

| Name                                                                                 | Description                           | Type          | Default | Required |
| ------------------------------------------------------------------------------------ | ------------------------------------- | ------------- | ------- | :------: |
| <a name="input_application_teams"></a> [application_teams](#input_application_teams) | Map of maps of teams to create        | `any`         | `{}`    |    no    |
| <a name="input_eks_cluster_name"></a> [eks_cluster_name](#input_eks_cluster_name)    | EKS Cluster name                      | `string`      | n/a     |   yes    |
| <a name="input_environment"></a> [environment](#input_environment)                   | n/a                                   | `string`      | n/a     |   yes    |
| <a name="input_platform_teams"></a> [platform_teams](#input_platform_teams)          | Map of maps of teams to create        | `any`         | `{}`    |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                        | A map of tags to add to all resources | `map(string)` | `{}`    |    no    |
| <a name="input_tenant"></a> [tenant](#input_tenant)                                  | n/a                                   | `string`      | n/a     |   yes    |
| <a name="input_zone"></a> [zone](#input_zone)                                        | n/a                                   | `string`      | n/a     |   yes    |

## Outputs

| Name                                                                                                                          | Description                                       |
| ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| <a name="output_application_teams_iam_role_arn"></a> [application_teams_iam_role_arn](#output_application_teams_iam_role_arn) | IAM role ARN for Teams                            |
| <a name="output_platform_teams_iam_role_arn"></a> [platform_teams_iam_role_arn](#output_platform_teams_iam_role_arn)          | IAM role ARN for Platform Teams                   |
| <a name="output_team_sa_irsa_iam_role_arn"></a> [team_sa_irsa_iam_role_arn](#output_team_sa_irsa_iam_role_arn)                | IAM role ARN for Teams EKS Service Account (IRSA) |

<!--- END_TF_DOCS --->
