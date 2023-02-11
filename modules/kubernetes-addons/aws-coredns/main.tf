locals {
  name = "coredns"
}

data "aws_eks_addon_version" "this" {
  addon_name = local.name
  # Need to allow both config routes - for managed and self-managed configs
  kubernetes_version = try(var.addon_config.kubernetes_version, var.helm_config.kubernetes_version)
  most_recent        = try(var.addon_config.most_recent, var.helm_config.most_recent, false)
}

resource "aws_eks_addon" "coredns" {
  count = var.enable_amazon_eks_coredns ? 1 : 0

  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = local.name
  addon_version            = try(var.addon_config.addon_version, data.aws_eks_addon_version.this.version)
  resolve_conflicts        = try(var.addon_config.resolve_conflicts, "OVERWRITE")
  service_account_role_arn = try(var.addon_config.service_account_role_arn, null)
  preserve                 = try(var.addon_config.preserve, true)
  configuration_values     = try(var.addon_config.configuration_values, null)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
}

module "helm_addon" {
  source = "../helm-addon"
  count  = var.enable_self_managed_coredns ? 1 : 0

  helm_config = merge({
    name        = local.name
    description = "CoreDNS is a DNS server that chains plugins and provides Kubernetes DNS Services"
    chart       = local.name
    repository  = "https://coredns.github.io/helm"
    namespace   = "kube-system"
    values = [
      <<-EOT
      image:
        repository: ${var.helm_config.image_registry}/eks/coredns
        tag: ${try(var.helm_config.addon_version, data.aws_eks_addon_version.this.version)}
      deployment:
        name: coredns
        annotations:
          eks.amazonaws.com/compute-type: ${try(var.helm_config.compute_type, "ec2")}
      service:
        name: kube-dns
        annotations:
          eks.amazonaws.com/compute-type: ${try(var.helm_config.compute_type, "ec2")}
      podAnnotations:
        eks.amazonaws.com/compute-type: ${try(var.helm_config.compute_type, "ec2")}
      EOT
    ]
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.create"
      value = true
    },
    {
      # This simply maps a dependency for Terraform to ensure the default deployment is
      # removed first (if enabled) before provisioning self-managed version (if enabled)
      name  = "blueprints.connection"
      value = try(null_resource.remove_default_coredns_deployment[0].id, "none")
    }
  ]

  # Blueprints
  addon_context = var.addon_context
}

#---------------------------------------------------------------
# Modifying CoreDNS for Fargate
#---------------------------------------------------------------

data "aws_eks_cluster_auth" "this" {
  name = time_sleep.this.triggers["eks_cluster_id"]
}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = time_sleep.this.triggers["eks_cluster_id"]
      cluster = {
        certificate-authority-data = var.eks_cluster_certificate_authority_data
        server                     = var.addon_context.aws_eks_cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = time_sleep.this.triggers["eks_cluster_id"]
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })
}

resource "time_sleep" "this" {
  create_duration = "1m"

  triggers = {
    eks_cluster_id = var.addon_context.eks_cluster_id
  }
}

# Separate resource so that this is only ever executed once
resource "null_resource" "remove_default_coredns_deployment" {
  count = var.enable_self_managed_coredns && var.remove_default_coredns_deployment ? 1 : 0

  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }

    # We are removing the deployment provided by the EKS service and replacing it through the self-managed CoreDNS Helm addon
    # However, we are maintaing the existing kube-dns service and annotating it for Helm to assume control
    command = <<-EOT
      kubectl --namespace kube-system delete deployment coredns --kubeconfig <(echo $KUBECONFIG | base64 -d)
    EOT
  }
}

resource "null_resource" "modify_kube_dns" {
  count = var.enable_self_managed_coredns && var.remove_default_coredns_deployment ? 1 : 0

  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
      CONNECTION = null_resource.remove_default_coredns_deployment[0].id
    }

    # We are maintaing the existing kube-dns service and annotating it for Helm to assume control
    command = <<-EOT
      kubectl --namespace kube-system annotate --overwrite service kube-dns meta.helm.sh/release-name=coredns --kubeconfig <(echo $KUBECONFIG | base64 -d)
      kubectl --namespace kube-system annotate --overwrite service kube-dns meta.helm.sh/release-namespace=kube-system --kubeconfig <(echo $KUBECONFIG | base64 -d)
      kubectl --namespace kube-system label --overwrite service kube-dns app.kubernetes.io/managed-by=Helm --kubeconfig <(echo $KUBECONFIG | base64 -d)
    EOT
  }
}

#---------------------------------------------------------------
# Cluster proportional autoscaler
#---------------------------------------------------------------

module "cluster_proportional_autoscaler" {
  source = "../cluster-proportional-autoscaler"

  count = var.enable_cluster_proportional_autoscaler ? 1 : 0

  helm_config = merge({
    values = [
      <<-EOT
        nameOverride: coredns

        config:
          linear:
            coresPerReplica: 256
            nodesPerReplica: 16
            min: 1
            max: 100
            preventSinglePointFailure: true
            includeUnschedulableNodes: true

        options:
          target: "deployment/coredns"

        podSecurityContext:
          seccompProfile:
            type: RuntimeDefault
          supplementalGroups: [ 65534 ]
          fsGroup: 65534

        tolerations:
          - key: "CriticalAddonsOnly"
            operator: "Exists"
        blueprints:
          connection: ${try(null_resource.remove_default_coredns_deployment[0].id, "none")}
      EOT
    ]
    },
    var.cluster_proportional_autoscaler_helm_config
  )

  addon_context = var.addon_context
}
