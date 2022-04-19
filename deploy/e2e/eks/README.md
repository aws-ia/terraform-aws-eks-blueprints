## How to deploy the example

    git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git

    cd ~/eks-blueprints/deploy/e2e/eks

    terraform init -backend-config backend.conf -reconfigure

    terraform plan -var-file base.tfvars

    terraform apply -var-file base.tfvars -auto-approve

## How to Destroy the cluster

    terraform destroy -var-file base.tfvars -auto-approve
