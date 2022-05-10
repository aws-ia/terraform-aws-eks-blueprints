provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

data "aws_availability_zones" "available" {}

data "aws_ami" "eks" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-*"]
  }
}

locals {
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  region      = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  cluster_name    = join("-", [local.tenant, local.environment, local.zone, "eks"])
  cluster_version = "1.21"

  terraform_version = "Terraform v1.0.1"
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  cidr = local.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

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
# Example to consume eks_blueprints module
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  cluster_version = local.cluster_version

  #----------------------------------------------------------------------------------------------------------#
  # Security groups used in this module created by the upstream modules terraform-aws-eks (https://github.com/terraform-aws-modules/terraform-aws-eks).
  #   Upstream module implemented Security groups based on the best practices doc https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html.
  #   So, by default the security groups are restrictive. Users needs to enable rules for specific ports required for App requirement or Add-ons
  #   See the notes below for each rule used in these examples
  #----------------------------------------------------------------------------------------------------------#
  node_security_group_additional_rules = {
    # Extend node-to-node security group rules. Recommended and required for the Add-ons
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    #Recommended outbound traffic for Node groups
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
    # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
    # Change this according to your security requirements if needed
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  managed_node_groups = {
    mg_4 = {
      node_group_name      = "managed-ondemand"
      instance_types       = ["m5.large"]
      subnet_ids           = module.aws_vpc.private_subnets
      force_update_version = true
    }
  }

  self_managed_node_groups = {
    self_mg_4 = {
      node_group_name    = "self-managed-ondemand"
      instance_type      = "m5.large"
      launch_template_os = "amazonlinux2eks"   # amazonlinux2eks  or bottlerocket or windows
      custom_ami_id      = data.aws_ami.eks.id # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
      subnet_ids         = module.aws_vpc.private_subnets
    }
  }

  fargate_profiles = {
    default = {
      fargate_profile_name = "default"
      fargate_profile_namespaces = [
        {
          namespace = "default"
          k8s_labels = {
            Environment = "preprod"
            Zone        = "dev"
            env         = "fargate"
          }
      }]
      subnet_ids = module.aws_vpc.private_subnets
      additional_tags = {
        ExtraTag = "Fargate"
      }
    },
  }

  # AWS Managed Services
  enable_amazon_prometheus = true
}

data "aws_eks_addon_version" "latest" {
  for_each = toset(["vpc-cni", "coredns"])

  addon_name         = each.value
  kubernetes_version = local.cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "default" {
  for_each = toset(["kube-proxy"])

  addon_name         = each.value
  kubernetes_version = local.cluster_version
  most_recent        = false
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../modules/kubernetes-addons"

  eks_cluster_id               = module.eks_blueprints.eks_cluster_id
  eks_worker_security_group_id = module.eks_blueprints.worker_node_security_group_id
  auto_scaling_group_names     = module.eks_blueprints.self_managed_node_group_autoscaling_groups

  enable_amazon_eks_vpc_cni = true
  amazon_eks_vpc_cni_config = {
    addon_version     = data.aws_eks_addon_version.latest["vpc-cni"].version
    resolve_conflicts = "OVERWRITE"
  }

  enable_amazon_eks_coredns = true
  amazon_eks_coredns_config = {
    addon_version     = data.aws_eks_addon_version.latest["coredns"].version
    resolve_conflicts = "OVERWRITE"
  }

  enable_amazon_eks_kube_proxy = true
  amazon_eks_kube_proxy_config = {
    addon_version     = data.aws_eks_addon_version.default["kube-proxy"].version
    resolve_conflicts = "OVERWRITE"
  }

  enable_amazon_eks_aws_ebs_csi_driver = true

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller_helm_config = {
    name       = "aws-load-balancer-controller"
    chart      = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    version    = "1.3.1"
  }

  enable_aws_node_termination_handler = true
  aws_node_termination_handler_helm_config = {
    name       = "aws-node-termination-handler"
    chart      = "aws-node-termination-handler"
    repository = "https://aws.github.io/eks-charts"
    version    = "0.18.2"
  }

  enable_traefik = true
  traefik_helm_config = {
    name       = "traefik"
    chart      = "traefik"
    repository = "https://helm.traefik.io/traefik"
    version    = "10.0.0"
    set = [{
      name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
    }]
    values = [templatefile("${path.module}/helm_values/traefik-values.yaml", {
      operating_system = "linux"
    })]
  }

  enable_metrics_server = true
  metrics_server_helm_config = {
    name       = "metrics-server"
    chart      = "metrics-server"
    repository = "https://kubernetes-sigs.github.io/metrics-server/"
    version    = "3.8.2"
    values = [templatefile("${path.module}/helm_values/metrics-server-values.yaml", {
      operating_system = "linux"
    })]
  }

  enable_cluster_autoscaler = true
  cluster_autoscaler_helm_config = {
    name       = "cluster-autoscaler"
    chart      = "cluster-autoscaler"
    repository = "https://kubernetes.github.io/autoscaler"
    version    = "9.10.7"
    values = [templatefile("${path.module}/helm_values/cluster-autoscaler-vaues.yaml", {
      operating_system = "linux"
    })]
  }

  # Prometheus and Amazon Managed Prometheus integration
  enable_prometheus                    = true
  enable_amazon_prometheus             = true
  amazon_prometheus_workspace_endpoint = module.eks_blueprints.amazon_prometheus_workspace_endpoint

  enable_ingress_nginx = true
  ingress_nginx_helm_config = {
    name       = "ingress-nginx"
    chart      = "ingress-nginx"
    repository = "https://kubernetes.github.io/ingress-nginx"
    version    = "3.33.0"
    values     = [templatefile("${path.module}/helm_values/nginx_values.yaml", {})]
  }

  # NOTE: Agones requires a Node group in Public Subnets and enable Public IP
  enable_agones = true
  agones_helm_config = {
    name               = "agones"
    chart              = "agones"
    repository         = "https://agones.dev/chart/stable"
    version            = "1.15.0"
    gameserver_minport = 7000 # required for sec group changes to worker nodes
    gameserver_maxport = 8000 # required for sec group changes to worker nodes
    values = [templatefile("${path.module}/helm_values/agones-values.yaml", {
      expose_udp            = true
      gameserver_namespaces = "{${join(",", ["default", "xbox-gameservers", "xbox-gameservers"])}}"
      gameserver_minport    = 7000
      gameserver_maxport    = 8000
    })]
  }

  enable_aws_for_fluentbit = true
  aws_for_fluentbit_helm_config = {
    name                                      = "aws-for-fluent-bit"
    chart                                     = "aws-for-fluent-bit"
    repository                                = "https://aws.github.io/eks-charts"
    version                                   = "0.1.0"
    namespace                                 = "logging"
    aws_for_fluent_bit_cw_log_group           = "/${module.eks_blueprints.eks_cluster_id}/worker-fluentbit-logs" # Optional
    aws_for_fluentbit_cwlog_retention_in_days = 90
    create_namespace                          = true
    values = [templatefile("${path.module}/helm_values/aws-for-fluentbit-values.yaml", {
      region                          = local.region
      aws_for_fluent_bit_cw_log_group = "/${module.eks_blueprints.eks_cluster_id}/worker-fluentbit-logs"
    })]
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }

  enable_fargate_fluentbit = true
  fargate_fluentbit_addon_config = {
    output_conf = <<-EOF
    [OUTPUT]
      Name cloudwatch_logs
      Match *
      region ${local.region}
      log_group_name /${module.eks_blueprints.eks_cluster_id}/fargate-fluentbit-logs
      log_stream_prefix "fargate-logs-"
      auto_create_group true
    EOF

    filters_conf = <<-EOF
    [FILTER]
      Name parser
      Match *
      Key_Name log
      Parser regex
      Preserve_Key True
      Reserve_Data True
    EOF

    parsers_conf = <<-EOF
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

  enable_argocd = true
  argocd_helm_config = {
    name             = "argo-cd"
    chart            = "argo-cd"
    repository       = "https://argoproj.github.io/argo-helm"
    version          = "3.26.3"
    namespace        = "argocd"
    create_namespace = true
    values           = [templatefile("${path.module}/helm_values/argocd-values.yaml", {})]
  }

  enable_keda = true
  keda_helm_config = {
    name       = "keda"
    chart      = "keda"
    repository = "https://kedacore.github.io/charts"
    version    = "2.6.2"
    namespace  = "keda"
    values     = [templatefile("${path.module}/helm_values/keda-values.yaml", {})]
  }

  enable_vpa = true
  vpa_helm_config = {
    name       = "vpa"
    chart      = "vpa"
    repository = "https://charts.fairwinds.com/stable"
    version    = "1.0.0"
    namespace  = "vpa"
    values     = [templatefile("${path.module}/helm_values/vpa-values.yaml", {})]
  }

  depends_on = [module.eks_blueprints.managed_node_groups]
}
