# Observability pattern for Memcached applications with Amazon EKS and Observability services

This example demonstrates how to use the Amazon EKS Blueprints for Terraform a
new Amazon EKS Cluster with AWS Distro for OpenTelemetry (ADOT) configured to
specifically monitor Memcached applications Prometheus metrics.
The ADOT collector deployed as a Kubernetes Operator, sends metrics to a
provided Amazon Managed Prometheus workspace, to be visualize with
Amazon Managed Grafana.

This example provides a curated dashboard along with Alerts and Rules on
Amazon Managed Prometheus configured as a default data source on Managed Grafana.

---

**NOTE**

For the sake of simplicity in this example, we store sensitive information and
credentials in `variables.tf`. This should not be done in a production environment.
Instead, use an external secret store such as AWS Secrets Manager and use the
[aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) data source to retrieve them.

---

## How to Deploy

### Prerequisites

- Terraform
- An AWS Account
- kubectl
- awscli
- jq
- An existing Amazon Managed Grafana workspace.

#### Generate a Grafana API Key

- Give admin access to the SSO user you set up when creating the Amazon Managed Grafana Workspace:
  - In the AWS Console, navigate to Amazon Grafana. In the left navigation bar, click **All workspaces**, then click on the workspace name you are using for this example.
  - Under **Authentication** within **AWS Single Sign-On (SSO)**, click **Configure users and user groups**
  - Check the box next to the SSO user you created and click **Make admin**
- Navigate back to the Grafana Dashboard. If you don't see the gear icon in the left navigation bar, log out and log back in.
- Click on the gear icon, then click on the **API keys** tab.
- Click **Add API key**, fill in the _Key name_ field and select _Admin_ as the Role.
- Copy your API key into `dev.tfvars` under `grafana_api_key`
- Add your Grafana endpoint to `dev.tfvars` under `grafana_endpoint`. (ex `https://<workspace-id>.grafana-workspace.<region>.amazonaws.com/`)

### Deployment Steps

- Clone this repository:

```
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

- Initialize a working directory

```
cd examples/observability/eks-cluster-with-adot-amp-grafana-for-memcached
terraform init
```

- Fill-in the values for the variables in `dev.tfvars`
- Verify the resources created by this execution:

```
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform validate
terraform plan -var-file=dev.tfvars
```

- Deploy resources:

```
terraform apply -var-file=dev.tfvars --auto-approve
```

- Add the cluster to your kubeconfig:

```
aws eks --region $AWS_REGION update-kubeconfig --name aws001-preprod-observability-eks
```

`terraform apply` will provision all the aforementioned resources.

---

**NOTE**

This example deploy all the necessary components to start monitoring your Memcached
applications. However, you can follow the steps below to build and deploy and example
application.

---

#### Verify that the Resources Deployed Successfully

- Verify that Amazon Managed Prometheus workspace was created successfully:

  - Check the status of Amazon Managed Prometheus workspace through the AWS console.

- Check that OpenTelemetry Collector is running successfully inside EKS:

```
kubectl get pods -A

NAMESPACE                       NAME                                                         READY   STATUS    RESTARTS   AGE
cert-manager                    cert-manager-7989877dff-jxk57                                1/1     Running   0          160m
cert-manager                    cert-manager-cainjector-7d55bf8f78-jcc6d                     1/1     Running   0          160m
cert-manager                    cert-manager-webhook-577f77586f-m6mlg                        1/1     Running   0          160m
kube-system                     aws-node-kvbdl                                               1/1     Running   0          3h36m
kube-system                     aws-node-lv4g4                                               1/1     Running   0          3h36m
kube-system                     aws-node-x8zcs                                               1/1     Running   0          3h36m
kube-system                     coredns-745979c988-bhtx6                                     1/1     Running   0          3h42m
kube-system                     coredns-745979c988-ktdlg                                     1/1     Running   0          3h42m
kube-system                     kube-proxy-2wqr2                                             1/1     Running   0          3h36m
kube-system                     kube-proxy-7kz4p                                             1/1     Running   0          3h36m
kube-system                     kube-proxy-rxkp8                                             1/1     Running   0          3h36m
opentelemetry-operator-system   adot-collector-64c8b46888-q6s98                              1/1     Running   0          158m
opentelemetry-operator-system   opentelemetry-operator-controller-manager-68f5b47944-pv6x7   2/2     Running   0          158m
```

- Open your Managed Grafana Workspace, head to the configuration page and and verify that Amazon Managed Prometheus was added as a default data source, test its connectivity.

#### Deploy an Example Application

In this section we will deploy sample application and extract metrics using AWS OpenTelemetry collector

- 1. Add the helm incubator repo:

```
helm repo add bitnami https://charts.bitnami.com/bitnami

```

- 2. Enter the following command to create a new namespace:

```
kubectl create namespace memcached-sample

```

- 3. Enter the following commands to install Memcached:

```
helm install my-memcached bitnami/memcached --namespace memcached-sample \
--set metrics.enabled=true \
--set-string serviceAnnotations.prometheus\\.io/port="9150" \
--set-string serviceAnnotations.prometheus\\.io/scrape="true"

```

- 4. Verify if the application is running

```
kubectl get pods -n memcached-sample

```

#### Vizualize the Application's dashboard

Log back into your Managed Grafana Workspace and navigate to the dashboard side panel, click on `Observability` Folder and open the `Memcached for Kubernetes` Dashboard.

<img width="1468" alt="java-dashboard" src="https://user-images.githubusercontent.com/10175027/159924937-51514e4e-3442-40a2-a921-950d69f372b4.png">

## Cleanup

- Run `terraform destroy -var-file=dev.tfvars` to remove all resources except for your Amazon Managed Grafana workspace.
- Delete your Amazon Managed Grafana workspace through the AWS console.

## Troubleshooting

- When running `terraform apply` or `terraform destroy`, the process will sometimes time-out. If that happens, run the command again and the operation will continue where it left off.

- You can explore the OpenTelemtry Collector logs by running the following command:

```
kubectl get pods -n opentelemetry-operator-system
kubectl logs -f -n opentelemetry-operator-system adot-collector-xxxx
```
