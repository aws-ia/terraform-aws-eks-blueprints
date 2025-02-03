################################################################################
# ECR Repository
################################################################################

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6"

  repository_name = local.name

  create_lifecycle_policy = false
  repository_force_delete = true

  tags = local.tags
}

################################################################################
# Image Build & Push Script
################################################################################

data "aws_caller_identity" "current" {}

resource "local_file" "vllm" {
  content = <<-EOT
  #!/usr/bin/env bash

  aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com

  TAG=vllm-$(date +%Y%m%d_%H%M%S)
  docker build . --output type=image,name=${module.ecr.repository_url}:$${TAG},compression=zstd,force-compression=true,compression-level=9,oci-mediatypes=true,platform=linux/amd64
  docker push ${module.ecr.repository_url}:$${TAG}

  # Update the pod manifest with the new image tag
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sed -i "s|image:.*|image: ${module.ecr.repository_url}:$${TAG}|g" ./lws.yaml
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|image:.*|image: ${module.ecr.repository_url}:$${TAG}|g" ./lws.yaml
  else
    echo "Unsupported OS: $OSTYPE"
    exit 1
  fi
  EOT

  filename = "${path.module}/build.sh"
}
