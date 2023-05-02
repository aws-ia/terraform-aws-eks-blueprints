# Karpenter

## Prerequisites

If deploying a node template that uses `spot`, please ensure you have the Spot service linked role available in your account. You can run the following command to ensure this role is available:

```sh
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
```

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the CoreDNS deployment for Fargate.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. Test by listing all the pods running currently

```sh
kubectl get pods -n karpenter

# Output should look similar to below
NAME                         READY   STATUS    RESTARTS   AGE
karpenter-6f97df4f77-5nqsk   1/1     Running   0          3m28s
karpenter-6f97df4f77-n7fkf   1/1     Running   0          3m28s
```

3. View the current nodes - this example utilizes EKS Fargate for hosting the Karpenter controller so only Fargate nodes are present currently:

```sh
kubectl get nodes

# Output should look similar to below
NAME                                                STATUS   ROLES    AGE     VERSION
fargate-ip-10-0-29-25.us-west-2.compute.internal    Ready    <none>   2m56s   v1.26.3-eks-f4dc2c0
fargate-ip-10-0-36-148.us-west-2.compute.internal   Ready    <none>   2m57s   v1.26.3-eks-f4dc2c0
fargate-ip-10-0-42-30.us-west-2.compute.internal    Ready    <none>   2m34s   v1.26.3-eks-f4dc2c0
fargate-ip-10-0-45-112.us-west-2.compute.internal   Ready    <none>   2m33s   v1.26.3-eks-f4dc2c0
```

4. Create a sample `pause` deployment to demonstrate scaling:

```sh
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
    name: inflate
spec:
    replicas: 0
    selector:
    matchLabels:
        app: inflate
    template:
    metadata:
        labels:
        app: inflate
    spec:
        terminationGracePeriodSeconds: 0
        containers:
        - name: inflate
            image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
            resources:
            requests:
                cpu: 1
EOF
```

5. Scale up the sample `pause` deployment to see Karpenter respond by provisioning nodes to support the workload:

```sh
kubectl scale deployment inflate --replicas 5
# To view logs
# kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller
```

6. Re-check the nodes, you will now see a new EC2 node provisioned to support the scaled workload:

```sh
kubectl get nodes

# Output should look similar to below
NAME                                                STATUS   ROLES    AGE     VERSION
fargate-ip-10-0-29-25.us-west-2.compute.internal    Ready    <none>   5m15s   v1.26.3-eks-f4dc2c0
fargate-ip-10-0-36-148.us-west-2.compute.internal   Ready    <none>   5m16s   v1.26.3-eks-f4dc2c0
fargate-ip-10-0-42-30.us-west-2.compute.internal    Ready    <none>   4m53s   v1.26.3-eks-f4dc2c0
fargate-ip-10-0-45-112.us-west-2.compute.internal   Ready    <none>   4m52s   v1.26.3-eks-f4dc2c0
ip-10-0-1-184.us-west-2.compute.internal            Ready    <none>   26s     v1.26.2-eks-a59e1f0 # <= new EC2 node launched
```

7. Remove the sample `pause` deployment:

```sh
kubectl delete deployment inflate
```
