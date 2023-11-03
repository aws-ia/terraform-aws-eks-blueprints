# Multi-Cluster centralized hub-spoke topology

This tutorial guides you through deploying an Amazon EKS cluster with addons configured via ArgoCD in a Multi-Cluster Hub-Spoke topoloy, employing the [GitOps Bridge Pattern](https://github.com/gitops-bridge-dev).

<img src="static/gitops-bridge-multi-cluster-hup-spoke.drawio.png" width=100%>


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
terraform apply -auto-approve
```
To retrieve `kubectl` config, execute the terraform output command:
```shell
terraform output -raw configure_kubectl
```

### Monitor GitOps Progress for Addons
Wait until **all** the ArgoCD applications' `HEALTH STATUS` is `Healthy`. Use Crl+C to exit the `watch` command
```shell
kubectl get applications -n argocd -w
```

## Access ArgoCD on Hub Cluster
Access ArgoCD's UI, run the command from the output:
```shell
terraform output -raw access_argocd
```

## Verify that ArgoCD Service Accouts has the annotation for IRSA
```shell
kubectl get sa -n argocd argocd-application-controller -o json | jq '.metadata.annotations."eks.amazonaws.com/role-arn"'
kubectl get sa -n argocd argocd-server  -o json | jq '.metadata.annotations."eks.amazonaws.com/role-arn"'
```
The output should match the `arn` for the IAM Role that will assume the IAM Role in spoke/remote clusters
```text
"arn:aws:iam::0123456789:role/hub-spoke-control-plane-argocd-hub"
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

To access Terraform output run the following commands for the particular environment
```shell
terraform workspace select dev
terraform output
```
```shell
terraform workspace select staging
terraform output
```
```shell
terraform workspace select prod
terraform output
```

Retrieve `kubectl` config, then execute the output command:
```shell
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
Verify that the addons are ready:
```shell
for i in dev staging prod ; do echo $i && kubectl --context spoke-$i get deployment -n kube-system metrics-server ; done
```


### Monitor GitOps Progress for Workloads from Hub Cluster (run on Hub Cluster context)
Watch until **all* the Workloads ArgoCD Applications are `Healthy`
```shell
kubectl --context hub get -n argocd applications -w
```
Wait until the ArgoCD Applications `HEALTH STATUS` is `Healthy`. Crl+C to exit the `watch` command


### Verify the Application
Verify that the application configuration is present and the pod is running:
```shell
for i in dev staging prod ; do echo $i && kubectl --context spoke-$i get all -n workload ; done
```

### Container Metrics
Check the application's CPU and memory metrics:
```shell
for i in dev staging prod ; do echo $i && kubectl --context spoke-$i top pods -n workload ; done
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
To modify the `values.yaml` file or the helm chart version for addons, you'll need to fork tthe repository [aws-samples/eks-blueprints-add-ons](https://github.com/aws-samples/eks-blueprints-add-ons).

After forking, update the following environment variables to point to your forks, replacing the default values.
```shell
export TF_VAR_gitops_addons_org=https://github.com/aws-samples
export TF_VAR_gitops_addons_repo=eks-blueprints-add-ons
export TF_VAR_gitops_addons_revision=main

```
