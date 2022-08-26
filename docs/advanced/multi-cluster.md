## Advanced Deployment Folder Structure

This example shows how to structure folders in your repo when you want to deploy multiple EKS Clusters across multiple regions and accounts.

The top-level `examples/advanced` folder provides an example of how you can structure your folders and files to define multiple EKS Cluster environments and consume this Blueprints module. This approach is suitable for large projects, with clearly defined sub directory and file structure.

Each folder under `live/<region>/application` represents an EKS cluster environment(e.g., dev, test, load etc.).

e.g. folder/file structure for defining multiple clusters

```
examples\advanced
└── live
    ├── preprod
    │   └── eu-west-1
    │       └── application
    │           └── dev
    │               ├── main.tf
    │               ├── variables.tf
    │               └── outputs.tf
    └── prod
        └── eu-west-1
            └── application
                └── prod
                    ├── main.tf
                    ├── variables.tf
                    └── outputs.tf
```

## Important Note

If you are using an existing VPC, you need to ensure that the following tags are added to the VPC and subnet resources

Add Tags to **Public Subnets tagging** requirement

```hcl
    public_subnet_tags = {
      "Kubernetes.io/role/elb"                      = 1
    }
```

Add Tags to **Private Subnets tagging** requirement

```hcl
    private_subnet_tags = {
      "Kubernetes.io/role/internal-elb"             = 1
    }
```
