# EKS Cluster with ArgoCD

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
    aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
    ```

2. List out the pods running currently:

    ```sh
    kubectl get pods -A

    NAMESPACE            NAME                                                         READY   STATUS    RESTARTS   AGE
    argo-rollouts        argo-rollouts-5656b86459-jgssp                               1/1     Running   0          6m59s
    argo-rollouts        argo-rollouts-5656b86459-kncxg                               1/1     Running   0          6m59s
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
    aws-for-fluent-bit   aws-for-fluent-bit-7gwzd                                     1/1     Running   0          7m10s
    aws-for-fluent-bit   aws-for-fluent-bit-9gzqw                                     1/1     Running   0          7m10s
    aws-for-fluent-bit   aws-for-fluent-bit-csrgh                                     1/1     Running   0          7m10s
    aws-for-fluent-bit   aws-for-fluent-bit-h9vtm                                     1/1     Running   0          7m10s
    aws-for-fluent-bit   aws-for-fluent-bit-p4bmj                                     1/1     Running   0          7m10s
    cert-manager         cert-manager-765c5d7777-k7jkk                                1/1     Running   0          7m6s
    cert-manager         cert-manager-cainjector-6bc9d758b-kt8dm                      1/1     Running   0          7m6s
    cert-manager         cert-manager-webhook-586d45d5ff-szkc7                        1/1     Running   0          7m6s
    geolocationapi       geolocationapi-fbb6987f8-d22qv                               2/2     Running   0          6m15s
    geolocationapi       geolocationapi-fbb6987f8-fqshh                               2/2     Running   0          6m15s
    karpenter            karpenter-5d65d77779-nnsjp                                   2/2     Running   0          7m42s
    keda                 keda-operator-676b4b8d8c-5bjmt                               1/1     Running   0          7m16s
    keda                 keda-operator-metrics-apiserver-5d679f968c-jkhz8             1/1     Running   0          7m16s
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
    prometheus           prometheus-alertmanager-758597fd7-pntlj                      2/2     Running   0          7m18s
    prometheus           prometheus-kube-state-metrics-5fd8648d78-w48p2               1/1     Running   0          7m18s
    prometheus           prometheus-node-exporter-7wr8x                               1/1     Running   0          7m18s
    prometheus           prometheus-node-exporter-9hjzw                               1/1     Running   0          7m19s
    prometheus           prometheus-node-exporter-kjsxt                               1/1     Running   0          7m18s
    prometheus           prometheus-node-exporter-mr9cx                               1/1     Running   0          7m19s
    prometheus           prometheus-node-exporter-qmm58                               1/1     Running   0          7m19s
    prometheus           prometheus-pushgateway-8696df5474-cv59q                      1/1     Running   0          7m18s
    prometheus           prometheus-server-58c58c58cc-n4242                           2/2     Running   0          7m18s
    team-burnham         nginx-66b6c48dd5-nnp9l                                       1/1     Running   0          7m39s
    team-riker           guestbook-ui-6847557d79-lrms2                                1/1     Running   0          7m39s
    traefik              traefik-b9955f58-pc2zp                                       1/1     Running   0          7m4s
    vpa                  vpa-recommender-554f56647b-lcz9w                             1/1     Running   0          7m35s
    vpa                  vpa-updater-67d6c5c7cf-b9hw4                                 1/1     Running   0          7m35s
    yunikorn             yunikorn-scheduler-5c446fcc89-lcmmm                          2/2     Running   0          7m28s
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
terraform destroy -target=module.eks_blueprints -auto-approve
terraform destroy -auto-approve
````
