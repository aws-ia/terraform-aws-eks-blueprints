```sh
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -auto-approve
```

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#destroy) for more details on cleaning up the resources created.
