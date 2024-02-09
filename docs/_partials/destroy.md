```sh
# Necessary to avoid removing Terraform's permissions too soon before its finished
# cleaning up the resources it deployed inside the cluster
terraform state rm 'module.eks.aws_eks_access_entry.this["cluster_creator_admin"]' || true

terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -auto-approve
```

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#destroy) for more details on cleaning up the resources created.
