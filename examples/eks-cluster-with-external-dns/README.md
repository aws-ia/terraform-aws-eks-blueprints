# EKS Cluster with External DNS

This example demonstrates how to leverage External DNS, in concert with Ingress Nginx and AWS Load Balancer Controller. It demonstrates how you can easily provision multiple services with secure, custom domains which sit behind a single load balancer. 

The pattern deploys the sample workloads that reside in the [EKS Blueprints Workloads repo](https://github.com/aws-samples/eks-blueprints-workloads) via ArgoCD. The [configuration for `team-riker`](https://github.com/aws-samples/eks-blueprints-workloads/tree/main/teams/team-riker/dev/templates) will deploy an Ingress resource which contains configuration for both path-based routing and the custom hostname for the `team-riker` service. Once the pattern is deployed, you will be able to reach the `team-riker` sample workload via a custom domain you supply.

## How to Deploy

### Prerequisites:

#### Tools 

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply
1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

#### AWS Resources 

This example requires the following AWS resources:

* A Route53 Hosted Zone for a domain that you own. 
* A SSL/TLS certificate for your domain stored in AWS Certificate Manager (ACM). 
 
For information on Route53 Hosted Zones, [see Route53 documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html). For instructions on requesting a SSL/TLS certificate for your domain, see [ACM docs](https://docs.aws.amazon.com/acm/latest/userguide/gs.html). 

### Deployment Steps

#### Step1: Clone the repo

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step2: Terraform INIT

Initialize a working directory with configuration files

```shell script
cd examples/eks-cluster-with-external-dns
terraform init
```

#### Step3: Replace placeholder values in terraform.tfvars

Both values in `terraform.tfvars` must be updated. 

* `eks_cluster_domain` - the domain for your cluster. Value is used to look up a Route53 Hosted Zone that you own. DNS records created by `ExternalDNS` will be created in this Hosted Zone.
* `acm_certificate_domain` - the domain for a certificate in ACM that will be leveraged by `Ingress Nginx`. Value is used to look up an ACM certificate that will be used to terminate HTTPS connections. This value should likely be a wildcard cert for your `eks_cluster_domain`.  

```
eks_cluster_domain      = "example.com"
acm_certificate_domain  = "*.example.com"
```

#### Step3: Terraform PLAN
Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step4: Terraform APPLY

```shell script
terraform apply
```

Enter `yes` to apply

#### Step5: Update local kubeconfig

`~/.kube/config` file gets updated with cluster details and certificate from the below command.

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step7: List all the pods running in `kube-system` namespace

    $ kubectl get pods -n kube-system


#### Step 8: Verify the Ingress resource was created for Team Riker

    $ kubectl get ingress -n team-riker

Navigate to the HOST url which should be `guestbook-ui.<eks_cluster_domain>`. At this point, you should be able to view the `guestbook-ui` application in the browser at the HOST url.

## How to Destroy

The following command destroys the resources created by `terraform apply`

```shell script
terraform destroy --auto-approve
```

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.66.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.6.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.66.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | 3.2.0 |
| <a name="module_eks_cluster"></a> [eks\_cluster](#module\_eks\_cluster) | ../.. | n/a |
| <a name="module_kubernetes-addons"></a> [kubernetes-addons](#module\_kubernetes-addons) | ../../modules/kubernetes-addons | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.issued](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_domain"></a> [acm\_certificate\_domain](#input\_acm\_certificate\_domain) | *.example.com | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes Version | `string` | `"1.21"` | no |
| <a name="input_eks_cluster_domain"></a> [eks\_cluster\_domain](#input\_eks\_cluster\_domain) | Route53 domain for the cluster. | `string` | `"example.com"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | `"preprod"` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | `"aws001"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |

<!--- END_TF_DOCS --->
