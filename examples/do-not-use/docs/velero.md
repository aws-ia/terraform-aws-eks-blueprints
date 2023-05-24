# Velero

[Velero](https://velero.io/) is an open source tool to safely backup and restore, perform disaster recovery, and migrate Kubernetes cluster resources and persistent volumes.

- [Helm chart](https://github.com/vmware-tanzu/helm-charts/tree/main/charts/velero)
- [Plugin for AWS](https://github.com/vmware-tanzu/velero-plugin-for-aws)

## Usage

[Velero](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/velero) can be deployed by enabling the add-on via the following.

```hcl
enable_velero           = true
velero_backup_s3_bucket = "<YOUR_BUCKET_NAME>"
velero = {
    s3_backup_location = "<YOUR_S3_BUCKET_ARN>[/prefix]"
  }
```

You can also customize the Helm chart that deploys `velero` via the following configuration:

```hcl
enable_velero           = true

velero = {
  name          = "velero"
  description   = "A Helm chart for velero"
  chart_version = "3.1.6"
  repository    = "https://vmware-tanzu.github.io/helm-charts/"
  namespace     = "velero"
  values        = [templatefile("${path.module}/values.yaml", {})]
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
pod/velero-7b8994d56-z89sl   1/1     Running   0          25h

NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/velero   ClusterIP   172.20.20.118   <none>        8085/TCP   25h

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/velero   1/1     1            1           25h

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/velero-7b8994d56   1         1         1       25h
```

3. Get backup location using velero [CLI](https://velero.io/docs/v1.8/basic-install/#install-the-cli)

```bash
velero backup-location get

# Output should look similar to below
NAME      PROVIDER   BUCKET/PREFIX                                 PHASE       LAST VALIDATED                  ACCESS MODE   DEFAULT
default   aws        stateful-20230503175301619800000005/backups   Available   2023-05-04 15:15:00 -0400 EDT   ReadWrite     true
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
Annotations:  velero.io/source-cluster-k8s-gitversion=v1.26.2-eks-a59e1f0
              velero.io/source-cluster-k8s-major-version=1
              velero.io/source-cluster-k8s-minor-version=26+

Phase:  Completed


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

CSISnapshotTimeout:    10m0s
ItemOperationTimeout:  0s

Hooks:  <none>

Backup Format Version:  1.1.0

Started:    2023-05-04 15:16:31 -0400 EDT
Completed:  2023-05-04 15:16:33 -0400 EDT

Expiration:  2023-06-03 15:16:31 -0400 EDT

Total items to be backed up:  9
Items backed up:              9

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
