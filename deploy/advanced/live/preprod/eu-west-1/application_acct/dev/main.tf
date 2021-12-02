
terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}

provider "aws" {
  region = data.aws_region.current.id
  alias  = "default"
}

terraform {
  backend "local" {
    path = "local_tf_state/terraform-main.tfstate"
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

locals {
  tenant      = "aws001"  # AWS account name or unique id for tenant
  environment = "preprod" # Environment area eg., preprod or prod
  zone        = "dev"     # Environment with in one sub_tenant or business unit

  kubernetes_version = "1.21"

  vpc_cidr     = "10.0.0.0/16"
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.0.1"
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.2.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.available.names

  public_subnets  = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

}
#---------------------------------------------------------------
# Example to consume aws-eks-accelerator-for-terraform module
#---------------------------------------------------------------
module "aws-eks-accelerator-for-terraform" {
  source            = "../../../../../../.."
  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  create_eks         = true
  kubernetes_version = local.kubernetes_version

  #---------------------------------------------------------#
  # EKS WORKER NODE GROUPS
  # Define Node groups as map of maps object as shown below. Each node group creates the following
  #    1. New node group
  #    2. IAM role and policies for Node group
  #    3. Security Group for Node group (Optional)
  #    4. Launch Templates for Node group   (Optional)
  #---------------------------------------------------------#
  managed_node_groups = {
    #---------------------------------------------------------#
    # ON-DEMAND Worker Group - Worker Group - 1
    #---------------------------------------------------------#
    mg_4 = {
      # 1> Node Group configuration - Part1
      node_group_name        = "managed-ondemand" # Max 40 characters for node group name
      create_launch_template = true               # false will use the default launch template
      launch_template_os     = "amazonlinux2eks"  # amazonlinux2eks or bottlerocket
      public_ip              = false              # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
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
      subnet_ids = module.aws_vpc.private_subnets # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

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
      launch_template_os        = "amazonlinux2eks" # amazonlinux2eks  or bottlerocket
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
      launch_template_os        = "bottlerocket" # amazonlinux2eks  or bottlerocket
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

  enable_windows_support = false

  self_managed_node_groups = {
    #---------------------------------------------------------#
    # ON-DEMAND Self Managed Worker Group - Worker Group - 1
    #---------------------------------------------------------#
    self_mg_4 = {
      node_group_name        = "self-managed-ondemand" # Name is used to create a dedicated IAM role for each node group and adds to AWS-AUTH config map
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
      custom_ami_id          = "ami-0dfaa019a300f219c" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
      public_ip              = false                   # Enable only for public subnets
      pre_userdata           = <<-EOT
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


      subnet_ids = [] # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      create_worker_security_group = false # Creates a dedicated sec group for this Node Group
    },
    /*
    spot_m5 = {
      # 1> Node Group configuration - Part1
      node_group_name = "self-managed-spot"
      create_launch_template = true
      launch_template_os = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
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
      create_launch_template = true
      launch_template_os = "bottlerocket"          # amazonlinux2eks  or bottlerocket or windows
      custom_ami_id   = "ami-044b114caf98ce8c5" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
      public_ip       = false                   # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata    = ""

      desired_size    = 3
      max_size        = 3
      min_size        = 3
      max_unavailable = 1

      instance_types = "m5.large"
      disk_size      = 50


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
      node_group_name = "windows-ondemand"
      create_launch_template = true
      launch_template_os = "windows"          # amazonlinux2eks  or bottlerocket or windows
      # custom_ami_id   = "ami-xxxxxxxxxxxxxxxx" # Bring your own custom AMI. Default Windows AMI is the latest EKS Optimized Windows Server 2019 English Core AMI.
      public_ip = false # Enable only for public subnets

      disk_size     = 50
      instance_type = "m5n.large"

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

      }

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      create_worker_security_group = false # Creates a dedicated sec group for this Node Group
    }
  */
  } # END OF SELF MANAGED NODE GROUPS

  #---------------------------------------------------------#
  # FARGATE PROFILES
  #---------------------------------------------------------#
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

  #---------------------------------------
  # FARGATE FLUENTBIT
  #---------------------------------------
  fargate_fluentbit_enable = false

  fargate_fluentbit_config = {
    output_conf  = <<EOF
[OUTPUT]
  Name cloudwatch_logs
  Match *
  region eu-west-1
  log_group_name /${local.cluster_name}/fargate-fluentbit-logs
  log_stream_prefix "fargate-logs-"
  auto_create_group true
    EOF
    filters_conf = <<EOF
[FILTER]
  Name parser
  Match *
  Key_Name log
  Parser regex
  Preserve_Key On
  Reserve_Data On
    EOF
    parsers_conf = <<EOF
[PARSER]
  Name regex
  Format regex
  Regex ^(?<time>[^ ]+) (?<stream>[^ ]+) (?<logtag>[^ ]+) (?<message>.+)$
  Time_Key time
  Time_Format %Y-%m-%dT%H:%M:%S.%L%z
  Time_Keep On
  Decode_Field_As json message
    EOF
  }

  #---------------------------------------
  # TRAEFIK INGRESS CONTROLLER HELM ADDON
  #---------------------------------------
  traefik_ingress_controller_enable = false

  # Optional Map value
  traefik_helm_chart = {
    name       = "traefik"                         # (Required) Release name.
    repository = "https://helm.traefik.io/traefik" # (Optional) Repository URL where to locate the requested chart.
    chart      = "traefik"                         # (Required) Chart name to be installed.
    version    = "10.0.0"                          # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace  = "kube-system"                     # (Optional) The namespace to install the release into. Defaults to default
    timeout    = "1200"                            # (Optional)
    lint       = "true"                            # (Optional)
    # (Optional) Example to show how to override values using SET
    set = [{
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
    }]
    # (Optional) Example to show how to pass traefik-values.yaml
    values = [templatefile("${path.module}/k8s_addons/traefik-values.yaml", {
      operating_system = "linux"
    })]
  }

  #---------------------------------------
  # METRICS SERVER HELM ADDON
  #---------------------------------------
  metrics_server_enable = true

  # Optional Map value
  metrics_server_helm_chart = {
    name       = "metrics-server"                                    # (Required) Release name.
    repository = "https://kubernetes-sigs.github.io/metrics-server/" # (Optional) Repository URL where to locate the requested chart.
    chart      = "metrics-server"                                    # (Required) Chart name to be installed.
    version    = "3.5.0"                                             # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace  = "kube-system"                                       # (Optional) The namespace to install the release into. Defaults to default
    timeout    = "1200"                                              # (Optional)
    lint       = "true"                                              # (Optional)

    # (Optional) Example to show how to pass metrics-server-values.yaml
    values = [templatefile("${path.module}/k8s_addons/metrics-server-values.yaml", {
      operating_system = "linux"
    })]
  }

  #---------------------------------------
  # CLUSTER AUTOSCALER HELM ADDON
  #---------------------------------------
  cluster_autoscaler_enable = true

  # Optional Map value
  cluster_autoscaler_helm_chart = {
    name       = "cluster-autoscaler"                      # (Required) Release name.
    repository = "https://kubernetes.github.io/autoscaler" # (Optional) Repository URL where to locate the requested chart.
    chart      = "cluster-autoscaler"                      # (Required) Chart name to be installed.
    version    = "9.10.7"                                  # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace  = "kube-system"                             # (Optional) The namespace to install the release into. Defaults to default
    timeout    = "1200"                                    # (Optional)
    lint       = "true"                                    # (Optional)

    # (Optional) Example to show how to pass cluster-autoscaler-values.yaml
    values = [templatefile("${path.module}/k8s_addons/cluster-autoscaler-vaues.yaml", {
      operating_system = "linux"
    })]
  }

  #---------------------------------------
  # AWS MANAGED PROMETHEUS ENABLE
  #---------------------------------------
  aws_managed_prometheus_enable         = false
  aws_managed_prometheus_workspace_name = "aws-managed-prometheus-workspace" # Optional

  #---------------------------------------
  # COMMUNITY PROMETHEUS ENABLE
  #---------------------------------------
  prometheus_enable = false

  # Optional Map value
  prometheus_helm_chart = {
    name       = "prometheus"                                         # (Required) Release name.
    repository = "https://prometheus-community.github.io/helm-charts" # (Optional) Repository URL where to locate the requested chart.
    chart      = "prometheus"                                         # (Required) Chart name to be installed.
    version    = "14.4."                                              # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace  = "prometheus"                                         # (Optional) The namespace to install the release into. Defaults to default
    values = [templatefile("${path.module}/k8s_addons/prometheus-values.yaml", {
      operating_system = "linux"
    })]

  }

  #---------------------------------------
  # ENABLE EMR ON EKS
  #---------------------------------------
  enable_emr_on_eks = true

  emr_on_eks_teams = {
    data_team_a = {
      emr_on_eks_username      = "emr-containers"
      emr_on_eks_namespace     = "spark"
      emr_on_eks_iam_role_name = "EMRonEKSExecution"
    }

    data_team_b = {
      emr_on_eks_username      = "data-team-b-user"
      emr_on_eks_namespace     = "data-team-b"
      emr_on_eks_iam_role_name = "data_team_b"
    }
  }
  #---------------------------------------
  # ENABLE NGINX
  #---------------------------------------

  nginx_ingress_controller_enable = false
  # Optional nginx_helm_chart
  nginx_helm_chart = {
    name       = "ingress-nginx"
    chart      = "ingress-nginx"
    repository = "https://kubernetes.github.io/ingress-nginx"
    version    = "3.33.0"
    namespace  = "kube-system"
    values     = [templatefile("${path.module}/k8s_addons/nginx-values.yaml", {})]
  }

  #---------------------------------------
  # ENABLE AGONES
  #---------------------------------------
  # NOTE: Agones requires a Node group in Public Subnets and enable Public IP
  agones_enable = false
  # Optional  agones_helm_chart
  agones_helm_chart = {
    name               = "agones"
    chart              = "agones"
    repository         = "https://agones.dev/chart/stable"
    version            = "1.15.0"
    namespace          = "kube-system"
    gameserver_minport = 7000 # required for sec group changes to worker nodes
    gameserver_maxport = 8000 # required for sec group changes to worker nodes
    values = [templatefile("${path.module}/k8s_addons/agones-values.yaml", {
      expose_udp            = true
      gameserver_namespaces = "{${join(",", ["default", "xbox-gameservers", "xbox-gameservers"])}}"
      gameserver_minport    = 7000
      gameserver_maxport    = 8000
    })]
  }

  #---------------------------------------
  # ENABLE AWS OPEN TELEMETRY
  #---------------------------------------
  aws_open_telemetry_enable = false
  aws_open_telemetry_addon = {
    aws_open_telemetry_namespace                        = "aws-otel-eks"
    aws_open_telemetry_emitter_otel_resource_attributes = "service.namespace=AWSObservability,service.name=ADOTEmitService"
    aws_open_telemetry_emitter_name                     = "trace-emitter"
    aws_open_telemetry_emitter_image                    = "public.ecr.aws/g9c4k4i4/trace-emitter:1"
    aws_open_telemetry_collector_image                  = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
    aws_open_telemetry_aws_region                       = "eu-west-1"
    aws_open_telemetry_emitter_oltp_endpoint            = "localhost:55680"
  }

  #---------------------------------------
  # AWS-FOR-FLUENTBIT HELM ADDON
  #---------------------------------------
  aws_for_fluentbit_enable = false

  aws_for_fluentbit_helm_chart = {
    name                                      = "aws-for-fluent-bit"
    chart                                     = "aws-for-fluent-bit"
    repository                                = "https://aws.github.io/eks-charts"
    version                                   = "0.1.0"
    namespace                                 = "logging"
    aws_for_fluent_bit_cw_log_group           = "/${local.cluster_name}/worker-fluentbit-logs" # Optional
    aws_for_fluentbit_cwlog_retention_in_days = 90
    create_namespace                          = true
    values = [templatefile("${path.module}/k8s_addons/aws-for-fluentbit-values.yaml", {
      region                          = data.aws_region.current.name,
      aws_for_fluent_bit_cw_log_group = "/${local.cluster_name}/worker-fluentbit-logs"
    })]
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }
  #---------------------------------------
  # SPARK K8S OPERATOR HELM ADDON
  #---------------------------------------
  spark_on_k8s_operator_enable = false

  # Optional Map value
  spark_on_k8s_operator_helm_chart = {
    name             = "spark-operator"
    chart            = "spark-operator"
    repository       = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
    version          = "1.1.6"
    namespace        = "spark-k8s-operator"
    timeout          = "1200"
    create_namespace = true
    values           = [templatefile("${path.module}/k8s_addons/spark-k8s-operator-values.yaml", {})]
  }

  #---------------------------------------
  # ENABLE ARGOCD
  #---------------------------------------
  argocd_enable = true
  # Optional Map value
  argocd_helm_chart = {
    name             = "argo-cd"
    chart            = "argo-cd"
    repository       = "https://argoproj.github.io/argo-helm"
    version          = "3.26.3"
    namespace        = "argocd"
    timeout          = "1200"
    create_namespace = true
    values           = [templatefile("${path.module}/k8s_addons/argocd-values.yaml", {})]
  }

}
