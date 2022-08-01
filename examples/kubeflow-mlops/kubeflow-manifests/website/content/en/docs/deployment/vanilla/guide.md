+++
title = "Vanilla Installation"
description = "Deploy Kubeflow on AWS using Amazon Elastic Kubernetes Service (EKS)"
weight = 30
+++

# Deploying Kubeflow on EKS

This guide describes how to deploy Kubeflow on AWS EKS. This vanilla version has minimal changes to the upstream Kubeflow manifests.

## Prerequisites

Be sure that you have satisfied the [installation prerequisites]({{< ref "../prerequisites.md" >}}) before working through this guide.

### Build Manifests and install Kubeflow

There two options for installing Kubeflow official components and common services with kustomize.

1. Single-command installation of all components under `apps` and `common`
2. Multi-command, individual components installation for `apps` and `common`

Option 1 targets ease of deployment for end users. \
Option 2 targets customization and ability to pick and choose individual components.

> Warning: In both options, we use a default email (`user@example.com`) and password (`12341234`). For any production Kubeflow deployment, you should change the default password by following [the relevant section](#change-default-user-password).

---
**NOTE**

`kubectl apply` commands may fail on the first try. This is inherent in how Kubernetes and `kubectl` work (e.g., CR must be created after CRD becomes ready). The solution is to re-run the command until it succeeds. For the single-line command, we have included a bash one-liner to retry the command.

---

### Install with a single command

You can install all Kubeflow official components (residing under `apps`) and all common services (residing under `common`) using the following command:

```sh
while ! kustomize build deployments/vanilla | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done
```

Once everything is installed successfully, you can access the Kubeflow Central Dashboard [by logging into your cluster](#connect-to-your-kubeflow-cluster).

You can now start experimenting and running your end-to-end ML workflows with Kubeflow!

### Install individual components

This section lists an installation command for each official Kubeflow component (under `apps`) and each common service (under `common`) using just `kubectl` and `kustomize`.

If you run all of the following commands, the end result is the same as installing everything through the [single command installation](#install-with-a-single-command). 

The purpose of this section is to:
- Provide a description of each component and insight on how it gets installed.
- Enable the user or distribution owner to pick and choose only the components they need.

#### cert-manager

`cert-manager` is used by many Kubeflow components to provide certificates for
admission webhooks.

Install `cert-manager`:

```sh
kustomize build upstream/common/cert-manager/cert-manager/base | kubectl apply -f -
kustomize build upstream/common/cert-manager/kubeflow-issuer/base | kubectl apply -f -
```

#### Istio

Istio is used by many Kubeflow components to secure their traffic, enforce
network authorization, and implement routing policies.

Install Istio:

```sh
kustomize build upstream/common/istio-1-11/istio-crds/base | kubectl apply -f -
kustomize build upstream/common/istio-1-11/istio-namespace/base | kubectl apply -f -
kustomize build upstream/common/istio-1-11/istio-install/base | kubectl apply -f -
```

#### Dex

Dex is an OpenID Connect Identity (OIDC) with multiple authentication backends. In this default installation, it includes a static user with the email `user@example.com`. By default, the user's password is `12341234`. For any production Kubeflow deployment, you should change the default password by following the steps in [Change default user password](#change-default-user-password).

Install Dex:

```sh
kustomize build upstream/common/dex/overlays/istio | kubectl apply -f -
```

#### OIDC AuthService

The OIDC AuthService extends your Istio Ingress-Gateway capabilities to be able to function as an OIDC client:

Install OIDC AuthService:

```sh
kustomize build upstream/common/oidc-authservice/base | kubectl apply -f -
```

#### Knative

Knative is used by the KServe/KFServing official Kubeflow component.

Install Knative Serving:

```sh
kustomize build upstream/common/knative/knative-serving/base | kubectl apply -f -
kustomize build upstream/common/istio-1-11/cluster-local-gateway/base | kubectl apply -f -
```

Optionally, you can install Knative Eventing, which can be used for inference request logging.

Install Knative Eventing:

```sh
kustomize build upstream/common/knative/knative-eventing/base | kubectl apply -f -
```

#### Kubeflow namespace

Create the namespace where the Kubeflow components will live. This namespace
is named `kubeflow`.

Install the `kubeflow` namespace:

```sh
kustomize build upstream/common/kubeflow-namespace/base | kubectl apply -f -
```

#### Kubeflow Roles

Create the Kubeflow ClusterRoles `kubeflow-view`, `kubeflow-edit`, and
`kubeflow-admin`. Kubeflow components aggregate permissions to these
ClusterRoles.

Install Kubeflow roles:

```sh
kustomize build upstream/common/kubeflow-roles/base | kubectl apply -f -
```

#### Kubeflow Istio Resources

Create the Istio resources needed by Kubeflow. This kustomization currently
creates an Istio Gateway named `kubeflow-gateway` in the `kubeflow` namespace.
If you want to install with your own Istio, then you need this kustomization as
well.

Install Istio resources:

```sh
kustomize build upstream/common/istio-1-11/kubeflow-istio-resources/base | kubectl apply -f -
```

#### Kubeflow Pipelines

Install the [Multi-User Kubeflow Pipelines](https://www.kubeflow.org/docs/components/pipelines/multi-user/) official Kubeflow component:

```sh
kustomize build upstream/apps/pipeline/upstream/env/cert-manager/platform-agnostic-multi-user | kubectl apply -f -
```

#### KServe / KFServing

KFServing was rebranded to KServe.

Install the KServe component:

```sh
kustomize build awsconfigs/apps/kserve | kubectl apply -f -
```

Install the Models web app:

```sh
kustomize build upstream/contrib/kserve/models-web-app/overlays/kubeflow | kubectl apply -f -
```

For those not ready to migrate to KServe, you can still install KFServing v0.6.1 with
the following command, but we recommend migrating to KServe as soon as possible:

```sh
kustomize build upstream/apps/kfserving/upstream/overlays/kubeflow | kubectl apply -f -
```

#### Katib

Install the Katib official Kubeflow component:

```sh
kustomize build upstream/apps/katib/upstream/installs/katib-with-kubeflow | kubectl apply -f -
```

#### Central Dashboard

Install the Central Dashboard official Kubeflow component:

```sh
kustomize build upstream/apps/centraldashboard/upstream/overlays/kserve | kubectl apply -f -
```

#### Admission Webhook

Install the Admission Webhook for PodDefaults:

```sh
kustomize build upstream/apps/admission-webhook/upstream/overlays/cert-manager | kubectl apply -f -
```

#### Notebooks

Install the Notebook Controller official Kubeflow component:

```sh
kustomize build upstream/apps/jupyter/notebook-controller/upstream/overlays/kubeflow | kubectl apply -f -
```

Install the Jupyter Web App official Kubeflow component:

```sh
kustomize build awsconfigs/apps/jupyter-web-app | kubectl apply -f -
```

#### Profiles and Kubeflow Access-Management (KFAM)

Install the Profile controller and the Kubeflow Access-Management (KFAM) official Kubeflow
components:

```sh
kustomize build upstream/apps/profiles/upstream/overlays/kubeflow | kubectl apply -f -
```

#### Volumes Web App

Install the Volumes Web App official Kubeflow component:

```sh
kustomize build upstream/apps/volumes-web-app/upstream/overlays/istio | kubectl apply -f -
```

#### Tensorboard

Install the Tensorboards Web App official Kubeflow component:

```sh
kustomize build upstream/apps/tensorboard/tensorboards-web-app/upstream/overlays/istio | kubectl apply -f -
```

Install the Tensorboard controller official Kubeflow component:

```sh
kustomize build upstream/apps/tensorboard/tensorboard-controller/upstream/overlays/kubeflow | kubectl apply -f -
```

#### Training Operator

Install the Training Operator official Kubeflow component:

```sh
kustomize build upstream/apps/training-operator/upstream/overlays/kubeflow | kubectl apply -f -
```

#### AWS Telemetry

Install the AWS Kubeflow telemetry component. This is an optional component. See [Usage Tracking]({{< ref "/docs/about/usage-tracking.md" >}}) for more information

```sh
kustomize build awsconfigs/common/aws-telemetry | kubectl apply -f -
```

#### User namespace

Finally, create a new namespace for the the default user. In this example, the namespace is called `kubeflow-user-example-com`.

```sh
kustomize build upstream/common/user-namespace/base | kubectl apply -f -
```

### Connect to your Kubeflow cluster

After installation, it will take some time for all Pods to become ready. Make sure all Pods are ready before trying to connect, otherwise you might get unexpected errors. To check that all Kubeflow-related Pods are ready, use the following commands:

```sh
kubectl get pods -n cert-manager
kubectl get pods -n istio-system
kubectl get pods -n auth
kubectl get pods -n knative-eventing
kubectl get pods -n knative-serving
kubectl get pods -n kubeflow
kubectl get pods -n kubeflow-user-example-com
# Depending on your installation if you installed KServe
kubectl get pods -n kserve
```

#### Port-Forward

To get started quickly, you can access Kubeflow via port-forward. Run the following to port-forward Istio's Ingress-Gateway to local port `8080`:

```sh
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```

After running the command, you can access the Kubeflow Central Dashboard by doing the following:

1. Open your browser and visit `http://localhost:8080`. You should get the Dex login screen.
2. Login with the default user's credential. The default email address is `user@example.com` and the default password is `12341234`.

#### Exposing Kubeflow over Load Balancer

In order to expose Kubeflow over an external address, you can set up AWS Application Load Balancer. Please take a look at the [Load Balancer guide]({{< ref "/docs/deployment/add-ons/load-balancer/guide.md" >}}) to set it up.

### Change default user password

For security reasons, we do not recommend using the default password for the default Kubeflow user when installing in security-sensitive environments. Instead, you should define your own password before deploying. To define a password for the default user:

1. Pick a password for the default user, with email `user@example.com`, and hash it using `bcrypt`:

    ```sh
    python3 -c 'from passlib.hash import bcrypt; import getpass; print(bcrypt.using(rounds=12, ident="2y").hash(getpass.getpass()))'
    ```

2. Edit `upstream/common/dex/base/config-map.yaml` and fill the relevant field with the hash of the password you chose:

    ```yaml
    ...
      staticPasswords:
      - email: user@example.com
        hash: <enter the generated hash here>
    ```
