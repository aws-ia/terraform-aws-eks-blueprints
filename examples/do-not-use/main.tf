data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# This resource is used to provide a means of mapping an implicit dependency
# between the cluster and the addons.
resource "time_sleep" "this" {
  create_duration = var.create_delay_duration

  triggers = {
    cluster_endpoint  = var.cluster_endpoint
    cluster_name      = var.cluster_name
    custom            = join(",", var.create_delay_dependencies)
    oidc_provider_arn = var.oidc_provider_arn
  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  dns_suffix = data.aws_partition.current.dns_suffix
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name

  # Threads the sleep resource into the module to make the dependency
  cluster_endpoint  = time_sleep.this.triggers["cluster_endpoint"]
  cluster_name      = time_sleep.this.triggers["cluster_name"]
  oidc_provider_arn = time_sleep.this.triggers["oidc_provider_arn"]

  iam_role_policy_prefix = "arn:${local.partition}:iam::aws:policy"

  # Used by Karpenter & AWS Node Termination Handler
  ec2_events = {
    health_event = {
      name        = "HealthEvent"
      description = "AWS health event"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      }
    }
    spot_interupt = {
      name        = "SpotInterrupt"
      description = "EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    instance_rebalance = {
      name        = "InstanceRebalance"
      description = "EC2 instance rebalance recommendation"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    instance_state_change = {
      name        = "InstanceStateChange"
      description = "EC2 instance state-change notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }
  }
}

################################################################################
# Argo Rollouts
################################################################################

module "argo_rollouts" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_argo_rollouts

  # https://github.com/argoproj/argo-helm/tree/main/charts/argo-rollouts
  name             = try(var.argo_rollouts.name, "argo-rollouts")
  description      = try(var.argo_rollouts.description, "A Helm chart for Argo Rollouts")
  namespace        = try(var.argo_rollouts.namespace, "argo-rollouts")
  create_namespace = try(var.argo_rollouts.create_namespace, true)
  chart            = "argo-rollouts"
  chart_version    = try(var.argo_rollouts.chart_version, "2.22.3")
  repository       = try(var.argo_rollouts.repository, "https://argoproj.github.io/argo-helm")
  values           = try(var.argo_rollouts.values, [])

  timeout                    = try(var.argo_rollouts.timeout, null)
  repository_key_file        = try(var.argo_rollouts.repository_key_file, null)
  repository_cert_file       = try(var.argo_rollouts.repository_cert_file, null)
  repository_ca_file         = try(var.argo_rollouts.repository_ca_file, null)
  repository_username        = try(var.argo_rollouts.repository_username, null)
  repository_password        = try(var.argo_rollouts.repository_password, null)
  devel                      = try(var.argo_rollouts.devel, null)
  verify                     = try(var.argo_rollouts.verify, null)
  keyring                    = try(var.argo_rollouts.keyring, null)
  disable_webhooks           = try(var.argo_rollouts.disable_webhooks, null)
  reuse_values               = try(var.argo_rollouts.reuse_values, null)
  reset_values               = try(var.argo_rollouts.reset_values, null)
  force_update               = try(var.argo_rollouts.force_update, null)
  recreate_pods              = try(var.argo_rollouts.recreate_pods, null)
  cleanup_on_fail            = try(var.argo_rollouts.cleanup_on_fail, null)
  max_history                = try(var.argo_rollouts.max_history, null)
  atomic                     = try(var.argo_rollouts.atomic, null)
  skip_crds                  = try(var.argo_rollouts.skip_crds, null)
  render_subchart_notes      = try(var.argo_rollouts.render_subchart_notes, null)
  disable_openapi_validation = try(var.argo_rollouts.disable_openapi_validation, null)
  wait                       = try(var.argo_rollouts.wait, null)
  wait_for_jobs              = try(var.argo_rollouts.wait_for_jobs, null)
  dependency_update          = try(var.argo_rollouts.dependency_update, null)
  replace                    = try(var.argo_rollouts.replace, null)
  lint                       = try(var.argo_rollouts.lint, null)

  postrender    = try(var.argo_rollouts.postrender, [])
  set           = try(var.argo_rollouts.set, [])
  set_sensitive = try(var.argo_rollouts.set_sensitive, [])

  tags = var.tags
}

################################################################################
# Argo Workflows
################################################################################

module "argo_workflows" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_argo_workflows

  # https://github.com/argoproj/argo-helm/tree/main/charts/argo-workflows
  name             = try(var.argo_workflows.name, "argo-workflows")
  description      = try(var.argo_workflows.description, "A Helm chart for Argo Workflows")
  namespace        = try(var.argo_workflows.namespace, "argo-workflows")
  create_namespace = try(var.argo_workflows.create_namespace, true)
  chart            = "argo-workflows"
  chart_version    = try(var.argo_workflows.chart_version, "2.22.13")
  repository       = try(var.argo_workflows.repository, "https://argoproj.github.io/argo-helm")
  values           = try(var.argo_workflows.values, [])

  timeout                    = try(var.argo_workflows.timeout, null)
  repository_key_file        = try(var.argo_workflows.repository_key_file, null)
  repository_cert_file       = try(var.argo_workflows.repository_cert_file, null)
  repository_ca_file         = try(var.argo_workflows.repository_ca_file, null)
  repository_username        = try(var.argo_workflows.repository_username, null)
  repository_password        = try(var.argo_workflows.repository_password, null)
  devel                      = try(var.argo_workflows.devel, null)
  verify                     = try(var.argo_workflows.verify, null)
  keyring                    = try(var.argo_workflows.keyring, null)
  disable_webhooks           = try(var.argo_workflows.disable_webhooks, null)
  reuse_values               = try(var.argo_workflows.reuse_values, null)
  reset_values               = try(var.argo_workflows.reset_values, null)
  force_update               = try(var.argo_workflows.force_update, null)
  recreate_pods              = try(var.argo_workflows.recreate_pods, null)
  cleanup_on_fail            = try(var.argo_workflows.cleanup_on_fail, null)
  max_history                = try(var.argo_workflows.max_history, null)
  atomic                     = try(var.argo_workflows.atomic, null)
  skip_crds                  = try(var.argo_workflows.skip_crds, null)
  render_subchart_notes      = try(var.argo_workflows.render_subchart_notes, null)
  disable_openapi_validation = try(var.argo_workflows.disable_openapi_validation, null)
  wait                       = try(var.argo_workflows.wait, null)
  wait_for_jobs              = try(var.argo_workflows.wait_for_jobs, null)
  dependency_update          = try(var.argo_workflows.dependency_update, null)
  replace                    = try(var.argo_workflows.replace, null)
  lint                       = try(var.argo_workflows.lint, null)

  postrender    = try(var.argo_workflows.postrender, [])
  set           = try(var.argo_workflows.set, [])
  set_sensitive = try(var.argo_workflows.set_sensitive, [])

  tags = var.tags
}

################################################################################
# ArgoCD
################################################################################

module "argocd" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_argocd

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/Chart.yaml
  # (there is no offical helm chart for argocd)
  name             = try(var.argocd.name, "argo-cd")
  description      = try(var.argocd.description, "A Helm chart to install the ArgoCD")
  namespace        = try(var.argocd.namespace, "argocd")
  create_namespace = try(var.argocd.create_namespace, true)
  chart            = "argo-cd"
  chart_version    = try(var.argocd.chart_version, "5.29.1")
  repository       = try(var.argocd.repository, "https://argoproj.github.io/argo-helm")
  values           = try(var.argocd.values, [])

  timeout                    = try(var.argocd.timeout, null)
  repository_key_file        = try(var.argocd.repository_key_file, null)
  repository_cert_file       = try(var.argocd.repository_cert_file, null)
  repository_ca_file         = try(var.argocd.repository_ca_file, null)
  repository_username        = try(var.argocd.repository_username, null)
  repository_password        = try(var.argocd.repository_password, null)
  devel                      = try(var.argocd.devel, null)
  verify                     = try(var.argocd.verify, null)
  keyring                    = try(var.argocd.keyring, null)
  disable_webhooks           = try(var.argocd.disable_webhooks, null)
  reuse_values               = try(var.argocd.reuse_values, null)
  reset_values               = try(var.argocd.reset_values, null)
  force_update               = try(var.argocd.force_update, null)
  recreate_pods              = try(var.argocd.recreate_pods, null)
  cleanup_on_fail            = try(var.argocd.cleanup_on_fail, null)
  max_history                = try(var.argocd.max_history, null)
  atomic                     = try(var.argocd.atomic, null)
  skip_crds                  = try(var.argocd.skip_crds, null)
  render_subchart_notes      = try(var.argocd.render_subchart_notes, null)
  disable_openapi_validation = try(var.argocd.disable_openapi_validation, null)
  wait                       = try(var.argocd.wait, null)
  wait_for_jobs              = try(var.argocd.wait_for_jobs, null)
  dependency_update          = try(var.argocd.dependency_update, null)
  replace                    = try(var.argocd.replace, null)
  lint                       = try(var.argocd.lint, null)

  postrender    = try(var.argocd.postrender, [])
  set           = try(var.argocd.set, [])
  set_sensitive = try(var.argocd.set_sensitive, [])

  tags = var.tags
}

################################################################################
# AWS Cloudwatch Metrics
################################################################################

locals {
  aws_cloudwatch_metrics_service_account = try(var.aws_cloudwatch_metrics.service_account_name, "aws-cloudwatch-metrics")
}

module "aws_cloudwatch_metrics" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_aws_cloudwatch_metrics

  # https://github.com/aws/eks-charts/tree/master/stable/aws-cloudwatch-metrics
  name             = try(var.aws_cloudwatch_metrics.name, "aws-cloudwatch-metrics")
  description      = try(var.aws_cloudwatch_metrics.description, "A Helm chart to deploy aws-cloudwatch-metrics project")
  namespace        = try(var.aws_cloudwatch_metrics.namespace, "amazon-cloudwatch")
  create_namespace = try(var.aws_cloudwatch_metrics.create_namespace, true)
  chart            = "aws-cloudwatch-metrics"
  chart_version    = try(var.aws_cloudwatch_metrics.chart_version, "0.0.8")
  repository       = try(var.aws_cloudwatch_metrics.repository, "https://aws.github.io/eks-charts")
  values           = try(var.aws_cloudwatch_metrics.values, [])

  timeout                    = try(var.aws_cloudwatch_metrics.timeout, null)
  repository_key_file        = try(var.aws_cloudwatch_metrics.repository_key_file, null)
  repository_cert_file       = try(var.aws_cloudwatch_metrics.repository_cert_file, null)
  repository_ca_file         = try(var.aws_cloudwatch_metrics.repository_ca_file, null)
  repository_username        = try(var.aws_cloudwatch_metrics.repository_username, null)
  repository_password        = try(var.aws_cloudwatch_metrics.repository_password, null)
  devel                      = try(var.aws_cloudwatch_metrics.devel, null)
  verify                     = try(var.aws_cloudwatch_metrics.verify, null)
  keyring                    = try(var.aws_cloudwatch_metrics.keyring, null)
  disable_webhooks           = try(var.aws_cloudwatch_metrics.disable_webhooks, null)
  reuse_values               = try(var.aws_cloudwatch_metrics.reuse_values, null)
  reset_values               = try(var.aws_cloudwatch_metrics.reset_values, null)
  force_update               = try(var.aws_cloudwatch_metrics.force_update, null)
  recreate_pods              = try(var.aws_cloudwatch_metrics.recreate_pods, null)
  cleanup_on_fail            = try(var.aws_cloudwatch_metrics.cleanup_on_fail, null)
  max_history                = try(var.aws_cloudwatch_metrics.max_history, null)
  atomic                     = try(var.aws_cloudwatch_metrics.atomic, null)
  skip_crds                  = try(var.aws_cloudwatch_metrics.skip_crds, null)
  render_subchart_notes      = try(var.aws_cloudwatch_metrics.render_subchart_notes, null)
  disable_openapi_validation = try(var.aws_cloudwatch_metrics.disable_openapi_validation, null)
  wait                       = try(var.aws_cloudwatch_metrics.wait, null)
  wait_for_jobs              = try(var.aws_cloudwatch_metrics.wait_for_jobs, null)
  dependency_update          = try(var.aws_cloudwatch_metrics.dependency_update, null)
  replace                    = try(var.aws_cloudwatch_metrics.replace, null)
  lint                       = try(var.aws_cloudwatch_metrics.lint, null)

  postrender = try(var.aws_cloudwatch_metrics.postrender, [])
  set = concat(
    [
      {
        name  = "clusterName"
        value = local.cluster_name
      },
      {
        name  = "serviceAccount.name"
        value = local.aws_cloudwatch_metrics_service_account
      }
    ],
    try(var.aws_cloudwatch_metrics.set, [])
  )
  set_sensitive = try(var.aws_cloudwatch_metrics.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.aws_cloudwatch_metrics.create_role, true)
  role_name                     = try(var.aws_cloudwatch_metrics.role_name, "aws-cloudwatch-metrics")
  role_name_use_prefix          = try(var.aws_cloudwatch_metrics.role_name_use_prefix, true)
  role_path                     = try(var.aws_cloudwatch_metrics.role_path, "/")
  role_permissions_boundary_arn = try(var.aws_cloudwatch_metrics.role_permissions_boundary_arn, null)
  role_description              = try(var.aws_cloudwatch_metrics.role_description, "IRSA for aws-cloudwatch-metrics project")
  role_policies = lookup(var.aws_cloudwatch_metrics, "role_policies",
    { CloudWatchAgentServerPolicy = "arn:${local.partition}:iam::aws:policy/CloudWatchAgentServerPolicy" }
  )
  create_policy = try(var.aws_cloudwatch_metrics.create_policy, false)

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_cloudwatch_metrics_service_account
    }
  }

  tags = var.tags
}

################################################################################
# AWS EFS CSI DRIVER
################################################################################

locals {
  aws_efs_csi_driver_controller_service_account = try(var.aws_efs_csi_driver.controller_service_account_name, "efs-csi-controller-sa")
  aws_efs_csi_driver_node_service_account       = try(var.aws_efs_csi_driver.node_service_account_name, "efs-csi-node-sa")
  efs_arns = lookup(var.aws_efs_csi_driver, "efs_arns",
    ["arn:${local.partition}:elasticfilesystem:${local.region}:${local.account_id}:file-system/*"],
  )
  efs_access_point_arns = lookup(var.aws_efs_csi_driver, "efs_access_point_arns",
    ["arn:${local.partition}:elasticfilesystem:${local.region}:${local.account_id}:access-point/*"]
  )
}

