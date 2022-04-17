# Invokes the generic helm-addon module which is a convenience module
# EKS Blueprints framework provides to create helm based addons easily


module "helm_addon" {
  source            = "github.com/aws-samples/aws-eks-accelerator-for-terraform//modules/kubernetes-addons/helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
  depends_on = [
    aws_s3_bucket.s3,
  ]
}


resource "aws_s3_bucket" "s3" {
  count         = var.velero_backup_bucket != "" ? 0 : 1
  bucket_prefix = local.s3bucketprefix

}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count  = var.velero_backup_bucket != "" ? 0 : 1
  bucket = aws_s3_bucket.s3[0].bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_iam_policy" "velero_policy" {
  name        = "Velero-AmazonEKS_Policy"
  description = "IAM policy for Velero to create backups of EKS cluster"
  policy      = data.aws_iam_policy_document.velero_policy.json
  tags        = var.addon_context.tags
}

