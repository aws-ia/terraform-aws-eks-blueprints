+++
title = "Cognito, RDS, and S3"
description = "Deploying Kubeflow with Amazon Cognito, RDS and S3"
weight = 60
+++

This guide describes how to deploy Kubeflow on Amazon EKS using Cognito for your identity provider, RDS for your database, and S3 for your artifact storage.

## 1. Prerequisites
Refer to the [general prerequisites guide]({{< ref "/docs/deployment/prerequisites.md" >}}) and the [RDS and S3 setup guide]({{< ref "/docs/deployment/rds-s3/guide.md" >}}) in order to:
1. Install the CLI tools
2. Clone the repositories
3. Create an EKS cluster
4. Create an S3 Bucket
5. Create an RDS Instance
6. Configure AWS Secrets for RDS and S3
7. Install AWS Secrets and Kubernetes Secrets Store CSI driver
8. Configure an RDS endpoint and an S3 bucket name for Kubeflow Pipelines

## Configure Custom Domain and Cognito

1. Follow the [Cognito setup guide]({{< ref "/docs/deployment/cognito/guide.md" >}}) from [Section 1.0 (Custom domain)]({{< ref "/docs/deployment/cognito/guide.md#10-custom-domain-and-certificates" >}}) up to [Section 3.0 (Configure ingress)]({{< ref "/docs/deployment/cognito/guide.md#30-configure-ingress" >}}) in order to:
    1. Create a custom domain
    1. Create TLS certificates for the domain
    1. Create a Cognito Userpool
    1. Configure Ingress
2. Deploy Kubeflow. Choose one of the two options to deploy kubeflow:
    1. **[Option 1]** Install with a single command:
        ```sh
        while ! kustomize build deployments/cognito-rds-s3 | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done
        ```
    1. **[Option 2]** Install individual components:
        ```sh
        # Kubeflow namespace
        kustomize build upstream/common/kubeflow-namespace/base | kubectl apply -f -
        
        # Kubeflow Roles
        kustomize build upstream/common/kubeflow-roles/base | kubectl apply -f -
        
        # Istio
        kustomize build upstream/common/istio-1-11/istio-crds/base | kubectl apply -f -
        kustomize build upstream/common/istio-1-11/istio-namespace/base | kubectl apply -f -
        kustomize build upstream/common/istio-1-11/istio-install/base | kubectl apply -f -

        # Cert-Manager
        kustomize build upstream/common/cert-manager/cert-manager/base | kubectl apply -f -
        kustomize build upstream/common/cert-manager/kubeflow-issuer/base | kubectl apply -f -
        
        # KNative
        kustomize build upstream/common/knative/knative-serving/overlays/gateways | kubectl apply -f -
        kustomize build upstream/common/knative/knative-eventing/base | kubectl apply -f -
        kustomize build upstream/common/istio-1-11/cluster-local-gateway/base | kubectl apply -f -
        
        # Kubeflow Istio Resources
        kustomize build upstream/common/istio-1-11/kubeflow-istio-resources/base | kubectl apply -f -
        
        # KServe
        kustomize build awsconfigs/apps/kserve | kubectl apply -f -
        kustomize build upstream/contrib/kserve/models-web-app/overlays/kubeflow | kubectl apply -f -

        # KFServing -  This is an optional component and required only if you are not ready to migrate to KServe. We recommend migrating to KServe as soon as possible
        kustomize build upstream/apps/kfserving/upstream/overlays/kubeflow | kubectl apply -f -
        
        # Central Dashboard
        kustomize build upstream/apps/centraldashboard/upstream/overlays/kserve | kubectl apply -f -
        
        # Notebooks
        kustomize build upstream/apps/jupyter/notebook-controller/upstream/overlays/kubeflow | kubectl apply -f -
        kustomize build awsconfigs/apps/jupyter-web-app | kubectl apply -f -
        
        # Admission Webhook
        kustomize build upstream/apps/admission-webhook/upstream/overlays/cert-manager | kubectl apply -f -
        
        # Profiles + KFAM
        kustomize build upstream/apps/profiles/upstream/overlays/kubeflow | kubectl apply -f -
        
        # Volumes Web App
        kustomize build upstream/apps/volumes-web-app/upstream/overlays/istio | kubectl apply -f -
        
        # Tensorboard
        kustomize build upstream/apps/tensorboard/tensorboards-web-app/upstream/overlays/istio | kubectl apply -f -
        kustomize build upstream/apps/tensorboard/tensorboard-controller/upstream/overlays/kubeflow | kubectl apply -f -

        # Training Operator
        kustomize build upstream/apps/training-operator/upstream/overlays/kubeflow | kubectl apply -f -

        # AWS Telemetry - This is an optional component. See usage tracking documentation for more information.
        kustomize build awsconfigs/common/aws-telemetry | kubectl apply -f -

        # AWS Secret Manager
        kustomize build awsconfigs/common/aws-secrets-manager | kubectl apply -f -

        # Kubeflow Pipelines
        kustomize build awsconfigs/apps/pipeline | kubectl apply -f -

        # Katib
        kustomize build awsconfigs/apps/katib-external-db-with-kubeflow | kubectl apply -f -

        # Configured for AWS Cognito
        
        # Ingress
        kustomize build awsconfigs/common/istio-ingress/overlays/cognito | kubectl apply -f -

        # ALB controller
        kustomize build awsconfigs/common/aws-alb-ingress-controller/base | kubectl apply -f -

        # Authservice
        kustomize build awsconfigs/common/aws-authservice/base | kubectl apply -f -        
        ```
1. Follow the rest of the Cognito guide from [section 5.0 (Updating the domain with ALB address)]({{< ref "/docs/deployment/cognito/guide.md#50-updating-the-domain-with-alb-address" >}}) in order to:
    1. Add/Update the DNS records in a custom domain with the ALB address
    1. Create a user in a Cognito user pool
    1. Create a profile for the user from the user pool
    1. Connect to the central dashboard
