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
  airflow_name                 = "airflow"
  airflow_webserver_service_account = "airflow-webserver-sa"
  airflow_webserver_secret_name = "airflow-webserver-secret"
  airflow_git_ssh_secret            = "airflow-git-ssh-secret"

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
  enable_prometheus = true

  enable_airflow                      = true
  airflow_helm_config = {
    name        = local.airflow_name
    chart       = local.airflow_name
    repository  = "https://airflow.apache.org"
    version     = "1.6.0"
    namespace   = local.airflow_name
    create_namespace = false
    timeout        = 240
    description = "Apache Airflow v2 Helm chart deployment configuration"
    values      = [templatefile("${path.module}/values.yaml", {
      airflow_db_name = module.db.db_instance_name
      airflow_db_port            = module.db.db_instance_port
      airflow_db_host = element(split(":", module.db.db_instance_endpoint), 0)
      #S3 bucket config
      s3_bucket_name  = aws_s3_bucket.this.id
      webserver_secret_name = local.airflow_webserver_secret_name
      airflow_git_ssh_secret = local.airflow_git_ssh_secret
    })]

    set_sensitive = [
      {
        name  = "data.metadataConnection.user"
        value = module.db.db_instance_username
      },
      {
        name  = "data.metadataConnection.pass"
        value = data.aws_secretsmanager_secret_version.postgres.secret_string
      }
    ]
  }

#  value = data.aws_secretsmanager_secret_version.postgres.secret_string
  tags = local.tags
}

