/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#---------------------------------------------------------#
# EKS CLUSTER CORE VARIABLES
#---------------------------------------------------------#
#Following fields used in tagging resources and building the name of the cluster
#e.g., eks cluster name will be {tenant}-{environment}-{zone}-{resource}
#---------------------------------------------------------#
org               = "aws"     # Organization Name. Used to tag resources
tenant            = "aws001"  # AWS account name or unique id for tenant
environment       = "preprod" # Environment area eg., preprod or prod
zone              = "dev"     # Environment with in one sub_tenant or business unit
terraform_version = "Terraform v1.0.1"

#---------------------------------------------------------#
# VPC and PRIVATE SUBNET DETAILS for EKS Cluster
# This provides two options Option1 and Option2. You should choose either of one to provide VPC details to the EKS cluster
#---------------------------------------------------------#

#---------------------------------------------------------#
# OPTION 1
# Provide an existing vpc_id and private_subnet_ids
#---------------------------------------------------------#
# create_vpc = false
# vpc_id = "xxxxxx"
# private_subnet_ids = ['xxxxxx','xxxxxx','xxxxxx']
# public_subnet_ids = ['xxxxxx','xxxxxx','xxxxxx']

#---------------------------------------------------------#
# OPTION 2
# Creates a new VPC, private Subnets and VPC Endpoints by taking the inputs of vpc_cidr_block and private_subnets_cidr. VPC Endpoints are S3, SSM , EC2, ECR API, ECR DKR, KMS, CloudWatch Logs, STS, Elastic Load Balancing, Autoscaling
#---------------------------------------------------------#
create_vpc             = true
enable_private_subnets = true
enable_public_subnets  = true

# Enable or Disable NAT Gateway and Internet Gateway for Public Subnets
enable_nat_gateway = true
single_nat_gateway = true
create_igw         = true

vpc_cidr_block       = "10.1.0.0/18"
private_subnets_cidr = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
public_subnets_cidr  = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22"]

# Change this to true when you want to create VPC endpoints for Private subnets
create_vpc_endpoints = true

#---------------------------------------------------------#
# EKS CONTROL PLANE VARIABLES
# API server endpoint access options
#   Endpoint public access: true    - Your cluster API server is accessible from the internet. You can, optionally, limit the CIDR blocks that can access the public endpoint.
#   Endpoint private access: true   - Kubernetes API requests within your cluster's VPC (such as node to control plane communication) use the private VPC endpoint.
#---------------------------------------------------------#
create_eks              = true
kubernetes_version      = "1.21"
endpoint_private_access = true
endpoint_public_access  = true

# Enable IAM Roles for Service Accounts (IRSA) on the EKS cluster
enable_irsa = true

enabled_cluster_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_period = 7

enable_vpc_cni_addon  = true
vpc_cni_addon_version = "v1.9.1-eksbuild.1"

enable_coredns_addon  = true
coredns_addon_version = "v1.8.4-eksbuild.1"

enable_kube_proxy_addon  = true
kube_proxy_addon_version = "v1.21.2-eksbuild.2"

