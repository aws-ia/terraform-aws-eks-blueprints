# EKS Cluster with Velero

Velero is a tool to backup and restore your Kubernetes cluster resources and persistent volumes. Velero lets you :

- Take backups of your cluster and restore in case of loss. 
- Migrate cluster resources to other clusters. 
- Replicate your production cluster to development and testing clusters.

For complete project documentation, please visit the [Velero documentation site](https://velero.io/docs/v1.7/).

# How to Deploy
## Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
5. [velero CLI](https://velero.io/docs/v1.8/basic-install/#install-the-cli)

## Deployment Steps
#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step2: Run Terraform INIT
to initialize a working directory with configuration files

```shell script
cd examples/velero/
terraform init
```

#### Step3: Run Terraform PLAN
to verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER-YOUR-REGION>   # Select your own region
terraform plan
```

#### Step4: Finally, Terraform APPLY
to create resources

```shell script
terraform apply
```

Enter `yes` to apply

### Configure kubectl and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step5: Run update-kubeconfig command.
`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region <Enter-your-region> update-kubeconfig --name <cluster-name>

#### Step6: List all the worker nodes by running the command below
You should see one Self-managed node up and running

    $ kubectl get nodes

#### Step7: List all the pods running in karpenter namespace

    $ kubectl get all -n velero

    # Output should look similar to below
    NAME                          READY   STATUS    RESTARTS   AGE
    pod/velero-78b8ddfc56-jmkdm   1/1     Running   0          10m

    NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    service/velero   ClusterIP   172.20.47.185   <none>        8085/TCP   10m

    NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/velero   1/1     1            1           10m

    NAME                                DESIRED   CURRENT   READY   AGE
    replicaset.apps/velero-78b8ddfc56   1         1         1       10m`


## Get backup location using velero [CLI](https://velero.io/docs/v1.8/basic-install/#install-the-cli)

```sh

velero backup-location get

NAME      PROVIDER   BUCKET/PREFIX                                    PHASE     LAST VALIDATED   ACCESS MODE   DEFAULT
default   aws        eks-tf-velero-backup20220410090713882000000001   Unknown   Unknown          ReadWrite  


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

# How to Destroy

NOTE: Make sure you delete all the deployments which clean up the nodes spun up by Karpenter Autoscaler
Ensure no nodes are running created by Karpenter before running the `Terraform Destroy`. Otherwise, EKS Cluster will be cleaned up however this may leave some nodes running in EC2.

```shell script
cd examples/eks-cluster-with-karpenter
terraform destroy
```

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.66.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.13.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.6.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.66.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-eks-accelerator-for-terraform"></a> [aws-eks-accelerator-for-terraform](#module\_aws-eks-accelerator-for-terraform) | ../.. | n/a |
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | v3.2.0 |
| <a name="module_karpenter-launch-templates"></a> [karpenter-launch-templates](#module\_karpenter-launch-templates) | ../../modules/launch-templates | n/a |
| <a name="module_kubernetes-addons"></a> [kubernetes-addons](#module\_kubernetes-addons) | ../../modules/kubernetes-addons | n/a |

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.karpenter_provisioner](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [kubectl_path_documents.karpenter_provisioners](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/path_documents) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |

<!--- END_TF_DOCS --->