data "aws_iam_policy_document" "aws_efs_csi_driver" {
  count = var.enable_aws_efs_csi_driver ? 1 : 0

  statement {
    sid       = "AllowDescribeAvailabilityZones"
    actions   = ["ec2:DescribeAvailabilityZones"]
    resources = ["*"]
  }

  statement {
    sid = "AllowDescribeFileSystems"
    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets"
    ]
    resources = flatten([
      local.efs_arns,
      local.efs_access_point_arns,
    ])
  }

  statement {
    sid       = "AllowCreateAccessPoint"
    actions   = ["elasticfilesystem:CreateAccessPoint"]
    resources = local.efs_arns

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    sid       = "AllowDeleteAccessPoint"
    actions   = ["elasticfilesystem:DeleteAccessPoint"]
    resources = local.efs_access_point_arns

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    sid = "ClientReadWrite"
    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount",
    ]
    resources = local.efs_arns

    condition {
      test     = "Bool"
      variable = "elasticfilesystem:AccessedViaMountTarget"
      values   = ["true"]
    }
  }
}

module "aws_efs_csi_driver" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_aws_efs_csi_driver

  # https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/charts/aws-efs-csi-driver
  name             = try(var.aws_efs_csi_driver.name, "aws-efs-csi-driver")
  description      = try(var.aws_efs_csi_driver.description, "A Helm chart to deploy aws-efs-csi-driver")
  namespace        = try(var.aws_efs_csi_driver.namespace, "kube-system")
  create_namespace = try(var.aws_efs_csi_driver.create_namespace, false)
  chart            = "aws-efs-csi-driver"
  chart_version    = try(var.aws_efs_csi_driver.chart_version, "2.4.1")
  repository       = try(var.aws_efs_csi_driver.repository, "https://kubernetes-sigs.github.io/aws-efs-csi-driver/")
  values           = try(var.aws_efs_csi_driver.values, [])

  timeout                    = try(var.aws_efs_csi_driver.timeout, null)
  repository_key_file        = try(var.aws_efs_csi_driver.repository_key_file, null)
  repository_cert_file       = try(var.aws_efs_csi_driver.repository_cert_file, null)
  repository_ca_file         = try(var.aws_efs_csi_driver.repository_ca_file, null)
  repository_username        = try(var.aws_efs_csi_driver.repository_username, null)
  repository_password        = try(var.aws_efs_csi_driver.repository_password, null)
  devel                      = try(var.aws_efs_csi_driver.devel, null)
  verify                     = try(var.aws_efs_csi_driver.verify, null)
  keyring                    = try(var.aws_efs_csi_driver.keyring, null)
  disable_webhooks           = try(var.aws_efs_csi_driver.disable_webhooks, null)
  reuse_values               = try(var.aws_efs_csi_driver.reuse_values, null)
  reset_values               = try(var.aws_efs_csi_driver.reset_values, null)
  force_update               = try(var.aws_efs_csi_driver.force_update, null)
  recreate_pods              = try(var.aws_efs_csi_driver.recreate_pods, null)
  cleanup_on_fail            = try(var.aws_efs_csi_driver.cleanup_on_fail, null)
  max_history                = try(var.aws_efs_csi_driver.max_history, null)
  atomic                     = try(var.aws_efs_csi_driver.atomic, null)
  skip_crds                  = try(var.aws_efs_csi_driver.skip_crds, null)
  render_subchart_notes      = try(var.aws_efs_csi_driver.render_subchart_notes, null)
  disable_openapi_validation = try(var.aws_efs_csi_driver.disable_openapi_validation, null)
  wait                       = try(var.aws_efs_csi_driver.wait, null)
  wait_for_jobs              = try(var.aws_efs_csi_driver.wait_for_jobs, null)
  dependency_update          = try(var.aws_efs_csi_driver.dependency_update, null)
  replace                    = try(var.aws_efs_csi_driver.replace, null)
  lint                       = try(var.aws_efs_csi_driver.lint, null)

  postrender = try(var.aws_efs_csi_driver.postrender, [])
  set = concat([
    {
      name  = "controller.serviceAccount.name"
      value = local.aws_efs_csi_driver_controller_service_account
    },
    {
      name  = "node.serviceAccount.name"
      value = local.aws_efs_csi_driver_node_service_account
    }],
    try(var.aws_efs_csi_driver.set, [])
  )
  set_sensitive = try(var.aws_efs_csi_driver.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names = [
    "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn",
    "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  ]
  create_role                   = try(var.aws_efs_csi_driver.create_role, true)
  role_name                     = try(var.aws_efs_csi_driver.role_name, "aws-efs-csi-driver")
  role_name_use_prefix          = try(var.aws_efs_csi_driver.role_name_use_prefix, true)
  role_path                     = try(var.aws_efs_csi_driver.role_path, "/")
  role_permissions_boundary_arn = lookup(var.aws_efs_csi_driver, "role_permissions_boundary_arn", null)
  role_description              = try(var.aws_efs_csi_driver.role_description, "IRSA for aws-efs-csi-driver project")
  role_policies                 = lookup(var.aws_efs_csi_driver, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.aws_efs_csi_driver[*].json,
    lookup(var.aws_efs_csi_driver, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.aws_efs_csi_driver, "override_policy_documents", [])
  policy_statements         = lookup(var.aws_efs_csi_driver, "policy_statements", [])
  policy_name               = try(var.aws_efs_csi_driver.policy_name, null)
  policy_name_use_prefix    = try(var.aws_efs_csi_driver.policy_name_use_prefix, true)
  policy_path               = try(var.aws_efs_csi_driver.policy_path, null)
  policy_description        = try(var.aws_efs_csi_driver.policy_description, "IAM Policy for AWS EFS CSI Driver")

  oidc_providers = {
    controller = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_efs_csi_driver_controller_service_account
    }
    node = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_efs_csi_driver_node_service_account
    }
  }

  tags = var.tags
}

################################################################################
# AWS for Fluent-bit
################################################################################

locals {
  aws_for_fluentbit_service_account = try(var.aws_for_fluentbit.service_account_name, "aws-for-fluent-bit-sa")
}

resource "aws_cloudwatch_log_group" "aws_for_fluentbit" {
  count = try(var.aws_for_fluentbit_cw_log_group.create, true) && var.enable_aws_for_fluentbit ? 1 : 0

  name              = try(var.aws_for_fluentbit_cw_log_group.name, null)
  name_prefix       = try(var.aws_for_fluentbit_cw_log_group.name_prefix, "/${var.cluster_name}/aws-fluentbit-logs")
  retention_in_days = try(var.aws_for_fluentbit_cw_log_group.retention, 90)
  kms_key_id        = try(var.aws_for_fluentbit_cw_log_group.kms_key_arn, null)
  skip_destroy      = try(var.aws_for_fluentbit_cw_log_group.skip_destroy, false)
  tags              = merge(var.tags, try(var.aws_for_fluentbit_cw_log_group.tags, {}))
}

data "aws_iam_policy_document" "aws_for_fluentbit" {
  count = try(var.aws_for_fluentbit_cw_log_group.create, true) && var.enable_aws_for_fluentbit ? 1 : 0

  statement {
    sid    = "PutLogEvents"
    effect = "Allow"
    resources = [
      "arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:${try(var.aws_for_fluentbit_cw_log_group.name, "*")}:log-stream:*",
    ]

    actions = [
      "logs:PutLogEvents"
    ]
  }

  statement {
    sid    = "CreateCWLogs"
    effect = "Allow"
    resources = [
      "arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:${try(var.aws_for_fluentbit_cw_log_group.name, "*")}",
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutRetentionPolicy",
    ]
  }
}

module "aws_for_fluentbit" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_aws_for_fluentbit

  # https://github.com/aws/eks-charts/blob/master/stable/aws-for-fluent-bit/Chart.yaml
  name             = try(var.aws_for_fluentbit.name, "aws-for-fluent-bit")
  description      = try(var.aws_for_fluentbit.description, "A Helm chart to install the Fluent-bit Driver")
  namespace        = try(var.aws_for_fluentbit.namespace, "kube-system")
  create_namespace = try(var.aws_for_fluentbit.create_namespace, false)
  chart            = "aws-for-fluent-bit"
  chart_version    = try(var.aws_for_fluentbit.chart_version, "0.1.24")
  repository       = try(var.aws_for_fluentbit.repository, "https://aws.github.io/eks-charts")
  values           = try(var.aws_for_fluentbit.values, [])

  timeout                    = try(var.aws_for_fluentbit.timeout, null)
  repository_key_file        = try(var.aws_for_fluentbit.repository_key_file, null)
  repository_cert_file       = try(var.aws_for_fluentbit.repository_cert_file, null)
  repository_ca_file         = try(var.aws_for_fluentbit.repository_ca_file, null)
  repository_username        = try(var.aws_for_fluentbit.repository_username, null)
  repository_password        = try(var.aws_for_fluentbit.repository_password, null)
  devel                      = try(var.aws_for_fluentbit.devel, null)
  verify                     = try(var.aws_for_fluentbit.verify, null)
  keyring                    = try(var.aws_for_fluentbit.keyring, null)
  disable_webhooks           = try(var.aws_for_fluentbit.disable_webhooks, null)
  reuse_values               = try(var.aws_for_fluentbit.reuse_values, null)
  reset_values               = try(var.aws_for_fluentbit.reset_values, null)
  force_update               = try(var.aws_for_fluentbit.force_update, null)
  recreate_pods              = try(var.aws_for_fluentbit.recreate_pods, null)
  cleanup_on_fail            = try(var.aws_for_fluentbit.cleanup_on_fail, null)
  max_history                = try(var.aws_for_fluentbit.max_history, null)
  atomic                     = try(var.aws_for_fluentbit.atomic, null)
  skip_crds                  = try(var.aws_for_fluentbit.skip_crds, null)
  render_subchart_notes      = try(var.aws_for_fluentbit.render_subchart_notes, null)
  disable_openapi_validation = try(var.aws_for_fluentbit.disable_openapi_validation, null)
  wait                       = try(var.aws_for_fluentbit.wait, null)
  wait_for_jobs              = try(var.aws_for_fluentbit.wait_for_jobs, null)
  dependency_update          = try(var.aws_for_fluentbit.dependency_update, null)
  replace                    = try(var.aws_for_fluentbit.replace, null)
  lint                       = try(var.aws_for_fluentbit.lint, null)

  postrender = try(var.aws_for_fluentbit.postrender, [])
  set = concat([
    {
      name  = "serviceAccount.name"
      value = local.aws_for_fluentbit_service_account
    }],
    try(var.aws_for_fluentbit.set, [])
  )
  set_sensitive = try(var.aws_for_fluentbit.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names = [
    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn",
  ]
  create_role                   = try(var.aws_for_fluentbit.create_role, true)
  role_name                     = try(var.aws_for_fluentbit.role_name, "aws-for-fluent-bit")
  role_name_use_prefix          = try(var.aws_for_fluentbit.role_name_use_prefix, true)
  role_path                     = try(var.aws_for_fluentbit.role_path, "/")
  role_permissions_boundary_arn = lookup(var.aws_for_fluentbit, "role_permissions_boundary_arn", null)
  role_description              = try(var.aws_for_fluentbit.role_description, "IRSA for aws-for-fluent-bit")
  role_policies                 = lookup(var.aws_for_fluentbit, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.aws_for_fluentbit[*].json,
    lookup(var.aws_for_fluentbit, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.aws_for_fluentbit, "override_policy_documents", [])
  policy_statements         = lookup(var.aws_for_fluentbit, "policy_statements", [])
  policy_name               = try(var.aws_for_fluentbit.policy_name, "aws-for-fluent-bit")
  policy_name_use_prefix    = try(var.aws_for_fluentbit.policy_name_use_prefix, true)
  policy_path               = try(var.aws_for_fluentbit.policy_path, null)
  policy_description        = try(var.aws_for_fluentbit.policy_description, "IAM Policy for AWS Fluentbit")

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_for_fluentbit_service_account
    }
  }

  tags = var.tags
}

################################################################################
# AWS FSX CSI DRIVER
################################################################################

locals {
  aws_fsx_csi_driver_controller_service_account = try(var.aws_fsx_csi_driver.controller_service_account_name, "aws-fsx-csi-controller-sa")
  aws_fsx_csi_driver_node_service_account       = try(var.aws_fsx_csi_driver.node_service_account_name, "aws-fsx-csi-node-sa")
}

data "aws_iam_policy_document" "aws_fsx_csi_driver" {
  statement {
    sid       = "AllowCreateServiceLinkedRoles"
    resources = ["arn:${local.partition}:iam::*:role/aws-service-role/s3.data-source.lustre.fsx.${local.dns_suffix}/*"]

    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy",
    ]
  }

  statement {
    sid       = "AllowCreateServiceLinkedRole"
    resources = ["arn:${local.partition}:iam::${local.account_id}:role/*"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["fsx.${local.dns_suffix}"]
    }
  }

  statement {
    sid       = "AllowListBuckets"
    resources = ["arn:${local.partition}:s3:::*"]
    actions = [
      "s3:ListBucket"
    ]
  }

  statement {
    resources = ["arn:${local.partition}:fsx:${local.region}:${local.account_id}:file-system/*"]
    actions = [
      "fsx:CreateFileSystem",
      "fsx:DeleteFileSystem",
      "fsx:UpdateFileSystem",
    ]
  }

  statement {
    resources = ["arn:${local.partition}:fsx:${local.region}:${local.account_id}:*"]
    actions = [
      "fsx:DescribeFileSystems",
      "fsx:TagResource"
    ]
  }
}

