+++
title = "Automated Deployment Guide"
description = "Deploying Kubeflow with AWS Cognito as identity provider using setup scripts"
weight = 10
+++

This guide describes how to deploy Kubeflow on AWS EKS using Cognito as identity provider. Kubeflow uses Istio to manage internal traffic. In this guide we will be creating an Ingress to manage external traffic to the Kubernetes services and an Application Load Balancer (ALB) to provide public DNS and enable TLS authentication at the load balancer. We will also be creating a custom domain to host Kubeflow since certificates (needed for TLS) for ALB's public DNS names are not supported.

## Prerequisites

This guide assumes you have Python 3.8 installed and that you have completed the [prerequisites]({{< ref "/docs/deployment/prerequisites.md" >}}).

## Create required resources and deploy Kubeflow

1. The following steps automate [section 1.0(Custom domain and certificates)]({{< ref "/docs/deployment/cognito/guide.md#10-custom-domain-and-certificates" >}}) (creating a custom domain to host Kubeflow and TLS certificates for the domain), [section 2.0(Cognito user pool)]({{< ref "/docs/deployment/cognito/guide.md#20-cognito-user-pool" >}}) (creating a Cognito Userpool used for user authentication) and[section 3.0(Configure Ingress)]({{< ref "/docs/deployment/cognito/guide.md#30-configure-ingress" >}}) (configuring ingress and load balancer controller manifests) of the cognito guide.
    1. Install dependencies for the scripts
        ```sh
        pip install -r tests/e2e/requirements.txt
        ```
    1. Substitute values in `tests/e2e/utils/cognito_bootstrap/config.yaml`.
        1. Registed root domain in `route53.rootDomain.name`. Lets assume this domain is `example.com`
            1. If your domain is managed in route53, enter the Hosted zone ID found under Hosted zone details in `route53.rootDomain.hostedZoneId`. Skip this step if your domain is managed by other domain provider.
        1. Name of the sudomain you want to host Kubeflow (e.g. `platform.example.com`) in `route53.subDomain.name`. Please read [this section]({{< ref "/docs/deployment/add-ons/load-balancer/guide.md#create-domain-and-certificates" >}}) to understand why we use a subdomain.
        1. Cluster name and region where kubeflow will be deployed in `cluster.name` and `cluster.region` (e.g. us-west-2) respectively.
        1. Name of cognito userpool in `cognitoUserpool.name` e.g. kubeflow-users.
        1. The config file will look something like:
            1. ```yaml
                cognitoUserpool:
                    name: kubeflow-users
                cluster:
                    name: kube-eks-cluster
                    region: us-west-2
                route53:
                    rootDomain:
                        hostedZoneId: XXXX
                        name: example.com
                    subDomain:
                        name: platform.example.com
                ```
    1. Run the script to create the resources
        1. ```sh
            cd tests/e2e
            PYTHONPATH=.. python utils/cognito_bootstrap/cognito_pre_deployment.py
            cd -
            ```
    1. The script will update the config file with the resource names/ids/ARNs it created. It will look something like:
        1. ```yaml
            cognitoUserpool:
                ARN: arn:aws:cognito-idp:us-west-2:123456789012:userpool/us-west-2_yasI9dbxF
                appClientId: 5jmk7ljl2a74jk3n0a0fvj3l31
                domainAliasTarget: xxxxxxxxxx.cloudfront.net
                domain: auth.platform.example.com
                name: kubeflow-users
            kubeflow:
                alb:
                    serviceAccount:
                        name: alb-ingress-controller
                        namespace: kubeflow
                        policyArn: arn:aws:iam::123456789012:policy/alb_ingress_controller_kube-eks-clusterxxx
            cluster:
                name: kube-eks-cluster
                region: us-west-2
            route53:
                rootDomain:
                    certARN: arn:aws:acm:us-east-1:123456789012:certificate/9d8c4bbc-3b02-4a48-8c7d-d91441c6e5af
                    hostedZoneId: XXXXX
                    name: example.com
                subDomain:
                    us-west-2-certARN: arn:aws:acm:us-west-2:123456789012:certificate/d1d7b641c238-4bc7-f525-b7bf-373cc726
                    hostedZoneId: XXXXX
                    name: platform.example.com
                    us-east-1-certARN: arn:aws:acm:us-east-1:123456789012:certificate/373cc726-f525-4bc7-b7bf-d1d7b641c238
            ```

