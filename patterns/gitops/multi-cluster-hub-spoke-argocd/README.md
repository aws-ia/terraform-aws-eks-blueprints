# Multi-Cluster centralized hub-spoke topology

This tutorial guides you through deploying an Amazon EKS cluster with addons configured via ArgoCD in a Multi-Cluster Hub-Spoke topology, employing the [GitOps Bridge Pattern](https://github.com/gitops-bridge-dev).

<img src="https://raw.githubusercontent.com/aws-ia/terraform-aws-eks-blueprints/main/patterns/gitops/multi-cluster-hub-spoke-argocd/static/gitops-bridge-multi-cluster-hup-spoke.drawio.png" width=100%>

This example deploys ArgoCD on the Hub cluster (i.e. management/control-plane cluster).
The spoke clusters are registered as remote clusters in the Hub Cluster's ArgoCD
The ArgoCD on the Hub Cluster deploys addons and workloads to the spoke clusters

Each spoke cluster gets deployed an app of apps ArgoCD Application with the name `workloads-${env}`

## Prerequisites

Before you begin, make sure you have the following command line tools installed:

- git
- terraform
- kubectl
- argocd

## (Optional) Fork the GitOps git repositories

See the appendix section [Fork GitOps Repositories](#fork-gitops-repositories) for more info on the terraform variables to override.

## Deploy the Hub EKS Cluster

Change directory to `hub`

```shell
cd hub
```

Initialize Terraform and deploy the EKS cluster:

```shell
terraform init
terraform apply -target="module.vpc" -auto-approve
terraform apply -target="module.eks" -auto-approve
terraform apply -auto-approve
```

To retrieve `kubectl` config, execute the terraform output command:

```shell
terraform output -raw configure_kubectl
```

The expected output will have two lines you run in your terminal

```text
export KUBECONFIG="/tmp/hub-spoke"
aws eks --region us-west-2 update-kubeconfig --name getting-started-gitops --alias hub
```

>The first line sets the `KUBECONFIG` environment variable to a temporary file
that includes the cluster name. The second line uses the `aws` CLI to populate
that temporary file with the `kubectl` configuration. This approach offers the
advantage of not altering your existing `kubectl` context, allowing you to work
in other terminal windows without interference.

### Deploy ArgoCD Apps of ApplicationSets for Addons

This command verifies the initial ArgoCD installation, ArgoCD will be re-configured when the addons are deployed and configured from git.
```shell
kubectl --context hub get all -n argocd
```
This command creates the application set manifest to deploy the addons.
```shell
kubectl --context hub apply -n argocd -f ../hub/bootstrap/addons.yaml
```
The application sets defined here will then deploy addons to any spoke clusters provisioned later using Terraform


### Monitor GitOps Progress for Addons on Hub EKS Cluster

Wait until all the ArgoCD applications' `HEALTH STATUS` is `Healthy`.
Use `Ctrl+C` or `Cmd+C` to exit the `watch` command. ArgoCD Applications
can take a couple of minutes in order to achieve the Healthy status.

```shell
kubectl --context hub get applications -n argocd -w
```

The expected output should look like the following:

```text
NAME                                            SYNC STATUS   HEALTH STATUS
addon-in-cluster-argo-cd                        Synced        Healthy
addon-in-cluster-aws-load-balancer-controller   Synced        Healthy
addon-in-cluster-metrics-server                 Synced        Healthy
cluster-addons                                  Synced        Healthy
```

## (Optional) Access ArgoCD

Access to the ArgoCD's UI is completely optional, if you want to do it,
run the commands shown in the Terraform output as the example below:

```shell
terraform output -raw access_argocd
```

The expected output should contain the `kubectl` config followed by `kubectl` command to retrieve
the URL, username, password to login into ArgoCD UI or CLI.

```text
echo "ArgoCD Username: admin"
echo "ArgoCD Password: $(kubectl --context hub get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
echo "ArgoCD URL: https://$(kubectl --context hub get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

## Deploy the Spoke EKS Cluster

Use the `deploy.sh` script to create terraform workspace, initialize Terraform, and deploy the EKS clusters:

```shell
cd ../spokes
./deploy.sh dev
./deploy.sh staging
./deploy.sh prod
```

Each environment uses a Terraform workspace

To retrieve `kubectl` config, execute the terraform output command:

```shell
terraform workspace select dev
terraform output -raw configure_kubectl
```

```shell
terraform workspace select staging
terraform output -raw configure_kubectl
```

```shell
terraform workspace select prod
terraform output -raw configure_kubectl
```

### Verify ArgoCD Cluster Secret for Spokes have the correct IAM Role to be assume by Hub Cluster

```shell
for i in dev staging prod ; do echo $i && kubectl --context hub get secret -n argocd spoke-$i --template='{{index .data.config | base64decode}}' ; done
```

The output have a section `awsAuthConfig` with the `clusterName` and the `roleARN` that has write access to the spoke cluster

```json
{
  "tlsClientConfig": {
    "insecure": false,
    "caData" : "LS0tL...."
  },
  "awsAuthConfig" : {
    "clusterName": "hub-spoke-dev",
    "roleARN": "arn:aws:iam::0123456789:role/hub-spoke-dev-argocd-spoke"
  }
}
```

### Verify the Addons on Spoke Clusters

The addons on the spoke clusters are deployed using the Application Sets created on the EKS Hub Cluster. Verify that the addons are ready:

```shell
for i in dev staging prod ; do echo $i && kubectl --context $i get deployment -n kube-system ; done
```

### Deploy the sample application to EKS Spoke Clusters

This command will deploy the application using kubectl to all clusters connected to the hub cluster, using the manifest files in [./hub/bootstrap/workloads.yaml](./hub/bootstrap/workloads.yaml).
```shell
kubectl --context hub apply -n argocd -f ../hub/bootstrap/workloads.yaml
```

### Monitor GitOps Progress for Workloads from Hub Cluster (run on Hub Cluster context)

Watch until all the Workloads ArgoCD Applications are `Healthy`

```shell
kubectl --context hub get -n argocd applications -w
```

Wait until the ArgoCD Applications `HEALTH STATUS` is `Healthy`. Crl+C to exit the `watch` command

### Verify the Application

Verify that the application configuration is present and the pod is running:

```shell
for i in dev staging prod ; do echo $i && kubectl --context $i get all -n workload ; done
```

### Container Metrics

Check the application's CPU and memory metrics:

```shell
for i in dev staging prod ; do echo $i && kubectl --context $i top pods -n workload ; done
```

## Destroy the Spoke EKS Clusters

To tear down all the resources and the EKS cluster, run the following command:

```shell
./destroy.sh dev
./destroy.sh staging
./destroy.sh prod
```

## Destroy the Hub EKS Clusters

To tear down all the resources and the EKS cluster, run the following command:
Destroy Hub Clusters

```shell
cd ../hub
./destroy.sh
```

## Appendix

## Fork GitOps Repositories

To modify the `values.yaml` file or the helm chart version for addons, you'll need to fork the repository [aws-samples/eks-blueprints-add-ons](https://github.com/aws-samples/eks-blueprints-add-ons).

After forking, update the following environment variables to point to your forks, replacing the default values.

```shell
export TF_VAR_gitops_addons_org=https://github.com/aws-samples
export TF_VAR_gitops_addons_repo=eks-blueprints-add-ons
export TF_VAR_gitops_addons_revision=main

```
