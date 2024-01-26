provider "aws" {
  region = local.region
}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

data "terraform_remote_state" "main" {
  backend = "local"


  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}

locals {
  region               = data.terraform_remote_state.main.outputs.region
  cur_bucket_id        = data.terraform_remote_state.main.outputs.cur_bucket_id
  s3_cur_report_prefix = data.terraform_remote_state.main.outputs.s3_cur_report_prefix
}

################################################################################
# Athena
################################################################################

resource "null_resource" "download_file" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      if aws s3 ls s3://${local.cur_bucket_id}/${local.s3_cur_report_prefix}/kubecost/crawler-cfn.yml; then
        aws s3 cp s3://${local.cur_bucket_id}/${local.s3_cur_report_prefix}/kubecost/crawler-cfn.yml crawler-cfn.yml
      else
        echo "The crawler-cfn.yml does not exist yet. Come back and run terraform apply again in 24h."
      fi
    EOT
  }
}

resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"

  depends_on = [null_resource.download_file]
}

resource "aws_cloudformation_stack" "athena_integration" {
  count = fileexists("${path.module}/crawler-cfn.yml") ? 1 : 0

  name  = "kubecost"
  template_body = try(file("${path.module}/crawler-cfn.yml"), null)
  capabilities  = ["CAPABILITY_IAM"]

  depends_on = [null_resource.download_file, time_sleep.wait_60_seconds]
}