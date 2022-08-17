locals {
  instance_name = coalesce(var.instance_name, format("%s/karpenter/%s", var.eks_cluster_id, var.provisioner_name))
}

resource "kubectl_manifest" "provisioner" {
  yaml_body = yamlencode({
    "apiVersion" = "karpenter.sh/v1alpha5"
    "kind"       = "Provisioner"
    "metadata" = {
      "name" = var.provisioner_name
    }
    "spec" = {
      "kubeletConfiguration" = var.kubelet_configuration
      "limits" = {
        "resources" = {
          "cpu"    = var.cpu_limit
          "memory" = var.memory_limit
        }
      }
      "labels" = var.labels
      "providerRef" = {
        "name" = var.provisioner_name
      }
      "requirements"           = var.requirements
      "startupTaints"          = var.startup_taints
      "taints"                 = var.taints
      "ttlSecondsAfterEmpty"   = var.ttl_seconds_after_empty
      "ttlSecondsUntilExpired" = var.ttl_seconds_until_expired
    }
  })
}

resource "kubectl_manifest" "awsnodetemplate_launch_template" {
  count = length(var.launch_template) != 0 ? 1 : 0
  yaml_body = yamlencode({
    "apiVersion" = "karpenter.k8s.aws/v1alpha1"
    "kind"       = "AWSNodeTemplate"
    "metadata" = {
      "name" = var.provisioner_name
    }
    "spec" = {
      "launchTemplate" = var.launch_template
      "subnetSelector" = merge(
        {
          "karpenter.sh/discovery" = var.eks_cluster_id
        },
        var.extra_subnet_selectors
      )
      "tags" = merge(
        {
          "name"                   = local.instance_name
          "karpenter.sh/discovery" = var.eks_cluster_id
        },
        var.extra_tags
      )
    }
  })
}

resource "kubectl_manifest" "awsnodetemplate_no_launch_template" {
  count = length(var.launch_template) == 0 ? 1 : 0
  yaml_body = yamlencode({
    "apiVersion" = "karpenter.k8s.aws/v1alpha1"
    "kind"       = "AWSNodeTemplate"
    "metadata" = {
      "name" = var.provisioner_name
    }
    "spec" = {
      "amiFamily"           = var.ami_family
      "amiSelector"         = var.ami_selector
      "blockDeviceMappings" = var.block_device_mappings
      "instanceProfile"     = var.iam_instance_profile
      "metadataOptions"     = var.metadata_options
      "securityGroupSelector" = merge(
        {
          "karpenter.sh/discovery" = var.eks_cluster_id
        },
        var.extra_security_group_selectors
      )
      "subnetSelector" = merge(
        {
          "karpenter.sh/discovery" = var.eks_cluster_id
        },
        var.extra_subnet_selectors
      )
      "tags" = merge(
        {
          "name"                   = local.instance_name
          "karpenter.sh/discovery" = var.eks_cluster_id
        },
        var.extra_tags
      )
      "userData" = var.user_data
    }
  })
}