#---------------------------------------------------------#
# EKS WORKER NODE GROUPS
# Define Node groups as map of maps object as shown below. Each node group creates the following
#    1. New node group (Linux/Bottlerocket)
#    2. IAM role and policies for Node group
#    3. Security Group for Node group (Optional)
#    4. Launch Templates for Node group   (Optional)
#---------------------------------------------------------#
enable_managed_nodegroups = true
managed_node_groups = {
  #---------------------------------------------------------#
  # ON-DEMAND Worker Group - Worker Group - 1
  #---------------------------------------------------------#
  mg_4 = {
    # 1> Node Group configuration - Part1
    node_group_name        = "managed-ondemand"
    create_launch_template = true              # false will use the default launch template
    custom_ami_type        = "amazonlinux2eks" # amazonlinux2eks or windows or bottlerocket
    public_ip              = false             # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
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
    ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
    capacity_type  = "ON_DEMAND"  # ON_DEMAND or SPOT
    instance_types = ["m4.large"] # List of instances used only for SPOT type
    disk_size      = 50

    # 4> Node Group network configuration
    subnet_type = "private" # private or public
    subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

    k8s_taints = []

    k8s_labels = {
      Environment = "preprod"
      Zone        = "dev"
      WorkerType  = "ON_DEMAND"
    }
    additional_tags = {
      ExtraTag    = "m5x-on-demand"
      Name        = "m5x-on-demand"
      subnet_type = "private"
    }

    create_worker_security_group = true

  },
  #---------------------------------------------------------#
  # SPOT Worker Group - Worker Group - 2
  #---------------------------------------------------------#
  /*
  spot_m5 = {
    # 1> Node Group configuration - Part1
    node_group_name        = "managed-spot-m5"
    create_launch_template = true              # false will use the default launch template
    custom_ami_type        = "amazonlinux2eks" # amazonlinux2eks  or bottlerocket
    public_ip              = false             # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
    pre_userdata           = <<-EOT
               yum install -y amazon-ssm-agent
               systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent"
           EOT

    # Node Group scaling configuration
    desired_size = 3
    max_size     = 3
    min_size     = 3

    # Node Group update configuration. Set the maximum number or percentage of unavailable nodes to be tolerated during the node group version update.
    max_unavailable = 1 # or percentage = 20

    # Node Group compute configuration
    ami_type       = "AL2_x86_64"
    capacity_type  = "SPOT"
    instance_types = ["t3.medium", "t3a.medium"]
    disk_size      = 50

    # Node Group network configuration
    subnet_type = "private" # private or public
    subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

    k8s_taints = []

    k8s_labels = {
      Environment = "preprod"
      Zone        = "dev"
      WorkerType  = "SPOT"
    }
    additional_tags = {
      ExtraTag    = "spot_nodes"
      Name        = "spot"
      subnet_type = "private"
    }

    create_worker_security_group = false
  },

  #---------------------------------------------------------#
  # BOTTLEROCKET - Worker Group - 3
  #---------------------------------------------------------#
  brkt_m5 = {
    node_group_name        = "managed-brkt-m5"
    create_launch_template = true           # false will use the default launch template
    custom_ami_type        = "bottlerocket" # amazonlinux2eks  or bottlerocket
    public_ip              = false          # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
    pre_userdata           = ""

    desired_size    = 3
    max_size        = 3
    min_size        = 3
    max_unavailable = 1

    ami_type       = "CUSTOM"
    capacity_type  = "ON_DEMAND" # ON_DEMAND or SPOT
    instance_types = ["m5.large"]
    disk_size      = 50
    custom_ami_id  = "ami-044b114caf98ce8c5" # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami-bottlerocket.html

    # Node Group network configuration
    subnet_type = "private" # private or public
    subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

    k8s_taints = {}
    k8s_labels = {
      Environment = "preprod"
      Zone        = "dev"
      OS          = "bottlerocket"
      WorkerType  = "ON_DEMAND_BOTTLEROCKET"
    }
    additional_tags = {
      ExtraTag = "bottlerocket"
      Name     = "bottlerocket"
    }
    #security_group ID
    create_worker_security_group = true
  }

    */
} # END OF MANAGED NODE GROUPS

#---------------------------------------------------------#
# EKS SELF MANAGED WORKER NODE GROUPS
#---------------------------------------------------------#

enable_windows_support                    = false
windows_vpc_resource_controller_image_tag = "v0.2.7" # enable_windows_support= true
windows_vpc_admission_webhook_image_tag   = "v0.2.7" # enable_windows_support= true

