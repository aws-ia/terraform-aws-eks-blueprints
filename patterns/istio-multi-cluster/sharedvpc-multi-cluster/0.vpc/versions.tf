terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
  }

  # ##  Used for end-to-end testing on project; update to suit your needs
  # backend "s3" {
  #   bucket = "<BUCKET_NAME>"
  #   region = "<AWS_REGION>"
  #   key    = "e2e/istio-multi-cluster-vpc/terraform.tfstate"
  # }
}
