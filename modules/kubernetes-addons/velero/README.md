# [Velero](https://velero.io/)

Velero is an open source tool to safely backup and restore, perform disaster recovery, and migrate Kubernetes cluster resources and persistent volumes.

- [Helm chart](https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero)
- [Plugin for AWS](https://github.com/vmware-tanzu/velero-plugin-for-aws)

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the Velero deployment.

1. Run `update-kubeconfig` command:

```bash
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. Test by listing velero resources provisioned:

```bash
kubectl get all -n velero

# Output should look similar to below
NAME                         READY   STATUS    RESTARTS   AGE
pod/velero-b4d8fd5c7-5smp6   1/1     Running   0          112s

NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/velero   ClusterIP   172.20.217.203   <none>        8085/TCP   114s

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/velero   1/1     1            1           114s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/velero-b4d8fd5c7   1         1         1       114s
```

3. Get backup location using velero [CLI](https://velero.io/docs/v1.8/basic-install/#install-the-cli)

```bash
velero backup-location get

# Output should look similar to below
NAME      PROVIDER   BUCKET/PREFIX             PHASE       LAST VALIDATED                  ACCESS MODE   DEFAULT
default   aws        velero-ssqwm44hvofzb32d   Available   2022-05-22 10:53:26 -0400 EDT   ReadWrite     true
```

4. To demonstrate creating a backup and restoring, create a new namespace and run nginx using below commands:

```bash
kubectl create namespace backupdemo
kubectl run nginx --image=nginx -n backupdemo
```

5. Create backup of this namespace using velero

```bash
velero backup create backup1 --include-namespaces backupdemo

# Output should look similar to below
Backup request "backup1" submitted successfully.
Run `velero backup describe backup1` or `velero backup logs backup1` for more details.
```

6. Describe the backup to check the backup status

```bash
velero backup describe backup1

# Output should look similar to below
Name:         backup1
Namespace:    velero
Labels:       velero.io/storage-location=default
Annotations:  velero.io/source-cluster-k8s-gitversion=v1.21.9-eks-14c7a48
              velero.io/source-cluster-k8s-major-version=1
              velero.io/source-cluster-k8s-minor-version=21+

Phase:  Completed

Errors:    0
Warnings:  0

Namespaces:
  Included:  backupdemo
  Excluded:  <none>

Resources:
  Included:        *
  Excluded:        <none>
  Cluster-scoped:  auto

Label selector:  <none>

Storage Location:  default

Velero-Native Snapshot PVs:  auto

TTL:  720h0m0s

Hooks:  <none>

Backup Format Version:  1.1.0

Started:    2022-05-22 10:54:32 -0400 EDT
Completed:  2022-05-22 10:54:35 -0400 EDT

Expiration:  2022-06-21 10:54:32 -0400 EDT

Total items to be backed up:  10
Items backed up:              10

Velero-Native Snapshots: <none included>
```

7. Delete the namespace - this will be restored using the backup created

```bash
kubectl delete namespace backupdemo
```

8. Restore the namespace from your backup

```bash
velero restore create --from-backup backup1
```

9. Verify that the namespace is restored

```bash
kubectl get all -n backupdemo

# Output should look similar to below
NAME        READY   STATUS    RESTARTS   AGE
pod/nginx   1/1     Running   0          21s
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.velero](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.velero](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_backup_s3_bucket"></a> [backup\_s3\_bucket](#input\_backup\_s3\_bucket) | Bucket name for velero bucket | `string` | `""` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for velero | `any` | `{}` | no |
| <a name="input_irsa_policies"></a> [irsa\_policies](#input\_irsa\_policies) | Additional IAM policy ARNs for Velero IRSA | `list(string)` | `[]` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
| <a name="output_release_metadata"></a> [release\_metadata](#output\_release\_metadata) | Map of attributes of the Helm release metadata |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Name of Kubernetes service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