module "aws_fsx_csi_driver" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_aws_fsx_csi_driver

  # https://github.com/kubernetes-sigs/aws-fsx-csi-driver/tree/master/charts/aws-fsx-csi-driver
  name             = try(var.aws_fsx_csi_driver.name, "aws-fsx-csi-driver")
  description      = try(var.aws_fsx_csi_driver.description, "A Helm chart for AWS FSx for Lustre CSI Driver")
  namespace        = try(var.aws_fsx_csi_driver.namespace, "kube-system")
  create_namespace = try(var.aws_fsx_csi_driver.create_namespace, false)
  chart            = "aws-fsx-csi-driver"
  chart_version    = try(var.aws_fsx_csi_driver.chart_version, "1.5.1")
  repository       = try(var.aws_fsx_csi_driver.repository, "https://kubernetes-sigs.github.io/aws-fsx-csi-driver/")
  values           = try(var.aws_fsx_csi_driver.values, [])

  timeout                    = try(var.aws_fsx_csi_driver.timeout, null)
  repository_key_file        = try(var.aws_fsx_csi_driver.repository_key_file, null)
  repository_cert_file       = try(var.aws_fsx_csi_driver.repository_cert_file, null)
  repository_ca_file         = try(var.aws_fsx_csi_driver.repository_ca_file, null)
  repository_username        = try(var.aws_fsx_csi_driver.repository_username, null)
  repository_password        = try(var.aws_fsx_csi_driver.repository_password, null)
  devel                      = try(var.aws_fsx_csi_driver.devel, null)
  verify                     = try(var.aws_fsx_csi_driver.verify, null)
  keyring                    = try(var.aws_fsx_csi_driver.keyring, null)
  disable_webhooks           = try(var.aws_fsx_csi_driver.disable_webhooks, null)
  reuse_values               = try(var.aws_fsx_csi_driver.reuse_values, null)
  reset_values               = try(var.aws_fsx_csi_driver.reset_values, null)
  force_update               = try(var.aws_fsx_csi_driver.force_update, null)
  recreate_pods              = try(var.aws_fsx_csi_driver.recreate_pods, null)
  cleanup_on_fail            = try(var.aws_fsx_csi_driver.cleanup_on_fail, null)
  max_history                = try(var.aws_fsx_csi_driver.max_history, null)
  atomic                     = try(var.aws_fsx_csi_driver.atomic, null)
  skip_crds                  = try(var.aws_fsx_csi_driver.skip_crds, null)
  render_subchart_notes      = try(var.aws_fsx_csi_driver.render_subchart_notes, null)
  disable_openapi_validation = try(var.aws_fsx_csi_driver.disable_openapi_validation, null)
  wait                       = try(var.aws_fsx_csi_driver.wait, null)
  wait_for_jobs              = try(var.aws_fsx_csi_driver.wait_for_jobs, null)
  dependency_update          = try(var.aws_fsx_csi_driver.dependency_update, null)
  replace                    = try(var.aws_fsx_csi_driver.replace, null)
  lint                       = try(var.aws_fsx_csi_driver.lint, null)

  postrender = try(var.aws_fsx_csi_driver.postrender, [])
  set = concat([
    {
      name  = "controller.serviceAccount.name"
      value = local.aws_fsx_csi_driver_controller_service_account
    },
    {
      name  = "node.serviceAccount.name"
      value = local.aws_fsx_csi_driver_node_service_account
    }],
    try(var.aws_fsx_csi_driver.set, [])
  )
  set_sensitive = try(var.aws_fsx_csi_driver.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names = [
    "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn",
    "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  ]
  create_role                   = try(var.aws_fsx_csi_driver.create_role, true)
  role_name                     = try(var.aws_fsx_csi_driver.role_name, "aws-fsx-csi-driver")
  role_name_use_prefix          = try(var.aws_fsx_csi_driver.role_name_use_prefix, true)
  role_path                     = try(var.aws_fsx_csi_driver.role_path, "/")
  role_permissions_boundary_arn = lookup(var.aws_fsx_csi_driver, "role_permissions_boundary_arn", null)
  role_description              = try(var.aws_fsx_csi_driver.role_description, "IRSA for aws-fsx-csi-driver")
  role_policies                 = lookup(var.aws_fsx_csi_driver, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.aws_fsx_csi_driver[*].json,
    lookup(var.aws_fsx_csi_driver, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.aws_fsx_csi_driver, "override_policy_documents", [])
  policy_statements         = lookup(var.aws_fsx_csi_driver, "policy_statements", [])
  policy_name               = try(var.aws_fsx_csi_driver.policy_name, "aws-fsx-csi-driver")
  policy_name_use_prefix    = try(var.aws_fsx_csi_driver.policy_name_use_prefix, true)
  policy_path               = try(var.aws_fsx_csi_driver.policy_path, null)
  policy_description        = try(var.aws_fsx_csi_driver.policy_description, "IAM Policy for AWS FSX CSI Driver")

  oidc_providers = {
    controller = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_fsx_csi_driver_controller_service_account
    }
    node = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_fsx_csi_driver_node_service_account
    }
  }
}

################################################################################
# AWS Load Balancer Controller
################################################################################

locals {
  aws_load_balancer_controller_service_account = try(var.aws_load_balancer_controller.service_account_name, "aws-load-balancer-controller-sa")
}

data "aws_iam_policy_document" "aws_load_balancer_controller" {
  statement {
    resources = ["*"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.${local.dns_suffix}"]
    }
  }

  statement {
    resources = ["*"]
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeCoipPools",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeVpcs",
      "ec2:GetCoipPoolUsage",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
    ]
  }

  statement {
    resources = ["*"]
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "cognito-idp:DescribeUserPoolClient",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
      "shield:CreateProtection",
      "shield:DeleteProtection",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
    ]
  }

  statement {
    resources = ["*"]
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
    ]
  }

  statement {
    resources = ["*"]
    actions   = ["ec2:CreateSecurityGroup"]
  }

  statement {
    resources = ["arn:${local.partition}:ec2:*:*:security-group/*"]
    actions   = ["ec2:CreateTags"]

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSecurityGroup"]
    }
  }

  statement {
    resources = ["arn:${local.partition}:ec2:*:*:security-group/*"]
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/ingress.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    resources = [
      "arn:${local.partition}:elasticloadbalancing:*:*:loadbalancer/app/*/*",
      "arn:${local.partition}:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:${local.partition}:elasticloadbalancing:*:*:targetgroup/*/*",
    ]
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:RemoveTags",
    ]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/ingress.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    resources = ["arn:${local.partition}:ec2:*:*:security-group/*"]
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["true"]
    }
  }

  statement {
    resources = ["*"]
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupIngress",
    ]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    resources = ["*"]
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
    ]

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    resources = ["*"]
    actions = [
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteRule",
    ]
  }

  statement {
    resources = [
      "arn:${local.partition}:elasticloadbalancing:*:*:loadbalancer/app/*/*",
      "arn:${local.partition}:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:${local.partition}:elasticloadbalancing:*:*:targetgroup/*/*",
    ]
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
    ]

    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["true"]
    }

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    resources = [
      "arn:${local.partition}:elasticloadbalancing:*:*:listener/net/*/*/*",
      "arn:${local.partition}:elasticloadbalancing:*:*:listener/app/*/*/*",
      "arn:${local.partition}:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
      "arn:${local.partition}:elasticloadbalancing:*:*:listener-rule/app/*/*/*",
    ]
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
    ]
  }

  statement {
    resources = ["*"]
    actions = [
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
    ]

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    resources = ["arn:${local.partition}:elasticloadbalancing:*:*:targetgroup/*/*"]
    actions = [
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:RegisterTargets",
    ]
  }

  statement {
    resources = ["*"]
    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:SetWebAcl",
    ]
  }
}

module "aws_load_balancer_controller" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_aws_load_balancer_controller

  # https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/Chart.yaml
  name        = try(var.aws_load_balancer_controller.name, "aws-load-balancer-controller")
  description = try(var.aws_load_balancer_controller.description, "A Helm chart to deploy aws-load-balancer-controller for ingress resources")
  namespace   = try(var.aws_load_balancer_controller.namespace, "kube-system")
  # namespace creation is false here as kube-system already exists by default
  create_namespace = try(var.aws_load_balancer_controller.create_namespace, false)
  chart            = "aws-load-balancer-controller"
  chart_version    = try(var.aws_load_balancer_controller.chart_version, "1.4.8")
  repository       = try(var.aws_load_balancer_controller.repository, "https://aws.github.io/eks-charts")
  values           = try(var.aws_load_balancer_controller.values, [])

  timeout                    = try(var.aws_load_balancer_controller.timeout, null)
  repository_key_file        = try(var.aws_load_balancer_controller.repository_key_file, null)
  repository_cert_file       = try(var.aws_load_balancer_controller.repository_cert_file, null)
  repository_ca_file         = try(var.aws_load_balancer_controller.repository_ca_file, null)
  repository_username        = try(var.aws_load_balancer_controller.repository_username, null)
  repository_password        = try(var.aws_load_balancer_controller.repository_password, null)
  devel                      = try(var.aws_load_balancer_controller.devel, null)
  verify                     = try(var.aws_load_balancer_controller.verify, null)
  keyring                    = try(var.aws_load_balancer_controller.keyring, null)
  disable_webhooks           = try(var.aws_load_balancer_controller.disable_webhooks, null)
  reuse_values               = try(var.aws_load_balancer_controller.reuse_values, null)
  reset_values               = try(var.aws_load_balancer_controller.reset_values, null)
  force_update               = try(var.aws_load_balancer_controller.force_update, null)
  recreate_pods              = try(var.aws_load_balancer_controller.recreate_pods, null)
  cleanup_on_fail            = try(var.aws_load_balancer_controller.cleanup_on_fail, null)
  max_history                = try(var.aws_load_balancer_controller.max_history, null)
  atomic                     = try(var.aws_load_balancer_controller.atomic, null)
  skip_crds                  = try(var.aws_load_balancer_controller.skip_crds, null)
  render_subchart_notes      = try(var.aws_load_balancer_controller.render_subchart_notes, null)
  disable_openapi_validation = try(var.aws_load_balancer_controller.disable_openapi_validation, null)
  wait                       = try(var.aws_load_balancer_controller.wait, null)
  wait_for_jobs              = try(var.aws_load_balancer_controller.wait_for_jobs, null)
  dependency_update          = try(var.aws_load_balancer_controller.dependency_update, null)
  replace                    = try(var.aws_load_balancer_controller.replace, null)
  lint                       = try(var.aws_load_balancer_controller.lint, null)

  postrender = try(var.aws_load_balancer_controller.postrender, [])
  set = concat([
    {
      name  = "serviceAccount.name"
      value = local.aws_load_balancer_controller_service_account
      }, {
      name  = "clusterName"
      value = local.cluster_name
    }],
    try(var.aws_load_balancer_controller.set, [])
  )
  set_sensitive = try(var.aws_load_balancer_controller.set_sensitive, [])

  # IAM role for service account (IRSA)
  create_role                   = try(var.aws_load_balancer_controller.create_role, true)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  role_name                     = try(var.aws_load_balancer_controller.role_name, "alb-controller")
  role_name_use_prefix          = try(var.aws_load_balancer_controller.role_name_use_prefix, true)
  role_path                     = try(var.aws_load_balancer_controller.role_path, "/")
  role_permissions_boundary_arn = lookup(var.aws_load_balancer_controller, "role_permissions_boundary_arn", null)
  role_description              = try(var.aws_load_balancer_controller.role_description, "IRSA for aws-load-balancer-controller project")
  role_policies                 = lookup(var.aws_load_balancer_controller, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.aws_load_balancer_controller[*].json,
    lookup(var.aws_load_balancer_controller, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.aws_load_balancer_controller, "override_policy_documents", [])
  policy_statements         = lookup(var.aws_load_balancer_controller, "policy_statements", [])
  policy_name               = try(var.aws_load_balancer_controller.policy_name, null)
  policy_name_use_prefix    = try(var.aws_load_balancer_controller.policy_name_use_prefix, true)
  policy_path               = try(var.aws_load_balancer_controller.policy_path, null)
  policy_description        = try(var.aws_load_balancer_controller.policy_description, "IAM Policy for AWS Load Balancer Controller")

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_load_balancer_controller_service_account
    }
  }

  tags = var.tags
}

################################################################################
# AWS Node Termination Handler
################################################################################

locals {
  aws_node_termination_handler_service_account = try(var.aws_node_termination_handler.service_account_name, "aws-node-termination-handler-sa")
  aws_node_termination_handler_events = merge(
    {
      autoscaling_terminate = {
        name        = "ASGTerminiate"
        description = "Auto scaling instance terminate event"
        event_pattern = {
          source      = ["aws.autoscaling"]
          detail-type = ["EC2 Instance-terminate Lifecycle Action"]
        }
      }
    },
    local.ec2_events
  )
}

module "aws_node_termination_handler_sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  create = var.enable_aws_node_termination_handler

  name = try(var.aws_node_termination_handler_sqs.queue_name, "aws-nth-${var.cluster_name}")

  message_retention_seconds         = try(var.aws_node_termination_handler_sqs.message_retention_seconds, 300)
  sqs_managed_sse_enabled           = try(var.aws_node_termination_handler_sqs.sse_enabled, true)
  kms_master_key_id                 = try(var.aws_node_termination_handler_sqs.kms_master_key_id, null)
  kms_data_key_reuse_period_seconds = try(var.aws_node_termination_handler_sqs.kms_data_key_reuse_period_seconds, null)

  create_queue_policy = true
  queue_policy_statements = {
    account = {
      sid     = "SendEventsToQueue"
      actions = ["sqs:SendMessage"]
      principals = [
        {
          type = "Service"
          identifiers = [
            "events.${local.dns_suffix}",
            "sqs.${local.dns_suffix}",
          ]
        }
      ]
    }
  }

  tags = merge(var.tags, try(var.aws_node_termination_handler_sqs.tags, {}))
}

resource "aws_autoscaling_lifecycle_hook" "aws_node_termination_handler" {
  for_each = { for k, v in var.aws_node_termination_handler_asg_arns : k => v if var.enable_aws_node_termination_handler }

  name                   = "aws_node_termination_handler"
  autoscaling_group_name = replace(each.value, "/^.*:autoScalingGroupName//", "")
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}

resource "aws_autoscaling_group_tag" "aws_node_termination_handler" {
  for_each = { for k, v in var.aws_node_termination_handler_asg_arns : k => v if var.enable_aws_node_termination_handler }

  autoscaling_group_name = replace(each.value, "/^.*:autoScalingGroupName//", "")

  tag {
    key                 = "aws-node-termination-handler/managed"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler" {
  for_each = { for k, v in local.aws_node_termination_handler_events : k => v if var.enable_aws_node_termination_handler }

  name_prefix   = "NTH-${each.value.name}-"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

  tags = merge(
    { "ClusterName" : var.cluster_name },
    var.tags,
  )
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler" {
  for_each = { for k, v in local.aws_node_termination_handler_events : k => v if var.enable_aws_node_termination_handler }

  rule      = aws_cloudwatch_event_rule.aws_node_termination_handler[each.key].name
  target_id = "AWSNodeTerminationHandlerQueueTarget"
  arn       = module.aws_node_termination_handler_sqs.queue_arn
}

data "aws_iam_policy_document" "aws_node_termination_handler" {
  count = var.enable_aws_node_termination_handler ? 1 : 0

  statement {
    actions = [
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["autoscaling:CompleteLifecycleAction"]
    resources = var.aws_node_termination_handler_asg_arns
  }

  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
    ]
    resources = [module.aws_node_termination_handler_sqs.queue_arn]
  }
}

