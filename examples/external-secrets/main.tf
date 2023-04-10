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
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  name      = basename(path.cwd)
  namespace = "external-secrets"
  region    = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  cluster_secretstore_name = "cluster-secretstore-sm"
  cluster_secretstore_sa   = "cluster-secretstore-sa"
  secretstore_name         = "secretstore-ps"
  secretstore_sa           = "secretstore-sa"

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.12"

  cluster_name                   = local.name
  cluster_version                = "1.24"
  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 5
      desired_size = 2
    }
  }

  tags = local.tags
}

################################################################################
# Kubernetes Addons
################################################################################

module "eks_blueprints_kubernetes_addons" {
  source = "../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_provider    = module.eks.oidc_provider
  eks_cluster_version  = module.eks.cluster_version

  enable_external_secrets = true

  tags = local.tags
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

#---------------------------------------------------------------
# External Secrets Operator - Secret
#---------------------------------------------------------------

resource "aws_kms_key" "secrets" {
  enable_key_rotation = true
}

module "cluster_secretstore_role" {
  source                      = "../../modules/irsa"
  kubernetes_namespace        = local.namespace
  create_kubernetes_namespace = false
  kubernetes_service_account  = local.cluster_secretstore_sa
  irsa_iam_policies           = [aws_iam_policy.cluster_secretstore.arn]
  eks_cluster_id              = module.eks.cluster_name
  eks_oidc_provider_arn       = module.eks.oidc_provider_arn

  depends_on = [module.eks_blueprints_kubernetes_addons]
}

resource "aws_iam_policy" "cluster_secretstore" {
  name_prefix = local.cluster_secretstore_sa
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": "${aws_secretsmanager_secret.secret.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "${aws_kms_key.secrets.arn}"
    }
  ]
}
POLICY
}

resource "kubectl_manifest" "cluster_secretstore" {
  yaml_body  = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: ${local.cluster_secretstore_name}
spec:
  provider:
    aws:
      service: SecretsManager
      region: ${local.region}
      auth:
        jwt:
          serviceAccountRef:
            name: ${local.cluster_secretstore_sa}
            namespace: ${local.namespace}
YAML
  depends_on = [module.eks_blueprints_kubernetes_addons]
}

resource "aws_secretsmanager_secret" "secret" {
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.secrets.arn
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({
    username = "secretuser",
    password = "secretpassword"
  })
}

resource "kubectl_manifest" "secret" {
  yaml_body  = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${local.name}-sm
  namespace: ${local.namespace}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: ${local.cluster_secretstore_name}
    kind: ClusterSecretStore
  dataFrom:
  - extract:
      key: ${aws_secretsmanager_secret.secret.name}
YAML
  depends_on = [kubectl_manifest.cluster_secretstore]
}

#---------------------------------------------------------------
# External Secrets Operator - Parameter Store
#---------------------------------------------------------------

module "secretstore_role" {
  source                      = "../../modules/irsa"
  kubernetes_namespace        = local.namespace
  create_kubernetes_namespace = false
  kubernetes_service_account  = local.secretstore_sa
  irsa_iam_policies           = [aws_iam_policy.secretstore.arn]
  eks_cluster_id              = module.eks.cluster_name
  eks_oidc_provider_arn       = module.eks.oidc_provider_arn
  depends_on                  = [module.eks_blueprints_kubernetes_addons]
}

resource "aws_iam_policy" "secretstore" {
  name_prefix = local.secretstore_sa
  policy      = <<POLICY
{
	"Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter*"
      ],
      "Resource": "arn:aws:ssm:${local.region}:${data.aws_caller_identity.current.account_id}:parameter/${local.name}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "${aws_kms_key.secrets.arn}"
    }
  ]
}
POLICY
}

resource "kubectl_manifest" "secretstore" {
  yaml_body  = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: ${local.secretstore_name}
  namespace: ${local.namespace}
spec:
  provider:
    aws:
      service: ParameterStore
      region: ${local.region}
      auth:
        jwt:
          serviceAccountRef:
            name: ${local.secretstore_sa}
YAML
  depends_on = [module.eks_blueprints_kubernetes_addons]
}

resource "aws_ssm_parameter" "secret_parameter" {
  name = "/${local.name}/secret"
  type = "SecureString"
  value = jsonencode({
    username = "secretuser",
    password = "secretpassword"
  })
  key_id = aws_kms_key.secrets.arn
}


resource "kubectl_manifest" "secret_parameter" {
  yaml_body  = <<YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${local.name}-ps
  namespace: ${local.namespace}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: ${local.secretstore_name}
    kind: SecretStore
  dataFrom:
  - extract:
      key: ${aws_ssm_parameter.secret_parameter.name}
YAML
  depends_on = [kubectl_manifest.secretstore]
}
