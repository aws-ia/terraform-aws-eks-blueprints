# Private EKS cluster access via AWS PrivateLink

This pattern demonstrates how to access a private EKS cluster using AWS PrivateLink.

Refer to the [documentation](https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html)
for further details on  `AWS PrivateLink`.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites required to deploy this pattern and steps to deploy.

## Validate

### Network Connectivity

An output `ssm_test` has been provided to aid in quickly testing the
connectivity from the client EC2 instance to the private EKS cluster via AWS
PrivateLink. Copy the output value and paste it into your terminal to execute
and check the connectivity. If configured correctly, the value returned should
be `ok`.

```sh
COMMAND="curl -ks https://9A85B21811733524E3ABCDFEA8714642.gr7.us-west-2.eks.amazonaws.com/readyz"

COMMAND_ID=$(aws ssm send-command --region us-west-2 \
--document-name "AWS-RunShellScript" \
--parameters "commands=[$COMMAND]" \
--targets "Key=instanceids,Values=i-0a45eff73ba408575" \
--query 'Command.CommandId' \
--output text)

aws ssm get-command-invocation --region us-west-2 \
--command-id $COMMAND_ID \
--instance-id i-0a45eff73ba408575 \
--query 'StandardOutputContent' \
--output text
```

### Cluster Access

To test access to the cluster, you will need to execute Kubernetes API calls
from within the private network to access the cluster. An EC2 instance has been
deployed into a "client" VPC to simulate this scenario. However, since the EKS
cluster was created with your local IAM identity, the `aws-auth` ConfigMap will
only have your local identity that is permitted to access the cluster. Since
cluster's API endpoint is private, we cannot use Terraform to reach it to
add additional entries to the ConfigMap; we can only access the cluster from
within the private network of the cluster's VPC or from the client VPC using AWS
PrivateLink access.

> :warning: The "client" EC2 instance provided and copying of AWS credentials to
 that instance are merely for demonstration purposes only. Please consider
 alternate methods of network access such as AWS Client VPN to provide more
 secure access.

Perform the following steps to access the cluster with `kubectl` from the
provided "client" EC2 instance.

1. Execute the command below on your local machine to get temporary credentials
that will be used on the "client" EC2 instance:

   ```sh
   aws sts get-session-token --duration-seconds 3600 --output yaml
   ```

2. Start a new SSM session on the "client" EC2 instance using the provided
`ssm_start_session` output value. Copy the output value and paste it into your
terminal to execute. Your terminal will now be connected to the "client" EC2
instance.

   ```sh
   aws ssm start-session --region us-west-2 --target i-0280cf604085f4a44
   ```

3. Once logged in, export the following environment variables from the output
of step #1:

   > :exclamation: The session credentials are only valid for 1 hour; you can
   adjust the session duration in the command provided in step #1

   ```sh
   export AWS_ACCESS_KEY_ID=XXXX
   export AWS_SECRET_ACCESS_KEY=YYYY
   export AWS_SESSION_TOKEN=ZZZZ
   ```

4. Run the following command to update the local `~/.kube/config` file to enable
access to the cluster:

   ```sh
   aws eks update-kubeconfig --region us-west-2 --name privatelink-access
   ```

5. Test access by listing the pods running on the cluster:

   ```sh
   kubectl get pods -A
   ```

   The test succeeded if you see an output like the one shown below:

   ```text
   NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
   kube-system   aws-node-4f8g8             1/1     Running   0          1m
   kube-system   coredns-6ff9c46cd8-59sqp   1/1     Running   0          1m
   kube-system   coredns-6ff9c46cd8-svnpb   1/1     Running   0          2m
   kube-system   kube-proxy-mm2zc           1/1     Running   0          1m
   ```

## Destroy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#destroy) for steps to clean up the resources created.
