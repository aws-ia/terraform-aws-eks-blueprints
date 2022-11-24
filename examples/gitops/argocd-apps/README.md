# EKS Cluster with ArgoCD

This example shows how to install argocd -application to
ArgoCD from the official or any other repository.
To better understand how ArgoCD works with EKS Blueprints, read the EKS Blueprints ArgoCD [Documentation](https://aws-ia.github.io/terraform-aws-eks-blueprints/latest/add-ons/argocd/)

## Reference Documentation


- [EKS Blueprints Add-ons Repo](https://github.com/aws-samples/eks-blueprints-add-ons)


## Prerequisites

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

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the deployment.

1. Run `update-kubeconfig` command:

    ```sh
    aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
    ```

2. List out the pods running currently:

    ```sh
    kubectl get pods -A

    NAMESPACE            NAME                                                 READY   STATUS    RESTARTS   AGE
    argocd        argo-cd-argocd-application-controller-0                     1/1     Running   0          18m
    argocd        argo-cd-argocd-applicationset-controller-68854c9dd5-9ndnx   1/1     Running   0          18m
    argocd        argo-cd-argocd-dex-server-786d589d48-pf298                  1/1     Running   0          18m
    argocd        argo-cd-argocd-notifications-controller-5c6dccfbd7-fh4ch    1/1     Running   0          18m
    argocd        argo-cd-argocd-repo-server-7f4699495c-8m5px                 1/1     Running   0          18m
    argocd        argo-cd-argocd-repo-server-7f4699495c-rwqsg                 1/1     Running   0          18m
    argocd        argo-cd-argocd-server-b77c6f499-4t2df                       1/1     Running   0          18m
    argocd        argo-cd-argocd-server-b77c6f499-7l244                       1/1     Running   0          18m
    argocd        argo-cd-redis-ha-haproxy-6f9889946f-4jzx4                   1/1     Running   0          18m
    argocd        argo-cd-redis-ha-haproxy-6f9889946f-98tnb                   1/1     Running   0          18m
    argocd        argo-cd-redis-ha-haproxy-6f9889946f-kp2rb                   1/1     Running   0          18m
    argocd        argo-cd-redis-ha-server-0                                   4/4     Running   0          18m
    argocd        argo-cd-redis-ha-server-1                                   4/4     Running   0          15m
    argocd        argo-cd-redis-ha-server-2                                   4/4     Running   0          14m
    kube-system   aws-node-6cw9m                                              1/1     Running   0          17m
    kube-system   aws-node-94c5q                                              1/1     Running   0          17m
    kube-system   aws-node-mlrh9                                              1/1     Running   0          17m
    kube-system   coredns-5f77864c74-ds6nh                                    1/1     Running   0          21m
    kube-system   coredns-5f77864c74-n96lw                                    1/1     Running   0          21m
    kube-system   kube-proxy-jdg29                                            1/1     Running   0          17m
    kube-system   kube-proxy-nbdtr                                            1/1     Running   0          17m
    kube-system   kube-proxy-qh2zr                                            1/1     Running   0          17m
    ```

3. You can access the ArgoCD UI by running the following command:

    ```sh
    kubectl port-forward svc/argo-cd-argocd-server 8080:443 -n argocd
    ```

    Then, open your browser and navigate to `https://localhost:8080/`
    Username should be `admin`.


    You can easily retrieve the password by running the following command:

    ```sh
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```


## Destroy

To remove the resources created in this example you can use this command:


```sh
terraform destroy -auto-approve
````
