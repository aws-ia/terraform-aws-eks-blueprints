# Serverless EKS Cluster using Fargate Profiles

This example shows how to provision a serverless cluster (serverless data plane) using Fargate Profiles.

There are some challenges to achieve this, primarily around the management and usage of CoreDNS on Fargate. There are alternative solutions shown on the internet, typically utilizing a `kubectl patch ...` command to update the compute type of the template spec annotation. This approach does work, but with the downside that the EKS service will eventually update the CoreDNS deployment and overwrite the patch, causing the CoreDNS deployment to fail due to insufficient capacity (it will be looking for EC2 compute when only Fargate is available).

The `preserve` setting was added to the addons API, allowing users to remove the addon from EKS API control and instead manage the addon themselves without disrupting the currently running software (preserves what currently exists, but now in the user's control, not the EKS API's control). However, this requires managing the addon first (as an EKS managed addon) and unfortunately this does not work for CoreDNS when using Fargate Profiles at this time. When trying to manage the CoreDNS addon, the addon deployment will fail due to the default compute type of EC2.

This example solution has been developed to work around these current limitations and provides:

- AWS EKS Cluster (control plane)
- AWS EKS Fargate Profiles for the `default` namespace and `kube-system` namespace. This covers the two core namespaces, including the namespace used by the `coredns`, `vpc-cni`, and `kube-proxy` addons, while additional profiles can be added as needed.
- AWS EKS managed addons `vpc-cni` and `kube-proxy`
- Self-managed CoreDNS addon deployed through a Helm chart. The default CoreDNS deployment provided by AWS EKS is removed and replaced with a self-managed CoreDNS deployment, while the `kube-dns` service is updated to allow Helm to assume control.
- AWS Load Balancer Controller add-on deployed through a Helm chart. The default AWS Load Balancer Controller add-on configuration is overridden so that it can be deployed on Fargate compute.
- A [sample-app](./sample-app) is provided to demonstrates how to configure the Ingress so that application can be accessed over the internet.

⚠️ The management of CoreDNS as demonstrated in this example is intended to be used on new clusters. Existing clusters with existing workloads will see downtime if the CoreDNS deployment is modified as shown here.

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

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the CoreDNS deployment for Fargate.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. Test by listing all the pods running currently. The CoreDNS pod should reach a status of `Running` after approximately 60 seconds:

```sh
kubectl get pods -A

# Output should look like below
ame-2048      deployment-2048-7ff458c9f-mb5xs                 1/1     Running   0          5h23m
game-2048     deployment-2048-7ff458c9f-qc99d                 1/1     Running   0          4h23m
game-2048     deployment-2048-7ff458c9f-rm26f                 1/1     Running   0          4h23m
game-2048     deployment-2048-7ff458c9f-vzjhm                 1/1     Running   0          4h23m
game-2048     deployment-2048-7ff458c9f-xnrgh                 1/1     Running   0          4h23m
kube-system   aws-load-balancer-controller-7b69cfcc44-49z5n   1/1     Running   0          5h42m
kube-system   aws-load-balancer-controller-7b69cfcc44-9vhq7   1/1     Running   0          5h43m
kube-system   coredns-7c9d764485-z247p                        1/1     Running   0          6h1m
```

3. Test that the sample application is now available

```sh
kubectl get ingress/ingress-2048 -n game-2048

# Output should look like this
NAME           CLASS   HOSTS   ADDRESS                                                                  PORTS   AGE
ingress-2048   alb     *       k8s-game2048-ingress2-0d47205282-922438252.us-east-1.elb.amazonaws.com   80      4h28m
```

4. Open the browser to access the application via the ALB address http://k8s-game2048-ingress2-0d47205282-922438252.us-east-1.elb.amazonaws.com/

⚠️ You might need to wait a few minutes, and then refresh your browser.

⚠️ If your Ingress isn't created after several minutes, then run this command to view the AWS Load Balancer Controller logs:

```sh
kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -auto-approve
```
