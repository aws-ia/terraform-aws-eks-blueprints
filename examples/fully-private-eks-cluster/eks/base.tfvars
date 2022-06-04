region             = "us-west-2"
cluster_version    = "1.22"
vpc_id             = "vpc-060bda806b25adcdb"
private_subnet_ids = ["subnet-02a5f125ff267a180", "subnet-0dc515bc09af2b3ba", "subnet-0ae99c4c014c33251"]
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