1. Install Kubeflow using the following command:
   ```bash
    while ! kustomize build deployments/cognito | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done
    ```

1. Updating the domain with ALB address
    1. Check if ALB is provisioned. It takes around 3-5 minutes
        1. ```sh
            kubectl get ingress -n istio-system
            Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
            NAME            CLASS    HOSTS   ADDRESS                                                              PORTS   AGE
            istio-ingress   <none>   *       k8s-istiosys-istioing-xxxxxx-110050202.us-west-2.elb.amazonaws.com   80      15d
            ```
        2. If `ADDRESS` is empty after a few minutes, check the logs of alb-ingress-controller by following [this guide]({{< ref "/docs/troubleshooting-aws.md#alb-fails-to-provision" >}})
    1. Substitute the ALB address under `kubeflow.alb.dns` in `tests/e2e/utils/cognito_bootstrap/config.yaml`. The kubeflow section of the config file will look like:
        1. ```yaml
            kubeflow:
                alb:
                    dns: ebde55ee-istiosystem-istio-2af2-1100502020.us-west-2.elb.amazonaws.com
                    serviceAccount:
                        name: alb-ingress-controller
                        policyArn: arn:aws:iam::123456789012:policy/alb_ingress_controller_kube-eks-clusterxxx
            ```
    1. Run the following script to update the subdomain with ALB address
        1. ```sh
            cd tests/e2e
            PYTHONPATH=.. python utils/cognito_bootstrap/cognito_post_deployment.py
            cd -
            ```
1. Follow the rest of the cognito guide from [section 6.0(Connecting to central dashboard)]({{< ref "/docs/deployment/cognito/guide.md#60-connecting-to-central-dashboard" >}}) to:
    1. Create a user in Cognito user pool
    1. Create a profile for the user from the user pool
    1. Connect to the central dashboard

## Uninstall Kubeflow
> Note: Delete all the resources you might have created in your profile namespaces before running these steps.
1. Run the following commands to delete the profiles, ingress and corresponding ingress managed load balancer
   ```bash
    kubectl delete profiles --all
    kubectl delete ingress -n istio-system istio-ingress
    ```
1. Delete the kubeflow deployment
   ```bash
    kustomize build deployments/cognito | kubectl delete -f -
    ```
1. To delete the rest of resources(subdomain, certificates etc.), run the following commands from the root of your repository:
    > Note: Make sure that you have the configuration file created by the script in `tests/e2e/utils/cognito_bootstrap/config.yaml`. If you did not use the script, plug in the name, ARN, or ID of the resources that you created in a yaml file in `tests/e2e/utils/cognito_bootstrap/config.yaml` by referring to the following sample:
    - Sample config file:
    ```yaml
    cognitoUserpool:
        ARN: arn:aws:cognito-idp:us-west-2:123456789012:userpool/us-west-2_yasI9dbxF
        appClientId: 5jmk7ljl2a74jk3n0a0fvj3l31
        domainAliasTarget: xxxxxxxxxx.cloudfront.net
        domain: auth.platform.example.com
        name: kubeflow-users
    kubeflow:
        alb:
            serviceAccount:
                name: alb-ingress-controller
                namespace: kubeflow
                policyArn: arn:aws:iam::123456789012:policy/alb_ingress_controller_kube-eks-clusterxxx
    cluster:  
        name: kube-eks-cluster
        region: us-west-2
    route53:
        rootDomain:
            certARN: arn:aws:acm:us-east-1:123456789012:certificate/9d8c4bbc-3b02-4a48-8c7d-d91441c6e5af
            hostedZoneId: XXXXX
            name: example.com
        subDomain:
            us-west-2-certARN: arn:aws:acm:us-west-2:123456789012:certificate/d1d7b641c238-4bc7-f525-b7bf-373cc726
            hostedZoneId: XXXXX
            name: platform.example.com
            us-east-1-certARN: arn:aws:acm:us-east-1:123456789012:certificate/373cc726-f525-4bc7-b7bf-d1d7b641c238
    ```
    - Run the following command to install the script dependencies and delete the resources:
    > Note: You can rerun the script incase some resources fail to delete
    ```bash
    cd tests/e2e
    pip install -r requirements.txt
    PYTHONPATH=.. python utils/cognito_bootstrap/cognito_resources_cleanup.py
    cd -
    ```
