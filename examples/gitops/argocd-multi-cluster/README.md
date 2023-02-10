# Multi-cluster ArgoCD

This example demonstrate how to deploy a single instance of ArgoCD on a central cluster (hub)
managing multiple tenant clusters (spokes). In this example all spoke clusters get the same configuration for addons deployed from a central ArgoCD.

## Deploy Hub Cluster
```sh
cd hub-cluster
terraform init
terraform apply -auto-approve
cd ..
```

## Update Spoke Cluster Template

You can edit the file [spoke-cluster-template/main.tf](./spoke-cluster-template/main.tf) to change the configuration of the cluster and any addons to be installed in all the spoke clusters.

## Deploy Spoke Cluster 1
```sh
cd spoke-cluster-1
terraform init
terraform apply -auto-approve
cd ..
```

## Deploy Spoke Cluster 2
```sh
cd spoke-cluster-2
terraform init
terraform apply -auto-approve
cd ..
```

## Access ArgoCD UI

Login with kubectl to Hub Cluster
```sh
$(terraform output -chdir=hub-cluster -raw configure_kubectl)
echo "https://$(kubectl get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

Get ArgoCD URL and Password
```sh
echo "URL: https://$(kubectl get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "Username: admin"
echo "Password: $(aws secretsmanager get-secret-value --secret-id  argocd-login-2 --region us-west-2 | grep SecretString)"
```

Expected output:
>URL: https://a54906352f1984862b737855962b5d13-448052034.us-west-2.elb.amazonaws.com

>Username: admin

>Password: SecretString: **********

Login into ArgoCD UI with the provided username and password

Go to Settings->Clusters, you should see 2 remote clusters:
  - `cluster-1` is the Spoke Cluster 1
  - `cluster-2` is the Spoke Cluster 2


## CleanUp

Destroy the 3 clusters
```sh
terraform -chdir=hub-cluster destroy -auto-approve
terraform -chdir=spoke-cluster-1 destroy -auto-approve
terraform -chdir=spoke-cluster-2 destroy -auto-approve
```