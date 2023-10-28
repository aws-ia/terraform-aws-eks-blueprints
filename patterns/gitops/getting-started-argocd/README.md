# ArgoCD on Amazon EKS

This example shows how to deploy Amazon EKS with addons configured via ArgoCD using the [GitOps Bridge Pattern](https://github.com/gitops-bridge-dev)


## Fork the git repositories

### Fork the addon gitops repo
Fork the git repository for addons https://github.com/aws-samples/eks-blueprints-add-ons
Set the followign variables to point to your fork, change the deafult values below:
```shell
export TF_VAR_gitops_addons_org=https://github.com/aws-samples
export TF_VAR_gitops_addons_repo=eks-blueprints-add-ons
```

### Fork the workloads gitops repo
For the git repository for this pattern https://github.com/aws-ia/terraform-aws-eks-blueprints
Set the followign variables to point to your fork, change the default values below:
```shell
export TF_VAR_gitops_workload_org=https://github.com/aws-ia
export TF_VAR_gitops_workload_repo=terraform-aws-eks-blueprints
```

## Deploy the EKS Cluster

```shell
terraform init
terraform apply -auto-approve
```

Get `kubectl` config, and run the output
```shell
terraform output -raw configure_kubectl
```

Terraform added the GitOps Bridge Metadata in the ArgoCD Secret.
The annotations contains the metadata for the addons helm charts.
The labels contains an easy way to enable or disable an addon in ArgoCD for the cluster.
```shell
kubectl get secret -n argocd -l argocd.argoproj.io/secret-type=cluster -o jsonpath='{.metadata.annotations}'
kubectl get secret -n argocd -l argocd.argoproj.io/secret-type=cluster -o jsonpath='{.metadata.labels}'
```

## Deploy the Addons

Bootstrap the Addons using ArgoCD
```shell
kubectl apply -f bootstrap/addons.yaml
```
Verify Addons are ready
```shell
kubectl get applications -n argocd \
  addon-getting-started-gitops-aws-load-balancer-controller \
  addon-getting-started-gitops-metrics-server \
  addon-getting-started-gitops-argo-cd
kubectl get sts -n argocd
kubectl get deployment -n kube-system \
  aws-load-balancer-controller \
  metrics-server
```

Get ArgoCD UI and CLI access configuration, and run the output in a new terminal window
```shell
terraform output -raw configure_argocd
```

## Deploy the Workloads

Deploy Sample Application located in [k8s/game-2048.yaml](k8s/game-2048.yaml) using ArgoCD
```shell
kubectl apply -f bootstrap/workloads.yaml
```
Verify Application is ready
```shell
kubectl get -n argocd applications workloads
kubectl get -n game-2048 deployments
kubectl get -n game-2048 deployments
kubectl get -n game-2048 ingress
```

Get the Ingress URL for the Application
```shell
echo "Application URL: http://$(kubectl get -n game-2048 ingress game-2048 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

!!! info
    You might need to wait a few minutes, and then refresh your browser.
    If your Ingress isn't created after several minutes, then run this command to view the AWS Load Balancer Controller logs:

```shell
kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller
```

Verify Application from Terminal
```shell
curl -I $(kubectl get -n game-2048 ingress game-2048 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

Verify Application CPU and Memory metrics
```shell
kubectl top pods -n game-2048
```

## Destroy the EKS Cluster
```shell
./destroy.sh
```
