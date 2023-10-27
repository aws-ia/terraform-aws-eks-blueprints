# ArgoCD on Amazon EKS

This example shows how to deploy Amazon EKS with addons configured via ArgoCD using the [GitOps Bridge Pattern](https://github.com/gitops-bridge-dev)

Deploy EKS Cluster
```shell
terraform init
terraform apply -auto-approve
```

Get `kubectl` config, and run the output
```shell
terraform output -raw configure_kubectl
```

Terraform adds the GitOps Bridge Metadata in the ArgoCD Secret.
The annotations contains the metadata for the addons helm charts.
The labels contains an easy way to enable or disable an addon for the cluster.
```shell
kubectl get secret -n argocd -l argocd.argoproj.io/secret-type=cluster -o jsonpath='{.metadata.annotations}'
kubectl get secret -n argocd -l argocd.argoproj.io/secret-type=cluster -o jsonpath='{.metadata.labels}'
```


Deploy Addons using ArgoCD
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

Deploy Sample Application located in [k8s/game-2048.yaml](k8s/game-2048.yaml)
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

Destroy EKS Cluster
```shell
./destroy.sh
```
