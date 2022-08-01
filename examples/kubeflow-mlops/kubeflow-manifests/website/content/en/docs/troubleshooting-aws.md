+++
title = "Troubleshooting"
description = "Diagnose and fix issues you may encounter in your Kubeflow deployment"
weight = 30
+++

For general errors related to Kubernetes and Amazon EKS, please refer to the [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html) troubleshooting section. For issues with cluster creation or modification with `eksctl`, see the [`eksctl` troubleshooting](https://eksctl.io/usage/troubleshooting/) page.

### Validate prerequisites

You may experience issues due to version incompatibility. Before diving into more specific issues, check to make sure that you have the correct [prerequisites]({{< ref "/docs/deployment/prerequisites.md" >}}) installed. 

### ALB fails to provision

If you see that your istio-ingress `ADDRESS` is empty after more than a few minutes, it is possible that something is misconfigured in your ALB ingress controller.
```bash
kubectl get ingress -n istio-system
NAME            HOSTS   ADDRESS   PORTS   AGE
istio-ingress   *                 80      3min
```

Check the AWS ALB Ingress Controller logs for errors.
```shell
kubectl -n kube-system logs $(kubectl get pods -n kube-system --selector=app.kubernetes.io/name=aws-load-balancer-controller --output=jsonpath={.items..metadata.name})
```

If the logs indicate issues with a missing clustername, check the following ConfigMap:
```bash
kubectl get configmaps -n kube-system aws-load-balancer-controller-config -o yaml
```

Make sure that the ConfigMap has the correct EKS cluster name assigned to the `clusterName` variable.
```bash
apiVersion: v1
kind: ConfigMap
data:
  clusterName: your-eks-cluster-name
```
If this does not resolve the error, it is possible that your subnets are not tagged so that Kubernetes knows which subnets to use for external load balancers. To fix this, ensure that your cluster's public subnets are tagged with the **Key**: ```kubernetes.io/role/elb``` and **Value**: ```1```. See the Prerequisites section for application load balancing in the [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html) for further details.

### FSx issues

Verify that the FSx drivers are installed by running the following command: 
```bash
kubectl get csidriver -A
```

Check that `PersistentVolumes`, `PersistentVolumeClaims`, and `StorageClasses` are all deployed as expected:
```bash
kubectl get pv,pvc,sc -A
```

Use the `kubectl logs` command to get more information on Pods that use these resources.

For more information, see the [Amazon FSx for Lustre CSI Driver](https://github.com/kubernetes-sigs/aws-fsx-csi-driver) GitHub repository. Troubleshooting information for specific FSx filesystems can be found in the [Amazon FSx documentation](https://docs.aws.amazon.com/fsx/index.html). 

### RDS issues

To troubleshoot RDS issues, follow the [installation verification steps]({{< ref "/docs/deployment/rds-s3/guide.md#40-verify-the-installation" >}}).
