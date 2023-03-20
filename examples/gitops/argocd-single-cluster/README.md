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

    NAMESPACE            NAME                                                        READY   STATUS    RESTARTS   AGE
    argocd               argo-cd-argocd-application-controller-0                     1/1     Running   0          4h52m
    argocd               argo-cd-argocd-applicationset-controller-545ccfc6b5-5224c   1/1     Running   0          4h52m
    argocd               argo-cd-argocd-dex-server-778b56ccb6-2bf62                  1/1     Running   0          4h52m
    argocd               argo-cd-argocd-notifications-controller-6958fd7b5f-5wbsz    1/1     Running   0          4h52m
    argocd               argo-cd-argocd-repo-server-76bc99f6f9-bk5tm                 1/1     Running   0          4h52m
    argocd               argo-cd-argocd-repo-server-76bc99f6f9-w5bw4                 1/1     Running   0          4h52m
    argocd               argo-cd-argocd-server-7d94cb6fdd-rtxqb                      1/1     Running   0          4h52m
    argocd               argo-cd-argocd-server-7d94cb6fdd-zd9qb                      1/1     Running   0          4h52m
    argocd               argo-cd-redis-ha-haproxy-776d4dc75f-228h5                   1/1     Running   0          4h52m
    argocd               argo-cd-redis-ha-haproxy-776d4dc75f-kjghp                   1/1     Running   0          4h52m
    argocd               argo-cd-redis-ha-haproxy-776d4dc75f-q49q9                   1/1     Running   0          4h52m
    argocd               argo-cd-redis-ha-server-0                                   3/3     Running   0          4h52m
    argocd               argo-cd-redis-ha-server-1                                   3/3     Running   0          4h50m
    argocd               argo-cd-redis-ha-server-2                                   2/3     Running   0          4h49m
    aws-for-fluent-bit   aws-for-fluent-bit-b8pj8                                    1/1     Running   0          103s
    aws-for-fluent-bit   aws-for-fluent-bit-cxz6l                                    1/1     Running   0          52s
    aws-for-fluent-bit   aws-for-fluent-bit-k4hgv                                    1/1     Running   0          103s
    cert-manager         cert-manager-5988d49cb9-574m8                               1/1     Running   0          95s
    cert-manager         cert-manager-cainjector-9cc6bbc8b-x7wsg                     1/1     Running   0          95s
    cert-manager         cert-manager-webhook-678c96cb8f-kc9xw                       1/1     Running   0          95s
    geolocationapi       geolocationapi-7fc86654f-m45ng                              2/2     Running   0          84s
    geolocationapi       geolocationapi-7fc86654f-vfjfg                              2/2     Running   0          84s
    geordie              downstream0-6c4f5f86d9-pgfj4                                1/1     Running   0          89s
    geordie              downstream1-74966d8bd-6z5fz                                 1/1     Running   0          89s
    geordie              frontend-6bf488454-58qp2                                    1/1     Running   0          89s
    geordie              redis-server-5d46d8bc95-fcbzx                               1/1     Running   0          89s
    geordie              yelb-appserver-58cb77cdd5-6v7sv                             1/1     Running   0          89s
    geordie              yelb-db-79b954dbd6-7dr96                                    1/1     Running   0          90s
    geordie              yelb-ui-8457b656f6-skbmn                                    1/1     Running   0          89s
    karpenter            karpenter-6d57cdbbd6-2wrm9                                  1/1     Running   0          101s
    karpenter            karpenter-6d57cdbbd6-rcpwg                                  1/1     Running   0          101s
    kube-system          aws-load-balancer-controller-9584499dc-l75lw                1/1     Running   0          99s
    kube-system          aws-load-balancer-controller-9584499dc-s6r8p                1/1     Running   0          99s
    kube-system          aws-node-78gh5                                              1/1     Running   0          4h51m
    kube-system          aws-node-llgpn                                              1/1     Running   0          4h51m
    kube-system          aws-node-termination-handler-96cwm                          1/1     Running   0          101s
    kube-system          aws-node-termination-handler-qxm4j                          1/1     Running   0          52s
    kube-system          aws-node-termination-handler-xbqcv                          1/1     Running   0          101s
    kube-system          aws-node-zstqw                                              1/1     Running   0          52s
    kube-system          cluster-autoscaler-aws-cluster-autoscaler-54b58f76b-g4h54   1/1     Running   0          102s
    kube-system          coredns-55bb869c54-rd8lv                                    1/1     Running   0          4h53m
    kube-system          coredns-55bb869c54-x2mpz                                    1/1     Running   0          4h53m
    kube-system          ebs-csi-controller-77b447d695-8nrhs                         6/6     Running   0          4h53m
    kube-system          ebs-csi-controller-77b447d695-f4r2f                         6/6     Running   0          4h53m
    kube-system          ebs-csi-node-bm8ps                                          3/3     Running   0          52s
    kube-system          ebs-csi-node-jh5pp                                          3/3     Running   0          4h51m
    kube-system          ebs-csi-node-xd894                                          3/3     Running   0          4h51m
    kube-system          kube-proxy-65tmh                                            1/1     Running   0          4h51m
    kube-system          kube-proxy-jw2j4                                            1/1     Running   0          4h51m
    kube-system          kube-proxy-sdtsj                                            1/1     Running   0          52s
    kube-system          metrics-server-7cd9d56884-bqqhn                             1/1     Running   0          103s
    kube-system          metrics-server-7cd9d56884-v7pgf                             1/1     Running   0          103s
    kube-system          metrics-server-7cd9d56884-w9vgq                             1/1     Running   0          103s
    prometheus           prometheus-alertmanager-c4bffdb7b-vv4z7                     2/2     Running   0          76s
    prometheus           prometheus-kube-state-metrics-5c9f756cf8-dpqs9              1/1     Running   0          75s
    prometheus           prometheus-node-exporter-dfbdp                              1/1     Running   0          76s
    prometheus           prometheus-node-exporter-fs6tp                              1/1     Running   0          42s
    prometheus           prometheus-node-exporter-pb2lk                              1/1     Running   0          76s
    prometheus           prometheus-pushgateway-75c66bf7d8-5rr46                     1/1     Running   0          75s
    prometheus           prometheus-server-7d57c9697f-kkts8                          2/2     Running   0          75s
    team-burnham         burnham-558f4c4f8b-9kpbf                                    1/1     Running   0          94s
    team-burnham         burnham-558f4c4f8b-9l6gh                                    1/1     Running   0          94s
    team-burnham         burnham-558f4c4f8b-bq7zs                                    1/1     Running   0          94s
    team-burnham         nginx-74f76956db-xjgpv                                      1/1     Running   0          94s
    team-riker           deployment-2048-cfc677879-4lkjh                             1/1     Running   0          94s
    team-riker           deployment-2048-cfc677879-6bzrr                             1/1     Running   0          94s
    team-riker           deployment-2048-cfc677879-6zmmr                             1/1     Running   0          94s
    team-riker           guestbook-ui-b9cfb7875-nl5dw                                1/1     Running   0          94s
    vpa                  vpa-recommender-746bf6945b-gmjts                            1/1     Running   0          98s
    vpa                  vpa-updater-56ff87bd4c-4s2p2                                1/1     Running   0          98s
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
    aws secretsmanager get-secret-value --secret-id <SECRET_NAME> --region <REGION>
    ```

    Replace `<SECRET_NAME>` with the name of the secret name (example argocd), if you haven't changed it then it should be `argocd`, also, make sure to replace `<REGION>` with the region you are using.

    Pickup the the secret from the `SecretString`.

## Destroy

To teardown and remove the resources created in this example:

First, we need to ensure that the ArgoCD applications are properly cleaned up from the cluster, this can be achieved in multiple ways:

1) Disabling the `argocd_applications` configuration and running `terraform apply` again
2) Deleting the apps using `argocd` [cli](https://argo-cd.readthedocs.io/en/stable/user-guide/app_deletion/#deletion-using-argocd)
3) Deleting the apps using `kubectl` following [ArgoCD guidance](https://argo-cd.readthedocs.io/en/stable/user-guide/app_deletion/#deletion-using-kubectl)

Then you can start delete the terraform resources:
```sh
./destroy.sh
```
