output "arn" {
  value = aws_s3_bucket.artifact_bucket.arn
}

output "bucket" {
  value = aws_s3_bucket.artifact_bucket.bucket
}

output "bucket_url" {
  value = "https://s3.console.aws.amazon.com/s3/buckets/${aws_s3_bucket.artifact_bucket.bucket}?region=${aws_s3_bucket.artifact_bucket.region}&tab=objects"
}
