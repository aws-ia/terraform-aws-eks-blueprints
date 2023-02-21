# Multi-cluster ArgoCD

This example demonstrate how to deploy a single instance of ArgoCD on a central cluster (hub)
managing multiple tenant clusters (spokes). In this example all spoke clusters get the same configuration for addons deployed from a central ArgoCD.

## Create domain certificate in ACM, for example 
```
aws acm request-certificate --domain-name '*.example.com' ---validation-method DNS
```

## Setup Domain
Set the sub domain for argocd
```
export TF_VAR_argo_domain=example.com
```

## Deploy Hub Cluster
```sh
cd hub-cluster
terraform init
terraform apply -auto-approve
cd ..
```

## Update Spoke Cluster Template

You can edit the file [spoke-cluster-template/main.tf](./spoke-cluster-template/main.tf) to change the configuration of the cluster and any addons to make it optional to install in any of  the spoke clusters.

## Deploy Spoke Cluster 1 "DEV"
```sh
cd spoke-cluster-1-dev
terraform init
terraform apply -auto-approve
cd ..
```

## Deploy Spoke Cluster 2 "TEST"
```sh
cd spoke-cluster-2-test
terraform init
terraform apply -auto-approve
cd ..
```

## Deploy Spoke Cluster 2 "PROD"
```sh
cd spoke-cluster-2-prod
terraform init
terraform apply -auto-approve
cd ..
```

## Access ArgoCD UI

Login with kubectl to Hub Cluster
```sh
terraform -chdir=hub-cluster output -raw configure_kubectl
```

Get ArgoCD URL and Password
```sh
echo "URL: https://$(kubectl get ing -n argocd argo-cd-argocd-server -o jsonpath='{.spec.tls[0].hosts[0]}')"
echo "Username: admin"
echo "Password: $(aws secretsmanager get-secret-value --secret-id  argocd-login-2 --region us-west-2 | grep SecretString)"
```
> If using Service instead of Ingress get the URL via the following command:
```sh
echo "URL: https://$(kubectl get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

Expected output:
>URL: https://a54906352f1984862b737855962b5d13-448052034.us-west-2.elb.amazonaws.com

>Username: admin

>Password: SecretString: **********

Login into ArgoCD UI with the provided username and password

Go to Settings->Clusters, you should see 3 remote clusters:
  - `cluster-dev`  is the Spoke Cluster 1 "DEV"
  - `cluster-test` is the Spoke Cluster 2 "TEST"
  - `cluster-prod` is the Spoke Cluster 3 "PROD"


## CleanUp

### Destroy Spoke Cluster 1 "DEV"
```sh
cd spoke-cluster-1-dev
./destroy.sh
cd ..
```

### Destroy Spoke Cluster 2 "TEST"
```sh
cd spoke-cluster-2-test
./destroy.sh
cd ..
```

### Destroy Spoke Cluster 3 "PROD"
```sh
cd spoke-cluster-2-prod
./destroy.sh
cd ..
```

### Destroy Hub Cluster
Get the login for Hub Cluster and login with `kubectl`
```sh
terraform -chdir=hub-cluster output -raw configure_kubectl
```
Login into Hub Cluster to manually delete the ingress before uninstalling argocd server, the ingress depends on the aws-loadbalancer-controller addon being deployed via gitops using argocd application.
```sh
kubectl delete ing argo-cd-argocd-server -n argocd
```
Destroy the cluster
```sh
cd hub-cluster
./destroy.sh
cd ..
```