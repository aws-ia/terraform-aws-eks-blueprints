# Multi-cluster ArgoCD

This example demonstrate how to deploy a single instance of ArgoCD on a central cluster (hub)
managing multiple tenant clusters (spokes). In this example all spoke clusters get the same configuration for addons deployed from a central ArgoCD.


## Setup LoadBalancer or Ingress
The example supports ArgoCD UI configuration with a valid domain name (ie example.com) or LoadBalancer with a generated domain name.
To use Ingress you need to create a Route 53 Hosted zone, and configure ACM with the domain name.

### (Option 1) LoadBalancer
Edit the [hub-cluster/main.tf](./hub-cluster/main.tf) and for the ArgoCD helm config `argocd_helm_config` variable comment `ingress` section and uncomment `service` section
```hcl
service : {
  type : "LoadBalancer"
}
```

### (Option 2) Ingress
You will be able to use ArgoCD with valid ssl certificate on a domain (ie. argocd.example.com)

#### Create DNS Hosted Zone in Route 53
You can use the Console, or the `aws` cli
```sh
aws route53 create-hosted-zone --name 'example.com' --caller-reference "$(date)"
```

#### Create domain certificate in ACM, for example
You can use the Console, or the `aws` cli
```sh
aws acm request-certificate --domain-name '*.example.com' ---validation-method DNS
```

#### Setup Domain
Set the sub domain for argocd
```
export TF_VAR_argo_domain=example.com
```

## Deploy Hub Cluster
After selecting LoadBalancer or Ingress for ArgoCD deploy the Hub Cluster
```sh
cd hub-cluster
terraform init
terraform apply -auto-approve
cd ..
```

## Update Spoke Cluster Template

You have the option to edit the file [spoke-cluster-template/main.tf](./spoke-cluster-template/main.tf) to change the configuration of the spoke clusters.

Each spoke cluster deploys a different set of Cluster addons and applications. See the `main.tf` for each spoke cluster to review the configuration.

Spoke cluster can be created in different accounts or regions than the hub cluster,
inpect the `main.tf` to pass the optional parameters.
```hcl
spoke_profile = "account-spoke-Admin"
spoke_region  = "us-east-1"
hub_profile   = "account-hub-Admin"
hub_region    = "us-west-2"
```

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
```
URL: https://argocd.example.com
Username: admin
Password: SecretString: **********
```
Login into ArgoCD UI with the provided username and password

Go to Settings->Clusters, you should see 3 remote clusters:
  - `cluster-dev`  is the Spoke Cluster 1 "DEV"
  - `cluster-test` is the Spoke Cluster 2 "TEST"
  - `cluster-prod` is the Spoke Cluster 3 "PROD"


## (Optiona) Private git repositories
To use private git repositories you can use SSH authentication.

1. Create a secret key `github-ssh-key` with in Secret Manager
containing the private SSH key in plain text, this key is specified using the variable `ssh_key_secret_name` in [spoke-cluster-template/main.tf](./spoke-cluster-template/main.tf)
2. Edit the file [spoke-cluster-template/main.tf](./spoke-cluster-template/main.tf) and specify the git url using SSH notation (ie git@gitub.com/<user_or_org>/<repository>).
The variables `git_secret_namespace` and `git_secret_name` are used to store the git configuration in the Hub Cluster.

For more information see [ArgoCD SSH git authentication](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#repositories)
```hcl
repo_url             = "git@gitub.com/<user_or_org>/<repository>"
ssh_key_secret_name  = "github-ssh-key"
git_secret_namespace = "argocd"
git_secret_name      = "${local.name}-addons"
```

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