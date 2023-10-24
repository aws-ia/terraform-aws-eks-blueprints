# Private EKS cluster access via AWS PrivateLink

This pattern demonstrates how to access a private EKS cluster using AWS PrivateLink.

Refer to the [documentation](https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html)
for further details on  `AWS PrivateLink`.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and follow the steps below to deploy this pattern.

```sh
terraform init
terraform apply -target=module.eventbridge -target=module.nlb --auto-approve
terraform apply --auto-approve
```

Once the pattern has successfully deployed, you will be provided with multiple
output values.

Review the output value for `cluster_endpoint_private`, it should look similar
to snippet below:

```sh
aws eks update-cluster-config \
--region us-west-2 \
--name privatelink-access \
--resources-vpc-config endpointPublicAccess=false,endpointPrivateAccess=true
```

Copy the command and run it in a terminal session to take the cluster API endpoint
private.

## Test access to EKS Kubernetes API server endpoint

Of the other output values, the value `ssm_test` is provided to aid in quickly
testing the connectivity from the client EC2 instance to the private EKS cluster
via AWS PrivateLink. Copy the output value, which looks like the snippet shown
below (as an example) and paste it into your terminal to execute and check the
connectivity. If configured correctly, the value returned should be `ok`.

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

## Test access to EKS Kubernetes API with `kubectl`

Perform the following steps to access the cluster with `kubectl` from the
provided Client EC2 instance.

### Log into the Client EC2 instance
Start a new SSM session on the Client EC2 instance using the provided
`ssm_start_session` output value. It should look similar to the snippet
shown below. Copy the output value and paste it into your terminal to execute.
Your terminal will now be connected to the Client EC2 instance.

```sh
aws ssm start-session --region us-west-2 --target i-0280cf604085f4a44
```

### Update Kubeconfig
On the Client EC2 machine, run the following command to update the local
`~/.kube/config` file to enable access to the cluster:

```sh
aws eks update-kubeconfig --region us-west-2 --name privatelink-access
```

### Test complete access with `kubectl`
Test access by listing the pods running on the cluster:

```sh
kubectl get pods -A
```

```text
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-4f8g8             1/1     Running   0          1m
kube-system   coredns-6ff9c46cd8-59sqp   1/1     Running   0          1m
kube-system   coredns-6ff9c46cd8-svnpb   1/1     Running   0          2m
kube-system   kube-proxy-mm2zc           1/1     Running   0          1m
```

## Destroy

Before we could destroy/teardown all the resources created, we need to ensure
that the cluster state is restored for the Terraform to do a complete cleanup.
This would mean that we make cluster API endpoint public again.

Review the output value for `cluster_endpoint_public`, it should look similar
to snippet below:

```sh
aws eks update-cluster-config \
--region us-west-2 \
--name privatelink-access \
--resources-vpc-config endpointPublicAccess=true,endpointPrivateAccess=true
```

Copy the command and run it in a terminal session to take the cluster API
endpoint public. After ensuring that the cluster API endpoint is public, continue
with the steps below to destroy all the resources created by this pattern.

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
