# Amazon EKS Cluster w/ ArgoCD

This example shows how to provision an EKS cluster with:

- ArgoCD
  - Workloads and addons deployed by ArgoCD

To better understand how ArgoCD works with EKS Blueprints, read the EKS Blueprints ArgoCD [Documentation](https://aws-ia.github.io/terraform-aws-eks-blueprints/latest/add-ons/argocd/)

## Reference Documentation

- [Documentation](https://aws-ia.github.io/terraform-aws-eks-blueprints/latest/add-ons/argocd/)
- [EKS Blueprints Add-ons Repo](https://github.com/aws-samples/eks-blueprints-add-ons)
- [EKS Blueprints Workloads Repo](https://github.com/aws-samples/eks-blueprints-workloads)

## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Minimum IAM Policy

> **Note**: The policy resource is set as `*` to allow all resources, this is not a recommended practice.

You can find the policy [here](min-iam-policy.json)

## Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the deployment.

1. Run `update-kubeconfig` command:

    ```sh
    aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME> --alias <CLUSTER_NAME>
    ```

2. List out the pods running currently:

    ```sh
    kubectl get pods -A

    NAMESPACE        NAME                                                        READY   STATUS    RESTARTS          AGE
    argo-rollouts    argo-rollouts-5d47ccb8d4-854s6                              1/1     Running   0                 23h
    argo-rollouts    argo-rollouts-5d47ccb8d4-srjk9                              1/1     Running   0                 23h
    argocd           argo-cd-argocd-application-controller-0                     1/1     Running   0                 24h
    argocd           argo-cd-argocd-applicationset-controller-547f9cfd68-kp89p   1/1     Running   0                 24h
    argocd           argo-cd-argocd-dex-server-55765f7cd7-t8r2f                  1/1     Running   0                 24h
    argocd           argo-cd-argocd-notifications-controller-657df4dbcb-p596r    1/1     Running   0                 24h
    argocd           argo-cd-argocd-repo-server-7d4dddf886-2vmgt                 1/1     Running   0                 24h
    argocd           argo-cd-argocd-repo-server-7d4dddf886-bm7tz                 1/1     Running   0                 24h
    argocd           argo-cd-argocd-server-775ddf74b8-8jzvc                      1/1     Running   0                 24h
    argocd           argo-cd-argocd-server-775ddf74b8-z6lz6                      1/1     Running   0                 24h
    argocd           argo-cd-redis-ha-haproxy-6d7b7d4656-b8bt8                   1/1     Running   0                 24h
    argocd           argo-cd-redis-ha-haproxy-6d7b7d4656-mgjx5                   1/1     Running   0                 24h
    argocd           argo-cd-redis-ha-haproxy-6d7b7d4656-qsbgw                   1/1     Running   0                 24h
    argocd           argo-cd-redis-ha-server-0                                   4/4     Running   0                 24h
    argocd           argo-cd-redis-ha-server-1                                   4/4     Running   0                 24h
    argocd           argo-cd-redis-ha-server-2                                   4/4     Running   0                 24h
    cert-manager     cert-manager-586ccb6656-2v8mf                               1/1     Running   0                 23h
    cert-manager     cert-manager-cainjector-99d64d795-2gwnj                     1/1     Running   0                 23h
    cert-manager     cert-manager-webhook-8d87786cb-24kww                        1/1     Running   0                 23h
    geolocationapi   geolocationapi-85599c5c74-rqqqs                             2/2     Running   0                 25m
    geolocationapi   geolocationapi-85599c5c74-whsp6                             2/2     Running   0                 25m
    geordie          downstream0-7f6ff946b6-r8sxc                                1/1     Running   0                 25m
    geordie          downstream1-64c7db6f9-rsbk5                                 1/1     Running   0                 25m
    geordie          frontend-646bfb947c-wshpb                                   1/1     Running   0                 25m
    geordie          redis-server-6bd7885d5d-s7rqw                               1/1     Running   0                 25m
    geordie          yelb-appserver-5d89946ffd-vkxt9                             1/1     Running   0                 25m
    geordie          yelb-db-697bd9f9d9-2t4b6                                    1/1     Running   0                 25m
    geordie          yelb-ui-75ff8b96ff-fh6bw                                    1/1     Running   0                 25m
    karpenter        karpenter-7b99fb785d-87k6h                                  1/1     Running   0                 106m
    karpenter        karpenter-7b99fb785d-lkq9l                                  1/1     Running   0                 106m
    kube-system      aws-load-balancer-controller-6cf9bdbfdf-h7bzb               1/1     Running   0                 20m
    kube-system      aws-load-balancer-controller-6cf9bdbfdf-vfbrj               1/1     Running   0                 20m
    kube-system      aws-node-cvjmq                                              1/1     Running   0                 24h
    kube-system      aws-node-fw7zc                                              1/1     Running   0                 24h
    kube-system      aws-node-l7589                                              1/1     Running   0                 24h
    kube-system      aws-node-nll82                                              1/1     Running   0                 24h
    kube-system      aws-node-zhz8l                                              1/1     Running   0                 24h
    kube-system      coredns-7975d6fb9b-5sf7r                                    1/1     Running   0                 24h
    kube-system      coredns-7975d6fb9b-k78dz                                    1/1     Running   0                 24h
    kube-system      ebs-csi-controller-5cd4944c94-7jwlb                         6/6     Running   0                 24h
    kube-system      ebs-csi-controller-5cd4944c94-8tcsg                         6/6     Running   0                 24h
    kube-system      ebs-csi-node-66jmx                                          3/3     Running   0                 24h
    kube-system      ebs-csi-node-b2pw4                                          3/3     Running   0                 24h
    kube-system      ebs-csi-node-g4v9z                                          3/3     Running   0                 24h
    kube-system      ebs-csi-node-k7nvp                                          3/3     Running   0                 24h
    kube-system      ebs-csi-node-tfq9q                                          3/3     Running   0                 24h
    kube-system      kube-proxy-4x8vm                                            1/1     Running   0                 24h
    kube-system      kube-proxy-gtlpm                                            1/1     Running   0                 24h
    kube-system      kube-proxy-vfnbf                                            1/1     Running   0                 24h
    kube-system      kube-proxy-z9wdh                                            1/1     Running   0                 24h
    kube-system      kube-proxy-zzx9m                                            1/1     Running   0                 24h
    kube-system      metrics-server-7f4db5fd87-9n6dv                             1/1     Running   0                 23h
    kube-system      metrics-server-7f4db5fd87-t8wxg                             1/1     Running   0                 23h
    kube-system      metrics-server-7f4db5fd87-xcxlv                             1/1     Running   0                 23h
    team-burnham     burnham-66fccc4fb5-k4qtm                                    1/1     Running   0                 25m
    team-burnham     burnham-66fccc4fb5-rrf4j                                    1/1     Running   0                 25m
    team-burnham     burnham-66fccc4fb5-s9kbr                                    1/1     Running   0                 25m
    team-burnham     nginx-7d47cfdff7-lzdjb                                      1/1     Running   0                 25m
    team-riker       deployment-2048-6f7c78f959-h76rx                            1/1     Running   0                 25m
    team-riker       deployment-2048-6f7c78f959-skmrr                            1/1     Running   0                 25m
    team-riker       deployment-2048-6f7c78f959-tn9dw                            1/1     Running   0                 25m
    team-riker       guestbook-ui-c86c478bd-zg2z4                                1/1     Running   0                 25m
    ```

3. You can access the ArgoCD UI by running the following command:

    ```sh
    kubectl port-forward svc/argo-cd-argocd-server 8080:443 -n argocd
    ```

    Then, open your browser and navigate to `https://localhost:8080/`
    Username should be `admin`.

    The password will be the generated password by `random_password` resource, stored in AWS Secrets Manager.
    You can easily retrieve the password by running the following command:

    ```sh
    aws secretsmanager get-secret-value --secret-id <SECRET_NAME>--region <REGION>
    ```

    Replace `<SECRET_NAME>` with the name of the secret name, if you haven't changed it then it should be `argocd`, also, make sure to replace `<REGION>` with the region you are using.

    Pickup the the secret from the `SecretString`.

## Destroy

To teardown and remove the resources created in this example:

First, we need to ensure that the ArgoCD applications are properly cleaned up from the cluster, this can be achieved in multiple ways:

1) Disabling the `argocd_applications` configuration and running `terraform apply` again
2) Deleting the apps using `argocd` [cli](https://argo-cd.readthedocs.io/en/stable/user-guide/app_deletion/#deletion-using-argocd)
3) Deleting the apps using `kubectl` following [ArgoCD guidance](https://argo-cd.readthedocs.io/en/stable/user-guide/app_deletion/#deletion-using-kubectl)

Then you can start delete the terraform resources:
```sh
terraform destroy -target=module.eks_blueprints_kubernetes_addons -auto-approve
terraform destroy -target=module.eks -auto-approve
terraform destroy -auto-approve
````
