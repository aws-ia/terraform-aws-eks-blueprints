provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

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

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.30"

  cluster_name    = local.name
  cluster_version = "1.24"

  cluster_enabled_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      # Required for EMR on EKS virtual cluster
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSServiceRoleForAmazonEMRContainers"
      username = "emr-containers"
    },
  ]

  fargate_profiles = {
    kube_system = {
      name = "kube-system"
      selectors = [
        { namespace = "kube-system" }
      ]
    }
    # Wildcard profile for EMR namespaces (prefix with `emr-`)
    emr_wildcard = {
      name = "emr-wildcard"
      selectors = [
        { namespace = "emr-*" }
      ]
    }
  }

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id        = module.eks.cluster_id
  eks_cluster_endpoint  = module.eks.cluster_endpoint
  eks_oidc_provider     = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  eks_cluster_version   = module.eks.cluster_version

  # Wait on the `kube-system` profile before provisioning addons
  data_plane_wait_arn = module.eks.aws_auth_configmap_yaml

  enable_self_managed_coredns       = true
  remove_default_coredns_deployment = true
  self_managed_coredns_helm_config = {
    # Sets the correct annotations to ensure the Fargate provisioner is used and not the EC2 provisioner
    compute_type       = "fargate"
    kubernetes_version = module.eks.cluster_version
  }

  # Enable Fargate logging
  enable_fargate_fluentbit = true

  enable_emr_on_eks = true
  emr_on_eks_config = {
    # Default settigns
    emr-containers = {
      namespace = "emr-default"
    }
    # Example of all settings
    custom = {
      name = "emr-custom"

      create_namespace = true
      namespace        = "emr-custom"

      create_iam_role = true
      s3_bucket_arns = [
        module.s3_bucket.s3_bucket_arn,
        "${module.s3_bucket.s3_bucket_arn}/*"
      ]
      role_name                     = "emr-custom-role"
      iam_role_use_name_prefix      = false
      iam_role_path                 = "/"
      iam_role_description          = "EMR custom Role"
      iam_role_permissions_boundary = null
      iam_role_additional_policies  = []

      tags = {
        AdditionalTags = "sure"
      }
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# Sample Spark Job
#---------------------------------------------------------------

resource "null_resource" "s3_sync" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]

    environment = {
      AWS_DEFAULT_REGION = local.region
    }

    # Sync to a bucket that we can provide access to (see `s3_bucket_arns` above)
    command = <<-EOT
      aws s3 sync s3://aws-data-analytics-workshops/emr-eks-workshop/scripts/ s3://${module.s3_bucket.s3_bucket_id}/emr-eks-workshop/scripts/
    EOT
  }
}

resource "time_sleep" "coredns" {
  create_duration = "60s"

  # In practice, this generally won't be necessary since the cluster will be provisioned long before jobs are scheduled on the cluster
  # However, for this example, its necessary to ensure CoreDNS is ready before we schedule the example job
  triggers = {
    coredns = module.eks_blueprints_kubernetes_addons.aws_coredns.service_account
  }
}

resource "null_resource" "start_job_run" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]

    environment = {
      AWS_DEFAULT_REGION = local.region
    }

    command = <<-EOT
      aws emr-containers start-job-run \
      --virtual-cluster-id ${module.eks_blueprints_kubernetes_addons.emr_on_eks["custom"].virtual_cluster_id} \
      --name ${local.name}-example \
      --execution-role-arn ${module.eks_blueprints_kubernetes_addons.emr_on_eks["custom"].job_execution_role_arn} \
      --release-label emr-6.8.0-latest \
      --job-driver '{
          "sparkSubmitJobDriver": {
              "entryPoint": "s3://${module.s3_bucket.s3_bucket_id}/emr-eks-workshop/scripts/pi.py",
              "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
              }
          }' \
      --configuration-overrides '{
          "applicationConfiguration": [
            {
              "classification": "spark-defaults",
              "properties": {
                "spark.driver.memory":"2G"
              }
            }
          ],
          "monitoringConfiguration": {
            "cloudWatchMonitoringConfiguration": {
              "logGroupName": "${module.eks_blueprints_kubernetes_addons.emr_on_eks["custom"].cloudwatch_log_group_name}",
              "logStreamNamePrefix": "eks-blueprints"
            }
          }
        }'
    EOT
  }

  depends_on = [
    time_sleep.coredns
  ]
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
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 3.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc_endpoints_sg.security_group_id]

  endpoints = merge({
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = {
        Name = "${local.name}-s3"
      }
    }
    },
    { for service in toset(["ecr.api", "ecr.dkr", "sts", "logs"]) :
      replace(service, ".", "_") =>
      {
        service             = service
        subnet_ids          = module.vpc.private_subnets
        private_dns_enabled = true
        tags                = { Name = "${local.name}-${service}" }
      }
  })

  tags = local.tags
}

################################################################################
# VPC Endpoints - Security Group
################################################################################

module "vpc_endpoints_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-vpc-endpoints"
  description = "Security group for VPC endpoint access"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "VPC CIDR HTTPS"
      cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
    },
  ]

  tags = local.tags
}

#tfsec:ignore:*
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> v3.0"

  bucket_prefix = "${local.name}-"

  # Allow deletion of non-empty bucket
  # Example usage only - not recommended for production
  force_destroy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}
