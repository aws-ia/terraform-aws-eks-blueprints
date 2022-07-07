# Velero

[Velero](https://velero.io/) is an open source tool to safely backup and restore, perform disaster recovery, and migrate Kubernetes cluster resources and persistent volumes.

- [Helm chart](https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero)
- [Plugin for AWS](https://github.com/vmware-tanzu/velero-plugin-for-aws)

## Usage

[Velero](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/velero) can be deployed by enabling the add-on via the following.

```hcl
enable_velero           = true
velero_backup_s3_bucket = "<YOUR_BUCKET_NAME>"
```

You can also customize the Helm chart that deploys `velero` via the following configuration:

```hcl
enable_velero           = true
velero_helm_config = {
  name        = "velero"
  description = "A Helm chart for velero"
  chart       = "velero"
  version     = "2.30.0"
  repository  = "https://vmware-tanzu.github.io/helm-charts/"
  namespace   = "velero"
  values = [templatefile("${path.module}/values.yaml", {
    bucket = "<YOUR_BUCKET_NAME>",
    region = "<YOUR_BUCKET_REGION>"
  })]
}
```

To see a working example, see the [`stateful`](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/stateful) example blueprint.

## Validate


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
