# aws-eks-accelerator-for-terraform

# Main Purpose
This project provides a framework for deploying best-practice multi-tenant [EKS Clusters](https://aws.amazon.com/eks) with [Kubernetes Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/), provisioned via [Hashicorp Terraform](https://www.terraform.io/) and [Helm charts](https://helm.sh/) on [AWS](https://aws.amazon.com/).

# Overview
The AWS EKS Accelerator for Terraform module helps you to provision [EKS Clusters](https://aws.amazon.com/eks), [Managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) with [On-Demand](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html) and [Spot Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html), [AWS Fargate profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html), and all the necessary Kubernetes add-ons for a production-ready EKS cluster.
The [Terraform Helm provider](https://github.com/hashicorp/terraform-provider-helm) is used to deploy common Kubernetes Addons with publicly available [Helm Charts](https://artifacthub.io/). This module also provides the integration for number AWS services like Amazon Managed Prometheus, EMR on EKS etc.
This project leverages the community [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) modules to EKS Cluster.

The intention of this framework is to help design config driven solution. This will help you to create EKS clusters for various environments and AWS accounts across multiple regions with a **unique Terraform configuration and state file** per EKS cluster.

* `main.tf` - [EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/clusters.html) and [Amazon EKS Addon](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) resources.
* `aws-eks-worker.tf`  - [Amazon Managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html), [Self-managed nodes](https://docs.aws.amazon.com/eks/latest/userguide/worker.html), [AWS EKS Fargate profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html) resources
* `kubernetes-addons.tf` - contains resources to deploy Kubernetes Addons using Helm and Kubernetes provider.

* `modules` - folder contains AWS resource sub modules used in this module.
* `kubernetes-addons` - folder contains Helm charts and Kubernetes resources for deploying Kubernetes Addons.
* `deploy` - folder contains example to deploy EKS cluster with multiple node groups and Kubernetes add-ons

# EKS Cluster Deployment Options
This module provisions the following EKS resources

## EKS Cluster resources

1. [EKS Cluster with multiple networking options](https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/)
   - [Fully Private EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)
   - [Public + Private EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html)
   - [Public Cluster](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html)
2. [Amazon EKS Addons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)
   - [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
   - [Kube-Proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html)
   - [VPC-CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
3. [Managed Node Groups with On-Demand](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) - AWS Managed Node Groups with On-Demand Instances
4. [Managed Node Groups with Spot](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) - AWS Managed Node Groups with Spot Instances
5. [AWS Fargate Profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html) - AWS Fargate Profiles
6. [Self-managed Node Group with Windows support](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html) - Ability to create a self-managed node group for Linux or Windows workloads.
7. [Launch Templates](https://aws.amazon.com/blogs/containers/introducing-launch-template-and-custom-ami-support-in-amazon-eks-managed-node-groups/) - Launch templates available to Managed Node Groups and Self-managed Node Groups
8. [Bottlerocket OS](https://github.com/bottlerocket-os/bottlerocket) - Managed and Self-managed Node Groups with Bottlerocket OS and Launch Templates
9. [Amazon Managed Service for Prometheus (AMP)](https://aws.amazon.com/prometheus/) - AMP makes it easy to monitor containerized applications at scale
10. [Amazon EMR on Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/blogs/aws/new-amazon-emr-on-amazon-elastic-kubernetes-service-eks/)

## Kubernetes Addons

Kubernetes Addons deployed using [Helm Charts](https://helm.sh/docs/topics/charts/) and Kubernetes Resources

1. [Metrics Server](https://github.com/Kubernetes-sigs/metrics-server)
2. [Cluster Autoscaler](https://github.com/Kubernetes/autoscaler)
3. [AWS LB Ingress Controller](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
4. [Traefik Ingress Controller](https://doc.traefik.io/traefik/providers/Kubernetes-ingress/)
5. [Ngnix Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
6. [FluentBit for Node Groups](https://github.com/aws/aws-for-fluent-bit)
7. [FluentBit for Fargate Containers](https://aws.amazon.com/blogs/containers/fluent-bit-for-amazon-eks-on-aws-fargate-is-here/)
8. [Agones](https://agones.dev/site/) - Host, Run and Scale dedicated game servers on Kubernetes
9. [Prometheus](https://github.com/prometheus-community/helm-charts)
10. [Kube-state-metrics](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics)
11. [Alert-manager](https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager)
12. [Prometheus-node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter)
13. [Prometheus-pushgateway](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway)
14. [Cert Manager](https://github.com/jetstack/cert-manager)
15. [spark-k8s-operator](https://github.com/GoogleCloudPlatform/spark-on-k8s-operator)

# Node Group Modules
This module uses dedicated sub modules for creating [AWS Managed Node Groups](modules/aws-eks-managed-node-groups), [Self-managed Node groups](modules/aws-eks-self-managed-node-groups) and [Fargate profiles](modules/aws-eks-fargate-profiles).
These modules provide flexibility to add or remove managed/self-managed node groups/fargate profiles by simply adding/removing map of values to input config. See [example](deploy/eks-cluster-with-new-vpc/main.tf).

The `aws-auth` ConfigMap handled by this module allow your nodes to join your cluster, and you also use this ConfigMap to add RBAC access to IAM users and roles.
Each Node Group can have dedicated IAM role, Launch template and Security Group to improve the security.

Please refer this [full example](deploy/eks-cluster-with-new-vpc/main.tf)
### EKS Cluster Deployment Example

```hcl
module "aws-eks-accelerator-for-terraform" {
  source = "git@github.com:aws-samples/aws-eks-accelerator-for-terraform.git"

  tenant            = "management"        # aws account alias
  environment       = "preprod"
  zone              = "dev"

  vpc_id             = "" # Enter VPC ID
  private_subnet_ids = [] # Enter Private Subnet IDs

  create_eks         = true
  kubernetes_version = "1.21"

  enable_managed_nodegroups = true
  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m4.large"]
      subnet_ids      = [] # Enter Private Subnet IDs
    }
  }

}
```

### Managed Node Groups Example

```hcl
    enable_managed_nodegroups = true

    managed_node_groups = {
      mg_m4 = {
        # 1> Node Group configuration
        node_group_name             = "managed-ondemand"
        create_launch_template      = true              # false will use the default launch template
        launch_template_os          = "amazonlinux2eks" # amazonlinux2eks or bottlerocket
        public_ip                   = false             # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
        # pre_userdata is just an example however ssm agent is now included with managed node groups
        pre_userdata           = <<-EOT
                yum install -y amazon-ssm-agent
                systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent"
            EOT

        # 2> Node Group scaling configuration
        desired_size    = 3
        max_size        = 3
        min_size        = 3
        max_unavailable = 1 # or percentage = 20

        # 3> Node Group compute configuration
        ami_type       = "AL2_x86_64"             # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
        capacity_type  = "ON_DEMAND"              # ON_DEMAND or SPOT
        instance_types = ["m4.large"]             # List of instances used only for SPOT type
        disk_size      = 50

        # 4> Node Group network configuration
        subnet_ids  = []                          # Mandatory - # Define private/public subnets list with comma separated ["subnet1","subnet2","subnet3"]
        k8s_taints = []
        k8s_labels = {
          Environment = "preprod"
          Zone        = "dev"
          WorkerType  = "ON_DEMAND"
        }
        additional_tags = {
          ExtraTag    = "m4-on-demand"
          Name        = "m4-on-demand"
          subnet_type = "private"
        }
        create_worker_security_group = false
      }
    }
```

### Self-managed Node Groups Example

```hcl
  enable_self_managed_nodegroups = true

  self_managed_node_groups = {
    self_mg_4 = {
      node_group_name    = "self-managed-ondemand"
      create_launch_template = true
      launch_template_os = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
      custom_ami_id      = "ami-0dfaa019a300f219c" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
      public_ip          = false                   # Enable only for public subnets
      pre_userdata       = <<-EOT
            yum install -y amazon-ssm-agent \
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent \
        EOT

      disk_size     = 20
      instance_type = "m5.large"
      desired_size = 2
      max_size     = 10
      min_size     = 2
      capacity_type = "" # Optional Use this only for SPOT capacity as  capacity_type = "spot"
      k8s_labels = {
        Environment = "preprod"
        Zone        = "test"
        WorkerType  = "SELF_MANAGED_ON_DEMAND"
      }
      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }
      subnet_ids  = module.aws_vpc.private_subnets
      create_worker_security_group = false
    },

  }
```

### Fargate Profile Example

```hcl
    enable_fargate = true

    fargate_profiles = {
      default = {
        fargate_profile_name = "default"
        fargate_profile_namespaces = [{
          namespace = "default"
          k8s_labels = {
            Environment = "preprod"
            Zone        = "dev"
            env         = "fargate"
          }
        }]
        subnet_ids = [] # Mandatory - # Define private subnets list with comma separated ["subnet1","subnet2","subnet3"]
        additional_tags = {
          ExtraTag = "Fargate"
        }
      }
    }
```

### Kubernetes Addon Example

The following example deploys the Addons with default configuration.

```hcl
metrics_server_enable = true            # Deploys Metrics Server Addon

cluster_autoscaler_enable = true        # Deploys Cluster Autoscaler Addon

prometheus_enable = true                # Deploys Prometheus Addon

```

This module also allows you to override `values.yaml` from consumer module.

```hcl
  # Optional Map value
  metrics_server_helm_chart = {
    name           = "metrics-server"
    repository     = "https://kubernetes-sigs.github.io/metrics-server/"
    chart          = "metrics-server"
    version        = "3.5.0"
    namespace      = "kube-system"
    timeout        = "1200"

    # (Optional) Example to pass metrics-server-values.yaml from your local repo
    values = [templatefile("${path.module}/k8s_addons/metrics-server-values.yaml", {
      operating_system                = "linux"
    })]
  }
```

## Bottlerocket OS

[Bottlerocket](https://aws.amazon.com/bottlerocket/) is an open source operating system specifically designed for running containers. Bottlerocket build system is based on Rust. It's a container host OS and doesn't have additional software's or package managers other than what is needed for running containers hence its very light weight and secure. Container optimized operating systems are ideal when you need to run applications in Kubernetes  with minimal setup and do not want to worry about security or updates, or want OS support from  cloud provider. Container operating systems does updates transactionally.

Bottlerocket has two containers runtimes running. Control container **on** by default used for AWS Systems manager and remote API access. Admin container **off** by default for deep debugging and exploration.

Bottlerocket [Launch templates userdata](modules/aws-eks-managed-node-groups/templates/userdata-bottlerocket.tpl) uses the TOML format with Key-value pairs.
Remote API access API via SSM agent. You can launch trouble shooting container via user data `[settings.host-containers.admin] enabled = true`.

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
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deployment Steps
The following steps walks you through the deployment of example [DEV cluster](deploy/eks-cluster-with-new-vpc/main.tf) configuration.
This config deploys a private EKS cluster with public and private subnets.
One managed node group and fargate profile for default namespace placed in private subnets. ALB placed in Public subnets created by AWS LB Ingress controller.
It also deploys few kubernetes apps i.e., AWS LB Ingress Controller, Metrics Server and Cluster Autoscaler.

#### Step1: Clone the repo

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step2: (Optional) Update example [main.tf](deploy/eks-cluster-with-new-vpc/main.tf) file

Update local variables `deploy/eks-cluster-with-new-vpc/main.tf` or keep it as default
You can choose to use an existing VPC ID and Subnet IDs or create a new VPC and subnets by providing CIDR ranges.

#### Step3: Set AWS profile or Assume IAM role
This role will become the Kubernetes Admin by default. Please see this document for [assuming a role](https://aws.amazon.com/premiumsupport/knowledge-center/iam-assume-role-cli/)

#### Step4: Run Terraform INIT
To initialize a working directory with configuration files

```shell script
cd deploy/eks-cluster-with-new-vpc/
terraform init
```

#### Step5: Run Terraform PLAN
To verify the resources created by this execution

```shell script
terraform plan
```

#### Step6: Finally, Terraform APPLY
to create resources

```shell script
terraform apply
```

### Configure kubectl and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step7: Run update-kubeconfig command.

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region <region> update-kubeconfig --name <cluster-name>

#### Step8: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step9: List all the pods running in kube-system namespace

    $ kubectl get pods -n kube-system

## Advanced Deployment Folder Structure

This example shows how to structure folders in your repo when you want to deploy multiple EKS Clusters across multiple regions and accounts.

The top-level `deploy\advanced` folder provides an example of how you can structure your folders and files to define multiple EKS Cluster environments and consume this accelerator module.
This approach is suitable for large projects, with clearly defined sub directory and file structure.
This can be modified the way that suits your requirement.
You can define a unique configuration for each EKS Cluster and making this module as central source of truth.

Each folder under `live/<region>/application` represents an EKS cluster environment(e.g., dev, test, load etc.).
This folder contains `backend.conf` and `<env>.tfvars`, used to create a unique Terraform state for each cluster environment.
Terraform backend configuration can be updated in `backend.conf` and cluster common configuration variables in `<env>.tfvars`

e.g. folder/file structure for defining multiple clusters

        ├── deploy\advanced
        │   └── live
        │       └── preprod
        │           └── eu-west-1
        │               └── application
        │                   └── dev
        │                       └── backend.conf
        │                       └── dev.tfvars
        │                       └── main.tf
        │                       └── variables.tf
        │                       └── outputs.tf
        │                   └── test
        │                       └── backend.conf
        │                       └── test.tfvars
        │       └── prod
        │           └── eu-west-1
        │               └── application
        │                   └── prod
        │                       └── backend.conf
        │                       └── prod.tfvars
        │                       └── main.tf
        │                       └── variables.tf
        │                       └── outputs.tf


## Important Note
If you are using an existing VPC then you need to ensure that the following tags added to the VPC and subnet resources

Add Tags to **VPC**
```hcl
    Key = "Kubernetes.io/cluster/${local.cluster_name}"
    Value = "Shared"
```

Add Tags to **Public Subnets tagging** requirement
```hcl
    public_subnet_tags = {
      "Kubernetes.io/cluster/${local.cluster_name}" = "shared"
      "Kubernetes.io/role/elb"                      = "1"
    }
```

Add Tags to **Private Subnets tagging** requirement
```hcl
    private_subnet_tags = {
      "Kubernetes.io/cluster/${local.cluster_name}" = "shared"
      "Kubernetes.io/role/internal-elb"             = "1"
    }
```

For **fully Private EKS clusters** requires the following VPC endpoints to be created to communicate with AWS services.

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


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

<!--- BEGIN_TF_DOCS --->
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: MIT-0

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.60.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.3.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.5.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.60.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 2.4.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_agones"></a> [agones](#module\_agones) | ./kubernetes-addons/agones | n/a |
| <a name="module_argocd"></a> [argocd](#module\_argocd) | ./kubernetes-addons/argocd | n/a |
| <a name="module_aws-for-fluent-bit"></a> [aws-for-fluent-bit](#module\_aws-for-fluent-bit) | ./kubernetes-addons/aws-for-fluentbit | n/a |
| <a name="module_aws_eks"></a> [aws\_eks](#module\_aws\_eks) | terraform-aws-modules/eks/aws | v17.20.0 |
| <a name="module_aws_eks_addon"></a> [aws\_eks\_addon](#module\_aws\_eks\_addon) | ./modules/aws-eks-addon | n/a |
| <a name="module_aws_eks_fargate_profiles"></a> [aws\_eks\_fargate\_profiles](#module\_aws\_eks\_fargate\_profiles) | ./modules/aws-eks-fargate-profiles | n/a |
| <a name="module_aws_eks_managed_node_groups"></a> [aws\_eks\_managed\_node\_groups](#module\_aws\_eks\_managed\_node\_groups) | ./modules/aws-eks-managed-node-groups | n/a |
| <a name="module_aws_eks_self_managed_node_groups"></a> [aws\_eks\_self\_managed\_node\_groups](#module\_aws\_eks\_self\_managed\_node\_groups) | ./modules/aws-eks-self-managed-node-groups | n/a |
| <a name="module_aws_managed_prometheus"></a> [aws\_managed\_prometheus](#module\_aws\_managed\_prometheus) | ./modules/aws-managed-prometheus | n/a |
| <a name="module_aws_opentelemetry_collector"></a> [aws\_opentelemetry\_collector](#module\_aws\_opentelemetry\_collector) | ./kubernetes-addons/aws-opentelemetry-eks | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./kubernetes-addons/cert-manager | n/a |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ./kubernetes-addons/cluster-autoscaler | n/a |
| <a name="module_eks_tags"></a> [eks\_tags](#module\_eks\_tags) | ./modules/aws-resource-tags | n/a |
| <a name="module_emr_on_eks"></a> [emr\_on\_eks](#module\_emr\_on\_eks) | ./modules/emr-on-eks | n/a |
| <a name="module_fargate_fluentbit"></a> [fargate\_fluentbit](#module\_fargate\_fluentbit) | ./kubernetes-addons/fargate-fluentbit | n/a |
| <a name="module_lb_ingress_controller"></a> [lb\_ingress\_controller](#module\_lb\_ingress\_controller) | ./kubernetes-addons/lb-ingress-controller | n/a |
| <a name="module_metrics_server"></a> [metrics\_server](#module\_metrics\_server) | ./kubernetes-addons/metrics-server | n/a |
| <a name="module_nginx_ingress"></a> [nginx\_ingress](#module\_nginx\_ingress) | ./kubernetes-addons/nginx-ingress | n/a |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | ./kubernetes-addons/prometheus | n/a |
| <a name="module_spark-k8s-operator"></a> [spark-k8s-operator](#module\_spark-k8s-operator) | ./kubernetes-addons/spark-k8s-operator | n/a |
| <a name="module_traefik_ingress"></a> [traefik\_ingress](#module\_traefik\_ingress) | ./kubernetes-addons/traefik-ingress | n/a |
| <a name="module_windows_vpc_controllers"></a> [windows\_vpc\_controllers](#module\_windows\_vpc\_controllers) | ./kubernetes-addons/windows-vpc-controllers | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [http_http.eks_cluster_readiness](https://registry.terraform.io/providers/terraform-aws-modules/http/2.4.1/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agones_enable"></a> [agones\_enable](#input\_agones\_enable) | Enabling Agones Gaming Helm Chart | `bool` | `false` | no |
| <a name="input_agones_helm_chart"></a> [agones\_helm\_chart](#input\_agones\_helm\_chart) | Agones GameServer Helm chart config | `any` | `{}` | no |
| <a name="input_argocd_enable"></a> [argocd\_enable](#input\_argocd\_enable) | Enable ARGO CD Kubernetes Addon | `bool` | `false` | no |
| <a name="input_argocd_helm_chart"></a> [argocd\_helm\_chart](#input\_argocd\_helm\_chart) | ARGO CD Kubernetes Addon Configuration | `any` | `{}` | no |
| <a name="input_aws_auth_additional_labels"></a> [aws\_auth\_additional\_labels](#input\_aws\_auth\_additional\_labels) | Additional kubernetes labels applied on aws-auth ConfigMap | `map(string)` | `{}` | no |
| <a name="input_aws_for_fluentbit_enable"></a> [aws\_for\_fluentbit\_enable](#input\_aws\_for\_fluentbit\_enable) | Enabling FluentBit Addon on EKS Worker Nodes | `bool` | `false` | no |
| <a name="input_aws_for_fluentbit_helm_chart"></a> [aws\_for\_fluentbit\_helm\_chart](#input\_aws\_for\_fluentbit\_helm\_chart) | Helm chart definition for aws\_for\_fluent\_bit | `any` | `{}` | no |
| <a name="input_aws_lb_ingress_controller_enable"></a> [aws\_lb\_ingress\_controller\_enable](#input\_aws\_lb\_ingress\_controller\_enable) | enabling LB Ingress Controller on eks cluster | `bool` | `false` | no |
| <a name="input_aws_lb_ingress_controller_helm_app"></a> [aws\_lb\_ingress\_controller\_helm\_app](#input\_aws\_lb\_ingress\_controller\_helm\_app) | Helm chart definition for aws\_lb\_ingress\_controller | `any` | `{}` | no |
| <a name="input_aws_managed_prometheus_enable"></a> [aws\_managed\_prometheus\_enable](#input\_aws\_managed\_prometheus\_enable) | Enable AWS Managed Prometheus service | `bool` | `false` | no |
| <a name="input_aws_managed_prometheus_workspace_name"></a> [aws\_managed\_prometheus\_workspace\_name](#input\_aws\_managed\_prometheus\_workspace\_name) | AWS Managed Prometheus WorkSpace Name | `string` | `"aws-managed-prometheus-workspace"` | no |
| <a name="input_aws_open_telemetry_addon"></a> [aws\_open\_telemetry\_addon](#input\_aws\_open\_telemetry\_addon) | AWS Open Telemetry Distro Addon Configuration | `any` | `{}` | no |
| <a name="input_aws_open_telemetry_enable"></a> [aws\_open\_telemetry\_enable](#input\_aws\_open\_telemetry\_enable) | Enable AWS Open Telemetry Distro Addon | `bool` | `false` | no |
| <a name="input_cert_manager_enable"></a> [cert\_manager\_enable](#input\_cert\_manager\_enable) | Enabling Cert Manager Helm Chart installation. It is automatically enabled if Windows support is enabled. | `bool` | `false` | no |
| <a name="input_cert_manager_helm_chart"></a> [cert\_manager\_helm\_chart](#input\_cert\_manager\_helm\_chart) | Cert Manager Helm chart configuration | `any` | `{}` | no |
| <a name="input_cluster_autoscaler_enable"></a> [cluster\_autoscaler\_enable](#input\_cluster\_autoscaler\_enable) | Enabling Cluster autoscaler on eks cluster | `bool` | `false` | no |
| <a name="input_cluster_autoscaler_helm_chart"></a> [cluster\_autoscaler\_helm\_chart](#input\_cluster\_autoscaler\_helm\_chart) | Cluster Autoscaler Helm Chart Config | `any` | `{}` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logging to enable | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false | `bool` | `false` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true | `bool` | `true` | no |
| <a name="input_cluster_log_retention_period"></a> [cluster\_log\_retention\_period](#input\_cluster\_log\_retention\_period) | Number of days to retain cluster logs | `number` | `7` | no |
| <a name="input_coredns_addon_version"></a> [coredns\_addon\_version](#input\_coredns\_addon\_version) | CoreDNS Addon version | `string` | `"v1.8.3-eksbuild.1"` | no |
| <a name="input_create_eks"></a> [create\_eks](#input\_create\_eks) | ---------------------------------------------------------- EKS CONTROL PLANE ---------------------------------------------------------- | `bool` | `false` | no |
| <a name="input_emr_on_eks_teams"></a> [emr\_on\_eks\_teams](#input\_emr\_on\_eks\_teams) | EMR on EKS Teams configuration | `any` | `{}` | no |
| <a name="input_enable_coredns_addon"></a> [enable\_coredns\_addon](#input\_enable\_coredns\_addon) | Enable CoreDNS Addon | `bool` | `false` | no |
| <a name="input_enable_emr_on_eks"></a> [enable\_emr\_on\_eks](#input\_enable\_emr\_on\_eks) | Enabling EMR on EKS Config | `bool` | `false` | no |
| <a name="input_enable_fargate"></a> [enable\_fargate](#input\_enable\_fargate) | Enable Fargate profiles | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true | `bool` | `true` | no |
| <a name="input_enable_kube_proxy_addon"></a> [enable\_kube\_proxy\_addon](#input\_enable\_kube\_proxy\_addon) | Enable Kube Proxy Addon | `bool` | `false` | no |
| <a name="input_enable_managed_nodegroups"></a> [enable\_managed\_nodegroups](#input\_enable\_managed\_nodegroups) | Enable self-managed worker groups | `bool` | `false` | no |
| <a name="input_enable_self_managed_nodegroups"></a> [enable\_self\_managed\_nodegroups](#input\_enable\_self\_managed\_nodegroups) | Enable self-managed worker groups | `bool` | `false` | no |
| <a name="input_enable_vpc_cni_addon"></a> [enable\_vpc\_cni\_addon](#input\_enable\_vpc\_cni\_addon) | Enable VPC CNI Addon | `bool` | `false` | no |
| <a name="input_enable_windows_support"></a> [enable\_windows\_support](#input\_enable\_windows\_support) | Enable Windows support | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | `"preprod"` | no |
| <a name="input_fargate_fluentbit_config"></a> [fargate\_fluentbit\_config](#input\_fargate\_fluentbit\_config) | Fargate fluentbit configuration | `any` | `{}` | no |
| <a name="input_fargate_fluentbit_enable"></a> [fargate\_fluentbit\_enable](#input\_fargate\_fluentbit\_enable) | Enabling fargate\_fluent\_bit module on eks cluster | `bool` | `false` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Fargate Profile configuration | `any` | `{}` | no |
| <a name="input_kube_proxy_addon_version"></a> [kube\_proxy\_addon\_version](#input\_kube\_proxy\_addon\_version) | KubeProxy Addon version | `string` | `"v1.20.4-eksbuild.2"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Desired Kubernetes master version. If you do not specify a value, the latest available version is used | `string` | `"1.21"` | no |
| <a name="input_managed_node_groups"></a> [managed\_node\_groups](#input\_managed\_node\_groups) | Managed Node groups configuration | `any` | `{}` | no |
| <a name="input_map_accounts"></a> [map\_accounts](#input\_map\_accounts) | Additional AWS account numbers to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles) | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users) | Additional IAM users to add to the aws-auth configmap. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_metrics_server_enable"></a> [metrics\_server\_enable](#input\_metrics\_server\_enable) | Enabling metrics server on eks cluster | `bool` | `false` | no |
| <a name="input_metrics_server_helm_chart"></a> [metrics\_server\_helm\_chart](#input\_metrics\_server\_helm\_chart) | Metrics Server Helm Addon Config | `any` | `{}` | no |
| <a name="input_nginx_helm_chart"></a> [nginx\_helm\_chart](#input\_nginx\_helm\_chart) | NGINX Ingress Controller Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_nginx_ingress_controller_enable"></a> [nginx\_ingress\_controller\_enable](#input\_nginx\_ingress\_controller\_enable) | Enabling NGINX Ingress Controller on EKS Cluster | `bool` | `false` | no |
| <a name="input_org"></a> [org](#input\_org) | tenant, which could be your organization name, e.g. aws' | `string` | `""` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list(string)` | n/a | yes |
| <a name="input_prometheus_enable"></a> [prometheus\_enable](#input\_prometheus\_enable) | Enable Community Prometheus Helm Addon | `bool` | `false` | no |
| <a name="input_prometheus_helm_chart"></a> [prometheus\_helm\_chart](#input\_prometheus\_helm\_chart) | Community Prometheus Helm Addon Config | `any` | `{}` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list(string)` | `[]` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | n/a | `any` | `{}` | no |
| <a name="input_spark_on_k8s_operator_enable"></a> [spark\_on\_k8s\_operator\_enable](#input\_spark\_on\_k8s\_operator\_enable) | Enabling Spark on K8s Operator on EKS Cluster | `bool` | `false` | no |
| <a name="input_spark_on_k8s_operator_helm_chart"></a> [spark\_on\_k8s\_operator\_helm\_chart](#input\_spark\_on\_k8s\_operator\_helm\_chart) | Spark on K8s Operator Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | `"aws"` | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Terraform Version | `string` | `"Terraform"` | no |
| <a name="input_traefik_helm_chart"></a> [traefik\_helm\_chart](#input\_traefik\_helm\_chart) | Traefik Helm Addon Config | `any` | `{}` | no |
| <a name="input_traefik_ingress_controller_enable"></a> [traefik\_ingress\_controller\_enable](#input\_traefik\_ingress\_controller\_enable) | Enabling Traefik Ingress Controller on eks cluster | `bool` | `false` | no |
| <a name="input_vpc_cni_addon_version"></a> [vpc\_cni\_addon\_version](#input\_vpc\_cni\_addon\_version) | VPC CNI Addon version | `string` | `"v1.8.0-eksbuild.1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id | `string` | n/a | yes |
| <a name="input_windows_vpc_controllers_helm_chart"></a> [windows\_vpc\_controllers\_helm\_chart](#input\_windows\_vpc\_controllers\_helm\_chart) | Windows VPC Controllers Helm chart configuration | `any` | `{}` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amp_work_arn"></a> [amp\_work\_arn](#output\_amp\_work\_arn) | AWS Managed Prometheus workspace ARN |
| <a name="output_amp_work_id"></a> [amp\_work\_id](#output\_amp\_work\_id) | AWS Managed Prometheus workspace id |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Kubernetes Cluster Name |
| <a name="output_cluster_oidc_url"></a> [cluster\_oidc\_url](#output\_cluster\_oidc\_url) | The URL on the EKS cluster OIDC Issuer |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | EKS Cluster Security group ID |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | EKS Control Plane Security Group ID |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_emr_on_eks_role_arn"></a> [emr\_on\_eks\_role\_arn](#output\_emr\_on\_eks\_role\_arn) | IAM execution role ARN for EMR on EKS |
| <a name="output_emr_on_eks_role_id"></a> [emr\_on\_eks\_role\_id](#output\_emr\_on\_eks\_role\_id) | IAM execution role ID for EMR on EKS |
| <a name="output_fargate_profiles"></a> [fargate\_profiles](#output\_fargate\_profiles) | Outputs from EKS Fargate profiles groups |
| <a name="output_fargate_profiles_aws_auth_config_map"></a> [fargate\_profiles\_aws\_auth\_config\_map](#output\_fargate\_profiles\_aws\_auth\_config\_map) | Fargate profiles AWS auth map |
| <a name="output_fargate_profiles_iam_role_arns"></a> [fargate\_profiles\_iam\_role\_arns](#output\_fargate\_profiles\_iam\_role\_arns) | IAM role arn's for Fargate Profiles |
| <a name="output_managed_node_group_aws_auth_config_map"></a> [managed\_node\_group\_aws\_auth\_config\_map](#output\_managed\_node\_group\_aws\_auth\_config\_map) | Managed node groups AWS auth map |
| <a name="output_managed_node_group_iam_role_arns"></a> [managed\_node\_group\_iam\_role\_arns](#output\_managed\_node\_group\_iam\_role\_arns) | IAM role arn's of managed node groups |
| <a name="output_managed_node_groups"></a> [managed\_node\_groups](#output\_managed\_node\_groups) | Outputs from EKS Managed node groups |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true`. |
| <a name="output_self_managed_node_group_aws_auth_config_map"></a> [self\_managed\_node\_group\_aws\_auth\_config\_map](#output\_self\_managed\_node\_group\_aws\_auth\_config\_map) | Self managed node groups AWS auth map |
| <a name="output_self_managed_node_group_iam_role_arns"></a> [self\_managed\_node\_group\_iam\_role\_arns](#output\_self\_managed\_node\_group\_iam\_role\_arns) | IAM role arn's of self managed node groups |
| <a name="output_self_managed_node_groups"></a> [self\_managed\_node\_groups](#output\_self\_managed\_node\_groups) | Outputs from EKS Self-managed node groups |
| <a name="output_windows_node_group_aws_auth_config_map"></a> [windows\_node\_group\_aws\_auth\_config\_map](#output\_windows\_node\_group\_aws\_auth\_config\_map) | Windows node groups AWS auth map |
| <a name="output_worker_security_group_id"></a> [worker\_security\_group\_id](#output\_worker\_security\_group\_id) | EKS Worker Security group ID created by EKS module |

<!--- END_TF_DOCS --->
