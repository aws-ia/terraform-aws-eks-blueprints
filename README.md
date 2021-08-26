# aws-eks-accelerator-for-terraform

# Main Purpose
This project provides a framework for deploying best-practice multi-tenant [EKS Clusters](https://aws.amazon.com/eks), provisioned via [Hashicorp Terraform](https://www.terraform.io/) and [Helm charts](https://helm.sh/) on [AWS](https://aws.amazon.com/).

# Overview
The AWS EKS Accelerator for Terraform module helps you to provision [EKS Clusters](https://aws.amazon.com/eks), [managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) with [on-demand](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html) and [spot instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html), [Fargate profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html), and all the necessary plugins/add-ons for a production-ready EKS cluster. The [Terraform Helm provider](https://github.com/hashicorp/terraform-provider-helm) is used to deploy common Kubernetes add-ons with publicly available [Helm Charts](https://artifacthub.io/). This project leverages the official [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module to create EKS Clusters

This framework helps you to design and create EKS clusters for different environments in various AWS accounts across multiple regions with a **unique Terraform configuration and state file** per EKS cluster.

* The top-level `live` folder contains the configuration for each cluster. Each folder under `live/<region>/application` represents an EKS cluster environment(e.g., dev, test, load etc.).
This folder contains `backend.conf` and `base.tfvars`, used to create a unique Terraform state for each cluster environment.
Terraform backend configuration can be updated in `backend.conf` and cluster common configuration variables in `base.tfvars`

* `vpc.tf` contains all VPC resources
* `eks.tf` contains all EKS Cluster resources
* `helm.tf` contains resources to invoke helm modules under helm folder
* `modules` folder contains all the AWS resource modules
* `helm` folder contains all the Helm chart modules
* `examples` folder contains sample template files with `base.tfvars` which can be used to deploy clusters with multiple add-on options

# EKS Cluster Deployment Options
This module provisions the following EKS resources

## EKS Cluster Networking Resources

1. [VPC and Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html)
    - [Public Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
    - [Private Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
2. [VPC endpoints for fully private EKS Clusters](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)
3. [NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
4. [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)

## EKS Cluster resources

1. [EKS Cluster with multiple networking options](https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/)
   1. [Fully Private EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)
   2. [Public + Private EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html)
   3. [Public Cluster](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html))
2. [EKS Addons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) -
   - [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
   - [Kube-Proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html)
   - [VPC-CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
3. [Managed Node Groups with On-Demand](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) - AWS Managed Node Groups with On-Demand Instances
4. [Managed Node Groups with Spot](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) - AWS Managed Node Groups with Spot Instances
5. [Fargate Profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html) - AWS Fargate Profiles
6. [Launch Templates with SSM agent](https://aws.amazon.com/blogs/containers/introducing-launch-template-and-custom-ami-support-in-amazon-eks-managed-node-groups/) - Deployed through launch templates to Managed Node Groups
7. [Bottlerocket OS](https://github.com/bottlerocket-os/bottlerocket) - Managed Node Groups with Bottlerocket OS and Launch Templates
8. [RBAC](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html) for Developers and Administrators with IAM roles
9. [Amazon Managed Service for Prometheus (AMP)](https://aws.amazon.com/prometheus/) - AMP makes it easy to monitor containerized applications at scale
10. [Self-managed Node Group with Windows support](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html) - Ability to create a self-managed node group for Linux or Windows workloads. See [Windows](./examples/windows-support) and [Linux](./examples/self-managed-linux-nodegroup) examples.

## Kubernetes Addons using [Helm Charts](https://helm.sh/docs/topics/charts/)

1. [Metrics Server](https://github.com/Kubernetes-sigs/metrics-server)
2. [Cluster Autoscaler](https://github.com/Kubernetes/autoscaler)
3. [AWS LB Ingress Controller](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
4. [Traefik Ingress Controller](https://doc.traefik.io/traefik/providers/Kubernetes-ingress/)
5. [FluentBit to CloudWatch for Managed Node groups](https://github.com/aws/aws-for-fluent-bit)
6. [FluentBit to CloudWatch for Fargate Containers](https://aws.amazon.com/blogs/containers/fluent-bit-for-amazon-eks-on-aws-fargate-is-here/)
7. [Agones](https://agones.dev/site/) - Host, Run and Scale dedicated game servers on Kubernetes
8. [Prometheus](https://github.com/prometheus-community/helm-charts)
9. [Kube-state-metrics](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics)
10. [Alert-manager](https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager)
11. [Prometheus-node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter)
12. [Prometheus-pushgateway](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway)
13. [OpenTelemetry](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector)

# Helm Charts Modules
Helm Chart Module within this framework allows you to deploy Kubernetes  apps using Terraform helm chart provider with **enabled** conditional parameter in `base.tfvars`.

You can find the README for each Helm module with instructions on how to download the images from Docker Hub or third-party repos and upload it to your private ECR repo.

For example, [ALB Ingress Controller](helm/lb_ingress_controller/README.md) for AWS LB Ingress Controller module.

## Ingress Controller Modules
Ingress is an API object that defines the traffic routing rules (e.g., load balancing, SSL termination, path-based routing, protocol), whereas the Ingress Controller is the component responsible for fulfilling those requests.

* [ALB Ingress Controller](helm/lb_ingress_controller/README.md) can be deployed by specifying the following line in `base.tfvars` file.
**AWS ALB Ingress controller** triggers the creation of an ALB and the necessary supporting AWS resources whenever a Kubernetes  user declares an Ingress resource in the cluster.
[ALB Docs](https://Kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)

    `alb_ingress_controller_enable = true`

* [Traefik Ingress Controller](helm/traefik_ingress/README.md) can be deployed by specifying the following line in `base.tfvars` file.
**Traefik is an open source Kubernetes  Ingress Controller**. The Traefik Kubernetes  Ingress provider is a Kubernetes  Ingress controller; that is to say, it manages access to cluster services by supporting the Ingress specification. For more details about [Traefik can be found here](https://doc.traefik.io/traefik/providers/Kubernetes-ingress/)

    `traefik_ingress_controller_enable = true`

## Autoscaling Modules
**Cluster Autoscaler** and **Metric Server** Helm Modules gets deployed by default with the EKS Cluster.

* [Cluster Autoscaler](helm/cluster_autoscaler/README.md) can be deployed by specifying the following line in `base.tfvars` file.
The Kubernetes  Cluster Autoscaler automatically adjusts the number of nodes in your cluster when pods fail or are rescheduled onto other nodes. It's not deployed by default in EKS clusters.
That is, the AWS Cloud Provider implementation within the Kubernetes  Cluster Autoscaler controls the **DesiredReplicas** field of Amazon EC2 Auto Scaling groups.
The Cluster Autoscaler is typically installed as a **Deployment** in your cluster. It uses leader election to ensure high availability, but scaling is one done by a single replica at a time.

    `cluster_autoscaler_enable = true`

* [Metrics Server](helm/metrics_server/README.md) can be deployed by specifying the following line in `base.tfvars` file.
The Kubernetes  Metrics Server, used to gather metrics such as cluster CPU and memory usage over time, is not deployed by default in EKS clusters.

    `metrics_server_enable = true`

## Logging and Monitoring
**FluentBit** is an open source Log Processor and Forwarder which allows you to collect any data like metrics and logs from different sources, enrich them with filters and send them to multiple destinations.

* [aws-for-fluent-bit](helm/aws-for-fluent-bit/README.md) can be deployed by specifying the following line in `base.tfvars` file.
AWS provides a Fluent Bit image with plugins for both CloudWatch Logs and Kinesis Data Firehose. The AWS for Fluent Bit image is available on the Amazon ECR Public Gallery.
For more details, see [aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit) on the Amazon ECR Public Gallery.

    `aws-for-fluent-bit_enable = true`

* [fargate-fluentbit](helm/fargate_fluentbit) can be deployed by specifying the following line in `base.tfvars` file.
This module ships the Fargate Container logs to CloudWatch

    `fargate_fluent_bit_enable = true`

## Bottlerocket OS

[Bottlerocket](https://aws.amazon.com/bottlerocket/) is an open source operating system specifically designed for running containers. Bottlerocket build system is based on Rust. It's a container host OS and doesn't have additional software's or package managers other than what is needed for running containers hence its very light weight and secure. Container optimized operating systems are ideal when you need to run applications in Kubernetes  with minimal setup and do not want to worry about security or updates, or want OS support from  cloud provider. Container operating systems does updates transactionally.

Bottlerocket has two containers runtimes running. Control container **on** by default used for AWS Systems manager and remote API access. Admin container **off** by default for deep debugging and exploration.

Bottlerocket [Launch templates userdata](modules/launch-templates/templates/bottlerocket-userdata.sh.tpl) uses the TOML format with Key-value pairs. Remote API access API via SSM agent. You can launch trouble shooting container via user data `[settings.host-containers.admin] enabled = true`.

### Features
* [Secure](https://github.com/bottlerocket-os/bottlerocket/blob/develop/SECURITY_FEATURES.md) - Opinionated, specialized and highly secured
* **Flexible** - Multi cloud and multi orchestrator
* **Transactional** -  Image based upgraded and rollbacks
* **Isolated** - Separate container Runtimes

### Updates
Bottlerocket can be updated automatically via Kubernetes  Operator

```shell script
    kubectl apply -f Bottlerocket_k8s.csv.yaml
    kubectl get ClusterServiceVersion Bottlerocket_k8s | jq.'status'
```

# How to Deploy

## Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [wget](https://www.gnu.org/software/wget/)
5. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
6. [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) - currently needed to enable Windows support

## Deployment Steps
The following steps walks you through the deployment of example [DEV cluster](live/preprod/eu-west-1/application/dev/base.tfvars) configuration. This config deploys a private EKS cluster with public and private subnets.

Two managed worker nodes with On-demand and Spot instances along with one fargate profile for default namespace placed in private subnets. ALB placed in Public subnets created by LB Ingress controller.

It also deploys few kubernetes apps i.e., LB Ingress Controller, Metrics Server, Cluster Autoscaler, aws-for-fluent-bit CloudWatch logging for Managed node groups, FluentBit CloudWatch logging for Fargate etc.

### Provision VPC (optional) and EKS cluster with selected Helm modules

#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step2: Update base.tfvars file

Update `~/aws-eks-accelerator-for-terraform/live/preprod/eu-west-1/application/dev/base.tfvars` file with the instructions specified in the file (OR use the default values). You can choose to use an existing VPC ID and Subnet IDs or create a new VPC and subnets by providing CIDR ranges in `base.tfvars` file

####  Step3: Update Terraform backend config file

Update `~/aws-eks-accelerator-for-terraform/live/preprod/eu-west-1/application/dev/backend.conf` with your local directory path. [state.tf](state.tf) file contains backend config.

Local terraform state backend config variables

```hcl-terraform
    path = "local_tf_state/ekscluster/preprod/application/dev/terraform-main.tfstate"
```

It's highly recommended to use remote state in S3 instead of using local backend. The following variables needs filling for S3 backend.

```hcl-terraform
    bucket = "<s3 bucket name>"
    region = "<aws region>"
    key    = "ekscluster/preprod/application/dev/terraform-main.tfstate"
```

#### Step4: Assume IAM role before creating a EKS cluster.
This role will become the Kubernetes  Admin by default.

```shell script
aws-mfa --assume-role  arn:aws:iam::<ACCOUNTID>:role/<IAMROLE>
```

#### Step5: Run Terraform INIT
to initialize a working directory with configuration files

```shell script
terraform init -backend-config /live/preprod/eu-west-1/application/dev/backend.conf
```


#### Step6: Run Terraform PLAN
to verify the resources created by this execution

```shell script
terraform plan -var-file /live/preprod/eu-west-1/application/dev/base.tfvars
```

#### Step7: Finally, Terraform APPLY
to create resources

```shell script
terraform apply -var-file /live/preprod/eu-west-1/application/dev/base.tfvars
```

**Alternatively you can use Makefile to deploy by skipping Step5, Step6 and Step7**

### Deploy EKS Cluster using [Makefile](Makefile)

#### Executing Terraform PLAN
    $ make tf-plan-eks env=<env> region=<region> account=<account> subenv=<subenv>
    e.g.,
    $ make tf-plan-eks env=preprod region=eu-west-1 account=application subenv=dev

#### Executing Terraform APPLY
    $ make tf-apply-eks env=<env> region=<region> account=<account> subenv=<subenv>
    e.g.,
    $ make tf-apply-eks env=preprod region=eu-west-1 account=application subenv=dev

#### Executing Terraform DESTROY
    $ make tf-destroy-eks env=<env> region=<region> account=<account> subenv=<subenv>
    e.g.,
    make tf-destroy-eks env=preprod region=eu-west-1 account=application subenv=dev

### Configure kubectl and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step8: Run update-kubeconfig command.

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region eu-west-1 update-kubeconfig --name <cluster-name>

#### Step9: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step10: List all the pods running in kube-system namespace

    $ kubectl get pods -n kube-system

## Deploying example templates
The `examples` folder contains multiple cluster templates with pre-populated `.tfvars` which can be used as a quick start. Reuse the templates from `examples` and follow the above Deployment steps as mentioned above.

# EKS Addons update
Amazon EKS doesn't modify any of your Kubernetes  add-ons when you update a cluster to newer versions.
It's important to upgrade EKS Addons [Amazon VPC CNI](https://github.com/aws/amazon-vpc-cni-k8s), [DNS (CoreDNS)](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html) and [KubeProxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html) for each EKS release.

This [README](eks_cluster_addons_upgrade/README.md) guides you to update the EKS Cluster abd the addons for newer versions that matches with your EKS cluster version

Updating a EKS cluster instructions can be found in [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html).

# Important note
This module tested only with **Kubernetes v1.20 version**. Helm Charts addon modules aligned with k8s v1.20. If you are looking to use this code to deploy different versions of Kubernetes  then ensure Helm charts and docker images aligned with k8s version.

The `Kubernetes _version="1.20"` is the required variable in `base.tfvars`. Kubernetes  is evolving a lot, and each major version includes new features, fixes, or changes.

Always check [Kubernetes Release Notes](https://Kubernetes.io/docs/setup/release/notes/) before updating the major version. You also need to ensure your applications and Helm addons updated,
or workloads could fail after the upgrade is complete. For action, you may need to take before upgrading, see the steps in the EKS documentation.

# Notes:
If you are using an existing VPC then you may need to ensure that the following tags added to the VPC and subnet resources

Add Tags to **VPC**

```hcl-terraform
    Key = Kubernetes .io/cluster/${local.cluster_name} Value = Shared
```

Add Tags to **Public Subnets tagging** requirement

```hcl-terraform
      public_subnet_tags = {
        "Kubernetes .io/cluster/${local.cluster_name}" = "shared"
        "Kubernetes .io/role/elb"                      = "1"
      }
```

Add Tags to **Private Subnets tagging** requirement

```hcl-terraform
      private_subnet_tags = {
        "Kubernetes .io/cluster/${local.cluster_name}" = "shared"
        "Kubernetes .io/role/internal-elb"             = "1"
      }
```

For fully Private EKS clusters requires the following VPC endpoints to be created to communicate with AWS services. This module will create these endpoints if you choose to create VPC. If you are using an existing VPC then you may need to ensure these endpoints are created.

    com.amazonaws.region.aps-workspaces            - For AWS Managed Prometheus Workspace
    com.amazonaws.region.ssm                       - Secrets Management
    com.amazonaws.region.ec2
    com.amazonaws.region.ecr.api
    com.amazonaws.region.ecr.dkr
    com.amazonaws.region.logs                       – For CloudWatch Logs
    com.amazonaws.region.sts                        – If using AWS Fargate or IAM roles for service accounts
    com.amazonaws.region.elasticloadbalancing       – If using Application Load Balancers
    com.amazonaws.region.autoscaling                – If using Cluster Autoscaler
    com.amazonaws.region.s3                         – Creates S3 gateway


# Author
Created by [Vara Bonthu](https://github.com/vara-bonthu). Maintained by [Ulaganathan N](https://github.com/UlaganathanNamachivayam), [Jomcy Pappachen](https://github.com/jomcy-amzn)

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

