# Bottlerocket with Bottlerocket Update Operator

This pattern demostrates how to deploy Amazon EKS Clusters using [Bottlerocket OS](https://aws.amazon.com/bottlerocket/) for Managed Node Groups (MNG) and [Karpenter](https://karpenter.sh/), using [Bottlerocket Update Operator (BRUPOP)](https://github.com/bottlerocket-os/bottlerocket-update-operator) to manage CVE patches automatically at the Node OS level. The BROPUP doesn't work with minor or major upgrades, just patch level.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. List all Nodes in the cluster. You should see three Nodes that belongs to the defined MNG, and should be in the `v1.28.1-eks-f0272c7` version since we are using a specific AMI ID to test the BRUPOP.

```sh
$ kubectl get nodes
NAME                                        STATUS   ROLES    AGE     VERSION
ip-10-0-2-29.us-west-2.compute.internal     Ready    <none>   7m24s   v1.28.1-eks-f0272c7
ip-10-0-26-48.us-west-2.compute.internal    Ready    <none>   7m23s   v1.28.1-eks-f0272c7
ip-10-0-43-187.us-west-2.compute.internal   Ready    <none>   7m19s   v1.28.1-eks-f0272c7
```

2. Check for the Label `"bottlerocket.aws/updater-interface-version"="2.0.0"` that is set to all the Nodes in the MNG. This Label is responsible to mark the Nodes that will have updates managed by BRUPOP.

```sh
$ kubectl get nodes -L bottlerocket.aws/updater-interface-version
NAME                                        STATUS   ROLES    AGE   VERSION               UPDATER-INTERFACE-VERSION
ip-10-0-2-29.us-west-2.compute.internal     Ready    <none>   79m   v1.28.1-eks-f0272c7   2.0.0
ip-10-0-26-48.us-west-2.compute.internal    Ready    <none>   79m   v1.28.1-eks-f0272c7   2.0.0
ip-10-0-43-187.us-west-2.compute.internal   Ready    <none>   79m   v1.28.1-eks-f0272c7   2.0.0
```

3. Validate if all the Pods are in Running status, and Ready.

```sh
$ kubectl get pods -A
NAMESPACE                 NAME                                            READY   STATUS    RESTARTS        AGE
brupop-bottlerocket-aws   brupop-agent-2msn5                              1/1     Running   0               3m20s
brupop-bottlerocket-aws   brupop-agent-7kvx5                              1/1     Running   0               3m20s
brupop-bottlerocket-aws   brupop-agent-8d8n8                              1/1     Running   0               3m20s
brupop-bottlerocket-aws   brupop-apiserver-7b45c5546f-dzwqz               1/1     Running   0               3m20s
brupop-bottlerocket-aws   brupop-apiserver-7b45c5546f-lvnt4               1/1     Running   0               3m20s
brupop-bottlerocket-aws   brupop-apiserver-7b45c5546f-xmvx2               1/1     Running   0               3m20s
brupop-bottlerocket-aws   brupop-controller-deployment-7fcfc69978-rwkml   1/1     Running   0               3m20s
cert-manager              cert-manager-5b44f85959-zc5zc                   1/1     Running   0               4m2s
cert-manager              cert-manager-cainjector-7f97f54fd-kjnq5         1/1     Running   0               4m3s
cert-manager              cert-manager-webhook-c59f66876-jkwhj            1/1     Running   0               4m3s
karpenter                 karpenter-7b7958bbf5-647n2                      1/1     Running   0               11m
karpenter                 karpenter-7b7958bbf5-s8475                      1/1     Running   0               11m
kube-system               aws-node-5n496                                  2/2     Running   0               10m
kube-system               aws-node-krz6q                                  2/2     Running   0               10m
kube-system               aws-node-tx76l                                  2/2     Running   0               10m
kube-system               coredns-544fd9dfb5-6l6nt                        1/1     Running   0               9m27s
kube-system               coredns-544fd9dfb5-hcq84                        1/1     Running   0               9m27s
kube-system               kube-proxy-9sh2s                                1/1     Running   0               9m19s
kube-system               kube-proxy-gl5g9                                1/1     Running   0               9m24s
kube-system               kube-proxy-jwcqp                                1/1     Running   0               9m15s
```

4. Test the Bottlerocket Update Operator. By default in this pattern, it's set to check for updates every hour.

```hcl
  set = [{
    name  = "scheduler_cron_expression"
    value = "0 * * * * * *" # Default Unix Cron syntax, set to check every hour. Example "0 0 23 * * Sat *" Perform update checks every Saturday at 23H / 11PM
    }]
```

Describe any Node with the `v1.28.1-eks-f0272c7` version.

```sh
$ kubectl describe node ip-10-0-43-187.us-west-2.compute.internal | grep Image
  OS Image:                   Bottlerocket OS 1.15.1 (aws-k8s-1.28)
```

5. Wait until the next full hour and check that one of the Nodes were updated to a newer version without downtime, in this example, `v1.28.4-eks-d91a302`.

```sh
$ kubectl get nodes
NAME                                        STATUS   ROLES    AGE   VERSION
ip-10-0-2-29.us-west-2.compute.internal     Ready    <none>   83m   v1.28.4-eks-d91a302
ip-10-0-26-48.us-west-2.compute.internal    Ready    <none>   83m   v1.28.1-eks-f0272c7
ip-10-0-43-187.us-west-2.compute.internal   Ready    <none>   83m   v1.28.1-eks-f0272c7
```

6. Describe the Node with the `v1.28.4-eks-d91a302` version.

```sh
$ kubectl describe node ip-10-0-2-29.us-west-2.compute.internal | grep Image
  OS Image:                   Bottlerocket OS 1.18.0 (aws-k8s-1.28)
```

7. In the Karpenter's EC2NodeClass configuration, the default OS is also set to Bottlerocket, but in it's latest version, and the label to perform automated updates is not set, since Karpenter is configured to expire the Nodes every 24 hours.

```sh
kubectl describe ec2nodeclasses.karpenter.k8s.aws default | grep Status -A50 | egrep 'Amis|Id|Name'
  Amis:
    Id:    ami-01b71889c3f284b0a
    Name:  bottlerocket-aws-k8s-1.28-x86_64-v1.18.0-7452c37e
    Id:          ami-0ce0c1aa90b150d58
    Name:        bottlerocket-aws-k8s-1.28-nvidia-x86_64-v1.18.0-7452c37e
    Id:          ami-0ce0c1aa90b150d58
    Name:        bottlerocket-aws-k8s-1.28-nvidia-x86_64-v1.18.0-7452c37e
    Id:          ami-051b2c0f7fbcb46f0
    Name:        bottlerocket-aws-k8s-1.28-nvidia-aarch64-v1.18.0-7452c37e
    Id:          ami-051b2c0f7fbcb46f0
    Name:        bottlerocket-aws-k8s-1.28-nvidia-aarch64-v1.18.0-7452c37e
    Id:          ami-0e0f7fff616a55a1c
    Name:        bottlerocket-aws-k8s-1.28-aarch64-v1.18.0-7452c37e
```

8. To validate that, use the `kubectl` command to create an example deployment, and scale it to any desired amount of replicas. Karpenter should provision a new Node in with the latest available version for Bottlerocket.

```sh
$ kubectl scale deployment inflate --replicas 10
deployment.apps/inflate scaled

$ kubectl get pods -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP            NODE                                       NOMINATED NODE   READINESS GATES
inflate-7849c696cd-2668t   1/1     Running   0          49s   10.0.34.254   ip-10-0-45-41.us-west-2.compute.internal   <none>           <none>
inflate-7849c696cd-5wffm   1/1     Running   0          49s   10.0.46.13    ip-10-0-45-41.us-west-2.compute.internal   <none>           <none>
inflate-7849c696cd-8x5ws   1/1     Running   0          49s   10.0.35.190   ip-10-0-45-41.us-west-2.compute.internal   <none>           <none>
inflate-7849c696cd-9nhvr   1/1     Running   0          49s   10.0.42.99    ip-10-0-45-41.us-west-2.compute.internal   <none>           <none>
inflate-7849c696cd-cbr5q   1/1     Running   0          49s   10.0.35.195   ip-10-0-45-41.us-west-2.compute.internal   <none>           <none>
inflate-7849c696cd-jcr7r   1/1     Running   0          49s   10.0.33.41    ip-10-0-45-41.us-west-2.compute.internal   <none>           <none>
inflate-7849c696cd-nhjt4   1/1     Running   0          49s   10.0.35.213   ip-10-0-45-41.us-west-2.compute.internal   <none>           <none>
inflate-7849c696cd-p9j7x   1/1     Running   0          49s   10.0.43.102   ip-10-0-45-41.us-west-2.compute.internal   <none>           <none>
inflate-7849c696cd-qr7th   1/1     Running   0          49s   10.0.37.221   ip-10-0-45-41.us-west-2.compute.internal   <none>           <none>
inflate-7849c696cd-rzjzr   1/1     Running   0          49s   10.0.33.210   ip-10-0-45-41.us-west-2.compute.internal   <none>           <none>

$ kubect get nodes
NAME                                        STATUS                     ROLES    AGE   VERSION
ip-10-0-2-29.us-west-2.compute.internal     Ready                      <none>   90m   v1.28.4-eks-d91a302
ip-10-0-26-48.us-west-2.compute.internal    Ready                      <none>   90m   v1.28.1-eks-f0272c7
ip-10-0-43-187.us-west-2.compute.internal   Ready                      <none>   90m   v1.28.1-eks-f0272c7
ip-10-0-45-41.us-west-2.compute.internal    Ready                      <none>   60s   v1.28.4-eks-d91a302

$ kubectl describe node ip-10-0-45-41.us-west-2.compute.internal | grep Image
  OS Image:                   Bottlerocket OS 1.18.0 (aws-k8s-1.28)
```

## Destroy

Scale down the example application to de-provision Karpenter Nodes.

```sh
$ kubectl delete -f example.yaml
deployment.apps "inflate" deleted
```

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