module "aws_node_termination_handler" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_aws_node_termination_handler

  # https://github.com/aws/eks-charts/blob/master/stable/aws-node-termination-handler/Chart.yaml
  name             = try(var.aws_node_termination_handler.name, "aws-node-termination-handler")
  description      = try(var.aws_node_termination_handler.description, "A Helm chart to deploy AWS Node Termination Handler")
  namespace        = try(var.aws_node_termination_handler.namespace, "aws-node-termination-handler")
  create_namespace = try(var.aws_node_termination_handler.create_namespace, true)
  chart            = "aws-node-termination-handler"
  chart_version    = try(var.aws_node_termination_handler.chart_version, "0.21.0")
  repository       = try(var.aws_node_termination_handler.repository, "https://aws.github.io/eks-charts")
  values           = try(var.aws_node_termination_handler.values, [])

  timeout                    = try(var.aws_node_termination_handler.timeout, null)
  repository_key_file        = try(var.aws_node_termination_handler.repository_key_file, null)
  repository_cert_file       = try(var.aws_node_termination_handler.repository_cert_file, null)
  repository_ca_file         = try(var.aws_node_termination_handler.repository_ca_file, null)
  repository_username        = try(var.aws_node_termination_handler.repository_username, null)
  repository_password        = try(var.aws_node_termination_handler.repository_password, null)
  devel                      = try(var.aws_node_termination_handler.devel, null)
  verify                     = try(var.aws_node_termination_handler.verify, null)
  keyring                    = try(var.aws_node_termination_handler.keyring, null)
  disable_webhooks           = try(var.aws_node_termination_handler.disable_webhooks, null)
  reuse_values               = try(var.aws_node_termination_handler.reuse_values, null)
  reset_values               = try(var.aws_node_termination_handler.reset_values, null)
  force_update               = try(var.aws_node_termination_handler.force_update, null)
  recreate_pods              = try(var.aws_node_termination_handler.recreate_pods, null)
  cleanup_on_fail            = try(var.aws_node_termination_handler.cleanup_on_fail, null)
  max_history                = try(var.aws_node_termination_handler.max_history, null)
  atomic                     = try(var.aws_node_termination_handler.atomic, null)
  skip_crds                  = try(var.aws_node_termination_handler.skip_crds, null)
  render_subchart_notes      = try(var.aws_node_termination_handler.render_subchart_notes, null)
  disable_openapi_validation = try(var.aws_node_termination_handler.disable_openapi_validation, null)
  wait                       = try(var.aws_node_termination_handler.wait, null)
  wait_for_jobs              = try(var.aws_node_termination_handler.wait_for_jobs, null)
  dependency_update          = try(var.aws_node_termination_handler.dependency_update, null)
  replace                    = try(var.aws_node_termination_handler.replace, null)
  lint                       = try(var.aws_node_termination_handler.lint, null)

  postrender = try(var.aws_node_termination_handler.postrender, [])
  set = concat(
    [
      {
        name  = "serviceAccount.name"
        value = local.aws_node_termination_handler_service_account
      },
      {
        name  = "awsRegion"
        value = local.region
      },
      { name  = "queueURL"
        value = module.aws_node_termination_handler_sqs.queue_url
      },
      {
        name  = "enableSqsTerminationDraining"
        value = true
      }
    ],
    try(var.aws_node_termination_handler.set, [])
  )
  set_sensitive = try(var.aws_node_termination_handler.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.aws_node_termination_handler.create_role, true)
  role_name                     = try(var.aws_node_termination_handler.role_name, "aws-node-termination-handler")
  role_name_use_prefix          = try(var.aws_node_termination_handler.role_name_use_prefix, true)
  role_path                     = try(var.aws_node_termination_handler.role_path, "/")
  role_permissions_boundary_arn = lookup(var.aws_node_termination_handler, "role_permissions_boundary_arn", null)
  role_description              = try(var.aws_node_termination_handler.role_description, "IRSA for AWS Node Termination Handler project")
  role_policies                 = lookup(var.aws_node_termination_handler, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.aws_node_termination_handler[*].json,
    lookup(var.aws_node_termination_handler, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.aws_node_termination_handler, "override_policy_documents", [])
  policy_statements         = lookup(var.aws_node_termination_handler, "policy_statements", [])
  policy_name               = try(var.aws_node_termination_handler.policy_name, null)
  policy_name_use_prefix    = try(var.aws_node_termination_handler.policy_name_use_prefix, true)
  policy_path               = try(var.aws_node_termination_handler.policy_path, null)
  policy_description        = try(var.aws_node_termination_handler.policy_description, "IAM Policy for AWS Node Termination Handler")

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_node_termination_handler_service_account
    }
  }

  tags = var.tags
}

################################################################################
# AWS Private CA Issuer
################################################################################

locals {
  aws_privateca_issuer_service_account = try(var.aws_privateca_issuer.service_account_name, "aws-privateca-issuer-sa")
}

data "aws_iam_policy_document" "aws_privateca_issuer" {
  count = var.enable_aws_privateca_issuer ? 1 : 0

  statement {
    actions = [
      "acm-pca:DescribeCertificateAuthority",
      "acm-pca:GetCertificate",
      "acm-pca:IssueCertificate",
    ]
    resources = [
      try(var.aws_privateca_issuer.acmca_arn,
      "arn:${local.partition}:acm-pca:${local.region}:${local.account_id}:certificate-authority/*")
    ]
  }
}

module "aws_privateca_issuer" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_aws_privateca_issuer

  # https://github.com/cert-manager/aws-privateca-issuer/blob/main/charts/aws-pca-issuer/Chart.yaml
  name             = try(var.aws_privateca_issuer.name, "aws-privateca-issuer")
  description      = try(var.aws_privateca_issuer.description, "A Helm chart to install the AWS Private CA Issuer")
  namespace        = try(var.aws_privateca_issuer.namespace, "kube-system")
  create_namespace = try(var.aws_privateca_issuer.create_namespace, false)
  chart            = "aws-privateca-issuer"
  chart_version    = try(var.aws_privateca_issuer.chart_version, "v1.2.5")
  repository       = try(var.aws_privateca_issuer.repository, "https://cert-manager.github.io/aws-privateca-issuer")
  values           = try(var.aws_privateca_issuer.values, [])

  timeout                    = try(var.aws_privateca_issuer.timeout, null)
  repository_key_file        = try(var.aws_privateca_issuer.repository_key_file, null)
  repository_cert_file       = try(var.aws_privateca_issuer.repository_cert_file, null)
  repository_ca_file         = try(var.aws_privateca_issuer.repository_ca_file, null)
  repository_username        = try(var.aws_privateca_issuer.repository_username, null)
  repository_password        = try(var.aws_privateca_issuer.repository_password, null)
  devel                      = try(var.aws_privateca_issuer.devel, null)
  verify                     = try(var.aws_privateca_issuer.verify, null)
  keyring                    = try(var.aws_privateca_issuer.keyring, null)
  disable_webhooks           = try(var.aws_privateca_issuer.disable_webhooks, null)
  reuse_values               = try(var.aws_privateca_issuer.reuse_values, null)
  reset_values               = try(var.aws_privateca_issuer.reset_values, null)
  force_update               = try(var.aws_privateca_issuer.force_update, null)
  recreate_pods              = try(var.aws_privateca_issuer.recreate_pods, null)
  cleanup_on_fail            = try(var.aws_privateca_issuer.cleanup_on_fail, null)
  max_history                = try(var.aws_privateca_issuer.max_history, null)
  atomic                     = try(var.aws_privateca_issuer.atomic, null)
  skip_crds                  = try(var.aws_privateca_issuer.skip_crds, null)
  render_subchart_notes      = try(var.aws_privateca_issuer.render_subchart_notes, null)
  disable_openapi_validation = try(var.aws_privateca_issuer.disable_openapi_validation, null)
  wait                       = try(var.aws_privateca_issuer.wait, null)
  wait_for_jobs              = try(var.aws_privateca_issuer.wait_for_jobs, null)
  dependency_update          = try(var.aws_privateca_issuer.dependency_update, null)
  replace                    = try(var.aws_privateca_issuer.replace, null)
  lint                       = try(var.aws_privateca_issuer.lint, null)

  postrender = try(var.aws_privateca_issuer.postrender, [])
  set = concat([
    {
      name  = "serviceAccount.name"
      value = local.aws_privateca_issuer_service_account
    }],
    try(var.aws_privateca_issuer.set, [])
  )
  set_sensitive = try(var.aws_privateca_issuer.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.aws_privateca_issuer.create_role, true)
  role_name                     = try(var.aws_privateca_issuer.role_name, "aws-privateca-issuer")
  role_name_use_prefix          = try(var.aws_privateca_issuer.role_name_use_prefix, true)
  role_path                     = try(var.aws_privateca_issuer.role_path, "/")
  role_permissions_boundary_arn = lookup(var.aws_privateca_issuer, "role_permissions_boundary_arn", null)
  role_description              = try(var.aws_privateca_issuer.role_description, "IRSA for AWS Private CA Issuer")
  role_policies                 = lookup(var.aws_privateca_issuer, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.aws_privateca_issuer[*].json,
    lookup(var.aws_privateca_issuer, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.aws_privateca_issuer, "override_policy_documents", [])
  policy_statements         = lookup(var.aws_privateca_issuer, "policy_statements", [])
  policy_name               = try(var.aws_privateca_issuer.policy_name, "aws-privateca-issuer")
  policy_name_use_prefix    = try(var.aws_privateca_issuer.policy_name_use_prefix, true)
  policy_path               = try(var.aws_privateca_issuer.policy_path, null)
  policy_description        = try(var.aws_privateca_issuer.policy_description, "IAM Policy for AWS Private CA Issuer")

  oidc_providers = {
    controller = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.aws_privateca_issuer_service_account
    }
  }

  tags = var.tags
}

################################################################################
# Cert Manager
################################################################################

locals {
  cert_manager_service_account = try(var.cert_manager.service_account_name, "cert-manager")
  create_cert_manager_irsa     = var.enable_cert_manager && length(var.cert_manager_route53_hosted_zone_arns) > 0
}

data "aws_iam_policy_document" "cert_manager" {
  count = local.create_cert_manager_irsa ? 1 : 0

  statement {
    actions   = ["route53:GetChange", ]
    resources = ["arn:${local.partition}:route53:::change/*"]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = var.cert_manager_route53_hosted_zone_arns
  }

  statement {
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}

module "cert_manager" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_cert_manager

  # https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/Chart.template.yaml
  name             = try(var.cert_manager.name, "cert-manager")
  description      = try(var.cert_manager.description, "A Helm chart to deploy cert-manager")
  namespace        = try(var.cert_manager.namespace, "cert-manager")
  create_namespace = try(var.cert_manager.create_namespace, true)
  chart            = "cert-manager"
  chart_version    = try(var.cert_manager.chart_version, "v1.11.1")
  repository       = try(var.cert_manager.repository, "https://charts.jetstack.io")
  values           = try(var.cert_manager.values, [])

  timeout                    = try(var.cert_manager.timeout, null)
  repository_key_file        = try(var.cert_manager.repository_key_file, null)
  repository_cert_file       = try(var.cert_manager.repository_cert_file, null)
  repository_ca_file         = try(var.cert_manager.repository_ca_file, null)
  repository_username        = try(var.cert_manager.repository_username, null)
  repository_password        = try(var.cert_manager.repository_password, null)
  devel                      = try(var.cert_manager.devel, null)
  verify                     = try(var.cert_manager.verify, null)
  keyring                    = try(var.cert_manager.keyring, null)
  disable_webhooks           = try(var.cert_manager.disable_webhooks, null)
  reuse_values               = try(var.cert_manager.reuse_values, null)
  reset_values               = try(var.cert_manager.reset_values, null)
  force_update               = try(var.cert_manager.force_update, null)
  recreate_pods              = try(var.cert_manager.recreate_pods, null)
  cleanup_on_fail            = try(var.cert_manager.cleanup_on_fail, null)
  max_history                = try(var.cert_manager.max_history, null)
  atomic                     = try(var.cert_manager.atomic, null)
  skip_crds                  = try(var.cert_manager.skip_crds, null)
  render_subchart_notes      = try(var.cert_manager.render_subchart_notes, null)
  disable_openapi_validation = try(var.cert_manager.disable_openapi_validation, null)
  wait                       = try(var.cert_manager.wait, null)
  wait_for_jobs              = try(var.cert_manager.wait_for_jobs, null)
  dependency_update          = try(var.cert_manager.dependency_update, null)
  replace                    = try(var.cert_manager.replace, null)
  lint                       = try(var.cert_manager.lint, null)

  postrender = try(var.cert_manager.postrender, [])
  set = concat([
    {
      name  = "installCRDs"
      value = true
    }
    ],
    try(var.cert_manager.set, [])
  )
  set_sensitive = try(var.cert_manager.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = local.create_cert_manager_irsa && try(var.cert_manager.create_role, true)
  role_name                     = try(var.cert_manager.role_name, "cert-manager")
  role_name_use_prefix          = try(var.cert_manager.role_name_use_prefix, true)
  role_path                     = try(var.cert_manager.role_path, "/")
  role_permissions_boundary_arn = lookup(var.cert_manager, "role_permissions_boundary_arn", null)
  role_description              = try(var.cert_manager.role_description, "IRSA for cert-manger project")
  role_policies                 = lookup(var.cert_manager, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.cert_manager[*].json,
    lookup(var.cert_manager, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.cert_manager, "override_policy_documents", [])
  policy_statements         = lookup(var.cert_manager, "policy_statements", [])
  policy_name               = try(var.cert_manager.policy_name, null)
  policy_name_use_prefix    = try(var.cert_manager.policy_name_use_prefix, true)
  policy_path               = try(var.cert_manager.policy_path, null)
  policy_description        = try(var.cert_manager.policy_description, "IAM Policy for cert-manager")

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.cert_manager_service_account
    }
  }

  tags = var.tags
}

################################################################################
# Cluster Autoscaler
################################################################################

