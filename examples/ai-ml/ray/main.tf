provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

provider "grafana" {
  url  = var.eks_cluster_domain == null ? data.kubernetes_ingress_v1.ingress.status[0].load_balancer[0].ingress[0].hostname : "https://ray-demo.${var.eks_cluster_domain}/monitoring"
  auth = "admin:${aws_secretsmanager_secret_version.grafana.secret_string}"
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "issued" {
  count = var.acm_certificate_domain == null ? 0 : 1

  domain   = var.acm_certificate_domain
  statuses = ["ISSUED"]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

locals {
  name      = basename(path.cwd)
  namespace = "ray-cluster"
  region    = var.region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../../.."

  cluster_name    = local.name
  cluster_version = "1.23"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

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
    # Recommended outbound traffic for Node groups
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
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.8xlarge"]
      min_size        = 3
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Blueprints AddOns
#---------------------------------------------------------------
module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version
  eks_cluster_domain   = var.eks_cluster_domain

  # Add-Ons
  enable_kuberay_operator             = true
  enable_ingress_nginx                = true
  enable_aws_load_balancer_controller = true
  enable_external_dns                 = var.eks_cluster_domain == null ? false : true
  enable_kube_prometheus_stack        = true

  # Add-on customizations
  ingress_nginx_helm_config = {
    values = [templatefile("${path.module}/helm-values/nginx-values.yaml", {
      hostname     = var.eks_cluster_domain
      ssl_cert_arn = var.acm_certificate_domain == null ? null : data.aws_acm_certificate.issued[0].arn
    })]
  }
  kube_prometheus_stack_helm_config = {
    values = [templatefile("${path.module}/helm-values/kube-stack-prometheus-values.yaml", {
      hostname = var.eks_cluster_domain
    })]
    set_sensitive = [
      {
        name  = "grafana.adminPassword"
        value = aws_secretsmanager_secret_version.grafana.secret_string
      }
    ]
  }

  tags = local.tags
}

data "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "ray-cluster-ingress"
    namespace = local.namespace
  }
  depends_on = [
    kubectl_manifest.cluster_provisioner
  ]
}

#---------------------------------------------------------------
# Deploy Ray Cluster Resources
#---------------------------------------------------------------
resource "aws_kms_key" "objects" {
  enable_key_rotation     = true
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

#tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v3.3.0"

  bucket_prefix           = "ray-demo-models-"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

data "aws_iam_policy_document" "irsa_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${module.s3_bucket.s3_bucket_arn}"]
  }
  statement {
    actions   = ["s3:*Object"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
  }
  statement {
    actions = [
      "ssm:PutParameter",
      "ssm:DeleteParameter",
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:DeleteParameters",
      "ssm:DescribeParameters"
    ]
    resources = ["arn:aws:ssm:${local.region}:${data.aws_caller_identity.current.account_id}:parameter/ray-*"]
  }

  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.objects.arn]
  }
}

resource "aws_iam_policy" "irsa_policy" {
  description = "IAM Policy for IRSA"
  name_prefix = substr("${module.eks_blueprints.eks_cluster_id}-${local.namespace}-access", 0, 127)
  policy      = data.aws_iam_policy_document.irsa_policy.json
}

module "cluster_irsa" {
  source                     = "../../../modules/irsa"
  kubernetes_namespace       = local.namespace
  kubernetes_service_account = "${local.namespace}-sa"
  irsa_iam_policies          = [aws_iam_policy.irsa_policy.arn]
  eks_cluster_id             = module.eks_blueprints.eks_cluster_id
  eks_oidc_provider_arn      = module.eks_blueprints.eks_oidc_provider_arn

  depends_on = [module.s3_bucket]
}

resource "kubectl_manifest" "cluster_provisioner" {
  yaml_body = templatefile("ray-clusters/example-cluster.yaml", {
    namespace       = local.namespace
    hostname        = var.eks_cluster_domain == null ? "" : var.eks_cluster_domain
    account_id      = data.aws_caller_identity.current.account_id
    region          = local.region
    service_account = "${local.namespace}-sa"
  })

  depends_on = [
    module.cluster_irsa,
    module.eks_blueprints_kubernetes_addons
  ]
}

#---------------------------------------------------------------
# Monitoring
#---------------------------------------------------------------
resource "kubectl_manifest" "prometheus" {
  yaml_body = templatefile("monitoring/monitor.yaml", {
    namespace = local.namespace
  })

  depends_on = [
    module.eks_blueprints_kubernetes_addons,
    kubectl_manifest.cluster_provisioner
  ]
}

resource "random_password" "grafana" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "grafana" {
  name_prefix             = "grafana-"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "grafana" {
  secret_id     = aws_secretsmanager_secret.grafana.id
  secret_string = random_password.grafana.result
}

resource "grafana_folder" "ray" {
  title = "ray"

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

resource "grafana_dashboard" "ray" {
  for_each = fileset("${path.module}/monitoring", "*.json")

  config_json = file("${path.module}/monitoring/${each.value}")
  folder      = grafana_folder.ray.id
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}
