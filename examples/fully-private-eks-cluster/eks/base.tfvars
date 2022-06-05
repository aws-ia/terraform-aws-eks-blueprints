region             = "us-west-2"
cluster_version    = "1.22"
vpc_id             = "vpc-045cde3975b801469"
private_subnet_ids = ["subnet-03a21a869766169d5", "subnet-0899effaed018015c", "subnet-085209c3a039361b1"]
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