tenant      = "aws001"
environment = "preprod"
zone        = "test"
region      = "us-west-2"

kubernetes_version = "1.21"

tf_state_vpc_s3_bucket = "terraform-ssp-github-actions-state"
tf_state_vpc_s3_key    = "e2e/vpc/terraform-main.tfstate"
