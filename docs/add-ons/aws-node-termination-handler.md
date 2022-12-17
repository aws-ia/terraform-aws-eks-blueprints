# AWS Node Termination Handler

This project ensures that the Kubernetes control plane responds appropriately to events that can cause your EC2 instance to become unavailable, such as EC2 maintenance events, EC2 Spot interruptions, ASG Scale-In, ASG AZ Rebalance, and EC2 Instance Termination via the API or Console. If not handled, your application code may not stop gracefully, take longer to recover full availability, or accidentally schedule work to nodes that are going down. For more information see [README.md](https://github.com/aws/aws-node-termination-handler#readme).

The aws-node-termination-handler (NTH) can operate in two different modes: Instance Metadata Service (IMDS) or the Queue Processor. In the EKS Blueprints, we provision the NTH in Queue Processor mode. This means that NTH will monitor an SQS queue of events from Amazon EventBridge for ASG lifecycle events, EC2 status change events, Spot Interruption Termination Notice events, and Spot Rebalance Recommendation events. When NTH detects an instance is going down, NTH uses the Kubernetes API to cordon the node to ensure no new work is scheduled there, then drain it, removing any existing work.

The NTH will be deployed in the `kube-system` namespace. AWS resources required as part of the setup of NTH will be provisioned for you. These include:

1. Node group ASG tagged with `key=aws-node-termination-handler/managed`
2. AutoScaling Group Termination Lifecycle Hook
3. Amazon Simple Queue Service (SQS) Queue
4. Amazon EventBridge Rule
5. IAM Role for the aws-node-termination-handler Queue Processing Pods

## Usage

```hcl
enable_aws_node_termination_handler = true
```

You can optionally customize the Helm chart that deploys `aws-node-termination-handler` via the following configuration.

```hcl
  enable_aws_node_termination_handler = true

  aws_node_termination_handler_helm_config = {
    name                       = "aws-node-termination-handler"
    chart                      = "aws-node-termination-handler"
    repository                 = "https://aws.github.io/eks-charts"
    version                    = "0.16.0"
    timeout                    = "1200"
  }
```


To validate that controller is running, ensure that controller deployment is in RUNNING state:

```sh
# Assuming controller is installed in kube-system namespace
$ kubectl get deployments -n kube-system
aws-node-termination-handler  1/1   1   1   5d9h
```

### GitOps Configuration
The following properties are made available for use when managing the add-on via GitOps.

GitOps with ArgoCD Add-on repo is located [here](https://github.com/aws-samples/eks-blueprints-add-ons/blob/main/chart/values.yaml)

When enabling NTH for GitOps, be sure that you are using `self_managed_node_groups` as this module will check to ensure that it finds valid backing autoscaling groups.

If you're using `managed_node_groups`, NTH isn't required as per the following - https://github.com/aws/aws-node-termination-handler/issues/186
```
Amazon EKS automatically drains nodes using the Kubernetes API during terminations or updates. Updates respect the pod disruption budgets that you set for your pods.
```

```hcl
  awsNodeTerminationHandler = {
    enable             = true
    serviceAccountName = "<service_account>"
  }
```
