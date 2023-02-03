resource "kubernetes_namespace" "spark" {
  metadata {
    annotations = {
      name = local.emr_on_eks_team["namespace"]
    }

    labels = {
      job-type = "spark"
    }

    name = local.emr_on_eks_team["namespace"]
  }
}

resource "kubernetes_role" "emr_containers" {
  metadata {
    name      = local.emr_service_name
    namespace = kubernetes_namespace.spark.id
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "watch", "describe", "create", "edit", "delete", "deletecollection", "annotate", "patch", "label"]
    api_groups = [""]
    resources  = ["serviceaccounts", "services", "configmaps", "events", "pods", "pods/log"]
  }

  rule {
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
  }

  rule {
    verbs      = ["create", "patch", "delete", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["get", "list", "watch", "describe", "create", "edit", "delete", "annotate", "patch", "label"]
    api_groups = ["apps"]
    resources  = ["statefulsets", "deployments"]
  }

  rule {
    verbs      = ["get", "list", "watch", "describe", "create", "edit", "delete", "annotate", "patch", "label"]
    api_groups = ["batch"]
    resources  = ["jobs"]
  }

  rule {
    verbs      = ["get", "list", "watch", "describe", "create", "edit", "delete", "annotate", "patch", "label"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["get", "list", "watch", "describe", "create", "edit", "delete", "deletecollection", "annotate", "patch", "label"]
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
  }
}

resource "kubernetes_role_binding" "emr_containers" {
  metadata {
    name      = local.emr_service_name
    namespace = kubernetes_namespace.spark.id
  }

  subject {
    kind = "User"
    name = local.emr_service_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = local.emr_service_name
  }
}

resource "aws_iam_role" "emr_on_eks_execution" {
  name                  = format("%s-%s", var.eks_cluster_id, local.emr_on_eks_team["job_execution_role"])
  assume_role_policy    = data.aws_iam_policy_document.emr_assume_role.json
  force_detach_policies = true
  path                  = var.iam_role_path
  permissions_boundary  = var.iam_role_permissions_boundary
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "custom" {
  count = length(local.emr_on_eks_team["additional_iam_policies"])

  role       = aws_iam_role.emr_on_eks_execution.name
  policy_arn = local.emr_on_eks_team["additional_iam_policies"][count.index]
}

# TODO Replace this resource once the provider is available for aws emr-containers
resource "null_resource" "update_trust_policy" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    environment = {
      AWS_DEFAULT_REGION = data.aws_region.current.id
    }
    command = <<EOF
set -e

aws emr-containers update-role-trust-policy \
--cluster-name ${var.eks_cluster_id} \
--namespace ${kubernetes_namespace.spark.id} \
--role-name ${aws_iam_role.emr_on_eks_execution.id}

EOF
  }
  triggers = {
    always_run = timestamp()
  }
  depends_on = [kubernetes_namespace.spark, aws_iam_role.emr_on_eks_execution]
}
