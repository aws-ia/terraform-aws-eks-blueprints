# Known Issues

## Timeouts on destroy

Customers who are deleting their environments using `terraform destroy` may see timeout errors when VPCs are being deleted. This is due to a known issue in the [vpc-cni](https://github.com/aws/amazon-vpc-cni-k8s/issues/1223#issue-704536542)

Customers may face a situation where ENIs that were attached to EKS managed nodes (same may apply to self-managed nodes) are not being deleted by the VPC CNI as expected.

This leads into situations where customers trying to cleanup their environment via IaC tools (CloudFormation/Terraform etc.) where the VPC components can’t be deleted - which leads to IaC tool failures. Reasons:

* ENIs are left on subnets , while the IaC not managing those ENIs,  you are not allowed to delete subnets until the ENIs are properly cleaned, therefore the IaC cleanup will fail.
* EKS managed security group which is attached to the ENI can’t be deleted by EKS (see arn):

```json
{
    "eventVersion": "1.08",
    "userIdentity": {
        "type": "AssumedRole",
        "principalId": "AROAXWEUFIYRVLF6F7CRF:AmazonEKS",
        "arn": "arn:aws:sts::XXXXXXXXXX:assumed-role/AWSServiceRoleForAmazonEKS/AmazonEKS",
        "accountId": "XXXXXXXX",
        "sessionContext": {
            "sessionIssuer": {
                "type": "Role",
                "principalId": "AROAXWEUFIYRVLF6F7CRF",
                "arn": "arn:aws:iam::XXXXXXXXXX:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS",
                "accountId": "XXXXXXXXX",
                "userName": "AWSServiceRoleForAmazonEKS"
            },
            "webIdFederationData": {},
            "attributes": {
                "creationDate": "2022-03-29T16:28:44Z",
                "mfaAuthenticated": "false"
            }
        },
        "invokedBy": "eks.amazonaws.com"
    },
    "eventTime": "2022-03-29T16:28:48Z",
    "eventSource": "ec2.amazonaws.com",
    "eventName": "DeleteSecurityGroup",
    "awsRegion": "us-west-2",
    "sourceIPAddress": "eks.amazonaws.com",
    "userAgent": "eks.amazonaws.com",
    "errorCode": "Client.DependencyViolation",
    "errorMessage": "resource sg-06efd8d3333bd0fa9 has a dependent object",
    "requestParameters": {
        "groupId": "sg-06efd8d3333bd0fa9"
    },
    "responseElements": null,
    "requestID": "1592dc20-b3db-4447-8911-4572506107b0",
    "eventID": "ac86cee0-80b7-4fe6-aab4-883d8443eb9e",
    "readOnly": false,
    "eventType": "AwsApiCall",
    "managementEvent": true,
    "recipientAccountId": "528591701539",
    "eventCategory": "Management"
}
```

(CloudTrail log example where EKS trying to delete the SG but can’t because it’s still used by the leaked ENI).

After checking the CNI code and discussing the issue with EKS service team here’s what we understand:

* The VPC CNI cleanup logic (at a very high level) is :
  * Detach ENIs
  * Delete ENIs

Those are two different API operations, and post detaching ENI you may need for EC2 to properly detach the ENI which can take several seconds, the delete ENI does have a retry mechanism.

If, during the time of delete calls, the nodes are also being terminated , we are in a state where the ENI are detached, but not deleted, therefore the term “Leak” used commonly.

The current suggestion given by service team is to execute cleanup in the following order:

1. delete all pods that have been created in the cluster.
2. add delay/ wait
3. delete VPC CNI
4. delete nodes
5. delete cluster

The problem with this suggestion is the first point, IaC based solution (e.g. eksctl/EKS Blueprints etc.) not aware of all the pods existing in the cluster, as customer may deploy those pods outside of the used tool.

## Leaked CloudWatch Logs Group

Sometimes, customers may see the CloudWatch Log Group for EKS cluster being created is left behind after their blueprint has been destroyed using `terraform destroy`. This happens because even after terraform deletes the CW log group, there’s still logs being processed behind the scene by AWS EKS and service continues to write logs after recreating the log group using the EKS service IAM role which users don't have control over. This results in a terraform failure when the same blueprint is being recreated due to the existing log group left behind.

There are two options here:

1. During cluster creation set `var.create_cloudwatch_log_group` to `false` (default behavior). This will indicate to the upstream [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/6d7245621f97bb8e38642a9e40ddce3a32ff9efb/main.tf#L70) to not create the log group, but instead let the service create the log group. This means that upon cluster deletion the log group will be left behind but there will not be terraform failures if you re-create the same cluster as terraform does not manage the log group creation/deletion anymore.
2. During cluster creation set `var.create_cloudwatch_log_group` to `true`. This will indicate to the upstream [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/6d7245621f97bb8e38642a9e40ddce3a32ff9efb/main.tf#L70) to create the log group via terraform. EKS service will detect the log group and will start forwarding the logs for the log types [enabled](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/6d7245621f97bb8e38642a9e40ddce3a32ff9efb/variables.tf#L35). Upon deletion terraform will delete the log group but depending upon any unforwarded logs, the EKS service may recreate log group using the service role. This will result in terraform errors if the same blueprint is recreated. To proceed, manually delete the log group using the console or cli rerun the `terraform apply`.