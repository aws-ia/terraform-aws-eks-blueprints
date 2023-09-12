# Amazon EKS Cluster w/ IPv6 Networking

This pattern demonstrates an EKS cluster that utilizes IPv6 networking.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. Test by listing all the pods running currently; the `IP` should be an IPv6 address.

    ```sh
    kubectl get pods -A -o wide
    ```

    ```text
    # Output should look like below
    NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE     IP                                       NODE                                        NOMINATED NODE   READINESS GATES
    kube-system   aws-node-bhd2s             1/1     Running   0          3m5s    2600:1f13:6c4:a703:ecf8:3ac1:76b0:9303   ip-10-0-10-183.us-west-2.compute.internal   <none>           <none>
    kube-system   aws-node-nmdgq             1/1     Running   0          3m21s   2600:1f13:6c4:a705:a929:f8d4:9350:1b20   ip-10-0-12-188.us-west-2.compute.internal   <none>           <none>
    kube-system   coredns-799c5565b4-6wxrc   1/1     Running   0          10m     2600:1f13:6c4:a705:bbda::                ip-10-0-12-188.us-west-2.compute.internal   <none>           <none>
    kube-system   coredns-799c5565b4-fjq4q   1/1     Running   0          10m     2600:1f13:6c4:a705:bbda::1               ip-10-0-12-188.us-west-2.compute.internal   <none>           <none>
    kube-system   kube-proxy-58tp7           1/1     Running   0          4m25s   2600:1f13:6c4:a703:ecf8:3ac1:76b0:9303   ip-10-0-10-183.us-west-2.compute.internal   <none>           <none>
    kube-system   kube-proxy-hqkgw           1/1     Running   0          4m25s   2600:1f13:6c4:a705:a929:f8d4:9350:1b20   ip-10-0-12-188.us-west-2.compute.internal   <none>           <none>
    ```

2. Test by listing all the nodes running currently; the `INTERNAL-IP` should be an IPv6 address.

    ```sh
    kubectl nodes -A -o wide
    ```

    ```text
    # Output should look like below
    NAME                                        STATUS   ROLES    AGE     VERSION               INTERNAL-IP                              EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION                 CONTAINER-RUNTIME
    ip-10-0-10-183.us-west-2.compute.internal   Ready    <none>   4m57s   v1.24.7-eks-fb459a0   2600:1f13:6c4:a703:ecf8:3ac1:76b0:9303   <none>        Amazon Linux 2   5.4.226-129.415.amzn2.x86_64   containerd://1.6.6
    ip-10-0-12-188.us-west-2.compute.internal   Ready    <none>   4m57s   v1.24.7-eks-fb459a0   2600:1f13:6c4:a705:a929:f8d4:9350:1b20   <none>        Amazon Linux 2   5.4.226-129.415.amzn2.x86_64   containerd://1.6.6
    ```

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