enable_self_managed_nodegroups = false
self_managed_node_groups = {
  #---------------------------------------------------------#
  # ON-DEMAND Self Managed Worker Group - Worker Group - 1
  #---------------------------------------------------------#
  self_mg_4 = {
    node_group_name = "self-managed-ondemand" # Name is used to create a dedicated IAM role for each node group and adds to AWS-AUTH config map
    custom_ami_type = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
    custom_ami_id   = "ami-0dfaa019a300f219c" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
    public_ip       = false                   # Enable only for public subnets
    pre_userdata    = <<-EOT
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

    subnet_type = "private" # private or public
    subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

    create_worker_security_group = false # Creates a dedicated sec group for this Node Group
  },
  /*
  spot_m5 = {
    # 1> Node Group configuration - Part1
    node_group_name = "self-managed-spot"
    custom_ami_type = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
    custom_ami_id   = "ami-0dfaa019a300f219c" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
    public_ip       = false                   # Enable only for public subnets
    pre_userdata    = <<-EOT
            yum install -y amazon-ssm-agent \
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent \
        EOT

    disk_size     = 20
    instance_type = "m5.large"

    desired_size = 2
    max_size     = 10
    min_size     = 2

    capacity_type = "spot"

    # Node Group network configuration
    subnet_type = "private" # private or public
    subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

    k8s_taints = []
    k8s_labels = {
      Environment = "preprod"
      Zone        = "dev"
      WorkerType  = "SPOT"
    }
    additional_tags = {
      ExtraTag    = "spot_nodes"
      Name        = "spot"
      subnet_type = "private"
    }

    create_worker_security_group = false
  },

  brkt_m5 = {
    node_group_name = "self-managed-brkt"
    custom_ami_type = "bottlerocket"          # amazonlinux2eks  or bottlerocket or windows
    custom_ami_id   = "ami-044b114caf98ce8c5" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
    public_ip       = false                   # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
    pre_userdata    = ""

    desired_size    = 3
    max_size        = 3
    min_size        = 3
    max_unavailable = 1

    instance_types = "m5.large"
    disk_size      = 50

    subnet_type = "private" # private or public
    subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

    k8s_taints = []

    k8s_labels = {
      Environment = "preprod"
      Zone        = "dev"
      OS          = "bottlerocket"
      WorkerType  = "ON_DEMAND_BOTTLEROCKET"
    }
    additional_tags = {
      ExtraTag = "bottlerocket"
      Name     = "bottlerocket"
    }

    create_worker_security_group = true
  }

  #---------------------------------------------------------#
  # ON-DEMAND Self Managed Windows Worker Node Group
  #---------------------------------------------------------#
  windows_od = {
    node_group_name = "windows-ondemand" # Name is used to create a dedicated IAM role for each node group and adds to AWS-AUTH config map
    custom_ami_type = "windows"          # amazonlinux2eks  or bottlerocket or windows
    # custom_ami_id   = "ami-xxxxxxxxxxxxxxxx" # Bring your own custom AMI. Default Windows AMI is the latest EKS Optimized Windows Server 2019 English Core AMI.
    public_ip = false # Enable only for public subnets

    disk_size     = 50
    instance_type = "m5.large"

    desired_size = 2
    max_size     = 4
    min_size     = 2

    k8s_labels = {
      Environment = "preprod"
      Zone        = "dev"
      WorkerType  = "WINDOWS_ON_DEMAND"
    }

    additional_tags = {
      ExtraTag    = "windows-on-demand"
      Name        = "windows-on-demand"
      subnet_type = "private"
    }

    subnet_type = "private" # private or public
    subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

    create_worker_security_group = false # Creates a dedicated sec group for this Node Group
  }
*/
} # END OF SELF MANAGED NODE GROUPS

#---------------------------------------------------------#
# FARGATE PROFILES
#---------------------------------------------------------#
enable_fargate = true

# Enable logging only when you create a Fargate profile e.g., enable_fargate = true
fargate_fluent_bit_enable = true

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

    subnet_ids = [] # Provide list of private subnets

    additional_tags = {
      ExtraTag = "Fargate"
    }
  },
  /*
  multi = {
    fargate_profile_name = "multi-namespaces"
    fargate_profile_namespaces = [{
      namespace = "default"
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        OS          = "Fargate"
        WorkerType  = "FARGATE"
        Namespace   = "default"
      }
      },
      {
        namespace = "sales"
        k8s_labels = {
          Environment = "preprod"
          Zone        = "dev"
          OS          = "Fargate"
          WorkerType  = "FARGATE"
          Namespace   = "default"
        }
    }]

    subnet_ids = [] # Provide list of private subnets

    additional_tags = {
      ExtraTag = "Fargate"
    }
  }, */
} # END OF FARGATE PROFILES

