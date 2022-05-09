tenant      = "aws001"
environment = "preprod"
zone        = "test"
region      = "us-west-2"

cluster_version = "1.22"

vpc_id  = "vpc-09bf8427d75b9211d"
private_subnet_ids = ["subnet-05cab0b36bdf92bed", "subnet-0b8eb4a6273bf6f6c", "subnet-04ae4bb5f88bfe0fb", "subnet-04d70035e7d7f34d3" ]

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