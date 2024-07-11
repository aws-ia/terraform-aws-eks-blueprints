# ECR Pull Through Cache

This pattern demonstrates how to set up ECR cache pull-through for public images. The Terraform code creates four cache pull-through rules for public image repositories: Docker, Kubernetes, Quay, and ECR. It also configures basic scanning on push for all repositories and includes a creation template. Additionally, it configures the EC2 node role with permissions to pull through images. The setup then installs ALB Controller, Metrics Server, Gatekeeper, ArgoCD, and Prometheus Operator, with their respective Helm charts configured in the values files to pull images through the pull-through cache.

## Deploy
Follow the instructions [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

```
terraform init
terraform apply -var='docker_secret={"username":"your-docker-username", "accessToken":"your-docker-password"}'
```

## Validate
Validate the pull trough cache rules connectivity:
```
for i in docker-hub ecr k8s quay ; do aws ecr validate-pull-through-cache-rule --ecr-repository-prefix $i --region us-east-1; done
```
Expected output:
```
{
    "ecrRepositoryPrefix": "docker-hub",
    "registryId": "111122223333",
    "upstreamRegistryUrl": "registry-1.docker.io",
    "credentialArn": "arn:aws:secretsmanager:us-east-1:111122223333:secret:ecr-pullthroughcache/docker-111XXX",
    "isValid": true,
    "failure": ""
}
{
    "ecrRepositoryPrefix": "ecr",
    "registryId": "111122223333",
    "upstreamRegistryUrl": "public.ecr.aws",
    "isValid": true,
    "failure": ""
}
{
    "ecrRepositoryPrefix": "k8s",
    "registryId": "111122223333",
    "upstreamRegistryUrl": "registry.k8s.io",
    "isValid": true,
    "failure": ""
}
{
    "ecrRepositoryPrefix": "quay",
    "registryId": "111122223333",
    "upstreamRegistryUrl": "quay.io",
    "isValid": true,
    "failure": ""
}
```
Validate pods are pulling the images and in Running state:
```
kubectl get pods -A
```
Expected output:
```
NAMESPACE               NAME                                                        READY   STATUS      RESTARTS   AGE
argocd                  argo-cd-argocd-application-controller-0                     1/1     Running     0          2m26s
argocd                  argo-cd-argocd-applicationset-controller-78ccd75cfb-7zfs5   1/1     Running     0          2m28s
argocd                  argo-cd-argocd-notifications-controller-8cc5c5578-r7g8s     1/1     Running     0          2m27s
argocd                  argo-cd-argocd-redis-secret-init-x55l4                      0/1     Completed   0          2m43s
argocd                  argo-cd-argocd-repo-server-5d64dff78d-wg7xm                 1/1     Running     0          2m27s
argocd                  argo-cd-argocd-server-7b7974dfbf-dl7z6                      1/1     Running     0          2m27s
argocd                  argo-cd-redis-ha-haproxy-78456c586d-4jxxh                   1/1     Running     0          2m28s
argocd                  argo-cd-redis-ha-haproxy-78456c586d-cp7sw                   1/1     Running     0          2m28s
argocd                  argo-cd-redis-ha-haproxy-78456c586d-hpfrl                   1/1     Running     0          2m28s
argocd                  argo-cd-redis-ha-server-0                                   3/3     Running     0          2m26s
argocd                  argo-cd-redis-ha-server-1                                   3/3     Running     0          71s
argocd                  argo-cd-redis-ha-server-2                                   1/3     Running     0          11s
gatekeeper-system       gatekeeper-audit-85cc8756cf-zx5xn                           1/1     Running     0          53s
gatekeeper-system       gatekeeper-controller-manager-568c7544d-6s5hw               1/1     Running     0          53s
gatekeeper-system       gatekeeper-controller-manager-568c7544d-gtq88               1/1     Running     0          53s
gatekeeper-system       gatekeeper-controller-manager-568c7544d-nz5g4               1/1     Running     0          53s
kube-prometheus-stack   alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running     0          9m33s
kube-prometheus-stack   kube-prometheus-stack-grafana-76f988cb8c-dbsc5              3/3     Running     0          9m38s
kube-prometheus-stack   kube-prometheus-stack-kube-state-metrics-57c4f8df9c-td9tp   1/1     Running     0          9m38s
kube-prometheus-stack   kube-prometheus-stack-operator-77695dc8-z4qm2               1/1     Running     0          9m38s
kube-prometheus-stack   kube-prometheus-stack-prometheus-node-exporter-dp9nl        1/1     Running     0          9m38s
kube-prometheus-stack   kube-prometheus-stack-prometheus-node-exporter-gsp24        1/1     Running     0          9m38s
kube-prometheus-stack   kube-prometheus-stack-prometheus-node-exporter-vgl4r        1/1     Running     0          9m38s
kube-prometheus-stack   prometheus-kube-prometheus-stack-prometheus-0               2/2     Running     0          9m33s
kube-system             aws-load-balancer-controller-7cb475c856-7rgwm               1/1     Running     0          10m
kube-system             aws-load-balancer-controller-7cb475c856-qh2v6               1/1     Running     0          10m
kube-system             aws-node-4v2c5                                              2/2     Running     0          12m
kube-system             aws-node-lgcsc                                              2/2     Running     0          12m
kube-system             aws-node-lprv6                                              2/2     Running     0          12m
kube-system             coredns-86d5d9b668-gw2c7                                    1/1     Running     0          11m
kube-system             coredns-86d5d9b668-qtfxm                                    1/1     Running     0          11m
kube-system             ebs-csi-controller-57547c649b-bm4lv                         6/6     Running     0          11m
kube-system             ebs-csi-controller-57547c649b-q68b6                         6/6     Running     0          11m
kube-system             ebs-csi-node-7shn9                                          3/3     Running     0          11m
kube-system             ebs-csi-node-f25zz                                          3/3     Running     0          11m
kube-system             ebs-csi-node-rdq6v                                          3/3     Running     0          11m
kube-system             kube-proxy-7mzgr                                            1/1     Running     0          12m
kube-system             kube-proxy-ksz6w                                            1/1     Running     0          12m
kube-system             kube-proxy-w6x2s                                            1/1     Running     0          12m
kube-system             metrics-server-5d6489d58d-pbrxv                             1/1     Running     0          10m
```

## Destroy
ECR repositories are automatically created via pull through cache and can be deleted using the following command.
NOTE: This commands deletes all the ecr repositories in a region.
```
for REPO in $(aws ecr describe-repositories --query 'repositories[].repositoryName' --output text); do aws ecr delete-repository --repository-name $REPO --force ; done
```  
{%
   include-markdown "../../docs/_partials/destroy.md"
%}
