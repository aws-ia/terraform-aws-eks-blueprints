# EKS Cluster with External DNS

This example demonstrates how to leverage External DNS, in concert with Ingress Nginx and AWS Load Balancer Controller. It demonstrates how you can easily provision multiple services with secure, custom domains which sit behind a single load balancer.

The pattern deploys the sample workloads that reside in the [EKS Blueprints Workloads repo](https://github.com/aws-samples/eks-blueprints-workloads) via ArgoCD. The [configuration for `team-riker`](https://github.com/aws-samples/eks-blueprints-workloads/tree/main/teams/team-riker/dev/templates) will deploy an Ingress resource which contains configuration for both path-based routing and the custom hostname for the `team-riker` service. Once the pattern is deployed, you will be able to reach the `team-riker` sample workload via a custom domain you supply.

## How to Deploy

### Prerequisites:

#### Tools

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

#### AWS Resources

This example requires the following AWS resources:

- A Route53 Hosted Zone for a domain that you own.
- A SSL/TLS certificate for your domain stored in AWS Certificate Manager (ACM).

For information on Route53 Hosted Zones, [see Route53 documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html). For instructions on requesting a SSL/TLS certificate for your domain, see [ACM docs](https://docs.aws.amazon.com/acm/latest/userguide/gs.html).

### Deployment Steps

#### Step 1: Clone the repo

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step 2: Terraform INIT

Initialize a working directory with configuration files

```sh
cd examples/eks-cluster-with-external-dns
terraform init
```

#### Step 3: Replace placeholder values in terraform.tfvars

Both values in `terraform.tfvars` must be updated.

- `eks_cluster_domain` - the domain for your cluster. Value is used to look up a Route53 Hosted Zone that you own. DNS records created by `ExternalDNS` will be created in this Hosted Zone.
- `acm_certificate_domain` - the domain for a certificate in ACM that will be leveraged by `Ingress Nginx`. Value is used to look up an ACM certificate that will be used to terminate HTTPS connections. This value should likely be a wildcard cert for your `eks_cluster_domain`.

```
eks_cluster_domain      = "example.com"
acm_certificate_domain  = "*.example.com"
```

#### Step 3: Terraform PLAN

Verify the resources created by this execution

```sh
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 4: Terraform APPLY

**Deploy the pattern**

```sh
terraform apply
```

Enter `yes` to apply.

#### Step 5: Update local kubeconfig

`~/.kube/config` file gets updated with cluster details and certificate from the below command.

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step 7: List all the pods running in `kube-system` namespace

    $ kubectl get pods -n kube-system

#### Step 8: Verify the Ingress resource was created for Team Riker

    $ kubectl get ingress -n team-riker

Navigate to the HOST url which should be `guestbook-ui.<eks_cluster_domain>`. At this point, you should be able to view the `guestbook-ui` application in the browser at the HOST url.

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```
