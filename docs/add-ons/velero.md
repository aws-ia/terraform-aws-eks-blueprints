# Velero

Velero is a tool to backup and restore your Kubernetes cluster resources and persistent volumes. Velero lets you :

- Take backups of your cluster and restore in case of loss.
- Migrate cluster resources to other clusters.
- Replicate your production cluster to development and testing clusters.

For complete project documentation, please visit the [Velero documentation site](https://velero.io/docs/v1.7/).

## Usage

[Velero](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/velero) can be deployed by enabling the add-on via the following.

```hcl
enable_velero= true
```

## How to verfiy velero installation

Once the velero deployment is successful, run the following command from your a local machine which have access to an EKS cluster using kubectl.

```
$ kubectl get all -n velero
```

Install the velero [CLI](https://velero.io/docs/v1.8/basic-install/#install-the-cli) on your local machine to start using velero for backup and restore.

Once the velero CLI is installed run the following command to get the location of the S3 bucket that would store your backups

```
velero backup-location get
```

## Example of backup and restore for a namespace running nginx

Create a new namespace and run nginx using below commands

```
kubectl create namespace backupdemo
kubectl run nginx --image=nginx -n backupdemo
```

Create backup of this namespace using velero

```
velero backup create backup1 --include-namespaces backupdemo
velero backup describe backup1
```

Delete the namespace

```
kubectl delete namespace backupdemo
```

Restore the namespace from your backup

```
velero restore create --from-backup backup1
```

Verify that the namespace is restored

```
kubectl get ns
kubectl get all -n backupdemo
```
