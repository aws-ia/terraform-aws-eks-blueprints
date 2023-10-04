# Amazon EKS Cluster w/ Network Policies

This pattern demonstrates an EKS cluster that uses the native Network Policy support provided by the Amazon VPC CNI (1.14.0 or higher).

- [Documentation](https://docs.aws.amazon.com/eks/latest/userguide/cni-network-policy.html)
- [Launch Blog](https://aws.amazon.com/blogs/containers/amazon-vpc-cni-now-supports-kubernetes-network-policies/)

## Scenario

This pattern deploys an Amazon EKS Cluster with Network Policies support implemented by the Amazon VPC CNI. Further it deploys a simple demo application (distributed as a Helm Chart) and some sample Network Policies to restrict the traffic between different components of the application.

For a detailed description of the demo application and the Network Policies, please refer to the Stars demo of network policy section in the official [Documentation](https://docs.aws.amazon.com/eks/latest/userguide/cni-network-policy.html).

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. List out the pods running currently:

    ```sh
    kubectl get pods -A
    ```

    ```text
   NAMESPACE         NAME                                       READY   STATUS    RESTARTS   AGE
    [...]
    client            client-xlffc                               1/1     Running   0          5m19s
    [...]
    management-ui     management-ui-qrb2g                        1/1     Running   0          5m24s
    stars             backend-sz87q                              1/1     Running   0          5m23s
    stars             frontend-cscnf                             1/1     Running   0          5m21s
    [...]
    ```

    In your output, you should see pods in the namespaces shown in the following output. The NAMES of your pods and the number of pods in the READY column are different than those in the following output. Don't continue until you see pods with similar names and they all have Running in the STATUS column.

2. Connect to the management user interface using the EXTERNAL IP of the running service and observe the traffic flow and restrictions based on the Network Policies deployed:

    ```sh
    kubectl get service/management-ui -n management-ui
    ```

    Open the browser based on the URL obtained from the previous step to see the connection map and restrictions put in place by the Network Policies deployed.

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
