# Transparent Encryption with Cilium and Wireguard

This example shows how to provision an EKS cluster with:
- Managed node group based on Bottlerocket AMI
- Cilium configured in CNI chaining mode with VPC CNI and with Wireguard transparent encryption enabled

## Reference Documentation:

- [Cilium CNI Chaining Documentation](https://docs.cilium.io/en/v1.12/gettingstarted/cni-chaining-aws-cni/)
- [Cilium Wireguard Encryption Documentation](https://docs.cilium.io/en/v1.12/gettingstarted/encryption-wireguard/)

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example with a sample app for testing:

```sh
terraform init
terraform apply
```

To provision this example without sample app for testing:

```sh
terraform init
terraform apply -var enable_example=false
```

Enter `yes` at command prompt to apply

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the deployment.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. List the daemonsets

```sh
kubectl get ds -n kube-system

# Output should look something similar
NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
aws-node     2         2         2       2            2           <none>                   156m
cilium       2         2         2       2            2           kubernetes.io/os=linux   152m
kube-proxy   2         2         2       2            2           <none>                   156m
```

3. Open a shell inside the cilium container

```sh
kubectl -n kube-system exec -ti ds/cilium -- bash
```

4. Verify Encryption is enabled

```sh
cilium status | grep Encryption

# Output should look something similar
Encryption:              Wireguard   [cilium_wg0 (Pubkey: b2krgbHgaCsVWALMnFLiS/RekhhcE36PXEjQ7T8+mW0=, Port: 51871, Peers: 1)]
```

5. Install tcpdump

```sh
apt-get update
apt-get install -y tcpdump
```

6. Start a packet capture on `cilium_wg0` and verify you see payload in clear text, it means the traffic is encrypted with wireguard

```sh
tcpdump -A -c 40 -i cilium_wg0 | grep "Welcome to nginx!"

# Output should look similar below

<title>Welcome to nginx!</title>
<h1>Welcome to nginx!</h1>
...

40 packets captured
40 packets received by filter
0 packets dropped by kernel
```
7. Exit the container shell

```sh
exit
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -target=module.eks -auto-approve
terraform destroy -auto-approve
```
