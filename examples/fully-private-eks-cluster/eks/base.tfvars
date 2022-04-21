tenant      = "aws001"
environment = "preprod"
zone        = "test"
region      = "us-west-2"

cluster_version = "1.21"

tf_state_vpc_s3_bucket = "terraform-ssp-github-actions-state-dla"
tf_state_vpc_s3_key    = "private/vpc/terraform-main.tfstate"

cluster_security_group_additional_rules = {
  ingress_from_jenkins_host = {
    description = "Ingress from Jenkins/Bastion Host"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    type        = "ingress"
    cidr_blocks = ["172.31.0.0/16"]
  }
}