#---------------------------------------------------------#
# ENABLE HELM MODULES
#---------------------------------------------------------#
# Please note that you may need to download the docker images for each
#    helm module and push it to ECR if you create fully private EKS Clusters with no access to internet to fetch docker images.
#    README with instructions available in each HELM module under helm/
#---------------------------------------------------------#
# Enable `public_docker_repo = true` if worker Node groups has access to internet to download the docker images
public_docker_repo = true

# If public_docker_repo = false then provide the private_container_repo_url or it will use ECR repo url
# private_container_repo_url = ""
#---------------------------------------------------------#
# ENABLE METRICS SERVER
#---------------------------------------------------------#
metrics_server_enable            = true
metric_server_image_repo_name    = "bitnami/metrics-server"
metric_server_image_tag          = "0.5.0-debian-10-r83"
metric_server_helm_repo_url      = "https://charts.bitnami.com/bitnami"
metric_server_helm_chart_name    = "metrics-server"
metric_server_helm_chart_version = "5.10.1"
#---------------------------------------------------------#
# ENABLE CLUSTER AUTOSCALER
#---------------------------------------------------------#
cluster_autoscaler_enable          = true
cluster_autoscaler_image_tag       = "v1.21.0"
cluster_autoscaler_helm_repo_url   = "https://kubernetes.github.io/autoscaler"
cluster_autoscaler_image_repo_name = "k8s.gcr.io/autoscaling/cluster-autoscaler"
cluster_autoscaler_helm_chart_name = "cluster-autoscaler"
cluster_autoscaler_helm_version    = "9.10.7"

#---------------------------------------------------------//
# ENABLE AWS LB INGRESS CONTROLLER
#---------------------------------------------------------//
aws_lb_ingress_controller_enable = false
aws_lb_image_repo_name           = "amazon/aws-load-balancer-controller"
aws_lb_image_tag                 = "v2.2.4"
aws_lb_helm_chart_version        = "1.2.7"
aws_lb_helm_repo_url             = "https://aws.github.io/eks-charts"
aws_lb_helm_helm_chart_name      = "aws-load-balancer-controller"

#---------------------------------------------------------//
# ENABLE PROMETHEUS
#---------------------------------------------------------//
# Creates the AMP workspace and all the relevent IAM Roles
aws_managed_prometheus_enable         = false
aws_managed_prometheus_workspace_name = "EKS-Metrics-Workspace"

# Deploys Pometheus server with remote write to AWS AMP Workspace
prometheus_enable             = false
prometheus_helm_chart_url     = "https://prometheus-community.github.io/helm-charts"
prometheus_helm_chart_name    = "prometheus"
prometheus_helm_chart_version = "14.4.0"
prometheus_image_tag          = "v2.26.0"
alert_manager_image_tag       = "v0.21.0"
configmap_reload_image_tag    = "v0.5.0"
node_exporter_image_tag       = "v1.1.2"
pushgateway_image_tag         = "v1.3.1"

#---------------------------------------------------------#
# ENABLE AWS_FLUENT-BIT
#---------------------------------------------------------#
aws_for_fluent_bit_enable             = false
ekslog_retention_in_days              = 7
aws_for_fluent_bit_image_repo_name    = "amazon/aws-for-fluent-bit"
aws_for_fluent_bit_image_tag          = "2.17.0"
aws_for_fluent_bit_helm_chart_version = "0.1.11"
aws_for_fluent_bit_helm_chart_url     = "https://aws.github.io/eks-charts"
aws_for_fluent_bit_helm_chart_name    = "aws-for-fluent-bit"

