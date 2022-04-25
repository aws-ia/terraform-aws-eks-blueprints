# Teams

## Introduction

EKS Blueprints provides support for onboarding and managing teams and easily configuring cluster access. We currently support two `Team` types: `application_teams` and `platform_teams`.

`Application Teams` represent teams managing workloads running in cluster namespaces and `Platform Teams` represents platform administrators who have admin access (masters group) to clusters.

You can reference the [aws-eks-teams](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/aws-eks-teams) module to create your own team implementations.

### ApplicationTeam

To create an `application_team` for your cluster, you will need to supply a team name, with the options to pass map of labels, map of resource quotas, existing IAM entities (user/roles), and a directory where you may optionally place any policy definitions and generic manifests for the team. These manifests will be applied by EKS Blueprints and will be outside of the team control.

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

EKS Blueprints will do the following for every provided team:

- Create a namespace
- Register quotas
- Register IAM users for cross-account access
- Create a shared role for cluster access. Alternatively, an existing role can be supplied.
- Register provided users/roles in the `aws-auth` configmap for `kubectl` and console access to the cluster and namespace.
- (Optionally) read all additional manifests (e.g., network policies, OPA policies, others) stored in a provided directory, and apply them.

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

- Registers IAM users for admin access to the cluster (`kubectl` and console).
- Registers an existing role (or create a new role) for cluster access with trust relationship with the provided/created role.

## Cluster Access (`kubectl`)

The output will contain the IAM roles for every application(`application_teams_iam_role_arn`) or platform team(`platform_teams_iam_role_arn`).

To update your kubeconfig, you can run the following command:

```
aws eks update-kubeconfig --name ${eks_cluster_id} --region ${AWS_REGION} --role-arn ${TEAM_ROLE_ARN}
```

Make sure to replace the `${eks_cluster_id}`, `${AWS_REGION}` and `${TEAM_ROLE_ARN}` with the actual values.
