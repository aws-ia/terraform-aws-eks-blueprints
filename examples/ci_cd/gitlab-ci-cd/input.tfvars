# gitlab-provider.tf
group_id          = 12345
gitlab_project_id = 67890

# main.tf
tenant             = "aws001"
environment        = "preprod"
zone               = "qa"
kubernetes_version = "1.21"
vpc_cidr           = "10.2.0.0/16"
terraform_version  = "Terraform v1.1.3"