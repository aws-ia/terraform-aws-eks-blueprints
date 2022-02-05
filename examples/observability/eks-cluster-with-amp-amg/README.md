# EKS Cluster with Amazon Managed Grafana and Amazon OpenSearch Service

This example demonstrates how to use the AWS EKS Accelerator for Terraform to deploy a new Amazon EKS Cluster with Prometheus for metrics and Fluent Bit for logging. It also provisions Amazon Managed Prometheus (AMP), Amazon OpenSearch Service within a VPC, and integrates AMP with Amazon Managed Grafana (AMG). It also deploys an EC2 instance to let us test OpenSearch. Lastly, it includes a sample workload, provisioned with ArgoCD, to generate logs and metrics.

Prometheus sends application metrics to AMP, and AMG ingests data from AMP. Fluent Bit sends logs to Amazon OpenSearch Service.

---
**NOTE**

For the sake of simplicity in this example, we store sensitive information and credentials in `dev.tfvars`. This should not be done in a production environment. Instead, use an external secret store such as AWS Secrets Manager and use the [aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) data source to retrieve them.

---

## How to Deploy

### Prerequisites
- An existing Amazon Managed Grafana (AMG) Workspace.
  - As of this writing (February 3, 2022), the AWS Terraform Provider does not support Amazon Managed Grafana, so it must be manually created beforehand. Instructions [here](https://docs.aws.amazon.com/grafana/latest/userguide/getting-started-with-AMG.html).

#### Generate a Grafana API Key
- Give admin access to the SSO user you set up when creating the AMG Workspace:
  - In the AWS Console, navigate to Amazon Grafana. In the left navigation bar, click __All workspaces__, then click on the workspace name you are using for this example.
  - Under __Authentication__ within __AWS Single Sign-On (SSO)__, click __Configure users and user groups__
  - Check the box next to the SSO user you created and click __Make admin__
- Navigate back to the Grafana Dashboard. If you don't see the gear icon in the left navigation bar, log out and log back in.
- Click on the gear icon, then click on the __API keys__ tab.
- Click __Add API key__, fill in the _Key name_ field and select _Admin_ as the Role.
- Copy your API key into `dev.tfvars` under `grafana_api_key` 

### Deployment Steps
- Clone this repository: 
```
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```
- Initialize a working directory
```
cd examples/observability/eks-cluster-with-observability
terraform init
```
- Fill-in the values for the variables in `dev.tfvars`
  - The password for OpenSearch must be a minimum of eight characters with at least one uppercase, one lowercase, one digit, and one special character.
- Verify the resources created by this execution:
```
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform validate
terraform plan -tf-vars=dev.tfvars
```
- Deploy resources:
 ```
 terraform apply -tf-vars=dev.tfvars
 ```
- Add the cluster to your kubeconfig: 
```
aws eks --region $AWS_REGION update-kubeconfig --name aws001-preprod-observability-eks
```

`terraform apply` will provision a new EKS cluster with Fluent Bit, Prometheus, and a sample workload. It will also provision Amazon Managed Prometheus to ingest metrics from Prometheus, an Amazon OpenSearch service domain for ingesting logs from Fluent Bit, and an EC2 instance so we can test OpenSearch.

#### Verify that the Resources Deployed Sucessfully

- Check that the EC2 Instance we use to test OpenSearch is running in the EC2 Console.

- Check that the status of OpenSearch is green:
Navigate to Amazon OpenSearch in the AWS Console and select the __opensearch__ domain. Verify that *Cluster Health* under *General Information* lists Green.

- Check that Amazon Managed Prometheus is healthy:
  - Check the status of Amazon Managed Prometheus workspace through the AWS console.

- Check that Prometheus is healthy:
  - The following command gets the pod that is running the Prometheus server and sets up port fowarding to http://localhost:8080
  ``` 
  kubectl port-forward $(kubectl get pods --namespace=prometheus --selector='component=server' --output=name) 8080:9090 -n prometheus
  ```
  - Navigate to http://localhost:8080 and confirm that the dashboard webpage loads.
  - Press `CTRL+C` to stop port forwarding.

- To check that Fluent Bit is working:
  - Fluent Bit is provisioned properly if you see the option to add an index pattern while following the steps for the section below named __Set up an Index Pattern in OpenSearch to Explore Log Data__

- Check that the sample workload is running:
  - Run the command below, then navigate to http://localhost:4040 and confirm the webpage loads.
```
kubectl port-forward svc/guestbook-ui -n team-riker 4040:80
```

#### Map the Fluent Bit Role as a Backend Role in OpenSearch
OpenSearch roles are the core method for controlling access to your OpenSearch cluster. Backend roles are a way to map an external identity to an OpenSearch role. In this case we map the Fluent Bit IAM role as a backend role to OpenSearch's *all_access* role so Fluent Bit can send logs to OpenSearch.

Because we provisioned OpenSearch within our VPC, we use an EC2 instance with port forwarding to test and access our OpenSearch endpoints. Refer to the [Amazon OpenSearch Developer Guide](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/vpc.html#vpc-test) for more information.

- In a different terminal window, navigate back to the example directory and forward requests from https://localhost:9200 to your OpenSearch Service domain through the EC2 instance:

---
**NOTE**

This example automatically generates a key-pair for you and saves the private key to your current directory to make the next steps simpler. In production workloads, it is best practice to use your own key-pair instead of using Terraform to generate one for you.

---
```
export PRIVATE_KEY_FILE=ec2_instance_private_key.pem
export EC2_IP=$(terraform output -raw ec2_public_ip)
export OS_VPC_ENDPOINT=$(terraform output -raw opensearch_vpc_endpoint)
ssh -i $PRIVATE_KEY_FILE ec2-user@$EC2_IP -N -L "9200:${OS_VPC_ENDPOINT}:443"
```
- Back in your first terminal window:
```
export EC2_IP=$(terraform output -raw ec2_public_ip)
export OS_DOMAIN_USER=$(terraform output -raw opensearch_user)
export OS_DOMAIN_PASSWORD=$(terraform output -raw opensearch_pw)
export FLUENTBIT_ROLE="arn:aws:iam::$(aws sts get-caller-identity | jq -r '.Account'):role/aws001-preprod-observability-eks-aws-for-fluent-bit-sa-irsa"

curl  --insecure -sS -u "${OS_DOMAIN_USER}:${OS_DOMAIN_PASSWORD}" \
    -X PATCH \
    https://localhost:9200/_opendistro/_security/api/rolesmapping/all_access?pretty \
    -H 'Content-Type: application/json' \
    -d'
[
  {
    "op": "add", "path": "/backend_roles", "value": ["'${FLUENTBIT_ROLE}'"]
  }
]
'
```

#### Set up an Index Pattern in OpenSearch to Explore Log Data

You must set up an index pattern before you can explore data in the OpenSearch Dashboard. An index pattern selects which data to use. Read more about index patterns [here](https://www.elastic.co/guide/en/kibana/current/index-patterns.html).

- Log into the AWS console, navigate to Amazon OpenSearch Service, click on the "opensearch" domain and click on the link under __OpenSearch Dashboards URL__ to access the OpenSearch dashboard.
- Log into the OpenSearch dashboard with the credentials you set in `dev.tfvars`
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
 - Delete the private key file: `ec2_instance_private_key.pem`.

## Troubleshooting
When running `terraform apply` or `terraform destroy`, the process will sometimes time-out. If that happens, run the command again and the operation will continue where it left off.

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
| <a name="provider_local"></a> [local](#provider\_local) | 2.1.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.1.0 |

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
| [aws_elasticsearch_domain_policy.opensearch_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain_policy) | resource |
| [aws_iam_policy.fluentbit-opensearch-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_service_linked_role.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_instance.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.ec2_instance_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route_table.opensearch_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_security_group.opensearch_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [grafana_data_source.prometheus](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/data_source) | resource |
| [local_file.private_key_pem_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.ec2_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_elasticsearch_domain.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elasticsearch_domain) | data source |
| [aws_iam_policy_document.fluentbit-opensearch-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.opensearch_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_grafana_api_key"></a> [grafana\_api\_key](#input\_grafana\_api\_key) | Api key for authorizing the Grafana provider to make changes to Amazon Managed Grafana | `string` | n/a | yes |
| <a name="input_grafana_endpoint"></a> [grafana\_endpoint](#input\_grafana\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_local_computer_ip"></a> [local\_computer\_ip](#input\_local\_computer\_ip) | IP Address of the computer you are running and testing this example from | `string` | n/a | yes |
| <a name="input_opensearch_dashboard_pw"></a> [opensearch\_dashboard\_pw](#input\_opensearch\_dashboard\_pw) | n/a | `string` | n/a | yes |
| <a name="input_opensearch_dashboard_user"></a> [opensearch\_dashboard\_user](#input\_opensearch\_dashboard\_user) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_public_ip"></a> [ec2\_public\_ip](#output\_ec2\_public\_ip) | n/a |
| <a name="output_opensearch_pw"></a> [opensearch\_pw](#output\_opensearch\_pw) | Amazon OpenSearch Service Domain password |
| <a name="output_opensearch_user"></a> [opensearch\_user](#output\_opensearch\_user) | Amazon OpenSearch Service Domain username |
| <a name="output_opensearch_vpc_endpoint"></a> [opensearch\_vpc\_endpoint](#output\_opensearch\_vpc\_endpoint) | Amazon OpenSearch Service Domain-specific endpoint |