resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.project_name}-terraform-state-and-pr-details"
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "artifact_bucket_block_public_access" {
  bucket = aws_s3_bucket.artifact_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.artifact_bucket.id
  acl    = "private"
}