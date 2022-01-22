# gitlab-provider.tf
group_id          = 19364 //Refer GitlabUI to find your group ID
gitlab_project_id = 20206 ///Refer GitlabUI to find your Project ID

# main.tf
tenant             = "aws002"
environment        = "preprod"
zone               = "jimqa"
kubernetes_version = "1.21"
vpc_cidr           = "10.2.0.0/16"
terraform_version  = "Terraform v1.1.3"
