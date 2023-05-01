locals {
  name            = "karpenter"
  service_account = try(var.helm_config.service_account, "karpenter")
  set_values = [{
    name  = "serviceAccount.name"
    value = local.service_account
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  # https://github.com/aws/karpenter/blob/main/charts/karpenter/Chart.yaml
  helm_config = merge(
    {
      name       = local.name
      chart      = local.name
      repository = "oci://public.ecr.aws/karpenter"
      version    = "v0.27.3"
      namespace  = local.name
      values = [
        <<-EOT
          settings:
            aws:
              clusterName: ${var.addon_context.eks_cluster_id}
              clusterEndpoint: ${var.addon_context.aws_eks_cluster_endpoint}
              defaultInstanceProfile: ${var.node_iam_instance_profile}
              interruptionQueueName: ${try(aws_sqs_queue.this[0].name, "")}
        EOT
      ]
      description = "karpenter Helm Chart for Node Autoscaling"
    },
    var.helm_config
  )

  irsa_config = {
    kubernetes_namespace                = local.helm_config["namespace"]
    kubernetes_service_account          = local.service_account
    create_kubernetes_namespace         = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(local.helm_config["create_service_account_secret_token"], false)
    irsa_iam_policies                   = concat([aws_iam_policy.karpenter.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable                    = true
    serviceAccountName        = local.service_account
    controllerClusterEndpoint = var.addon_context.aws_eks_cluster_endpoint
    awsDefaultInstanceProfile = var.node_iam_instance_profile
    awsInterruptionQueueName  = try(aws_sqs_queue.this[0].name, "")
  }

  dns_suffix = data.aws_partition.current.dns_suffix

  # Karpenter Spot Interruption Event rules
  event_rules = {
    health_event = {
      name        = "HealthEvent"
      description = "Karpenter Interrupt - AWS health event for EC2"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
        detail = {
          service = ["EC2"]
        }
      }
    }
    spot_interupt = {
      name        = "SpotInterrupt"
      description = "Karpenter Interrupt - A spot interruption warning was triggered for the node"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    instance_rebalance = {
      name        = "InstanceRebalance"
      description = "Karpenter Interrupt - A spot rebalance recommendation was triggered for the node"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    instance_state_change = {
      name        = "InstanceStateChange"
      description = "Karpenter interrupt - EC2 instance state-change notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
        detail = {
          state = ["stopping", "terminated", "shutting-down", "stopped"] #ignored pending and running
        }
      }
    }
  }
}
