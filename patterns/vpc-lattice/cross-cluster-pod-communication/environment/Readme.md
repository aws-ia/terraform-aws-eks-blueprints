# Create Environment

This terraform stack will create the shared resources needed for our cross cluster EKS communication with VPC lattice.

The resources created will be similar to :

![vpc-lattice-pattern-environment.png](https://raw.githubusercontent.com/aws-ia/terraform-aws-eks-blueprints/main/patterns/vpc-lattice/cross-cluster-pod-communication/assets/vpc-lattice-pattern-environment.png)


- An Amazon Route53 Private hosted zone named `example.com`, attach to a dummy Private VPC (only created at this stage to have a private hosted zone)
- We also create an AWS Private Authority certificate that will be managing our private domain.
- From this private CA authority we also create a wildcard AWS Certificate manager that will be later attached to our VPC lattice services
- We also create an IAM Role, that will be used later by our application using EKS pod identity, with permissions to invoke VPC lattice services, and to download the AWS Private CA root certificate allowing the application to trust our private domain.
