region             = "us-west-2"
cluster_version    = "1.22"
vpc_id             = "vpc-084f79088473079b6"
private_subnet_ids = ["subnet-0352fd9e01cb59df6", "subnet-0ce88805c5c0480a9", "subnet-0ed543dfdabb26148"]
cluster_security_group_additional_rules = {
  ingress_from_cloud9_host = {
    description = "Ingress from  Cloud9 Host"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    type        = "ingress"
    cidr_blocks = ["172.31.0.0/16"]
  }
}