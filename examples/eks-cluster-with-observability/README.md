# EKS Cluster with Observability Tools

This example deploy a new Kubernetes Cluster with Amazon Managed Prometheus, Amazon Managed Grafana, FluentBit, and Opensearch. It also includes instructions for deploying a sample workload with ArgoCD to generate logs and metrics.

---
**NOTE**

For the sake of simplicity in this example, we store sensitive information and credentials in `dev.tfvars`. This should not be done in a production environment. Instead, store the information in AWS Secrets Manager.

---

## How to Deploy

### Prerequisites

- An existing Amazon Managed Grafana (AMG) Workspace.
  - As of this writing (January 25, 2022), the AWS Terraform Provider does not support Amazon Managed Grafana, so it must be manually created beforehand. Instructions [here](https://docs.aws.amazon.com/grafana/latest/userguide/getting-started-with-AMG.html)

#### Generate a Grafana API Key
- Give the SSO user you set up in when creating the AMG Workspace admin access. 
  - In the AWS Console, navigate to Amazon Grafana. In the left navigation bar, click __All workspaces__, then click __eks-ssp-observability__
  - Under __Authentication__ within __AWS Single Sign-On (SSO)__, click __Configure users and user groups__
  - Check the box next to the SSO user you created and click __Make admin__
- Navigate back to the Grafana Dashboard. If you don't see the gear icon in the left navigation bar, log out and log back in.
- Click on the gear icon, then click on the __API keys__ tab.
- Click __Add API key__, fill in the _Key name_ field and select _Admin_ as the Role.
- Copy your API key into `dev.tfvars` under `grafana_api_key` 

### Deployment Steps

- Clone this repository: `git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git`
- Initialize a working directory:
```
cd examples/observability/eks-cluster-with-observability
terraform init
```
- Fill-in the values for the variables in `dev.tfvars`
- Verify the resources created by this execution:
```
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform validate
terraform plan -tf-vars=dev.tfvars
```
- Deploy resources with `terraform apply -tf-vars=dev.tfvars`
- Add the cluster to your kubeconfig: `aws eks --region $AWS_REGION update-kubeconfig --name aws001-preprod-observability-eks`

#### Map the FluentBit Role as a Backend Role to OpenSearch

- Map the FluentBit Role as a Backend Role to OpenSearch:
  - Replace "\<Your AWS Account ID\>", "\<Your Username\>", and "\<Your Password\>" with your own values.

```
export FLUENTBIT_ROLE="arn:aws:iam::<Your AWS Account ID>:role/aws001-preprod-observability-eks-aws-for-fluent-bit-sa-irsa"
export ES_ENDPOINT=$(aws opensearch describe-domain --domain-name opensearch --output text --query "DomainStatus.Endpoint")
export ES_DOMAIN_USER="<Your Username>"
export ES_DOMAIN_PASSWORD='<Your Password>'

curl -sS -u "${ES_DOMAIN_USER}:${ES_DOMAIN_PASSWORD}" \
    -X PATCH \
    https://${ES_ENDPOINT}/_opendistro/_security/api/rolesmapping/all_access?pretty \
    -H 'Content-Type: application/json' \
    -d'
[
  {
    "op": "add", "path": "/backend_roles", "value": ["'${FLUENTBIT_ROLE}'"]
  }
]
'
```

#### Deploy the Example Workload to Generate Logs and Metrics

- Install ArgoCD https://argo-cd.readthedocs.io/en/stable/cli_installation/
- Navigate to this [quickstart](https://aws-quickstart.github.io/ssp-amazon-eks/getting-started/#deploy-workloads-with-argocd) Follow the instructions under __Deploy workloads with ArgoCD__ to deploy a sample workload.

#### Set up an Index Pattern in OpenSearch to Explore Log Data

- Log into console, navigate to OpenSearch console, click on the "opensearch" domain and click on the link under __OpenSearch Dashboards URL__ to access the Kibana dashboard.
- Log into the OpenSearch dashboard with the credentials set in `dev.tfvars`
- From the OpenSearch Dashboards Welcome screen select __Explore on my own__
- On _Select your tenant_ screen, select Private and click __Confirm__
- On the next screen click on the _OpenSearch Dashboards_ tile
- Click __Add your data__
- Click __Create index Pattern__
- Add __\*fluent-bit\*__ as the Index pattern and click __Next step__
- Select __@timestamp__ as the Time filter field name and close the Configuration window by clicking on __Create index pattern__
- Select __Discover__ from the left panel and start exploring the logs

## Cleanup

 - Run `terraform destroy -var-file=dev.tfvars` to remove all resources except for your Amazon Managed Grafana workspace.
 - Delete your Amazon Managed Grafana workspace through the AWS console.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.73.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | >= 1.13.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.73.0 |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 1.18.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-eks-accelerator-for-terraform"></a> [aws-eks-accelerator-for-terraform](#module\_aws-eks-accelerator-for-terraform) | ../.. | n/a |
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | v3.11.3 |
| <a name="module_kubernetes-addons"></a> [kubernetes-addons](#module\_kubernetes-addons) | ../../modules/kubernetes-addons | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_elasticsearch_domain.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain) | resource |
| [aws_elasticsearch_domain_policy.opensearch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain_policy) | resource |
| [aws_iam_policy.fluentbit-opensearch-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [grafana_data_source.prometheus](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/data_source) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.fluentbit-opensearch-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | volume size in gigabytes | `number` | n/a | yes |
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | Api key for authorizing the Grafana provider to make changes to Amazon Managed Grafana | `string` | n/a | yes |
| <a name="input_grafana_endpoint"></a> [grafana\_endpoint](#input\_grafana\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_opensearch_dashboard_pw"></a> [opensearch\_dashboard\_pw](#input\_opensearch\_dashboard\_pw) | n/a | `string` | n/a | yes |
| <a name="input_opensearch_dashboard_user"></a> [opensearch\_dashboard\_user](#input\_opensearch\_dashboard\_user) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
