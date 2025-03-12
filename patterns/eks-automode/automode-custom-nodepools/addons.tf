
#---------------------------------------------------------------
# EKS Managed Addons
#---------------------------------------------------------------

resource "aws_eks_addon" "cw_observability" {
  count = var.enable_cloudwatch_observability ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"
  preserve                    = false
  pod_identity_association {
    role_arn        = module.aws_cloudwatch_observability_pod_identity.iam_role_arn
    service_account = "cloudwatch-agent"
  }
  depends_on = [
    module.vpc,
    module.eks,
    resource.kubectl_manifest.custom_nodeClass,
    resource.kubectl_manifest.custom_nodePool
  ]

}

# EKS Pod Identity for cloudwatch observability pods
module "aws_cloudwatch_observability_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  name   = "aws-cloudwatch-observability"

  create = var.enable_cloudwatch_observability

  attach_aws_cloudwatch_observability_policy = true

  # Pod Identity Association is created by module EKS using aws_eks_addon
  # associations = {
  #   aws_cloudwatch_observability = {
  #     cluster_name = module.eks.cluster_name
  #     namespace       = "amazon-cloudwatch"
  #     service_account = "cloudwatch-agent"
  #   }
  # }
}

#---------------------------------------------------------------
# EKS Blueprints Addons
#---------------------------------------------------------------

locals {
  aws_for_fluentbit_service_account = "aws-for-fluent-bit-sa"
  aws_for_fluentbit_namespace       = "kube-system"
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.2" # change this to version = 1.2.2 for older version of Karpenter deployment

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_metrics_server = true

  #---------------------------------------
  # AWS for FluentBit - DaemonSet
  #---------------------------------------
  # Fluentbit is used to stream the pod logs to CloudWatch
  # EKS Pod Identity is still not supported by aws-fluent-bit, then using IRSA - https://github.com/aws/aws-for-fluent-bit/issues/784
  enable_aws_for_fluentbit = true
  aws_for_fluentbit_cw_log_group = {
    use_name_prefix   = false
    name              = "/${local.name}/aws-fluentbit-logs" # Add-on creates this log group
    retention_in_days = 30
  }
  aws_for_fluentbit = {
    aws_for_fluentbit_service_account = local.aws_for_fluentbit_service_account
    aws_for_fluentbit_namespace       = local.aws_for_fluentbit_namespace
    create_role                       = true
    # set_irsa_names = []
    chart_version = "0.1.34"
  }

  #---------------------------------------
  # Prometheus and Grafana stack
  #---------------------------------------
  #---------------------------------------------------------------
  # Install Monitoring Stack with Prometheus and Grafana
  # 1- Grafana port-forward `kubectl port-forward svc/kube-prometheus-stack-grafana 8080:80 -n kube-prometheus-stack`
  # 2- Grafana Admin user: admin
  # 3- Get admin user password: `aws secretsmanager get-secret-value --secret-id <output.grafana_secret_name> --region $AWS_REGION --query "SecretString" --output text`
  #---------------------------------------------------------------
  enable_kube_prometheus_stack = true
  kube_prometheus_stack = {
    values        = [templatefile("${path.module}/helm-values/kube-prometheus.yaml", {})]
    chart_version = "69.7.3"
    set_sensitive = [
      {
        name  = "grafana.adminPassword"
        value = data.aws_secretsmanager_secret_version.admin_password_version.secret_string
      }
    ],
  }

  tags = local.tags
  depends_on = [
    module.vpc,
    module.eks,
    resource.kubectl_manifest.custom_nodeClass,
    resource.kubectl_manifest.custom_nodePool
  ]
}

#---------------------------------------------------------------
# Grafana Admin credentials resources
#---------------------------------------------------------------
data "aws_secretsmanager_secret_version" "admin_password_version" {
  secret_id  = aws_secretsmanager_secret.grafana.id
  depends_on = [aws_secretsmanager_secret_version.grafana]
}

resource "random_password" "grafana" {
  length           = 16
  special          = true
  override_special = "@_"
}

resource "random_string" "grafana" {
  length  = 4
  special = false
  lower   = true
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "grafana" {
  name                    = "${local.name}-grafana-${random_string.grafana.result}"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "grafana" {
  secret_id     = aws_secretsmanager_secret.grafana.id
  secret_string = random_password.grafana.result
}

#---------------------------------------------------------------
# Data on EKS Kubernetes Addons
#---------------------------------------------------------------
module "eks_data_addons" {
  source  = "aws-ia/eks-data-addons/aws"
  version = "1.33.0" # ensure to update this to the latest/desired version

  oidc_provider_arn = module.eks.oidc_provider_arn

  #---------------------------------------------------------------
  # Kubecost Add-on
  #---------------------------------------------------------------
  # Note: Kubecost add-on depends on Kube Prometheus Stack add-on for storing the metrics
  enable_kubecost = true
  kubecost_helm_config = {
    values              = [templatefile("${path.module}/helm-values/kubecost-values.yaml", {})]
    version             = "1.104.5"
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
  }

  depends_on = [
    module.vpc,
    module.eks,
    resource.kubectl_manifest.custom_nodeClass,
    resource.kubectl_manifest.custom_nodePool
  ]

}