locals {
  cluster_autoscaler_service_account = try(var.cluster_autoscaler.service_account_name, "cluster-autoscaler-sa")

  # Lookup map to pull latest cluster-autoscaler patch version given the cluster version
  cluster_autoscaler_image_tag = {
    "1.20" = "v1.20.3"
    "1.21" = "v1.21.3"
    "1.22" = "v1.22.3"
    "1.23" = "v1.23.1"
    "1.24" = "v1.24.1"
    "1.25" = "v1.25.1"
    "1.26" = "v1.26.2"
  }
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes",
      "eks:DescribeNodegroup",
      "ec2:DescribeImages",
      "ec2:GetInstanceTypesFromInstanceRequirements"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }
  }
}

module "cluster_autoscaler" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_cluster_autoscaler

  # https://github.com/kubernetes/autoscaler/blob/master/charts/cluster-autoscaler/Chart.yaml
  name             = try(var.cluster_autoscaler.name, "cluster-autoscaler")
  description      = try(var.cluster_autoscaler.description, "A Helm chart to deploy cluster-autoscaler")
  namespace        = try(var.cluster_autoscaler.namespace, "kube-system")
  create_namespace = try(var.cluster_autoscaler.create_namespace, false)
  chart            = "cluster-autoscaler"
  chart_version    = try(var.cluster_autoscaler.chart_version, "9.28.0")
  repository       = try(var.cluster_autoscaler.repository, "https://kubernetes.github.io/autoscaler")
  values           = try(var.cluster_autoscaler.values, [])

  timeout                    = try(var.cluster_autoscaler.timeout, null)
  repository_key_file        = try(var.cluster_autoscaler.repository_key_file, null)
  repository_cert_file       = try(var.cluster_autoscaler.repository_cert_file, null)
  repository_ca_file         = try(var.cluster_autoscaler.repository_ca_file, null)
  repository_username        = try(var.cluster_autoscaler.repository_username, null)
  repository_password        = try(var.cluster_autoscaler.repository_password, null)
  devel                      = try(var.cluster_autoscaler.devel, null)
  verify                     = try(var.cluster_autoscaler.verify, null)
  keyring                    = try(var.cluster_autoscaler.keyring, null)
  disable_webhooks           = try(var.cluster_autoscaler.disable_webhooks, null)
  reuse_values               = try(var.cluster_autoscaler.reuse_values, null)
  reset_values               = try(var.cluster_autoscaler.reset_values, null)
  force_update               = try(var.cluster_autoscaler.force_update, null)
  recreate_pods              = try(var.cluster_autoscaler.recreate_pods, null)
  cleanup_on_fail            = try(var.cluster_autoscaler.cleanup_on_fail, null)
  max_history                = try(var.cluster_autoscaler.max_history, null)
  atomic                     = try(var.cluster_autoscaler.atomic, null)
  skip_crds                  = try(var.cluster_autoscaler.skip_crds, null)
  render_subchart_notes      = try(var.cluster_autoscaler.render_subchart_notes, null)
  disable_openapi_validation = try(var.cluster_autoscaler.disable_openapi_validation, null)
  wait                       = try(var.cluster_autoscaler.wait, null)
  wait_for_jobs              = try(var.cluster_autoscaler.wait_for_jobs, null)
  dependency_update          = try(var.cluster_autoscaler.dependency_update, null)
  replace                    = try(var.cluster_autoscaler.replace, null)
  lint                       = try(var.cluster_autoscaler.lint, null)

  postrender = try(var.cluster_autoscaler.postrender, [])
  set = concat(
    [
      {
        name  = "awsRegion"
        value = local.region
      },
      {
        name  = "autoDiscovery.clusterName"
        value = local.cluster_name
      },
      {
        name  = "image.tag"
        value = try(local.cluster_autoscaler_image_tag[var.cluster_version], "v${var.cluster_version}.0")
      },
      {
        name  = "rbac.serviceAccount.name"
        value = local.cluster_autoscaler_service_account
      }
    ],
    try(var.cluster_autoscaler.set, [])
  )
  set_sensitive = try(var.cluster_autoscaler.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.cluster_autoscaler.create_role, true)
  role_name                     = try(var.cluster_autoscaler.role_name, "cluster-autoscaler")
  role_name_use_prefix          = try(var.cluster_autoscaler.role_name_use_prefix, true)
  role_path                     = try(var.cluster_autoscaler.role_path, "/")
  role_permissions_boundary_arn = lookup(var.cluster_autoscaler, "role_permissions_boundary_arn", null)
  role_description              = try(var.cluster_autoscaler.role_description, "IRSA for cluster-autoscaler operator")
  role_policies                 = lookup(var.cluster_autoscaler, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.cluster_autoscaler[*].json,
    lookup(var.cluster_autoscaler, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.cluster_autoscaler, "override_policy_documents", [])
  policy_statements         = lookup(var.cluster_autoscaler, "policy_statements", [])
  policy_name               = try(var.cluster_autoscaler.policy_name, null)
  policy_name_use_prefix    = try(var.cluster_autoscaler.policy_name_use_prefix, true)
  policy_path               = try(var.cluster_autoscaler.policy_path, null)
  policy_description        = try(var.cluster_autoscaler.policy_description, "IAM Policy for cluster-autoscaler operator")

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.cluster_autoscaler_service_account
    }
  }

  tags = var.tags
}

################################################################################
# Cluster Proportional Autoscaler
################################################################################

module "cluster_proportional_autoscaler" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_cluster_proportional_autoscaler

  # https://github.com/kubernetes-sigs/cluster-proportional-autoscaler/blob/master/charts/cluster-proportional-autoscaler/Chart.yaml
  name             = try(var.cluster_proportional_autoscaler.name, "cluster-proportional-autoscaler")
  description      = try(var.cluster_proportional_autoscaler.description, "A Helm chart to install the Cluster Proportional Autoscaler")
  namespace        = try(var.cluster_proportional_autoscaler.namespace, "kube-system")
  create_namespace = try(var.cluster_proportional_autoscaler.create_namespace, false)
  chart            = "cluster-proportional-autoscaler"
  chart_version    = try(var.cluster_proportional_autoscaler.chart_version, "1.1.0")
  repository       = try(var.cluster_proportional_autoscaler.repository, "https://kubernetes-sigs.github.io/cluster-proportional-autoscaler")
  values           = try(var.cluster_proportional_autoscaler.values, [])

  timeout                    = try(var.cluster_proportional_autoscaler.timeout, null)
  repository_key_file        = try(var.cluster_proportional_autoscaler.repository_key_file, null)
  repository_cert_file       = try(var.cluster_proportional_autoscaler.repository_cert_file, null)
  repository_ca_file         = try(var.cluster_proportional_autoscaler.repository_ca_file, null)
  repository_username        = try(var.cluster_proportional_autoscaler.repository_username, null)
  repository_password        = try(var.cluster_proportional_autoscaler.repository_password, null)
  devel                      = try(var.cluster_proportional_autoscaler.devel, null)
  verify                     = try(var.cluster_proportional_autoscaler.verify, null)
  keyring                    = try(var.cluster_proportional_autoscaler.keyring, null)
  disable_webhooks           = try(var.cluster_proportional_autoscaler.disable_webhooks, null)
  reuse_values               = try(var.cluster_proportional_autoscaler.reuse_values, null)
  reset_values               = try(var.cluster_proportional_autoscaler.reset_values, null)
  force_update               = try(var.cluster_proportional_autoscaler.force_update, null)
  recreate_pods              = try(var.cluster_proportional_autoscaler.recreate_pods, null)
  cleanup_on_fail            = try(var.cluster_proportional_autoscaler.cleanup_on_fail, null)
  max_history                = try(var.cluster_proportional_autoscaler.max_history, null)
  atomic                     = try(var.cluster_proportional_autoscaler.atomic, null)
  skip_crds                  = try(var.cluster_proportional_autoscaler.skip_crds, null)
  render_subchart_notes      = try(var.cluster_proportional_autoscaler.render_subchart_notes, null)
  disable_openapi_validation = try(var.cluster_proportional_autoscaler.disable_openapi_validation, null)
  wait                       = try(var.cluster_proportional_autoscaler.wait, null)
  wait_for_jobs              = try(var.cluster_proportional_autoscaler.wait_for_jobs, null)
  dependency_update          = try(var.cluster_proportional_autoscaler.dependency_update, null)
  replace                    = try(var.cluster_proportional_autoscaler.replace, null)
  lint                       = try(var.cluster_proportional_autoscaler.lint, null)

  postrender    = try(var.cluster_proportional_autoscaler.postrender, [])
  set           = try(var.cluster_proportional_autoscaler.set, [])
  set_sensitive = try(var.cluster_proportional_autoscaler.set_sensitive, [])

  tags = var.tags
}

################################################################################
# EKS Addons
################################################################################

data "aws_eks_addon_version" "this" {
  for_each = var.eks_addons

  addon_name         = try(each.value.name, each.key)
  kubernetes_version = var.cluster_version
  most_recent        = try(each.value.most_recent, true)
}

resource "aws_eks_addon" "this" {
  for_each = var.eks_addons

  cluster_name = local.cluster_name
  addon_name   = try(each.value.name, each.key)

  addon_version            = try(each.value.addon_version, data.aws_eks_addon_version.this[each.key].version)
  configuration_values     = try(each.value.configuration_values, null)
  preserve                 = try(each.value.preserve, null)
  resolve_conflicts        = try(each.value.resolve_conflicts, "OVERWRITE")
  service_account_role_arn = try(each.value.service_account_role_arn, null)

  timeouts {
    create = try(each.value.timeouts.create, var.eks_addons_timeouts.create, null)
    update = try(each.value.timeouts.update, var.eks_addons_timeouts.update, null)
    delete = try(each.value.timeouts.delete, var.eks_addons_timeouts.delete, null)
  }

  tags = var.tags
}

################################################################################
# External DNS
################################################################################

locals {
  external_dns_service_account = try(var.external_dns.service_account_name, "external-dns-sa")
}

# https://github.com/external-secrets/kubernetes-external-secrets#add-a-secret
data "aws_iam_policy_document" "external_dns" {
  count = var.enable_external_dns && length(var.external_dns_route53_zone_arns) > 0 ? 1 : 0

  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = var.external_dns_route53_zone_arns
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }
}

module "external_dns" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_external_dns

  # https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns/Chart.yaml
  name             = try(var.external_dns.name, "external-dns")
  description      = try(var.external_dns.description, "A Helm chart to deploy external-dns")
  namespace        = try(var.external_dns.namespace, "external-dns")
  create_namespace = try(var.external_dns.create_namespace, true)
  chart            = "external-dns"
  chart_version    = try(var.external_dns.chart_version, "1.12.2")
  repository       = try(var.external_dns.repository, "https://kubernetes-sigs.github.io/external-dns/")
  values           = try(var.external_dns.values, ["provider: aws"])

  timeout                    = try(var.external_dns.timeout, null)
  repository_key_file        = try(var.external_dns.repository_key_file, null)
  repository_cert_file       = try(var.external_dns.repository_cert_file, null)
  repository_ca_file         = try(var.external_dns.repository_ca_file, null)
  repository_username        = try(var.external_dns.repository_username, null)
  repository_password        = try(var.external_dns.repository_password, null)
  devel                      = try(var.external_dns.devel, null)
  verify                     = try(var.external_dns.verify, null)
  keyring                    = try(var.external_dns.keyring, null)
  disable_webhooks           = try(var.external_dns.disable_webhooks, null)
  reuse_values               = try(var.external_dns.reuse_values, null)
  reset_values               = try(var.external_dns.reset_values, null)
  force_update               = try(var.external_dns.force_update, null)
  recreate_pods              = try(var.external_dns.recreate_pods, null)
  cleanup_on_fail            = try(var.external_dns.cleanup_on_fail, null)
  max_history                = try(var.external_dns.max_history, null)
  atomic                     = try(var.external_dns.atomic, null)
  skip_crds                  = try(var.external_dns.skip_crds, null)
  render_subchart_notes      = try(var.external_dns.render_subchart_notes, null)
  disable_openapi_validation = try(var.external_dns.disable_openapi_validation, null)
  wait                       = try(var.external_dns.wait, null)
  wait_for_jobs              = try(var.external_dns.wait_for_jobs, null)
  dependency_update          = try(var.external_dns.dependency_update, null)
  replace                    = try(var.external_dns.replace, null)
  lint                       = try(var.external_dns.lint, null)

  postrender = try(var.external_dns.postrender, [])
  set = concat([
    {
      name  = "serviceAccount.name"
      value = local.external_dns_service_account
    }],
    try(var.external_dns.set, [])
  )
  set_sensitive = try(var.external_dns.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.external_dns.create_role, true) && length(var.external_dns_route53_zone_arns) > 0
  role_name                     = try(var.external_dns.role_name, "external-dns")
  role_name_use_prefix          = try(var.external_dns.role_name_use_prefix, true)
  role_path                     = try(var.external_dns.role_path, "/")
  role_permissions_boundary_arn = lookup(var.external_dns, "role_permissions_boundary_arn", null)
  role_description              = try(var.external_dns.role_description, "IRSA for external-dns operator")
  role_policies                 = lookup(var.external_dns, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.external_dns[*].json,
    lookup(var.external_dns, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.external_dns, "override_policy_documents", [])
  policy_statements         = lookup(var.external_dns, "policy_statements", [])
  policy_name               = try(var.external_dns.policy_name, null)
  policy_name_use_prefix    = try(var.external_dns.policy_name_use_prefix, true)
  policy_path               = try(var.external_dns.policy_path, null)
  policy_description        = try(var.external_dns.policy_description, "IAM Policy for external-dns operator")

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.external_dns_service_account
    }
  }

  tags = var.tags
}

################################################################################
# External Secrets
################################################################################

locals {
  external_secrets_service_account = try(var.external_secrets.service_account_name, "external-secrets-sa")
}

# https://github.com/external-secrets/kubernetes-external-secrets#add-a-secret
data "aws_iam_policy_document" "external_secrets" {
  count = var.enable_external_secrets ? 1 : 0

  dynamic "statement" {
    for_each = length(var.external_secrets_ssm_parameter_arns) > 0 ? [1] : []

    content {
      actions   = ["ssm:DescribeParameters"]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = length(var.external_secrets_ssm_parameter_arns) > 0 ? [1] : []

    content {
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
      ]
      resources = var.external_secrets_ssm_parameter_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.external_secrets_secrets_manager_arns) > 0 ? [1] : []

    content {
      actions   = ["secretsmanager:ListSecrets"]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = length(var.external_secrets_secrets_manager_arns) > 0 ? [1] : []

    content {
      actions = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds",
      ]
      resources = var.external_secrets_secrets_manager_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.external_secrets_kms_key_arns) > 0 ? [1] : []

    content {
      actions   = ["kms:Decrypt"]
      resources = var.external_secrets_kms_key_arns
    }
  }
}

