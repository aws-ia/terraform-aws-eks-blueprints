# Observability pattern with EKS Cluster, Amazon Managed Prometheus, Amazon Managed Grafana and Amazon Open Search Service

This example demonstrates how to use the Amazon EKS Blueprints for Terraform to deploy a new Amazon EKS Cluster with Prometheus server for metrics and AWS Fluent Bit for logs. Outside of the EKS cluster, it also provisions Amazon Managed Prometheus, Amazon OpenSearch Service within a VPC, and integrates Amazon Managed Prometheus with Amazon Managed Grafana. It also deploys a bastion host to let us test OpenSearch. Lastly, it includes a sample workload, provisioned with ArgoCD, to generate logs and metrics.

Prometheus server collects these metrics and writes to remote Amazon Managed Prometheus endpoint via `remote write` config property. Amazon Managed Grafana is used to visualize the metrics in dashboards by leveraging Amazon Managed Prometheus workspace as a data source.

AWS FluentBit Addon is configured to collect the container logs from EKS Cluster nodes and write to Amazon Open Search service.

**NOTE**

For the sake of simplicity in this example, we store sensitive information and credentials in `dev.tfvars`. This should not be done in a production environment. Instead, use an external secret store such as AWS Secrets Manager and use the [aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) data source to retrieve them.

