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

    NAMESPACE            NAME                                                         READY   STATUS    RESTARTS   AGE
    argocd               argo-cd-argocd-application-controller-0                      1/1     Running   0          15m
    argocd               argo-cd-argocd-applicationset-controller-9f66b8d6b-bnvqk     1/1     Running   0          15m
    argocd               argo-cd-argocd-dex-server-66c5769c46-kxns4                   1/1     Running   0          15m
    argocd               argo-cd-argocd-notifications-controller-74c78485d-fgh4w      1/1     Running   0          15m
    argocd               argo-cd-argocd-repo-server-77b8c98d6f-kcq6j                  1/1     Running   0          15m
    argocd               argo-cd-argocd-repo-server-77b8c98d6f-mt7nf                  1/1     Running   0          15m
    argocd               argo-cd-argocd-server-849d775f7b-t2crt                       1/1     Running   0          15m
    argocd               argo-cd-argocd-server-849d775f7b-vnwtq                       1/1     Running   0          15m
    argocd               argo-cd-redis-ha-haproxy-578979d984-5chwx                    1/1     Running   0          15m
    argocd               argo-cd-redis-ha-haproxy-578979d984-74qdg                    1/1     Running   0          15m
    argocd               argo-cd-redis-ha-haproxy-578979d984-9dwf2                    1/1     Running   0          15m
    argocd               argo-cd-redis-ha-server-0                                    4/4     Running   0          15m
    argocd               argo-cd-redis-ha-server-1                                    4/4     Running   0          12m
    argocd               argo-cd-redis-ha-server-2                                    4/4     Running   0          11m
    kube-system          aws-node-66dl8                                               1/1     Running   0          14m
    kube-system          aws-node-7fgks                                               1/1     Running   0          14m
    kube-system          aws-node-828t9                                               1/1     Running   0          14m
    kube-system          aws-node-k7phx                                               1/1     Running   0          14m
    kube-system          aws-node-rptsc                                               1/1     Running   0          14m
    kube-system          cluster-autoscaler-aws-cluster-autoscaler-74456d5cc9-hfqlz   1/1     Running   0          7m24s
    kube-system          coredns-657694c6f4-kp6sm                                     1/1     Running   0          19m
    kube-system          coredns-657694c6f4-wcqh2                                     1/1     Running   0          19m
    kube-system          kube-proxy-6zwcj                                             1/1     Running   0          14m
    kube-system          kube-proxy-9kkg7                                             1/1     Running   0          14m
    kube-system          kube-proxy-q9bgv                                             1/1     Running   0          14m
    kube-system          kube-proxy-rzndg                                             1/1     Running   0          14m
    kube-system          kube-proxy-w86mz                                             1/1     Running   0          14m
    kube-system          metrics-server-694d47d564-psr4s                              1/1     Running   0          6m37s
    
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

To remove the resources created in this example you can use this command:


```sh
terraform destroy -auto-approve
````