module "external_secrets" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_external_secrets

  # https://github.com/external-secrets/external-secrets/blob/main/deploy/charts/external-secrets/Chart.yaml
  name             = try(var.external_secrets.name, "external-secrets")
  description      = try(var.external_secrets.description, "A Helm chart to deploy external-secrets")
  namespace        = try(var.external_secrets.namespace, "external-secrets")
  create_namespace = try(var.external_secrets.create_namespace, true)
  chart            = "external-secrets"
  chart_version    = try(var.external_secrets.chart_version, "0.8.1")
  repository       = try(var.external_secrets.repository, "https://charts.external-secrets.io")
  values           = try(var.external_secrets.values, [])

  timeout                    = try(var.external_secrets.timeout, null)
  repository_key_file        = try(var.external_secrets.repository_key_file, null)
  repository_cert_file       = try(var.external_secrets.repository_cert_file, null)
  repository_ca_file         = try(var.external_secrets.repository_ca_file, null)
  repository_username        = try(var.external_secrets.repository_username, null)
  repository_password        = try(var.external_secrets.repository_password, null)
  devel                      = try(var.external_secrets.devel, null)
  verify                     = try(var.external_secrets.verify, null)
  keyring                    = try(var.external_secrets.keyring, null)
  disable_webhooks           = try(var.external_secrets.disable_webhooks, null)
  reuse_values               = try(var.external_secrets.reuse_values, null)
  reset_values               = try(var.external_secrets.reset_values, null)
  force_update               = try(var.external_secrets.force_update, null)
  recreate_pods              = try(var.external_secrets.recreate_pods, null)
  cleanup_on_fail            = try(var.external_secrets.cleanup_on_fail, null)
  max_history                = try(var.external_secrets.max_history, null)
  atomic                     = try(var.external_secrets.atomic, null)
  skip_crds                  = try(var.external_secrets.skip_crds, null)
  render_subchart_notes      = try(var.external_secrets.render_subchart_notes, null)
  disable_openapi_validation = try(var.external_secrets.disable_openapi_validation, null)
  wait                       = try(var.external_secrets.wait, null)
  wait_for_jobs              = try(var.external_secrets.wait_for_jobs, null)
  dependency_update          = try(var.external_secrets.dependency_update, null)
  replace                    = try(var.external_secrets.replace, null)
  lint                       = try(var.external_secrets.lint, null)

  postrender = try(var.external_secrets.postrender, [])
  set = concat([
    {
      name  = "serviceAccount.name"
      value = local.external_secrets_service_account
    }],
    try(var.external_secrets.set, [])
  )
  set_sensitive = try(var.external_secrets.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.external_secrets.create_role, true)
  role_name                     = try(var.external_secrets.role_name, "external-secrets")
  role_name_use_prefix          = try(var.external_secrets.role_name_use_prefix, true)
  role_path                     = try(var.external_secrets.role_path, "/")
  role_permissions_boundary_arn = lookup(var.external_secrets, "role_permissions_boundary_arn", null)
  role_description              = try(var.external_secrets.role_description, "IRSA for external-secrets operator")
  role_policies                 = lookup(var.external_secrets, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.external_secrets[*].json,
    lookup(var.external_secrets, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.external_secrets, "override_policy_documents", [])
  policy_statements         = lookup(var.external_secrets, "policy_statements", [])
  policy_name               = try(var.external_secrets.policy_name, null)
  policy_name_use_prefix    = try(var.external_secrets.policy_name_use_prefix, true)
  policy_path               = try(var.external_secrets.policy_path, null)
  policy_description        = try(var.external_secrets.policy_description, "IAM Policy for external-secrets operator")

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.external_secrets_service_account
    }
  }

  tags = var.tags
}

################################################################################
# Fargate Fluentbit
################################################################################

resource "aws_cloudwatch_log_group" "fargate_fluentbit" {
  count = try(var.fargate_fluentbit_cw_log_group.create, true) && var.enable_fargate_fluentbit ? 1 : 0

  name              = try(var.fargate_fluentbit_cw_log_group.name, null)
  name_prefix       = try(var.fargate_fluentbit_cw_log_group.name_prefix, "/${var.cluster_name}/fargate-fluentbit-logs")
  retention_in_days = try(var.fargate_fluentbit_cw_log_group.retention, 90)
  kms_key_id        = try(var.fargate_fluentbit_cw_log_group.kms_key_arn, null)
  skip_destroy      = try(var.fargate_fluentbit_cw_log_group.skip_destroy, false)
  tags              = merge(var.tags, try(var.fargate_fluentbit_cw_log_group.tags, {}))
}

# Help on Fargate Logging with Fluentbit and CloudWatch
# https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html
resource "kubernetes_namespace_v1" "aws_observability" {
  count = var.enable_fargate_fluentbit ? 1 : 0

  metadata {
    name = "aws-observability"

    labels = {
      aws-observability = "enabled"
    }
  }
}

# fluent-bit-cloudwatch value as the name of the CloudWatch log group that is automatically created as soon as your apps start logging
resource "kubernetes_config_map_v1" "aws_logging" {
  count = var.enable_fargate_fluentbit ? 1 : 0

  metadata {
    name      = "aws-logging"
    namespace = kubernetes_namespace_v1.aws_observability[0].id
  }

  data = {
    "parsers.conf" = try(
      var.fargate_fluentbit.parsers_conf,
      <<-EOT
        [PARSER]
          Name regex
          Format regex
          Regex ^(?<time>[^ ]+) (?<stream>[^ ]+) (?<logtag>[^ ]+) (?<message>.+)$
          Time_Key time
          Time_Format %Y-%m-%dT%H:%M:%S.%L%z
          Time_Keep On
          Decode_Field_As json message
      EOT
    )
    "filters.conf" = try(
      var.fargate_fluentbit.filters_conf,
      <<-EOT
        [FILTER]
          Name parser
          Match *
          Key_Name log
          Parser regex
          Preserve_Key True
          Reserve_Data True
      EOT
    )
    "output.conf" = try(
      var.fargate_fluentbit.output_conf,
      <<-EOT
        [OUTPUT]
          Name cloudwatch_logs
          Match *
          region ${local.region}
          log_group_name ${try(var.fargate_fluentbit.cwlog_group, aws_cloudwatch_log_group.fargate_fluentbit[0].name)}
          log_stream_prefix ${try(var.fargate_fluentbit.cwlog_stream_prefix, "fargate-logs-")}
          auto_create_group true
      EOT
    )
    "flb_log_cw" = try(var.fargate_fluentbit.flb_log_cw, false)
  }
}

################################################################################
# Gatekeeper
################################################################################

module "gatekeeper" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_gatekeeper

  # https://github.com/open-policy-agent/gatekeeper/blob/master/charts/gatekeeper/Chart.yaml
  name             = try(var.gatekeeper.name, "gatekeeper")
  description      = try(var.gatekeeper.description, "A Helm chart to install Gatekeeper")
  namespace        = try(var.gatekeeper.namespace, "gatekeeper-system")
  create_namespace = try(var.gatekeeper.create_namespace, true)
  chart            = "gatekeeper"
  chart_version    = try(var.gatekeeper.chart_version, "3.12.0")
  repository       = try(var.gatekeeper.repository, "https://open-policy-agent.github.io/gatekeeper/charts")
  values           = try(var.gatekeeper.values, [])

  timeout                    = try(var.gatekeeper.timeout, null)
  repository_key_file        = try(var.gatekeeper.repository_key_file, null)
  repository_cert_file       = try(var.gatekeeper.repository_cert_file, null)
  repository_ca_file         = try(var.gatekeeper.repository_ca_file, null)
  repository_username        = try(var.gatekeeper.repository_username, null)
  repository_password        = try(var.gatekeeper.repository_password, null)
  devel                      = try(var.gatekeeper.devel, null)
  verify                     = try(var.gatekeeper.verify, null)
  keyring                    = try(var.gatekeeper.keyring, null)
  disable_webhooks           = try(var.gatekeeper.disable_webhooks, null)
  reuse_values               = try(var.gatekeeper.reuse_values, null)
  reset_values               = try(var.gatekeeper.reset_values, null)
  force_update               = try(var.gatekeeper.force_update, null)
  recreate_pods              = try(var.gatekeeper.recreate_pods, null)
  cleanup_on_fail            = try(var.gatekeeper.cleanup_on_fail, null)
  max_history                = try(var.gatekeeper.max_history, null)
  atomic                     = try(var.gatekeeper.atomic, null)
  skip_crds                  = try(var.gatekeeper.skip_crds, null)
  render_subchart_notes      = try(var.gatekeeper.render_subchart_notes, null)
  disable_openapi_validation = try(var.gatekeeper.disable_openapi_validation, null)
  wait                       = try(var.gatekeeper.wait, null)
  wait_for_jobs              = try(var.gatekeeper.wait_for_jobs, null)
  dependency_update          = try(var.gatekeeper.dependency_update, null)
  replace                    = try(var.gatekeeper.replace, null)
  lint                       = try(var.gatekeeper.lint, null)

  postrender    = try(var.gatekeeper.postrender, [])
  set           = try(var.gatekeeper.set, [])
  set_sensitive = try(var.gatekeeper.set_sensitive, [])

  tags = var.tags
}

################################################################################
# Ingress Nginx
################################################################################

module "ingress_nginx" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_ingress_nginx

  # https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/Chart.yaml
  name             = try(var.ingress_nginx.name, "ingress-nginx")
  description      = try(var.ingress_nginx.description, "A Helm chart to install the Ingress Nginx")
  namespace        = try(var.ingress_nginx.namespace, "ingress-nginx")
  create_namespace = try(var.ingress_nginx.create_namespace, true)
  chart            = "ingress-nginx"
  chart_version    = try(var.ingress_nginx.chart_version, "4.6.0")
  repository       = try(var.ingress_nginx.repository, "https://kubernetes.github.io/ingress-nginx")
  values           = try(var.ingress_nginx.values, [])

  timeout                    = try(var.ingress_nginx.timeout, null)
  repository_key_file        = try(var.ingress_nginx.repository_key_file, null)
  repository_cert_file       = try(var.ingress_nginx.repository_cert_file, null)
  repository_ca_file         = try(var.ingress_nginx.repository_ca_file, null)
  repository_username        = try(var.ingress_nginx.repository_username, null)
  repository_password        = try(var.ingress_nginx.repository_password, null)
  devel                      = try(var.ingress_nginx.devel, null)
  verify                     = try(var.ingress_nginx.verify, null)
  keyring                    = try(var.ingress_nginx.keyring, null)
  disable_webhooks           = try(var.ingress_nginx.disable_webhooks, null)
  reuse_values               = try(var.ingress_nginx.reuse_values, null)
  reset_values               = try(var.ingress_nginx.reset_values, null)
  force_update               = try(var.ingress_nginx.force_update, null)
  recreate_pods              = try(var.ingress_nginx.recreate_pods, null)
  cleanup_on_fail            = try(var.ingress_nginx.cleanup_on_fail, null)
  max_history                = try(var.ingress_nginx.max_history, null)
  atomic                     = try(var.ingress_nginx.atomic, null)
  skip_crds                  = try(var.ingress_nginx.skip_crds, null)
  render_subchart_notes      = try(var.ingress_nginx.render_subchart_notes, null)
  disable_openapi_validation = try(var.ingress_nginx.disable_openapi_validation, null)
  wait                       = try(var.ingress_nginx.wait, null)
  wait_for_jobs              = try(var.ingress_nginx.wait_for_jobs, null)
  dependency_update          = try(var.ingress_nginx.dependency_update, null)
  replace                    = try(var.ingress_nginx.replace, null)
  lint                       = try(var.ingress_nginx.lint, null)

  postrender    = try(var.ingress_nginx.postrender, [])
  set           = try(var.ingress_nginx.set, [])
  set_sensitive = try(var.ingress_nginx.set_sensitive, [])

  tags = var.tags
}

################################################################################
# Karpenter
################################################################################

locals {
  karpenter_service_account_name    = try(var.karpenter.service_account_name, "karpenter")
  karpenter_enable_spot_termination = var.enable_karpenter && var.karpenter_enable_spot_termination

  create_karpenter_node_iam_role = var.enable_karpenter && try(var.karpenter_node.create_iam_role, true)
  karpenter_node_iam_role_arn    = try(aws_iam_role.karpenter[0].arn, var.karpenter_node.iam_role_arn, "")
  karpenter_node_iam_role_name   = try(var.karpenter_node.iam_role_name, "karpenter-${var.cluster_name}")
}

