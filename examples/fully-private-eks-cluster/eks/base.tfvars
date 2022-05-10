tenant      = "aws001"
environment = "preprod"
zone        = "test"
region      = "us-east-1"

cluster_version = "1.22"

vpc_id  = "vpc-035cc2ce7fb7fed9d"
private_subnet_ids = ["subnet-05afaf975e6471bd6", "subnet-01d0b67244d3c045b", "subnet-052069914bfd4904b"]

# tf_state_vpc_s3_bucket = "terraform-ssp-github-actions-state-dla"
# tf_state_vpc_s3_key    = "e2e/vpc/terraform-main.tfstate"

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