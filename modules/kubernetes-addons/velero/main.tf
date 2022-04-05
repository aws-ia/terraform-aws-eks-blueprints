####
# Add your custom resources here...
# such as IRSA policy statement
####

# Invokes the generic helm-addon module which is a convenience module
# EKS Blueprints framework provides to create helm based addons easily


module "helm_addon" {
  source            = "github.com/aws-samples/aws-eks-accelerator-for-terraform//modules/kubernetes-addons/helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_s3_bucket" "s3" {
   bucket = "velero-backup-bucket"
  
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.s3.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "AES256"
    }
  }
}


resource "aws_iam_policy" "velero_policy" {
  name        = "Velero-AmazonEKS_Policy"
  description = "IAM policy for Velero to create backups of EKS cluster"
  policy      = data.aws_iam_policy_document.velero_policy.json
  tags        = var.addon_context.tags
}

