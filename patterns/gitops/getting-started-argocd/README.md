# ArgoCD on Amazon EKS

This example shows how to deploy Amazon EKS with addons configured via ArgoCD

Deploy EKS Cluster
```shell
terraform init
terraform apply
```

Get `kubectl` config, and run the output
```shell
terraform output -raw configure_kubectl
```

Deploy Addons using ArgoCD
```shell
kubectl apply -f bootstrap/addons.yaml
```
Verify Addons are ready
```shell
kubectl get applications -n argocd \
  addon-getting-started-gitops-aws-load-balancer-controller \
  addon-getting-started-gitops-metrics-server
kubectl get deployment -n kube-system \
  aws-load-balancer-controller \
  metrics-server
```

Get ArgoCD UI and CLI access configuration, and run the output in a new terminal window
```shell
terraform output -raw configure_argocd
```

Deploy Sample Application
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
kubectl get ingress
```
Verify Application on the Browser or Terminal
```shell
curl ...
```

Destroy EKS Cluster
```shell
./destroy.sh
```
