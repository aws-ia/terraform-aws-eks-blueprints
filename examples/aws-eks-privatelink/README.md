# Private EKS cluster endpoint access thru AWS PrivateLink

This example sets up resources in your AWS environment to demonstrate access from a client VPC to API endpoint(s) of a private EKS cluster deployed in a private/restricted VPC via `PrivateLink`

Refer to the [documentation](https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html) for `PrivateLink` concepts.

## Prerequisites:

Ensure that you have the following tools installed locally:

1. aws cli
2. kubectl
3. terraform

## Deploy

For using the variable values provided, as is, in `variables.tf`, run the
following command

```sh
terraform init
terraform apply --auto-approve
```

If you choose to customize, create a file by the name `terraform.tfvars` in the
root directory of this repo with the following content, customize the content as
per your needs and then run the command shown above

```
aws_region            = "us-west-2"
vpc_cidr              = "10.0.0.0/16"
eks_cluster_version   = "1.27
ssh_key_local_path    = "~/.ssh"
managed_node_group    = {
    node_group_name   = "managed-ondemand"
    instance_types    = ["t3.small"]
    min_size          = 1
    max_size          = 3
    desired_size      = 2  
}
aws_key_pair_name     = "aws-eks-privatelink"
eks_cluster_name      = "private-eks-cluster"
endpoint_service_name = "k8s-api-server-eps"  
endpoint_name         = "k8s-api-server-ep"
```

## Validate

When you deploy you may notice output like the one shown below:

```
Outputs:

client_instance_ssh_command = "ssh -i '~/.ssh/aws-eks-privatelink.pem' ec2-user@ec2-35-89-5-85.us-west-2.compute.amazonaws.com curl -ks https://vpce-03642bc3136a8f965-eoyji8cz.vpce-svc-088c62bd13d82059b.us-west-2.vpce.amazonaws.com/readyz"
```

Copy the SSH command in your terminal and run it. If you see `ok` as the output
the test was a success indicating that the API endpoint can be reached from the
client VPC.

## Configure for use with `kubectl`

Since the EKS cluster was setup with your (user) account, by default, the
`aws-auth` ConfigMap has only your account entry that allows access to the
cluster as `admin`. Also since, the API endpoint is private, Terraform cannot
reach it to add access for additional users.

Use the following manual steps to access the cluster with `kubectl` from the
client instance.

### Step 1: Get temporary credentials

Run the following command on your local machine to get temporary credentials and
save them to a local file.

```sh
# Get temporary credentials that expire in one hour
aws sts get-session-token --duration-seconds 3600 --output yaml
```

The output will look like this:

```
Credentials:
  AccessKeyId: XXXX
  Expiration: '2023-07-09T08:40:59+00:00'
  SecretAccessKey: YYYY
  SessionToken: ZZZZ
```

### Step 2: Log into the client instance and create/update a `~/.bashrc` file

Using part of the `client_instance_ssh_command` output (minus the `curl`
command) SSH into client instance.

Once logged in, create/update `~/.bashrc`
file with the following content using the information collected from the last
step.

```sh
export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=YYYY
export AWS_SESSION_TOKEN=ZZZZ
```

Save the file and exit. Source the file with the following command :

```sh
source ~/.bashrc
```

### Step 3: Setup kubeconfig file

Run the following command to setup the `kubeconfig` file to access the EKS
cluster

```sh
# Change/correct the parameters as applicable
aws eks update-kubeconfig --region us-west-2 --name private-eks-cluster
```

You can now choose to exit the SSH session with the client instance.

### Step 4: Test cluster access with `kubectl` within the next hour

```sh
# Change/correct the public DNS name of the client instance
ssh -i '~/.ssh/aws-eks-privatelink.pem' \
ec2-user@ec2-35-89-5-85.us-west-2.compute.amazonaws.com \
kubectl get nodes
```

If everything worked, you should see output like this :

```
NAME                                        STATUS   ROLES    AGE     VERSION
ip-10-0-17-85.us-west-2.compute.internal    Ready    <none>   5h58m   v1.25.9-eks-0a21954
ip-10-0-48-180.us-west-2.compute.internal   Ready    <none>   5h58m   v1.25.9-eks-0a21954
```

## Destroy

Run the following command to destroy all the resources created by Terraform:

```sh
terraform destroy --auto-approve
```
