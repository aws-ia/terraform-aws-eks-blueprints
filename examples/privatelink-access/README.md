# Private EKS cluster access via AWS PrivateLink

This example demonstrates how to access a private EKS cluster using AWS PrivateLink.

Refer to the [documentation](https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html) for further details on  `AWS PrivateLink`.

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example, first deploy the Lambda function that responds to `CreateNetworkInterface` API calls. This needs to exist before the cluster is created so that it can respond to the ENIs created by the EKS control plane:

```sh
terraform init
terraform apply -target=module.create_eni_lambda -target=module.nlb
```

Enter `yes` at command prompt to apply

Next, deploy the remaining resources:

```sh
terraform apply
```

Enter `yes` at command prompt to apply

## Validate

### Network Connectivity

1. An output `ssm_test` has been provided to aid in quickly testing the connectivity from the client EC2 instance to the private EKS cluster via AWS Privatelink. Copy the output value and paste it into your terminal to execute and check the connectivity. If configured correctly, the value returned should be `ok`.

```sh
COMMAND_ID=$(aws ssm send-command --region us-west-2 --document-name "AWS-RunShellScript" \
--parameters 'commands=["curl -ks https://0218D48323E3E7D404D98659F1D097DD.gr7.us-west-2.eks.amazonaws.com/readyz"]' \
--targets "Key=instanceids,Values=i-0280cf604085f4a44" --query 'Command.CommandId' --output text)

aws ssm get-command-invocation --region us-west-2 --command-id $COMMAND_ID --instance-id i-0280cf604085f4a44 --query 'StandardOutputContent' --output text
```

### Cluster Access

To test access to the cluster, you will need to execute Kubernetes API calls from within the private network to access the cluster. An EC2 instance has been deployed to simulate this scenario, where the EC2 is deployed into a "client" VPC. However, since the EKS cluster was created with your local IAM identity, the `aws-auth` ConfigMap will only have your local identity that is permitted to access the cluster. Since cluster's API endpoint is private, we cannot use Terraform to reach it to additional entries to the ConfigMap; we can only access the cluster from within the private network of the cluster's VPC or from the client VPC using AWS PrivateLink access.

:warning: The "client" EC2 instance provided and copying of AWS credentials to that instance are merely for demonstration purposes only. Please consider alternate methods of network access such as AWS Client VPN to provide more secure access.

Perform the following steps to access the cluster with `kubectl` from the provided "client" EC2 instance.

1. Execute the command below on your local machine to get temporary credentials that will be used on the "client" EC2 instance:

```sh
aws sts get-session-token --duration-seconds 3600 --output yaml
```

2. Start a new SSM session on the "client" EC2 instance using the provided `ssm_start_session` output value. Your terminal will now be connected to the "client" EC2 instance.

```sh
ssm_start_session = "aws ssm start-session --region us-west-2 --target i-0280cf604085f4a44"
```

3. Once logged in, export the following environment variables from the output of step 1. Note - the session credentials are only valid for 1 hour; you can adjust the session duration in the command provided in step 1:

```sh
export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=YYYY
export AWS_SESSION_TOKEN=ZZZZ
```

4. Update the local `~/.kube/config` file to enable access to the cluster:

```sh
aws eks update-kubeconfig --region us-west-2 --name privatelink-access
```

5. Test access by listing the pods running on the clsuter:

```sh
sh-4.2$ kubectl get pods -A

# Output
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-4f8g8             1/1     Running   0          1m
kube-system   coredns-6ff9c46cd8-59sqp   1/1     Running   0          1m
kube-system   coredns-6ff9c46cd8-svnpb   1/1     Running   0          2m
kube-system   kube-proxy-mm2zc           1/1     Running   0          1m
```

## Destroy

Run the following command to destroy all the resources created by Terraform:

```sh
terraform destroy --auto-approve
```
