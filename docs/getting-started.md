# Getting Started

This getting started guide will help you deploy your first pattern using EKS Blueprints.

## Prerequisites

Ensure that you have installed the following tools locally:

- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [kubectl](https://Kubernetes.io/docs/tasks/tools/)
- [terraform](https://developer.hashicorp.com/terraform/tutorials/terraform/install-cli)

## Deploy

1. For consuming EKS Blueprints, please see the [Consumption](https://aws-ia.github.io/terraform-aws-eks-blueprints/#consumption) section. For exploring and trying out the patterns provided, please
clone the project locally to quickly get up and running with a pattern. After cloning the project locally, `cd` into the pattern
directory of your choice.

2. To provision the pattern, the typical steps of execution are as follows:

    ```sh
    terraform init
    terraform apply -target="module.vpc" -auto-approve
    terraform apply -target="module.eks" -auto-approve
    terraform apply -auto-approve
    ```

    For patterns that deviate from this general flow, see the pattern's respective `README.md` for more details.

    !!! info "Terraform targeted apply"
        Please see the [Terraform Caveats](https://aws-ia.github.io/terraform-aws-eks-blueprints/#terraform-caveats) section for details on the use of targeted Terraform apply's

3. Once all of the resources have successfully been provisioned, the following command can be used to update the `kubeconfig`
on your local machine and allow you to interact with your EKS Cluster using `kubectl`.

    ```sh
    aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME> --alias <CLUSTER_NAME>
    ```

    !!! info "Pattern Terraform outputs"
        Most examples will output the `aws eks update-kubeconfig ...` command as part of the Terraform apply output to simplify this process for users

    !!! warning "Private clusters"
        Clusters that do not enable the clusters public endpoint will require users to access the cluster from within the VPC.
        For these patterns, a sample EC2 or other means are provided to demonstrate how to access those clusters privately
      and without exposing the public endpoint. Please see the respective pattern's `README.md` for more details.

4. Once you have updated your `kubeconfig`, you can verify that you are able to interact with your cluster by running the following command:

    ```sh
    kubectl get nodes
    ```

    This should return a list of the node(s) running in the cluster created. If any errors are encountered, please re-trace the steps above
    and consult the pattern's `README.md` for more details on any additional/specific steps that may be required.

## Destroy

To teardown and remove the resources created in the pattern, the typical steps of execution are as follows:

```sh
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -auto-approve
```

!!! danger "Resources created outside of Terraform"
    Depending on the pattern, some resources may have been created that Terraform is not aware of that will cause issues
    when attempting to clean up the pattern. For example, Karpenter is responsible for creating additional EC2 instances
    to satisfy the pod scheduling requirements. These instances will not be cleaned up by Terraform and will need to be
    de-provisioned *BEFORE* attempting to `terraform destroy`. This is why it is important that the addons, or any resources
    provisioned onto the cluster are cleaned up first. Please see the respective pattern's `README.md` for more
    details.
