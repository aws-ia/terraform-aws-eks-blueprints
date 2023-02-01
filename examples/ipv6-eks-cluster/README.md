# IPv6 EKS Cluster

This example shows how to create an EKS cluster that utilizes IPv6 networking.

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

2. Test by listing all the pods running currently; the `IP` should be an IPv6 address.

```sh
kubectl get pods -A -o wide

# Output should look like below
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE     IP                                       NODE                                        NOMINATED NODE   READINESS GATES
kube-system   aws-node-bhd2s             1/1     Running   0          3m5s    2600:1f13:6c4:a703:ecf8:3ac1:76b0:9303   ip-10-0-10-183.us-west-2.compute.internal   <none>           <none>
kube-system   aws-node-nmdgq             1/1     Running   0          3m21s   2600:1f13:6c4:a705:a929:f8d4:9350:1b20   ip-10-0-12-188.us-west-2.compute.internal   <none>           <none>
kube-system   coredns-799c5565b4-6wxrc   1/1     Running   0          10m     2600:1f13:6c4:a705:bbda::                ip-10-0-12-188.us-west-2.compute.internal   <none>           <none>
kube-system   coredns-799c5565b4-fjq4q   1/1     Running   0          10m     2600:1f13:6c4:a705:bbda::1               ip-10-0-12-188.us-west-2.compute.internal   <none>           <none>
kube-system   kube-proxy-58tp7           1/1     Running   0          4m25s   2600:1f13:6c4:a703:ecf8:3ac1:76b0:9303   ip-10-0-10-183.us-west-2.compute.internal   <none>           <none>
kube-system   kube-proxy-hqkgw           1/1     Running   0          4m25s   2600:1f13:6c4:a705:a929:f8d4:9350:1b20   ip-10-0-12-188.us-west-2.compute.internal   <none>           <none>
```

3. Test by listing all the nodes running currently; the `INTERNAL-IP` should be an IPv6 address.

```sh
kubectl nodes -A -o wide

# Output should look like below
NAME                                        STATUS   ROLES    AGE     VERSION               INTERNAL-IP                              EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION                 CONTAINER-RUNTIME
ip-10-0-10-183.us-west-2.compute.internal   Ready    <none>   4m57s   v1.24.7-eks-fb459a0   2600:1f13:6c4:a703:ecf8:3ac1:76b0:9303   <none>        Amazon Linux 2   5.4.226-129.415.amzn2.x86_64   containerd://1.6.6
ip-10-0-12-188.us-west-2.compute.internal   Ready    <none>   4m57s   v1.24.7-eks-fb459a0   2600:1f13:6c4:a705:a929:f8d4:9350:1b20   <none>        Amazon Linux 2   5.4.226-129.415.amzn2.x86_64   containerd://1.6.6
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -auto-approve
```
