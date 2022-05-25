# EKS Cluster with Windows support

This example deploys the following AWS resources.

- A new VPC, 3 AZs with private and public subnets
- Necessary VPC endpoints for node groups in private subnets
- An Internet gateway for the VPC and a NAT gateway in each public subnet
- An EKS cluster with an AWS-managed node group of spot Linux worker nodes and a self-managed node group of on-demand Windows worker nodes

# How to deploy

## Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run `terraform plan` and `terraform apply`

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deployment steps

### Step 1: Clone the repo using the command below

```bash
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

### Step 2: Run `terraform init`

to initialize a working directory with configuration files

```bash
cd examples/node-groups/windows-node-groups
terraform init
```

### Step 3: Run `terraform plan`

to verify the resources created by this execution

```bash
export AWS_REGION=us-west-2   # Select your own region
terraform plan
```

If you want to use a region other than `us-west-2`, update the `aws_region` name and `aws_availability_zones` filter in the data sources in [main.tf](./main.tf) accordingly.

### Step 4: Run `terraform apply`

to create resources

```bash
terraform apply -auto-approve
```

## Configure kubectl and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

### Step 5: Run `update-kubeconfig` command.

`~/.kube/config` file gets updated with EKS cluster context from the below command. Replace the region name and EKS cluster name with your cluster's name. (If you did not change the `tenant`, `environment`, and `zone` values in this example, the EKS cluster name will be `aws001-preprod-dev-eks`.)

    $ aws eks --region us-west-2 update-kubeconfig --name aws001-preprod-dev-eks

### Step 6: (Optional) Deploy sample Windows and Linux workloads to verify support for both operating systems

When Windows support is enabled in the cluster, it is necessary to use one of the ways to assign pods to specific nodes, such as `nodeSelector` or `affinity`. See the [K8s documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) for more info. This example uses `nodeSelector`s to select nodes with appropriate OS for pods.

#### Sample Windows deployment

```bash
cd examples/node-groups/windows-node-groups

# Sample Windows deployment
kubectl apply -f ./k8s/windows-iis-aspnet.yaml

# Wait for the Windows pod status to change to Running
# The following command will work on Linux
# On Mac, install the watch command using brew install watch
watch -n 1 "kubectl get po -n windows"

# When the pod starts running, create a proxy to the K8s API
kubectl proxy
```

Now visit [http://127.0.0.1:8001/api/v1/namespaces/windows/services/aspnet/proxy/demo](http://127.0.0.1:8001/api/v1/namespaces/windows/services/aspnet/proxy/demo) in your browser. If everything went well, the page should display text "Hello, World!". Use Ctrl+C in your terminal to stop the `kubectl` proxy.

Note: The `aspnet` service created by above example is a `LoadBalancer` service, so you can also visit the Network Load Balancer (NLB) endpoint in your browser instead of using `kubectl proxy` as mentioned above. To be able to access the NLB endpoint, update the security group attached to the Windows node where the `aspnet` pod is running to allow inbound access to port 80 from your IP address. You can grab the NLB endpoint from the service using the following command:

```
kubectl get svc -n windows -o jsonpath="{.items[0].status.loadBalancer.ingress[0].hostname}"
```

#### Sample Linux deployment

```bash
# Sample Linux deployment
kubectl apply -f ./k8s/linux-nginx.yaml
```

## Cleanup

```bash
cd examples/node-groups/windows-node-groups

# If you deployed sample Windows & Linux workloads from Step 6
kubectl delete svc,deploy -n windows --all
kubectl delete svc,deploy -n linux --all

# Destroy all resources
terraform destroy -auto-approve
```

## See also

- [EKS Windows support considerations](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html)
