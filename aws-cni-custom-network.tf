# TODO: use null_resource until can use kubernetes_daemonset to update environment var
resource "null_resource" "k8s_cni_custom_network" {
  triggers = {
    aws_region  = data.aws_region.current.name
    cluster_id  = module.aws_eks.cluster_id
  }

  provisioner "local-exec" {
    command = !local.enable_cni_custom_network ? "echo 'No configure CNI custom networking!'" :templatefile("${path.module}/cni-custom-network.tftpl", {
      aws_region  = data.aws_region.current.name
      cluster_id  = module.aws_eks.cluster_id
      subnet_maps = local.pod_subnet_maps
      worker_sgs  = local.worker_security_group_ids
    })
  }
  depends_on = [kubernetes_config_map.aws_auth]
}

# TODO: apply kubernetes_manifest when this resource can depend on other resources
# Ref: https://github.com/hashicorp/terraform-provider-kubernetes-alpha/issues/123

# resource "kubernetes_manifest" "eni_cfg_crd" {
#   for_each = local.pod_subnet_maps
#   manifest = {
#     apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
#     kind       = "ENIConfig"

#     metadata = {
#       name = each.key
#     }

#     spec = {
#       subnet = each.value
#       securityGroups = local.worker_security_group_ids
#     }
#   }
#   depends_on = [null_resource.k8s_cni_custom_network]
# }