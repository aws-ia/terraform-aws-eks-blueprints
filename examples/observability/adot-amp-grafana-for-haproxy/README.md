# Observability pattern for HAProxy applications with Amazon EKS and Observability services

This example demonstrates how to use the Amazon EKS Blueprints for Terraform a
new Amazon EKS Cluster with AWS Distro for OpenTelemetry (ADOT) configured to
specifically monitor HAProxy applications Prometheus metrics.
The ADOT collector deployed as a Kubernetes Operator, sends metrics to a
provided Amazon Managed Prometheus workspace, to be visualize with
Amazon Managed Grafana.

This example provides a curated dashboard along with Alerts and Rules on
Amazon Managed Prometheus configured as a default data source on Managed Grafana.

#### ⚠️ API Key

The Grafana API key is currently handled in this example through a variable until [native support is provided](https://github.com/hashicorp/terraform-provider-aws/issues/25100).
Users can store the retrieved key in a `terraform.tfvars` file with the variable name like `grafana_api_key="xxx"`, or set the value through an environment variable
like `export TF_VAR_grafana_api_key="xxx"` when working with the example. However, in a current production environment, users should use an external secret store such as AWS Secrets Manager and use the
[aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) data source to retrieve the API key.

## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

This example deploy all the necessary components to start monitoring your HAProxy
applications. You can follow the steps below to build and deploy an example
application to populate the dashboard with metrics.

To provision this example:

1. Provision the Grafana workspace first; we need to retrieve the key after creation before we can proceed with provisioning:

```sh
terraform init
terraform apply -target=module.managed_grafana # required to retrieve API key before we can proceed
```

Enter `yes` at command prompt to apply

Alternatively, you can reuse an existing Managed Grafana workspace. In this case, you can add `grafana_endpoint="https://xxx/"` to your `terraform.tfvars` or use an evironment variable `export TF_VAR_grafana_endpoint=""https://xxx/""`

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
adot-collector-haproxy          adot-collector-788f78cf45-przds                              1/1     Running   0          59s
cert-manager                    cert-manager-c84fb49b6-6qwr8                                 1/1     Running   0          6m49s
cert-manager                    cert-manager-cainjector-7d55bf8f78-w24bv                     1/1     Running   0          6m50s
cert-manager                    cert-manager-webhook-577f77586f-xldrk                        1/1     Running   0          6m49s
haproxy-ingress                 haproxy-ingress-566cc75f8b-dhv6g                             1/1     Running   0          7m15s
haproxy-ingress                 haproxy-ingress-default-backend-5c746cccb9-p2ztq             1/1     Running   0          7m15s
kube-system                     aws-node-6b6cb                                               1/1     Running   0          5m52s
kube-system                     aws-node-mgx8d                                               1/1     Running   0          5m53s
kube-system                     aws-node-z8p8r                                               1/1     Running   0          5m48s
kube-system                     coredns-85d5b4454c-dr4z5                                     1/1     Running   0          10m
kube-system                     coredns-85d5b4454c-zp8qs                                     1/1     Running   0          10m
kube-system                     kube-proxy-2n5vj                                             1/1     Running   0          5m52s
kube-system                     kube-proxy-rcvw4                                             1/1     Running   0          5m53s
kube-system                     kube-proxy-wzml2                                             1/1     Running   0          5m48s
opentelemetry-operator-system   opentelemetry-operator-controller-manager-865fd559cd-7tvmg   2/2     Running   0          65s
```

3. Open your Managed Grafana Workspace, head to the configuration page and and verify that Amazon Managed Prometheus was added as a default data source, test its connectivity.

4. Navigate to the dashboard side panel, click on `Observability` Folder and open the `HAProxy for Kubernetes` Dashboard.

<!-- TODO - this link is dead, is there a replacement link for what the dashboard should look like? -->
<img width="1468" alt="HAProxy-dashboard" src="https://github.com/awsdabra/amg-dashboard-examples/blob/d4275d2e0251963b8783dcc03fd475d6f8783cc7/haproxy_grafana_dashboard.png">

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