#---------------------------------------------------------------
# Apache Airflow Metadata database
#---------------------------------------------------------------
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier = local.airflow_name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14.4"
  family               = "postgres14"
  major_engine_version = "14"
  instance_class       = "db.m6i.xlarge"

  storage_type      = "io1"
  allocated_storage = 100
  iops              = 3000

  db_name  = local.airflow_name
  username = local.airflow_name
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
resource "kubectl_manifest" "airflow_webserver" {
  sensitive_fields = [
    "data.webserver-secret-key"
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
   name: ${local.airflow_webserver_secret_name}
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
resource "kubectl_manifest" "git_ssh_secret" {
  sensitive_fields = [
    "data.gitSshKey"
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
   name: ${local.airflow_git_ssh_secret}
   namespace: ${module.airflow_irsa.namespace}
type: Opaque
data:
  gitSshKey: LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUNGd0FBQUFkemMyZ3RjbgpOaEFBQUFBd0VBQVFBQUFnRUFtb3hLQ09LMUJ5U1E4aDBMK3BvODY0OHJGcEVibkJrUzRqZ3ZMemYrb3lpNzhFWUt5L1lyCkt6RjNTeVlMYXZLc1FGZFdNRVVpR3VybEhCVjd5ekpBYXkvanlwSHhEUWxoa2VaYkhZNVE0ejIrcUZxazFEaE9rUEdlWlUKbU14SVBvdUtnTkVTd0hjV3ZYQng0U2FCUDNvZWdzN2Z5ZytVdXpjWmhUWTNMTE1MWmplQnNGZ1hVRWh4dk1pa01YQVU5eQpCRDYrRm5sMm5OMmt4VEw2V29DNWhiQlZFVE50Ulg5RnBDTmdxN2tGWnVqZDNDemZDTFBwN2JINGNoTUVMWThvWGF0WlNUCnB6Zmpsb2EyRlJhOGdMTzhiMTFXK3ZNU1paQitsSzIvMWQ2SW9veVMwYkZiT1oyRzc3TzhBZHVQWG1VWmNCYktkY0pFRWUKc2Q3QjJzYUR6WWZCc21OZkMyVTJML1RaZ1NYbmtiOW1hQkl6bnJjUG1JL0l2Y0NYMlVxc0tRTGxSODAvWWtZVXBHbHBqbApQNWRhb3ZmbE85bWNtWTJvdHhXMXdMbkdRbTV3UTk0aTFDbTlwRXhFOFBXbzd6RkhUNnVRbW5IcEJIVDJQbVJSTlNBRTdNClBZUG05UDA2MDNWbkxHdHVqbWZXTDdSMzh1c1hkL205NUNyVW55S1gxU0x2Y29lTWNQZHNhKzFkcytnL3dSWjI0SVkvaEIKM1cxTDhiZmhXVldaUjVORXhpYktnTDVSVS9QUUs1TUNQSHgveU5lckJhU21PMC9KaExlQnpoTFhJcldKS2RnN1h1ZTRJeQpMR280SUdDR0FkU3VUR3BDc3lnOTJmRmhRSWtHMFBJNTgyY0xvZ1k1UzhqeWFVSXg2OHJUWVo4WDBkWXpmVFVEYWJSTExWClVBQUFkUWlWZVkySWxYbU5nQUFBQUhjM05vTFhKellRQUFBZ0VBbW94S0NPSzFCeVNROGgwTCtwbzg2NDhyRnBFYm5Ca1MKNGpndkx6ZitveWk3OEVZS3kvWXJLekYzU3lZTGF2S3NRRmRXTUVVaUd1cmxIQlY3eXpKQWF5L2p5cEh4RFFsaGtlWmJIWQo1UTR6MitxRnFrMURoT2tQR2VaVW1NeElQb3VLZ05FU3dIY1d2WEJ4NFNhQlAzb2VnczdmeWcrVXV6Y1poVFkzTExNTFpqCmVCc0ZnWFVFaHh2TWlrTVhBVTl5QkQ2K0ZubDJuTjJreFRMNldvQzVoYkJWRVROdFJYOUZwQ05ncTdrRlp1amQzQ3pmQ0wKUHA3Ykg0Y2hNRUxZOG9YYXRaU1RwemZqbG9hMkZSYThnTE84YjExVyt2TVNaWkIrbEsyLzFkNklvb3lTMGJGYk9aMkc3NwpPOEFkdVBYbVVaY0JiS2RjSkVFZXNkN0Iyc2FEellmQnNtTmZDMlUyTC9UWmdTWG5rYjltYUJJem5yY1BtSS9JdmNDWDJVCnFzS1FMbFI4MC9Za1lVcEdscGpsUDVkYW92ZmxPOW1jbVkyb3R4VzF3TG5HUW01d1E5NGkxQ205cEV4RThQV283ekZIVDYKdVFtbkhwQkhUMlBtUlJOU0FFN01QWVBtOVAwNjAzVm5MR3R1am1mV0w3UjM4dXNYZC9tOTVDclVueUtYMVNMdmNvZU1jUApkc2ErMWRzK2cvd1JaMjRJWS9oQjNXMUw4YmZoV1ZXWlI1TkV4aWJLZ0w1UlUvUFFLNU1DUEh4L3lOZXJCYVNtTzAvSmhMCmVCemhMWElyV0pLZGc3WHVlNEl5TEdvNElHQ0dBZFN1VEdwQ3N5ZzkyZkZoUUlrRzBQSTU4MmNMb2dZNVM4anlhVUl4NjgKclRZWjhYMGRZemZUVURhYlJMTFZVQUFBQURBUUFCQUFBQ0FESUU4N1U2Z3JLa0lCRnNXME1waGt3TEV6d0RqUGNSbW00RApGeXBtS2hEdWp4MHQzakt6SXJlaEUrWUxreWh6RUZMbXNXdUFCSkRIczQxS1dyMmlMdjFDQzZ5MVhWb0Z6a0ZsVjlvU0JKClgzbHV4d0llYlpybnYwNTNvS3V2ZWpaYi9XREJ5aHJtc0VKeDBUbTR0NTR1elE4ekczVVBZK2pQNVgrYTAzS3hKQ0JhR0sKeFZabjVDWkNWZ250dXRWZXZCMHBuV1l5dTdQN2ZHZWlueXFKZlFJSzF3MXhJbzJhcXBSOEtyNkpiSGtwSngwcW5LajVhZAozWGV2eVlzUUo1MGV1M0dIZTk1a0ZWSFRtYnpybGVqbHd6Z2I4cG5YNy8xVkxkSzdCVnFYNG9zUmlqYzUrcmVFQjNjdktjCnRFSDN2Q3B1QURVRldhb1dOWFFHRDZIYUhDLzVVK0ptN203MlpkZ1VCR29na20xb1d4NGJvdVF2OExIekl5cGkwZVRma0gKdUpMWXg4RW9sSm9kS05sbmEydnQrTUNHZWo5L3h2Z3VIQjA2dko2TUhpN01ZLy9HQm5KVVlqQno3M2liYlQ2WE9uVkpnVQoxcUFWSXN2QW1uaFRPMUhGblUvWGphTFdDenA1OTgzUlcxb2ZIQlg1R3hXSldXcVN2NjlXSUdISm5aWXN5ZmNoSWpFLzdoCnFZUEFXdGFWZ3A2NlVPWVJjVlRMc29NbytrMUZkbW10NjVoajNyT2VHMzN6ZXM4a1FyUXE5WHEvMElsTkNtMmprZ0tGaW0KTjBmQXVQaU9WUVJrNjRRYUdEREh4UXBKNXNRL1NXZjB2Q2hnVTBnNGw0Q2F6RE1DQ3YzRnl2aU1lWTMxMDB4ekE1WTNmeApIMStFZUFIM09NcE9DdDM3RGxBQUFCQUJqc2drb2dBNHhrS0hNMGRycDg0RUpmYWlRR2crQUJnWXRKM1pZSUYwQ2w5QlpVClFETVQzZnRUVXgvRS8xdUdINXlEYVQxU1VUTTQ3dG4vZHJMbVpwTTVRU3NjTlRsYTFGKytrNmdvTENsdUVlc3lHWTZwVXAKREJvdFlXSnY0RnIzUVZWbTJhVHFRblVvMEwxeU1hNU5PTm9PRkFoZnlJNFZQQ2djMitRRUhNN2FwbUc2RzVnRE9kY0lsQwo2dXlCbE5SWWYvMGtXN3dHbmVWOUdKS0E1SkZDUVNmdkVZd3NVNzhza1NIRzJQd2hMU0YzZlVMNUhqeC96bVMvOEZNb0NXClloY0czbHJwZlorUnlLRFAyclRva3hIMUhxclVBaTg1Mjh3bWlQaVZzVmRDQ1Iyb0dFRC9GZDBVbU9UTi95V25oVGFnU2EKclF5VUJWMVdNd2dhMmZZQUFBRUJBTXZtdTNLcllzaDVJREpEQkhvRmV0WWtOU1V6WHlRWDV1eDAvczVuUnRZOWFFUjhRMApJN3lHZ3puMWE5dnNVTlZ4S3FOT3AwdXo5dXpwUDNaNm1ia29wYnlsaTdyMUF2bFVuNjBBRmlBWVBXOVlDVWZMaW83ejRtCnB2cllVVHIraXUwbzlDNmVnSFZNRDE4UnQ3MVU3RkFGUFlNNm1XUmRrYmNMQklETjFQRVd5eTFDNVdwQTFEdjQ3cDhkYVgKWlNLUG5FaDRaMEtCdjViM2VWOWZ1NlNEVUJQKzVQcjc5cWFabTloREkyaGl1VEJCazcycmhmellDR2I0TWh2cE12c01qNwp1MkJkWlY4K2RHWVBQL3BGVHZRSmNwYmpMYlUyQUJkaU9JbExXN2RWdzZJRjFhc2dHVkdXU3YxaWkraTJCNmgxUE5NckJICitBbzloK1pDKysrMDhBQUFFQkFNSUpWbmhpeGFjZTBRQjhJRWdpOHgzVFlzdVUwb3I2cWd4cGo0blM2ekcxc2N0TWt4OEUKdmtjSlk1c3BZQXhmNjRjM09pQ01TNHIwL0wwbkhSQXlYZ1ozTkdtNVRWQWZOazVIR3lVT1YvbEh2b2xSZnVpMzdsR2xjZApRZUpuZUY3cEd5U0hFUGdncFF5U3AvZ2VzR0FMdjBkdm00ZU5jMFNEeUVKQU91RlFqWnRzTVhISHUrdjNRd3RFYmVrVVlrCkNBMENUbk5PbUNybkFsK0JxK0dwWTJKRDdxcUNCZE5DTld4MUN1dGFZQ0xHcG9nRitvZDFoTCtkaWpHTFNGSm50VkJQeVkKWFkwa3FTT29lSmFyU3laMnV0WUxDV2ZzbmJCWEhISGtuSWQ2eHl5ZytNZ0U1UGd0N3REZlZGSVBnMHAraHJoZUY5WXJQTgpGRlNWd2ZVVGxCc0FBQUFWZG1GeVlTNWliMjUwYUhWQVoyMWhhV3d1WTI5dEFRSURCQVVHCi0tLS0tRU5EIE9QRU5TU0ggUFJJVkFURSBLRVktLS0tLQ==
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
  kubernetes_namespace       = local.airflow_name
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