data "aws_iam_policy_document" "karpenter" {
  count = var.enable_karpenter ? 1 : 0

  statement {
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateTags",
      "ec2:DeleteLaunchTemplate",
      "ec2:RunInstances"
    ]
    resources = [
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:*",
      "arn:${local.partition}:ec2:${local.region}::image/*"
    ]
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = [local.karpenter_node_iam_role_arn]
  }

  statement {
    actions   = ["pricing:GetProducts"]
    resources = ["*"]
  }

  statement {
    actions   = ["ssm:GetParameter"]
    resources = ["arn:${local.partition}:ssm:${local.region}::parameter/*"]
  }

  statement {
    actions   = ["eks:DescribeCluster"]
    resources = ["arn:${local.partition}:eks:*:${local.account_id}:cluster/${var.cluster_name}"]
  }

  statement {
    actions   = ["ec2:TerminateInstances"]
    resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/*"]

    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/Name"
      values   = ["*karpenter*"]
    }
  }

  dynamic "statement" {
    for_each = var.karpenter_enable_spot_termination ? [1] : []

    content {
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage",
      ]
      resources = [module.karpenter_sqs.queue_arn]
    }
  }
}

module "karpenter_sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.1"

  create = local.karpenter_enable_spot_termination

  name = try(var.karpenter_sqs.queue_name, "karpenter-${var.cluster_name}")

  message_retention_seconds         = try(var.karpenter_sqs.message_retention_seconds, 300)
  sqs_managed_sse_enabled           = try(var.karpenter_sqs.sse_enabled, true)
  kms_master_key_id                 = try(var.karpenter_sqs.kms_master_key_id, null)
  kms_data_key_reuse_period_seconds = try(var.karpenter_sqs.kms_data_key_reuse_period_seconds, null)

  create_queue_policy = true
  queue_policy_statements = {
    account = {
      sid     = "SendEventsToQueue"
      actions = ["sqs:SendMessage"]
      principals = [
        {
          type = "Service"
          identifiers = [
            "events.${local.dns_suffix}",
            "sqs.${local.dns_suffix}",
          ]
        }
      ]
    }
  }

  tags = merge(var.tags, try(var.karpenter_sqs.tags, {}))
}

resource "aws_cloudwatch_event_rule" "karpenter" {
  for_each = { for k, v in local.ec2_events : k => v if local.karpenter_enable_spot_termination }

  name_prefix   = "Karpenter-${each.value.name}-"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

  tags = merge(
    { "ClusterName" : var.cluster_name },
    var.tags,
  )
}

resource "aws_cloudwatch_event_target" "karpenter" {
  for_each = { for k, v in local.ec2_events : k => v if local.karpenter_enable_spot_termination }

  rule      = aws_cloudwatch_event_rule.karpenter[each.key].name
  target_id = "KarpenterQueueTarget"
  arn       = module.karpenter_sqs.queue_arn
}

data "aws_iam_policy_document" "karpenter_assume_role" {
  count = local.create_karpenter_node_iam_role ? 1 : 0

  statement {
    sid     = "KarpenterNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${local.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "karpenter" {
  count = local.create_karpenter_node_iam_role ? 1 : 0

  name        = try(var.karpenter_node.iam_role_use_name_prefix, true) ? null : local.karpenter_node_iam_role_name
  name_prefix = try(var.karpenter_node.iam_role_use_name_prefix, true) ? "${local.karpenter_node_iam_role_name}-" : null
  path        = try(var.karpenter_node.iam_role_path, null)
  description = try(var.karpenter_node.iam_role_description, "Karpenter EC2 node IAM role")

  assume_role_policy    = try(data.aws_iam_policy_document.karpenter_assume_role[0].json, "")
  max_session_duration  = try(var.karpenter_node.iam_role_max_session_duration, null)
  permissions_boundary  = try(var.karpenter_node.iam_role_permissions_boundary, null)
  force_detach_policies = true

  tags = merge(var.tags, try(var.karpenter_node.iam_role_tags, {}))
}

resource "aws_iam_role_policy_attachment" "karpenter" {
  for_each = { for k, v in {
    AmazonEKSWorkerNodePolicy          = "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy",
    AmazonEC2ContainerRegistryReadOnly = "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly",
    AmazonEKS_CNI_Policy               = "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
  } : k => v if local.create_karpenter_node_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.karpenter[0].name
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = { for k, v in try(var.karpenter_node.iam_role_additional_policies, {}) : k => v if local.create_karpenter_node_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.karpenter[0].name
}

resource "aws_iam_instance_profile" "karpenter" {
  count = var.enable_karpenter && try(var.karpenter_node.create_instance_profile, true) ? 1 : 0

  name        = try(var.karpenter_node.iam_role_use_name_prefix, true) ? null : local.karpenter_node_iam_role_name
  name_prefix = try(var.karpenter_node.iam_role_use_name_prefix, true) ? "${local.karpenter_node_iam_role_name}-" : null
  path        = try(var.karpenter_node.iam_role_path, null)
  role        = try(aws_iam_role.karpenter[0].name, var.karpenter_node.iam_role_name, "")

  tags = merge(var.tags, try(var.karpenter_node.instance_profile_tags, {}))
}

module "karpenter" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_karpenter

  # https://github.com/aws/karpenter/blob/main/charts/karpenter/Chart.yaml
  name             = try(var.karpenter.name, "karpenter")
  description      = try(var.karpenter.description, "A Helm chart to deploy Karpenter")
  namespace        = try(var.karpenter.namespace, "karpenter")
  create_namespace = try(var.karpenter.create_namespace, true)
  chart            = "karpenter"
  chart_version    = try(var.karpenter.chart_version, "v0.27.2")
  repository       = try(var.karpenter.repository, "oci://public.ecr.aws/karpenter")
  values           = try(var.karpenter.values, [])

  timeout                    = try(var.karpenter.timeout, null)
  repository_key_file        = try(var.karpenter.repository_key_file, null)
  repository_cert_file       = try(var.karpenter.repository_cert_file, null)
  repository_ca_file         = try(var.karpenter.repository_ca_file, null)
  repository_username        = try(var.karpenter.repository_username, null)
  repository_password        = try(var.karpenter.repository_password, null)
  devel                      = try(var.karpenter.devel, null)
  verify                     = try(var.karpenter.verify, null)
  keyring                    = try(var.karpenter.keyring, null)
  disable_webhooks           = try(var.karpenter.disable_webhooks, null)
  reuse_values               = try(var.karpenter.reuse_values, null)
  reset_values               = try(var.karpenter.reset_values, null)
  force_update               = try(var.karpenter.force_update, null)
  recreate_pods              = try(var.karpenter.recreate_pods, null)
  cleanup_on_fail            = try(var.karpenter.cleanup_on_fail, null)
  max_history                = try(var.karpenter.max_history, null)
  atomic                     = try(var.karpenter.atomic, null)
  skip_crds                  = try(var.karpenter.skip_crds, null)
  render_subchart_notes      = try(var.karpenter.render_subchart_notes, null)
  disable_openapi_validation = try(var.karpenter.disable_openapi_validation, null)
  wait                       = try(var.karpenter.wait, null)
  wait_for_jobs              = try(var.karpenter.wait_for_jobs, null)
  dependency_update          = try(var.karpenter.dependency_update, null)
  replace                    = try(var.karpenter.replace, null)
  lint                       = try(var.karpenter.lint, null)

  postrender = try(var.karpenter.postrender, [])
  set = concat(
    [
      {
        name  = "settings.aws.clusterName"
        value = local.cluster_name
      },
      {
        name  = "settings.aws.clusterEndpoint"
        value = local.cluster_endpoint
      },
      {
        name  = "settings.aws.defaultInstanceProfile"
        value = try(aws_iam_instance_profile.karpenter[0].name, var.karpenter_node.instance_profile_name, "")
      },
      {
        name  = "settings.aws.interruptionQueueName"
        value = module.karpenter_sqs.queue_name
      },
      {
        name  = "serviceAccount.name"
        value = local.karpenter_service_account_name
      },
    ],
    try(var.karpenter.set, [])
  )
  set_sensitive = try(var.karpenter.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.karpenter.create_role, true)
  role_name                     = try(var.karpenter.role_name, "karpenter")
  role_name_use_prefix          = try(var.karpenter.role_name_use_prefix, true)
  role_path                     = try(var.karpenter.role_path, "/")
  role_permissions_boundary_arn = lookup(var.karpenter, "role_permissions_boundary_arn", null)
  role_description              = try(var.karpenter.role_description, "IRSA for Karpenter")
  role_policies                 = lookup(var.karpenter, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.karpenter[*].json,
    lookup(var.karpenter, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.karpenter, "override_policy_documents", [])
  policy_statements         = lookup(var.karpenter, "policy_statements", [])
  policy_name               = try(var.karpenter.policy_name, null)
  policy_name_use_prefix    = try(var.karpenter.policy_name_use_prefix, true)
  policy_path               = try(var.karpenter.policy_path, null)
  policy_description        = try(var.karpenter.policy_description, "IAM Policy for karpenter")

  oidc_providers = {
    this = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.karpenter_service_account_name
    }
  }

  tags = var.tags
}

################################################################################
# Kube Prometheus stack
################################################################################

# During destroy CRDs created by this chart are not removed by default and
# should be manually cleaned up:
# kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
# kubectl delete crd alertmanagers.monitoring.coreos.com
# kubectl delete crd podmonitors.monitoring.coreos.com
# kubectl delete crd probes.monitoring.coreos.com
# kubectl delete crd prometheuses.monitoring.coreos.com
# kubectl delete crd prometheusrules.monitoring.coreos.com
# kubectl delete crd servicemonitors.monitoring.coreos.com
# kubectl delete crd thanosrulers.monitoring.coreos.com

module "kube_prometheus_stack" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_kube_prometheus_stack

  # https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/Chart.yaml
  name             = try(var.kube_prometheus_stack.name, "kube-prometheus-stack")
  description      = try(var.kube_prometheus_stack.description, "A Helm chart to install the Kube Prometheus Stack")
  namespace        = try(var.kube_prometheus_stack.namespace, "kube-prometheus-stack")
  create_namespace = try(var.kube_prometheus_stack.create_namespace, true)
  chart            = "kube-prometheus-stack"
  chart_version    = try(var.kube_prometheus_stack.chart_version, "45.10.1")
  repository       = try(var.kube_prometheus_stack.repository, "https://prometheus-community.github.io/helm-charts")
  values           = try(var.kube_prometheus_stack.values, [])

  timeout                    = try(var.kube_prometheus_stack.timeout, null)
  repository_key_file        = try(var.kube_prometheus_stack.repository_key_file, null)
  repository_cert_file       = try(var.kube_prometheus_stack.repository_cert_file, null)
  repository_ca_file         = try(var.kube_prometheus_stack.repository_ca_file, null)
  repository_username        = try(var.kube_prometheus_stack.repository_username, null)
  repository_password        = try(var.kube_prometheus_stack.repository_password, null)
  devel                      = try(var.kube_prometheus_stack.devel, null)
  verify                     = try(var.kube_prometheus_stack.verify, null)
  keyring                    = try(var.kube_prometheus_stack.keyring, null)
  disable_webhooks           = try(var.kube_prometheus_stack.disable_webhooks, null)
  reuse_values               = try(var.kube_prometheus_stack.reuse_values, null)
  reset_values               = try(var.kube_prometheus_stack.reset_values, null)
  force_update               = try(var.kube_prometheus_stack.force_update, null)
  recreate_pods              = try(var.kube_prometheus_stack.recreate_pods, null)
  cleanup_on_fail            = try(var.kube_prometheus_stack.cleanup_on_fail, null)
  max_history                = try(var.kube_prometheus_stack.max_history, null)
  atomic                     = try(var.kube_prometheus_stack.atomic, null)
  skip_crds                  = try(var.kube_prometheus_stack.skip_crds, null)
  render_subchart_notes      = try(var.kube_prometheus_stack.render_subchart_notes, null)
  disable_openapi_validation = try(var.kube_prometheus_stack.disable_openapi_validation, null)
  wait                       = try(var.kube_prometheus_stack.wait, null)
  wait_for_jobs              = try(var.kube_prometheus_stack.wait_for_jobs, null)
  dependency_update          = try(var.kube_prometheus_stack.dependency_update, null)
  replace                    = try(var.kube_prometheus_stack.replace, null)
  lint                       = try(var.kube_prometheus_stack.lint, null)

  postrender    = try(var.kube_prometheus_stack.postrender, [])
  set           = try(var.kube_prometheus_stack.set, [])
  set_sensitive = try(var.kube_prometheus_stack.set_sensitive, [])

  tags = var.tags
}

################################################################################
# Metrics Server
################################################################################

module "metrics_server" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_metrics_server

  # https://github.com/kubernetes-sigs/metrics-server/blob/master/charts/metrics-server/Chart.yaml
  name             = try(var.metrics_server.name, "metrics-server")
  description      = try(var.metrics_server.description, "A Helm chart to install the Metrics Server")
  namespace        = try(var.metrics_server.namespace, "kube-system")
  create_namespace = try(var.metrics_server.create_namespace, false)
  chart            = "metrics-server"
  chart_version    = try(var.metrics_server.chart_version, "3.10.0")
  repository       = try(var.metrics_server.repository, "https://kubernetes-sigs.github.io/metrics-server/")
  values           = try(var.metrics_server.values, [])

  timeout                    = try(var.metrics_server.timeout, null)
  repository_key_file        = try(var.metrics_server.repository_key_file, null)
  repository_cert_file       = try(var.metrics_server.repository_cert_file, null)
  repository_ca_file         = try(var.metrics_server.repository_ca_file, null)
  repository_username        = try(var.metrics_server.repository_username, null)
  repository_password        = try(var.metrics_server.repository_password, null)
  devel                      = try(var.metrics_server.devel, null)
  verify                     = try(var.metrics_server.verify, null)
  keyring                    = try(var.metrics_server.keyring, null)
  disable_webhooks           = try(var.metrics_server.disable_webhooks, null)
  reuse_values               = try(var.metrics_server.reuse_values, null)
  reset_values               = try(var.metrics_server.reset_values, null)
  force_update               = try(var.metrics_server.force_update, null)
  recreate_pods              = try(var.metrics_server.recreate_pods, null)
  cleanup_on_fail            = try(var.metrics_server.cleanup_on_fail, null)
  max_history                = try(var.metrics_server.max_history, null)
  atomic                     = try(var.metrics_server.atomic, null)
  skip_crds                  = try(var.metrics_server.skip_crds, null)
  render_subchart_notes      = try(var.metrics_server.render_subchart_notes, null)
  disable_openapi_validation = try(var.metrics_server.disable_openapi_validation, null)
  wait                       = try(var.metrics_server.wait, null)
  wait_for_jobs              = try(var.metrics_server.wait_for_jobs, null)
  dependency_update          = try(var.metrics_server.dependency_update, null)
  replace                    = try(var.metrics_server.replace, null)
  lint                       = try(var.metrics_server.lint, null)

  postrender    = try(var.metrics_server.postrender, [])
  set           = try(var.metrics_server.set, [])
  set_sensitive = try(var.metrics_server.set_sensitive, [])

  tags = var.tags
}

################################################################################
# Secrets Store CSI Driver
################################################################################

module "secrets_store_csi_driver" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_secrets_store_csi_driver

  # https://github.com/kubernetes-sigs/secrets-store-csi-driver/blob/main/charts/secrets-store-csi-driver/Chart.yaml
  name             = try(var.secrets_store_csi_driver.name, "secrets-store-csi-driver")
  description      = try(var.secrets_store_csi_driver.description, "A Helm chart to install the Secrets Store CSI Driver")
  namespace        = try(var.secrets_store_csi_driver.namespace, "kube-system")
  create_namespace = try(var.secrets_store_csi_driver.create_namespace, false)
  chart            = "secrets-store-csi-driver"
  chart_version    = try(var.secrets_store_csi_driver.chart_version, "1.3.2")
  repository       = try(var.secrets_store_csi_driver.repository, "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts")
  values           = try(var.secrets_store_csi_driver.values, [])

  timeout                    = try(var.secrets_store_csi_driver.timeout, null)
  repository_key_file        = try(var.secrets_store_csi_driver.repository_key_file, null)
  repository_cert_file       = try(var.secrets_store_csi_driver.repository_cert_file, null)
  repository_ca_file         = try(var.secrets_store_csi_driver.repository_ca_file, null)
  repository_username        = try(var.secrets_store_csi_driver.repository_username, null)
  repository_password        = try(var.secrets_store_csi_driver.repository_password, null)
  devel                      = try(var.secrets_store_csi_driver.devel, null)
  verify                     = try(var.secrets_store_csi_driver.verify, null)
  keyring                    = try(var.secrets_store_csi_driver.keyring, null)
  disable_webhooks           = try(var.secrets_store_csi_driver.disable_webhooks, null)
  reuse_values               = try(var.secrets_store_csi_driver.reuse_values, null)
  reset_values               = try(var.secrets_store_csi_driver.reset_values, null)
  force_update               = try(var.secrets_store_csi_driver.force_update, null)
  recreate_pods              = try(var.secrets_store_csi_driver.recreate_pods, null)
  cleanup_on_fail            = try(var.secrets_store_csi_driver.cleanup_on_fail, null)
  max_history                = try(var.secrets_store_csi_driver.max_history, null)
  atomic                     = try(var.secrets_store_csi_driver.atomic, null)
  skip_crds                  = try(var.secrets_store_csi_driver.skip_crds, null)
  render_subchart_notes      = try(var.secrets_store_csi_driver.render_subchart_notes, null)
  disable_openapi_validation = try(var.secrets_store_csi_driver.disable_openapi_validation, null)
  wait                       = try(var.secrets_store_csi_driver.wait, null)
  wait_for_jobs              = try(var.secrets_store_csi_driver.wait_for_jobs, null)
  dependency_update          = try(var.secrets_store_csi_driver.dependency_update, null)
  replace                    = try(var.secrets_store_csi_driver.replace, null)
  lint                       = try(var.secrets_store_csi_driver.lint, null)

  postrender    = try(var.secrets_store_csi_driver.postrender, [])
  set           = try(var.secrets_store_csi_driver.set, [])
  set_sensitive = try(var.secrets_store_csi_driver.set_sensitive, [])

  tags = var.tags
}

################################################################################
# Secrets Store CSI Driver Provider AWS
################################################################################

locals {
  secrets_store_csi_driver_provider_aws_service_account = try(var.secrets_store_csi_driver_provider_aws.service_account_name, "secrets-store-csi-driver-provider-aws-sa")
}

module "secrets_store_csi_driver_provider_aws" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_secrets_store_csi_driver_provider_aws

  # https://github.com/aws/eks-charts/blob/master/stable/csi-secrets-store-provider-aws/Chart.yaml
  name             = try(var.secrets_store_csi_driver_provider_aws.name, "secrets-store-csi-driver-provider-aws")
  description      = try(var.secrets_store_csi_driver_provider_aws.description, "A Helm chart to install the Secrets Store CSI Driver and the AWS Key Management Service Provider inside a Kubernetes cluster.")
  namespace        = try(var.secrets_store_csi_driver_provider_aws.namespace, "kube-system")
  create_namespace = try(var.secrets_store_csi_driver_provider_aws.create_namespace, false)
  chart            = "secrets-store-csi-driver-provider-aws"
  chart_version    = try(var.secrets_store_csi_driver_provider_aws.chart_version, "0.3.2")
  repository       = try(var.secrets_store_csi_driver_provider_aws.repository, "https://aws.github.io/secrets-store-csi-driver-provider-aws")
  values           = try(var.secrets_store_csi_driver_provider_aws.values, [])

  timeout                    = try(var.secrets_store_csi_driver_provider_aws.timeout, null)
  repository_key_file        = try(var.secrets_store_csi_driver_provider_aws.repository_key_file, null)
  repository_cert_file       = try(var.secrets_store_csi_driver_provider_aws.repository_cert_file, null)
  repository_ca_file         = try(var.secrets_store_csi_driver_provider_aws.repository_ca_file, null)
  repository_username        = try(var.secrets_store_csi_driver_provider_aws.repository_username, null)
  repository_password        = try(var.secrets_store_csi_driver_provider_aws.repository_password, null)
  devel                      = try(var.secrets_store_csi_driver_provider_aws.devel, null)
  verify                     = try(var.secrets_store_csi_driver_provider_aws.verify, null)
  keyring                    = try(var.secrets_store_csi_driver_provider_aws.keyring, null)
  disable_webhooks           = try(var.secrets_store_csi_driver_provider_aws.disable_webhooks, null)
  reuse_values               = try(var.secrets_store_csi_driver_provider_aws.reuse_values, null)
  reset_values               = try(var.secrets_store_csi_driver_provider_aws.reset_values, null)
  force_update               = try(var.secrets_store_csi_driver_provider_aws.force_update, null)
  recreate_pods              = try(var.secrets_store_csi_driver_provider_aws.recreate_pods, null)
  cleanup_on_fail            = try(var.secrets_store_csi_driver_provider_aws.cleanup_on_fail, null)
  max_history                = try(var.secrets_store_csi_driver_provider_aws.max_history, null)
  atomic                     = try(var.secrets_store_csi_driver_provider_aws.atomic, null)
  skip_crds                  = try(var.secrets_store_csi_driver_provider_aws.skip_crds, null)
  render_subchart_notes      = try(var.secrets_store_csi_driver_provider_aws.render_subchart_notes, null)
  disable_openapi_validation = try(var.secrets_store_csi_driver_provider_aws.disable_openapi_validation, null)
  wait                       = try(var.secrets_store_csi_driver_provider_aws.wait, null)
  wait_for_jobs              = try(var.secrets_store_csi_driver_provider_aws.wait_for_jobs, null)
  dependency_update          = try(var.secrets_store_csi_driver_provider_aws.dependency_update, null)
  replace                    = try(var.secrets_store_csi_driver_provider_aws.replace, null)
  lint                       = try(var.secrets_store_csi_driver_provider_aws.lint, null)

  postrender = try(var.secrets_store_csi_driver_provider_aws.postrender, [])
  set = concat([
    {
      name  = "serviceAccount.name"
      value = local.secrets_store_csi_driver_provider_aws_service_account
    }],
    try(var.secrets_store_csi_driver_provider_aws.set, [])
  )
  set_sensitive = try(var.secrets_store_csi_driver_provider_aws.set_sensitive, [])

  tags = var.tags
}

################################################################################
# Velero
################################################################################

locals {
  velero_name                    = "velero"
  velero_service_account         = try(var.velero.service_account_name, "${local.velero_name}-server")
  velero_backup_s3_bucket        = try(split(":", var.velero.s3_backup_location), [])
  velero_backup_s3_bucket_arn    = try(split("/", var.velero.s3_backup_location)[0], var.velero.s3_backup_location, "")
  velero_backup_s3_bucket_name   = try(split("/", local.velero_backup_s3_bucket[5])[0], local.velero_backup_s3_bucket[5], "")
  velero_backup_s3_bucket_prefix = try(split("/", var.velero.s3_backup_location)[1], "")
}

# https://github.com/vmware-tanzu/velero-plugin-for-aws#option-1-set-permissions-with-an-iam-user
data "aws_iam_policy_document" "velero" {
  count = var.enable_velero ? 1 : 0

  statement {
    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot"
    ]
    resources = [
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/*",
      "arn:${local.partition}:ec2:${local.region}::snapshot/*",
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:volume/*"
    ]
  }

  statement {
    actions = [
      "ec2:DescribeSnapshots",
      "ec2:DescribeVolumes"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["${var.velero.s3_backup_location}/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [local.velero_backup_s3_bucket_arn]
  }
}

module "velero" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_velero

  # https://github.com/vmware-tanzu/helm-charts/blob/main/charts/velero/Chart.yaml
  name             = try(var.velero.name, "velero")
  description      = try(var.velero.description, "A Helm chart to install the Velero")
  namespace        = try(var.velero.namespace, "velero")
  create_namespace = try(var.velero.create_namespace, true)
  chart            = "velero"
  chart_version    = try(var.velero.chart_version, "3.1.6")
  repository       = try(var.velero.repository, "https://vmware-tanzu.github.io/helm-charts/")
  values           = try(var.velero.values, [])

  timeout                    = try(var.velero.timeout, null)
  repository_key_file        = try(var.velero.repository_key_file, null)
  repository_cert_file       = try(var.velero.repository_cert_file, null)
  repository_ca_file         = try(var.velero.repository_ca_file, null)
  repository_username        = try(var.velero.repository_username, null)
  repository_password        = try(var.velero.repository_password, null)
  devel                      = try(var.velero.devel, null)
  verify                     = try(var.velero.verify, null)
  keyring                    = try(var.velero.keyring, null)
  disable_webhooks           = try(var.velero.disable_webhooks, null)
  reuse_values               = try(var.velero.reuse_values, null)
  reset_values               = try(var.velero.reset_values, null)
  force_update               = try(var.velero.force_update, null)
  recreate_pods              = try(var.velero.recreate_pods, null)
  cleanup_on_fail            = try(var.velero.cleanup_on_fail, null)
  max_history                = try(var.velero.max_history, null)
  atomic                     = try(var.velero.atomic, null)
  skip_crds                  = try(var.velero.skip_crds, null)
  render_subchart_notes      = try(var.velero.render_subchart_notes, null)
  disable_openapi_validation = try(var.velero.disable_openapi_validation, null)
  wait                       = try(var.velero.wait, null)
  wait_for_jobs              = try(var.velero.wait_for_jobs, null)
  dependency_update          = try(var.velero.dependency_update, null)
  replace                    = try(var.velero.replace, null)
  lint                       = try(var.velero.lint, null)

  postrender = try(var.velero.postrender, [])
  set = concat([
    {
      name  = "initContainers"
      value = <<-EOT
   - name: velero-plugin-for-aws
     image: velero/velero-plugin-for-aws:v1.7.0
     imagePullPolicy: IfNotPresent
     volumeMounts:
       - mountPath: /target
         name: plugins
            EOT
    },
    {
      name  = "serviceAccount.server.name"
      value = local.velero_service_account
    },
    {
      name  = "configuration.provider"
      value = "aws"
    },
    {
      name  = "configuration.backupStorageLocation.prefix"
      value = local.velero_backup_s3_bucket_prefix
    },
    {
      name  = "configuration.backupStorageLocation.bucket"
      value = local.velero_backup_s3_bucket_name
    },
    {
      name  = "configuration.backupStorageLocation.config.region"
      value = local.region
    },
    {
      name  = "configuration.volumeSnapshotLocation.config.region"
      value = local.region
    },
    {
      name  = "credentials.useSecret"
      value = false
    }],
    try(var.velero.set, [])
  )
  set_sensitive = try(var.velero.set_sensitive, [])

  # IAM role for service account (IRSA)
  set_irsa_names                = ["serviceAccount.server.annotations.eks\\.amazonaws\\.com/role-arn"]
  create_role                   = try(var.velero.create_role, true)
  role_name                     = try(var.velero.role_name, "velero")
  role_name_use_prefix          = try(var.velero.role_name_use_prefix, true)
  role_path                     = try(var.velero.role_path, "/")
  role_permissions_boundary_arn = lookup(var.velero, "role_permissions_boundary_arn", null)
  role_description              = try(var.velero.role_description, "IRSA for Velero")
  role_policies                 = lookup(var.velero, "role_policies", {})

  source_policy_documents = compact(concat(
    data.aws_iam_policy_document.velero[*].json,
    lookup(var.velero, "source_policy_documents", [])
  ))
  override_policy_documents = lookup(var.velero, "override_policy_documents", [])
  policy_statements         = lookup(var.velero, "policy_statements", [])
  policy_name               = try(var.velero.policy_name, "velero")
  policy_name_use_prefix    = try(var.velero.policy_name_use_prefix, true)
  policy_path               = try(var.velero.policy_path, null)
  policy_description        = try(var.velero.policy_description, "IAM Policy for Velero")

  oidc_providers = {
    controller = {
      provider_arn = local.oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.velero_service_account
    }
  }

  tags = var.tags
}

################################################################################
# Vertical Pod Autoscaler
################################################################################

module "vpa" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.0.0"

  create = var.enable_vpa

  # https://github.com/FairwindsOps/charts/blob/master/stable/vpa/Chart.yaml
  # (there is no offical helm chart for VPA)
  name             = try(var.vpa.name, "vpa")
  description      = try(var.vpa.description, "A Helm chart to install the Vertical Pod Autoscaler")
  namespace        = try(var.vpa.namespace, "vpa")
  create_namespace = try(var.vpa.create_namespace, true)
  chart            = "vpa"
  chart_version    = try(var.vpa.chart_version, "1.7.2")
  repository       = try(var.vpa.repository, "https://charts.fairwinds.com/stable")
  values           = try(var.vpa.values, [])

  timeout                    = try(var.vpa.timeout, null)
  repository_key_file        = try(var.vpa.repository_key_file, null)
  repository_cert_file       = try(var.vpa.repository_cert_file, null)
  repository_ca_file         = try(var.vpa.repository_ca_file, null)
  repository_username        = try(var.vpa.repository_username, null)
  repository_password        = try(var.vpa.repository_password, null)
  devel                      = try(var.vpa.devel, null)
  verify                     = try(var.vpa.verify, null)
  keyring                    = try(var.vpa.keyring, null)
  disable_webhooks           = try(var.vpa.disable_webhooks, null)
  reuse_values               = try(var.vpa.reuse_values, null)
  reset_values               = try(var.vpa.reset_values, null)
  force_update               = try(var.vpa.force_update, null)
  recreate_pods              = try(var.vpa.recreate_pods, null)
  cleanup_on_fail            = try(var.vpa.cleanup_on_fail, null)
  max_history                = try(var.vpa.max_history, null)
  atomic                     = try(var.vpa.atomic, null)
  skip_crds                  = try(var.vpa.skip_crds, null)
  render_subchart_notes      = try(var.vpa.render_subchart_notes, null)
  disable_openapi_validation = try(var.vpa.disable_openapi_validation, null)
  wait                       = try(var.vpa.wait, null)
  wait_for_jobs              = try(var.vpa.wait_for_jobs, null)
  dependency_update          = try(var.vpa.dependency_update, null)
  replace                    = try(var.vpa.replace, null)
  lint                       = try(var.vpa.lint, null)

  postrender    = try(var.vpa.postrender, [])
  set           = try(var.vpa.set, [])
  set_sensitive = try(var.vpa.set_sensitive, [])

  tags = var.tags
}
