# EKS Cluster w/ Prefix Delegation

This example shows how to provision an EKS cluster with [AWS VCP CNI Metrics](https://docs.aws.amazon.com/eks/latest/userguide/cni-metrics-helper.html) addon. 

The Amazon VPC CNI plugin for Kubernetes metrics helper is a tool that you can use to scrape network interface and IP address information, aggregate metrics at the cluster level, and publish the metrics to Amazon CloudWatch.

## Reference Documentation:

- [Documentation](https://docs.aws.amazon.com/eks/latest/userguide/cni-metrics-helper.html)
- [Blog post](https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/)

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply


## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the deployment.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. List the pods for the VPC CNI metrics

```sh
kubectl get pods -n kube-system -l k8s-app=cni-metrics-helper

# Output should look like below
AME                                  READY   STATUS    RESTARTS   AGE
cni-metrics-helper-5785786c5b-jcxcm  1/1    Running    0          1m11s
```

You can view the CNI metrics in the Amazon CloudWatch console. Lear more by [creating a metrics dashboard](https://docs.aws.amazon.com/eks/latest/userguide/cni-metrics-helper.html#create-metrics-dashboard) with the metrics collected.

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -auto-approve
```
