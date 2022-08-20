provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  name   = basename(path.cwd)
  region = "eu-west-1"

  vpc_cidr                          = "10.0.0.0/16"
  azs                               = slice(data.aws_availability_zones.available.names, 0, 3)
  airflow_namespace                 = "airflow"
  airflow_webserver_service_account = "airflow-webserver-sa"

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
  cluster_version = "1.22"

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
    # Core node group for deploying all the critical add-ons
    mng1 = {
      node_group_name = "core-node-grp"
      subnet_ids      = module.vpc.private_subnets

      instance_types = ["m5.xlarge"]
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"

      disk_size = 100
      disk_type = "gp3"

      max_size               = 9
      min_size               = 3
      desired_size           = 3
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"

      update_config = [{
        max_unavailable_percentage = 50
      }]

      k8s_labels = {
        Environment   = "preprod"
        Zone          = "test"
        WorkerType    = "ON_DEMAND"
        NodeGroupType = "core"
      }

      # See this doc node-template tags https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-scale-a-node-group-to-0
      additional_tags = {
        Name                                                             = "core-node-grp"
        subnet_type                                                      = "private"
        "k8s.io/cluster-autoscaler/node-template/label/arch"             = "x86"
        "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/os" = "linux"
        "k8s.io/cluster-autoscaler/node-template/label/noderole"         = "core"
        "k8s.io/cluster-autoscaler/node-template/label/node-lifecycle"   = "on-demand"
        "k8s.io/cluster-autoscaler/${local.name}"                        = "owned"
        "k8s.io/cluster-autoscaler/enabled"                              = "true"
      }
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# Kubernetes Add-ons
#---------------------------------------------------------------
module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # EKS Addons
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  enable_aws_efs_csi_driver           = true
  enable_aws_for_fluentbit            = true
  enable_aws_load_balancer_controller = true
  enable_airflow                      = true
  airflow_helm_config = {
    create_namespace = false
    timeout          = "180"
  }
  enable_prometheus = true
  #  enable_prometheus_statsd = true # add this add-on
  tags = local.tags
}

#---------------------------------------------------------------
# Apache Airflow Metadata database
#---------------------------------------------------------------
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier = local.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14.4"
  family               = "postgres14"
  major_engine_version = "14"
  instance_class       = "db.m6i.xlarge"

  storage_type      = "io1"
  allocated_storage = 100
  iops              = 3000

  db_name  = "airflow"
  username = "airflow"
  password = sensitive(data.aws_secretsmanager_secret_version.postgres.secret_string)
  port     = 5432

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "airflow-metastore"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Airflow Postgres Metastore for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}

#---------------------------------------------------------------
# S3 bucket for Airflow Logs
#---------------------------------------------------------------
#tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "this" {
  bucket_prefix = format("%s-%s", "airflow-logs", data.aws_caller_identity.current.account_id)
  tags          = local.tags
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

#---------------------------------------------------------------
# Apache Airflow Postgres Metastore DB Master password
#---------------------------------------------------------------
resource "random_password" "postgress" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "postgres" {
  name                    = "postgres"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id     = aws_secretsmanager_secret.postgres.id
  secret_string = random_password.postgress.result
}

data "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id

  depends_on = [aws_secretsmanager_secret_version.postgres]
}

#---------------------------------------------------------------
# Apache Airflow Webserver Secret
#---------------------------------------------------------------
resource "random_password" "airflow_webserver" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "airflow_webserver" {
  name                    = "airflow_webserver"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "airflow_webserver" {
  secret_id     = aws_secretsmanager_secret.airflow_webserver.id
  secret_string = random_password.airflow_webserver.result
}

data "aws_secretsmanager_secret_version" "airflow_webserver" {
  secret_id = aws_secretsmanager_secret.airflow_webserver.id

  depends_on = [aws_secretsmanager_secret_version.airflow_webserver]
}
#---------------------------------------------------------------
# Webserver Secret Key
#---------------------------------------------------------------
# You should set a static webserver secret key when deploying with this chart as it will help ensure your Airflow components only restart when necessary
# webserverSecretKeySecretName: my-webserver-secret

resource "kubectl_manifest" "airflow_webserver" {
  sensitive_fields = [
    "data.webserver-secret-key"
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
   name: airflow-webserver-secret
   namespace: ${module.airflow_irsa.namespace}
type: Opaque
data:
  webserver-secret-key: ${base64encode(data.aws_secretsmanager_secret_version.airflow_webserver.secret_string)}
YAML

  depends_on = [module.eks_blueprints.eks_cluster_id]
}

#---------------------------------------------------------------
# Managing DAG files with GitSync
#---------------------------------------------------------------
# set the following
#dags.gitSync.sshKeySecret
#dags.gitSync.knownHosts

# ssh-keyscan -t rsa github.com > github_public_key
# ssh-keygen -lf github_public_key

#dags:
#  gitSync:
#    knownHosts: |
#      github.com ssh-rsa AAAA...FAaQ==
#  sshKeySecret: airflow-ssh-secret

resource "kubectl_manifest" "git_ssh_secret" {
  sensitive_fields = [
    "data.gitSshKey"
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
   name: airflow-ssh-secret
   namespace: ${module.airflow_irsa.namespace}
type: Opaque
data:
  gitSshKey: ${base64encode(data.aws_secretsmanager_secret_version.airflow_webserver.secret_string)}
YAML

  depends_on = [module.eks_blueprints.eks_cluster_id]
}

#---------------------------------------------------------------
# IRSA for Airflow S3 logging
#---------------------------------------------------------------
module "airflow_irsa" {
  source = "../../../modules/irsa"

  eks_cluster_id             = local.name
  eks_oidc_provider_arn      = module.eks_blueprints.eks_oidc_provider_arn
  irsa_iam_policies          = [aws_iam_policy.airflow.arn]
  kubernetes_namespace       = local.airflow_namespace
  kubernetes_service_account = local.airflow_webserver_service_account
}

#---------------------------------------------------------------
# Creates IAM policy for IRSA. Provides IAM permissions for Spark driver/executor pods
#---------------------------------------------------------------
resource "aws_iam_policy" "airflow" {
  description = "IAM role policy for Airflow S3 Logs"
  name        = "${local.name}-airflow-irsa"
  policy      = data.aws_iam_policy_document.airflow_s3_logs.json
}

data "aws_iam_policy_document" "airflow_s3_logs" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.this.id}"]

    actions = [
      "s3:ListBucket"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.this.id}/*"]

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
  }
}
#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 20)]

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

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
