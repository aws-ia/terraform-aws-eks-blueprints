# Known Issues

## Timeouts on destroy

Customers who are deleting their environments using `terraform destroy` may see timeout errors when VPCs are being deleted. This is due to a known issue in the [vpc-cni](https://github.com/aws/amazon-vpc-cni-k8s/issues/1223#issue-704536542)

Customers may face a situation where ENIs that were attached to EKS managed nodes (same may apply to self-managed nodes) are not being deleted by the VPC CNI as expected which leads to IaC tool failures, such as:

* ENIs are left on subnets
* EKS managed security group which is attached to the ENI can’t be deleted by EKS

The current recommendation is to execute cleanup in the following order:

1. delete all pods that have been created in the cluster.
2. add delay/ wait
3. delete VPC CNI
4. delete nodes
5. delete cluster

## Leaked CloudWatch Logs Group

Sometimes, customers may see the CloudWatch Log Group for EKS cluster being created is left behind after their blueprint has been destroyed using `terraform destroy`. This happens because even after terraform deletes the CW log group, there’s still logs being processed behind the scene by AWS EKS and service continues to write logs after recreating the log group using the EKS service IAM role which users don't have control over. This results in a terraform failure when the same blueprint is being recreated due to the existing log group left behind.

There are two options here:

1. During cluster creation set `var.create_cloudwatch_log_group` to `false` (default behavior). This will indicate to the upstream [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/6d7245621f97bb8e38642a9e40ddce3a32ff9efb/main.tf#L70) to not create the log group, but instead let the service create the log group. This means that upon cluster deletion the log group will be left behind but there will not be terraform failures if you re-create the same cluster as terraform does not manage the log group creation/deletion anymore.

2. During cluster creation set `var.create_cloudwatch_log_group` to `true`. This will indicate to the upstream [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/6d7245621f97bb8e38642a9e40ddce3a32ff9efb/main.tf#L70) to create the log group via terraform. EKS service will detect the log group and will start forwarding the logs for the log types [enabled](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/6d7245621f97bb8e38642a9e40ddce3a32ff9efb/variables.tf#L35). Upon deletion terraform will delete the log group but depending upon any unforwarded logs, the EKS service may recreate log group using the service role. This will result in terraform errors if the same blueprint is recreated. To proceed, manually delete the log group using the console or cli rerun the `terraform apply`.
