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
