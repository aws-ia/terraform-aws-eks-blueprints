# Amazon VPC Lattice

This folder contains use case-driven patterns covering different aspects of the Amazon VPC Lattice service.

## Use cases

- [Simple Client to Server Communication](./client-server-communication/)
    - This pattern describes how to expose a simple API within an Amazon EKS cluster deployed in VPC A to a client application hosted in VPC B through Amazon VPC Lattice.
- [Cross VPC and EKS clusters secure Communication](./cross-cluster-pod-communication/)
    - This patterns shows how to make 2 services in 2 different EKS clusters and VPC can communicate securely on private domain and sigV4 authorization.


## Supporting resources

- [Documentation](https://docs.aws.amazon.com/vpc-lattice/latest/ug/what-is-vpc-lattice.html)
- [AWS Gateway API Controller](https://www.gateway-api-controller.eks.aws.dev/)