#---------------------------------------------------------#
# ENABLE TRAEFIK INGRESS CONTROLLER
#---------------------------------------------------------#
traefik_ingress_controller_enable = false
traefik_helm_chart_url            = "https://helm.traefik.io/traefik"
traefik_helm_chart_name           = "traefik"
traefik_helm_chart_version        = "10.0.0"
traefik_image_tag                 = "v2.4.9"
traefik_image_repo_name           = "traefik"
#---------------------------------------------------------#
# ENABLE NGINX INGRESS CONTROLLER
#---------------------------------------------------------#
nginx_ingress_controller_enable = false
nginx_helm_chart_version        = "3.33.0"
nginx_helm_chart_url            = "https://kubernetes.github.io/ingress-nginx"
nginx_helm_chart_name           = "ingress-nginx"
nginx_image_tag                 = "v0.47.0"
nginx_image_repo_name           = "ingress-nginx/controller"

#---------------------------------------------------------//
# ENABLE AGONES GAMING CONTROLLER
#   A library for hosting, running and scaling dedicated game servers on Kubernetes
#   This chart installs the Agones application and defines deployment on a  cluster
#   NOTE: Edit Rules to add a new Custom UDP Rule with a 7000-8000 port range and an appropriate Source CIDR range (0.0.0.0/0 allows all traffic) (sec group e.g., gaming-preprod-test-eks-eks_worker_sg)
#         By default Agones prefers to be scheduled on nodes labeled with agones.dev/agones-system=true and tolerates the node taint agones.dev/agones-system=true:NoExecute.
#         If no dedicated nodes are available, Agones will run on regular nodes.
#---------------------------------------------------------//
agones_enable              = false
expose_udp                 = true
agones_helm_chart_name     = "agones"
agones_helm_chart_url      = "https://agones.dev/chart/stable"
agones_image_tag           = "1.15.0"
agones_image_repo          = "gcr.io/agones-images"
agones_game_server_minport = 7000
agones_game_server_maxport = 8000
#agones_helm_chart_version = ""

#---------------------------------------------------------#
# CERT MANAGER
#   enable_windows_support= true
#---------------------------------------------------------#
cert_manager_enable             = false
cert_manager_image_tag          = "v1.5.3"
cert_manager_helm_chart_version = "v1.5.3"
cert_manager_install_crds       = true
cert_manager_helm_chart_name    = "cert-manager"
cert_manager_helm_chart_url     = "https://charts.jetstack.io"
cert_manager_image_repo_name    = "quay.io/jetstack/cert-manager-controller"

#---------------------------------------------------------#
# ENABLE AWS Distro for OpenTelemetry Collector in EKS
# Help : https://aws-otel.github.io/docs/setup/eks
#---------------------------------------------------------#
aws_open_telemetry_enable    = false
aws_open_telemetry_namespace = "aws-otel-eks"
#EMITTER
aws_open_telemetry_emitter_name                     = "trace-emitter"
aws_open_telemetry_emitter_image                    = "public.ecr.aws/g9c4k4i4/trace-emitter:1"
aws_open_telemetry_emitter_oltp_endpoint            = "localhost:55680"
aws_open_telemetry_emitter_otel_resource_attributes = "service.namespace=AWSObservability,service.name=ADOTEmitService"
#COLLECTOR
aws_open_telemetry_collector_image = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
aws_open_telemetry_aws_region      = "eu-west-1"

#---------------------------------------------------------#
# ENABLE OPENTELEMETRY COLLECTOR FOR NODE GROUPS
#---------------------------------------------------------#
opentelemetry_enable       = false
opentelemetry_image        = "otel/opentelemetry-collector"
opentelemetry_image_tag    = "0.35.0"
opentelemetry_command_name = "otelcol"

opentelemetry_helm_chart_url     = "https://open-telemetry.github.io/opentelemetry-helm-charts"
opentelemetry_helm_chart         = "opentelemetry-collector"
opentelemetry_helm_chart_version = "0.5.11"

#agent_collector
opentelemetry_enable_agent_collector = true
opentelemetry_enable_container_logs  = true
# standalone_collector
opentelemetry_enable_standalone_collector             = false
opentelemetry_enable_autoscaling_standalone_collector = true
opentelemetry_min_standalone_collectors               = 1
opentelemetry_max_standalone_collectors               = 10
