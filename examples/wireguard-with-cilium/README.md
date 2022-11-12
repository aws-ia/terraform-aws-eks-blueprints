# Transparent Encryption with Cilium and Wirguard

This example shows how to provision an EKS cluster with:
- Managed node group based on Bottlerocket AMI
- Cilium configured in CNI chaining mode with VPC CNI and with Wiregaurd transparent encryption enabled

## Reference Documentation:

- [Cilium CNI Chaning Documentation](https://docs.cilium.io/en/v1.12/gettingstarted/cni-chaining-aws-cni/)
- [Cilium Wiregaurd Encryption Documentation](https://docs.cilium.io/en/v1.12/gettingstarted/encryption-wireguard/)

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

6. Start a packet capture and verify you don't see payload in clear text

```sh
tcpdump -A -c 3 -i cilium_wg0

# Output should look similar below (truncated for brevity)

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on cilium_wg0, link-type RAW (Raw IP), capture size 262144 bytes
05:28:30.234209 IP ip-10-0-11-73.ec2.internal.58086 > ip-10-0-10-160.ec2.internal.http: Flags [S], seq 2831772984, win 62727, options [mss 8961,sackOK,TS val 3834644316 ecr 0,nop,wscale 7], length 0
E..<].@.?...
..I
.
....P..m8........&.....#....
...\........
05:28:30.234306 IP ip-10-0-10-160.ec2.internal.http > ip-10-0-11-73.ec2.internal.58086: Flags [S.], seq 131501951, ack 2831772985, win 62643, options [mss 8961,sackOK,TS val 1959385110 ecr 3834644316,nop,wscale 7], length 0
E..<..@.?...
.
.
..I.P........m9....*.....#....
t......\....
05:28:30.234930 IP ip-10-0-11-73.ec2.internal.58086 > ip-10-0-10-160.ec2.internal.http: Flags [.], ack 1, win 491, options [nop,nop,TS val 3834644317 ecr 1959385110], length 0
E..4].@.?...
..I
.
....P..m9...............
...]t...
3 packets captured
9 packets received by filter
1 packet dropped by kernel
```
7. Exit the container shell

```sh
exit
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -target=module.eks_blueprints_kubernetes_addons -auto-approve
terraform destroy -target=module.eks_blueprints -auto-approve
terraform destroy -auto-approve
```