Checkout additional observability patterns at the [AWS Observability Accelerator for Terraform](https://github.com/aws-observability/terraform-aws-observability-accelerator)

## How to Deploy

### Prerequisites

- Terraform
- An AWS Account
- kubectl
- awscli
- jq
- An existing Amazon Managed Grafana workspace.
  - As of this writing (February 3, 2022), the AWS Terraform Provider does not support Amazon Managed Grafana, so it must be manually created beforehand. Follow the instructions [here](https://docs.aws.amazon.com/grafana/latest/userguide/getting-started-with-AMG.html) to deploy an Amazon Managed Grafana workspace.

#### Generate a Grafana API Key

- Give admin access to the SSO user you set up when creating the Amazon Managed Grafana Workspace:
  - In the AWS Console, navigate to Amazon Grafana. In the left navigation bar, click **All workspaces**, then click on the workspace name you are using for this example.
  - Under **Authentication** within **AWS Single Sign-On (SSO)**, click **Configure users and user groups**
  - Check the box next to the SSO user you created and click **Make admin**
- Navigate back to the Grafana Dashboard. If you don't see the gear icon in the left navigation bar, log out and log back in.
- Click on the gear icon, then click on the **API keys** tab.
- Click **Add API key**, fill in the _Key name_ field and select _Admin_ as the Role.
- Copy your API key into `dev.tfvars` under `grafana_api_key`

### Deployment Steps

- Clone this repository:

```
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

- Initialize a working directory

```
terraform init
```

- Fill-in the values for the variables in `dev.tfvars`
  - The password for OpenSearch must be a minimum of eight characters with at least one uppercase, one lowercase, one digit, and one special character.
  - If the `AWSServiceRoleForAmazonElasticsearchService` role already exists in your account, set `create_iam_service_linked_role = false`.
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

`terraform apply` will provision a new EKS cluster with Fluent Bit, Prometheus, and a sample workload. It will also provision Amazon Managed Prometheus to ingest metrics from Prometheus, an Amazon OpenSearch service domain for ingesting logs from Fluent Bit, and a bastion host so we can test OpenSearch.

---

**NOTE**

This example automatically generates a key-pair for you and saves the private key to your current directory to make the next steps simpler. In production workloads, it is best practice to use your own key-pair instead of using Terraform to generate one for you.

---

#### Verify that the Resources Deployed Successfully

- Check that the bastion host we use to test OpenSearch is running in the EC2 Console.

- Check that the status of OpenSearch is green:
  Navigate to Amazon OpenSearch in the AWS Console and select the **opensearch** domain. Verify that _Cluster Health_ under _General Information_ lists Green.

- Verify that Amazon Managed Prometheus workspace was created successfully:

  - Check the status of Amazon Managed Prometheus workspace through the AWS console.

- Check that Prometheus Server is healthy:

  - The following command gets the pod that is running the Prometheus server and sets up port fowarding to http://localhost:8080

  ```
  kubectl port-forward $(kubectl get pods --namespace=prometheus --selector='component=server' --output=name) 8080:9090 -n prometheus
  ```

  - Navigate to http://localhost:8080 and confirm that the dashboard webpage loads.
  - Press `CTRL+C` to stop port forwarding.

- To check that Fluent Bit is working:

  - Fluent Bit is provisioned properly if you see the option to add an index pattern while following the steps for the section below named **Set up an Index Pattern in OpenSearch to Explore Log Data**

- Check that the sample workload is running:
  - Run the command below, then navigate to http://localhost:4040 and confirm the webpage loads.

```
kubectl port-forward svc/guestbook-ui -n team-riker 4040:80
```

#### Map the Fluent Bit Role as a Backend Role in OpenSearch

OpenSearch roles are the core method for controlling access within your OpenSearch cluster. Backend roles are a method for mapping an external identity (such as an IAM role) to an OpenSearch role. Mapping the external identity to an OpenSearch role allows that identity to gain the permissions of that role. Here we map the Fluent Bit IAM role as a backend role to OpenSearch's _all_access_ role. This gives the Fluent Bit IAM role permission to send logs to OpenSearch. Read more about OpenSearch roles [here](https://opensearch.org/docs/latest/security-plugin/access-control/users-roles/).

- In a different terminal window, navigate back to the example directory and establish and SSH tunnel from https://localhost:9200 to your OpenSearch Service domain through the bastion host:
  - Because we provisioned OpenSearch within our VPC, we connect to a bastion host with an SSH tunnel to test and access our OpenSearch endpoints. Refer to the [Amazon OpenSearch Developer Guide](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/vpc.html#vpc-test) for more information.
  - For connecting with additional access control using Amazon Cognito, see this [page](https://aws.amazon.com/premiumsupport/knowledge-center/opensearch-outside-vpc-ssh/).

```
export PRIVATE_KEY_FILE=bastion_host_private_key.pem
export BASTION_HOST_IP=$(terraform output -raw bastion_host_public_ip)
export OS_VPC_ENDPOINT=$(terraform output -raw opensearch_vpc_endpoint)
ssh -i $PRIVATE_KEY_FILE ec2-user@$BASTION_HOST_IP -N -L "9200:${OS_VPC_ENDPOINT}:443"
```

- Back in your first terminal window:

```
export BASTION_HOST_IP=$(terraform output -raw bastion_host_public_ip)
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

#### Set up an Index Pattern in OpenSearch Dashboards to Explore Log Data

You must set up an index pattern before you can explore data in the OpenSearch Dashboards. An index pattern selects which data to use. Read more about index patterns [here](https://www.elastic.co/guide/en/kibana/current/index-patterns.html).

- Follow the steps outlined in **Configure the SOCKS proxy** and **Create the SSH tunnel** sections of this [Knowledge Center](https://aws.amazon.com/premiumsupport/knowledge-center/opensearch-outside-vpc-ssh/) article to establish a SOCKS5 tunnel from localhost to OpenSearch via the bastion host.
- Log into the AWS console, navigate to Amazon OpenSearch Service, click on the "opensearch" domain and click on the link under **OpenSearch Dashboards URL** to access the OpenSearch Dashboards.
- Log into the OpenSearch Dashboards with the credentials you set in `dev.tfvars`
- From the OpenSearch Dashboards Welcome screen select **Explore on my own**
- On _Select your tenant_ screen, select Private and click **Confirm**
- On the next screen click on the _OpenSearch Dashboards_ tile
- Click **Add your data**
- Click **Create index Pattern**
- Add **\*fluent-bit\*** as the Index pattern and click **Next step**
- Select **@timestamp** as the Time filter field name and close the Configuration window by clicking on **Create index pattern**
- Select **Discover** from the left panel and start exploring the logs

## Cleanup

- Run `terraform destroy -var-file=dev.tfvars` to remove all resources except for your Amazon Managed Grafana workspace.
- Delete your Amazon Managed Grafana workspace through the AWS console.
- Delete the private key file: `bastion_host_private_key.pem`.

## Troubleshooting

- When running `terraform apply` or `terraform destroy`, the process will sometimes time-out. If that happens, run the command again and the operation will continue where it left off.
- If your connection times out when trying to establish an SSH tunnel with the bastion host, check that you are disconnected from any VPNs.
