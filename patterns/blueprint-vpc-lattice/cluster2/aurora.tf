provider "random" {}

module "rds-aurora" {
  source  = "aws-ia/rds-aurora/aws"
  version = "0.0.7"
  # insert the 5 required variables here

  password             = random_password.password.result
  username = "admin"
  private_subnet_ids_p = module.vpc.private_subnets
  private_subnet_ids_s = null
  region               = local.region
  engine = "aurora-postgresql"
  engine_version_pg = "13.6"
  sec_region           = "us-west-2"
}


resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
