# Observability pattern for Memcached applications with Amazon EKS and Observability services

This example demonstrates how to use the Amazon EKS Blueprints for Terraform a
new Amazon EKS Cluster with AWS Distro for OpenTelemetry (ADOT) configured to
specifically monitor Memcached applications Prometheus metrics.
The ADOT collector deployed as a Kubernetes Operator, sends metrics to a
provided Amazon Managed Prometheus workspace, to be visualize with
Amazon Managed Grafana.

This example provides a curated dashboard along with Alerts and Rules on
Amazon Managed Prometheus configured as a default data source on Managed Grafana.

#### ⚠️ API Key

The Grafana API key is currently handled in this example through a variable until [native support is provided](https://github.com/hashicorp/terraform-provider-aws/issues/25100).
Users can store the retrieved key in a `terraform.tfvars` file with the variable name like `grafana_api_key="xxx"`, or set the value through an environment variable
like `export TF_VAR_grafana_api_key="xxx"`when working with the example. However, in a current production environment, users should use an external secret store such as AWS Secrets Manager and use the
[aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) data source to retrieve the API key.

## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

This example deploy all the necessary components to start monitoring your memcached
applications. You can follow the steps below to build and deploy an example
application to populate the dashboard with metrics.

To provision this example:

1. Provision the Grafana workspace first; we need to retrieve the key after creation before we can proceed with provisioning:

```sh
terraform init
terraform apply -target=module.managed_grafana # required to retrieve API key before we can proceed
```

Enter `yes` at command prompt to apply

Alternatively, you can reuse an existing Managed Grafana workspace. In this case, you can add `grafana_endpoint="https://xxx/"` to your `terraform.tfvars` or use an environment variable `export TF_VAR_grafana_endpoint=""https://xxx/""`

2. Generate a Grafana API Key

- Give admin access to the SSO user you set up when creating the Amazon Managed Grafana Workspace:
  - In the AWS Console, navigate to Amazon Grafana. In the left navigation bar, click **All workspaces**, then click on the workspace name you are using for this example.
  - Under **Authentication** within **AWS Single Sign-On (SSO)**, click **Configure users and user groups**
  - Check the box next to the SSO user you created and click **Make admin**
- From the workspace in the AWS console, click on the `Grafana workspace URL` to open the workspace
- If you don't see the gear icon in the left navigation bar, log out and log back in.
- Click on the gear icon, then click on the **API keys** tab.
- Click **Add API key**, fill in the _Key name_ field and select _Admin_ as the Role.
- Copy your API key into `terraform.tfvars` under the `grafana_api_key` variable (`grafana_api_key="xxx"`) or set as an environment variable on your CLI (`export TF_VAR_grafana_api_key="xxx"`)

3. Complete provisioning of resources

```sh
terraform apply
```

Enter `yes` at command prompt to apply

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the deployment.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. Test by listing all the pods running currently:

```sh
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

3. Open your Managed Grafana Workspace, head to the configuration page and and verify that Amazon Managed Prometheus was added as a default data source, test its connectivity.

#### Deploy an Example Application

In this section we will deploy sample application and extract metrics using AWS OpenTelemetry collector

1. Add the helm incubator repo:

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
```

2. Enter the following command to create a new namespace:

```sh
kubectl create namespace memcached-sample
```

3. Enter the following commands to install Memcached:

```sh
helm install my-memcached bitnami/memcached --namespace memcached-sample \
--set metrics.enabled=true \
--set-string serviceAnnotations.prometheus\\.io/port="9150" \
--set-string serviceAnnotations.prometheus\\.io/scrape="true"
```

4. Verify if the application is running

```sh
kubectl get pods -n memcached-sample
```

#### Visualize the Application's dashboard

Log back into your Managed Grafana Workspace and navigate to the dashboard side panel, click on `Observability` Folder and open the `Memcached for Kubernetes` Dashboard.

<img width="1468" alt="java-dashboard" src="https://user-images.githubusercontent.com/10175027/159924937-51514e4e-3442-40a2-a921-950d69f372b4.png">

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -target=module.eks_blueprints_kubernetes_addons -auto-approve
terraform destroy -target=module.eks_blueprints -auto-approve
terraform destroy -auto-approve
```

## Troubleshooting

- You can explore the OpenTelemetry Collector logs by running the following command:

```sh
kubectl get pods -n opentelemetry-operator-system
kubectl logs -f -n opentelemetry-operator-system
```
