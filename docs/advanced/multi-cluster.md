## Advanced Deployment Folder Structure

This example shows how to structure folders in your repo when you want to deploy multiple EKS Clusters across multiple regions and accounts.

The top-level `examples\advanced` folder provides an example of how you can structure your folders and files to define multiple EKS Cluster environments and consume this Blueprints module. This approach is suitable for large projects, with clearly defined sub directory and file structure.

Each folder under `live/<region>/application` represents an EKS cluster environment(e.g., dev, test, load etc.). Each folder contains a `backend.conf` and `<env>.tfvars`, used to create a unique Terraform state for each cluster environment.

Terraform backend configuration can be updated in `backend.conf` and cluster common configuration variables in `<env>.tfvars`

e.g. folder/file structure for defining multiple clusters

        ├── examples\advanced
        │   └── live
        │       └── preprod
        │           └── eu-west-1
        │               └── application
        │                   └── dev
        │                       └── backend.conf
        │                       └── dev.tfvars
        │                       └── main.tf
        │                       └── variables.tf
        │                       └── outputs.tf
        │                   └── test
        │                       └── backend.conf
        │                       └── test.tfvars
        │       └── prod
        │           └── eu-west-1
        │               └── application
        │                   └── prod
        │                       └── backend.conf
        │                       └── prod.tfvars
        │                       └── main.tf
        │                       └── variables.tf
        │                       └── outputs.tf


## Important Note

If you are using an existing VPC, you need to ensure that the following tags are added to the VPC and subnet resources

Add Tags to **VPC**
```hcl
    Key = "Kubernetes.io/cluster/${local.cluster_id}"
    Value = "Shared"
```

Add Tags to **Public Subnets tagging** requirement
```hcl
    public_subnet_tags = {
      "Kubernetes.io/cluster/${local.cluster_id}" = "shared"
      "Kubernetes.io/role/elb"                      = "1"
    }
```

Add Tags to **Private Subnets tagging** requirement
```hcl
    private_subnet_tags = {
      "Kubernetes.io/cluster/${local.cluster_id}" = "shared"
      "Kubernetes.io/role/internal-elb"             = "1"
    }
```
