# Kubeflow Manifests

## Table of Contents

<!-- toc -->

- [Overview](#overview)
- [Kubeflow components versions](#kubeflow-components-versions)
- [Installation](#installation)
  * [Prerequisites](#prerequisites)
  * [Install with a single command](#install-with-a-single-command)
  * [Install individual components](#install-individual-components)
  * [Connect to your Kubeflow Cluster](#connect-to-your-kubeflow-cluster)
  * [Change default user password](#change-default-user-password)
- [Frequently Asked Questions](#frequently-asked-questions)

<!-- tocstop -->

## Overview

This repo is owned by the [Manifests Working Group](https://github.com/kubeflow/community/blob/master/wg-manifests/charter.md).
If you are a contributor authoring or editing the packages please see [Best Practices](./docs/KustomizeBestPractices.md).

The Kubeflow Manifests repository is organized under three (3) main directories, which include manifests for installing:

| Directory | Purpose |
| - | - |
| `apps` | Kubeflow's official components, as maintained by the respective Kubeflow WGs |
| `common` | Common services, as maintained by the Manifests WG |
| `contrib` | 3rd party contributed applications, which are maintained externally and are not part of a Kubeflow WG |

The `distributions` directory contains manifests for specific, opinionated distributions of Kubeflow, and will be phased out during the 1.4 release, [since going forward distributions will maintain their manifests on their respective external repositories](https://github.com/kubeflow/community/blob/master/proposals/kubeflow-distributions.md).

The `docs`, `hack`, and `tests` directories will also be gradually phased out.

Starting from Kubeflow 1.3, all components should be deployable using `kustomize` only. Any automation tooling for deployment on top of the manifests should be maintained externally by distribution owners.

## Kubeflow components versions

This repo periodically syncs all official Kubeflow components from their respective upstream repos. The following matrix shows the git version that we include for each component:

| Component | Local Manifests Path | Upstream Revision |
| - | - | - |
| Training Operator | apps/training-operator/upstream | [v1.4.0](https://github.com/kubeflow/tf-operator/tree/v1.4.0/manifests) |
| Notebook Controller | apps/jupyter/notebook-controller/upstream | [v1.5.0](https://github.com/kubeflow/kubeflow/tree/v1.5.0/components/notebook-controller/config) |
| Tensorboard Controller | apps/tensorboard/tensorboard-controller/upstream | [v1.5.0](https://github.com/kubeflow/kubeflow/tree/v1.5.0/components/tensorboard-controller/config) |
| Central Dashboard | apps/centraldashboard/upstream | [v1.5.0](https://github.com/kubeflow/kubeflow/tree/v1.5.0/components/centraldashboard/manifests) |
| Profiles + KFAM | apps/profiles/upstream | [v1.5.0](https://github.com/kubeflow/kubeflow/tree/v1.5.0/components/profile-controller/config) |
| PodDefaults Webhook | apps/admission-webhook/upstream | [v1.5.0](https://github.com/kubeflow/kubeflow/tree/v1.5.0/components/admission-webhook/manifests) |
| Jupyter Web App | apps/jupyter/jupyter-web-app/upstream | [v1.5.0](https://github.com/kubeflow/kubeflow/tree/v1.5.0/components/crud-web-apps/jupyter/manifests) |
| Tensorboards Web App | apps/tensorboard/tensorboards-web-app/upstream | [v1.5.0](https://github.com/kubeflow/kubeflow/tree/v1.5.0/components/crud-web-apps/tensorboards/manifests) |
| Volumes Web App | apps/volumes-web-app/upstream | [v1.5.0](https://github.com/kubeflow/kubeflow/tree/v1.5.0/components/crud-web-apps/volumes/manifests) |
| Katib | apps/katib/upstream | [v0.13.0](https://github.com/kubeflow/katib/tree/v0.13.0/manifests/v1beta1) |
| KFServing | apps/kfserving/upstream | [v0.6.1](https://github.com/kubeflow/kfserving/releases/tag/v0.6.1) |
| KServe | contrib/kserve/upstream | [v0.7.0](https://github.com/kserve/kserve/tree/v0.7.0) |
| Kubeflow Pipelines | apps/pipeline/upstream | [1.8.2](https://github.com/kubeflow/pipelines/tree/1.8.2/manifests/kustomize) |
| Kubeflow Tekton Pipelines | apps/kfp-tekton/upstream | [v1.1.1](https://github.com/kubeflow/kfp-tekton/tree/v1.1.1/manifests/kustomize) |

The following is also a matrix with versions from common components that are
used from the different projects of Kubeflow:

| Component | Local Manifests Path | Upstream Revision |
| - | - | - |
| Istio | common/istio-1-11 | [1.11.0](https://github.com/istio/istio/releases/tag/1.11.0) |
| Knative | common/knative | [0.22.1](https://github.com/knative/serving/releases/tag/v0.22.1) |

## Installation

Starting from Kubeflow 1.3, the Manifests WG provides two options for installing Kubeflow official components and common services with kustomize. The aim is to help end users install easily and to help distribution owners build their opinionated distributions from a tested starting point:

1. Single-command installation of all components under `apps` and `common`
2. Multi-command, individual components installation for `apps` and `common`

Option 1 targets ease of deployment for end users. \
Option 2 targets customization and ability to pick and choose individual components.

The `example` directory contains an example kustomization for the single command to be able to run.

:warning: In both options, we use a default email (`user@example.com`) and password (`12341234`). For any production Kubeflow deployment, you should change the default password by following [the relevant section](#change-default-user-password).

### Prerequisites

- `Kubernetes` (up to `1.21`) with a default [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)
    - :warning: Kubeflow 1.5.0 is not compatible with version 1.22 and onwards.
        You can track the remaining work for K8s 1.22 support in
        [kubeflow/kubeflow#6353](https://github.com/kubeflow/kubeflow/issues/6353)
- `kustomize` (version `3.2.0`) ([download link](https://github.com/kubernetes-sigs/kustomize/releases/tag/v3.2.0))
    - :warning: Kubeflow 1.5.0 is not compatible with the latest versions of of kustomize 4.x. This is due to changes in the order resources are sorted and printed. Please see [kubernetes-sigs/kustomize#3794](https://github.com/kubernetes-sigs/kustomize/issues/3794) and [kubeflow/manifests#1797](https://github.com/kubeflow/manifests/issues/1797). We know this is not ideal and are working with the upstream kustomize team to add support for the latest versions of kustomize as soon as we can.
- `kubectl`

---
**NOTE**

`kubectl apply` commands may fail on the first try. This is inherent in how Kubernetes and `kubectl` work (e.g., CR must be created after CRD becomes ready). The solution is to simply re-run the command until it succeeds. For the single-line command, we have included a bash one-liner to retry the command.

---

### Install with a single command

You can install all Kubeflow official components (residing under `apps`) and all common services (residing under `common`) using the following command:

```sh
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done
```

Once, everything is installed successfully, you can access the Kubeflow Central Dashboard [by logging in to your cluster](#connect-to-your-kubeflow-cluster).

Congratulations! You can now start experimenting and running your end-to-end ML workflows with Kubeflow.

### Install individual components

In this section, we will install each Kubeflow official component (under `apps`) and each common service (under `common`) separately, using just `kubectl` and `kustomize`.

If all the following commands are executed, the result is the same as in the above section of the single command installation. The purpose of this section is to:

- Provide a description of each component and insight on how it gets installed.
- Enable the user or distribution owner to pick and choose only the components they need.

#### cert-manager

cert-manager is used by many Kubeflow components to provide certificates for
admission webhooks.

Install cert-manager:

```sh
kustomize build common/cert-manager/cert-manager/base | kubectl apply -f -
kustomize build common/cert-manager/kubeflow-issuer/base | kubectl apply -f -
```

#### Istio

Istio is used by many Kubeflow components to secure their traffic, enforce
network authorization and implement routing policies.

Install Istio:

```sh
kustomize build common/istio-1-11/istio-crds/base | kubectl apply -f -
kustomize build common/istio-1-11/istio-namespace/base | kubectl apply -f -
kustomize build common/istio-1-11/istio-install/base | kubectl apply -f -
```

#### Dex

Dex is an OpenID Connect Identity (OIDC) with multiple authentication backends. In this default installation, it includes a static user with email `user@example.com`. By default, the user's password is `12341234`. For any production Kubeflow deployment, you should change the default password by following [the relevant section](#change-default-user-password).

Install Dex:

```sh
kustomize build common/dex/overlays/istio | kubectl apply -f -
```

#### OIDC AuthService

The OIDC AuthService extends your Istio Ingress-Gateway capabilities, to be able to function as an OIDC client:

```sh
kustomize build common/oidc-authservice/base | kubectl apply -f -
```

#### Knative

Knative is used by the KFServing official Kubeflow component.

Install Knative Serving:

```sh
kustomize build common/knative/knative-serving/overlays/gateways | kubectl apply -f -
kustomize build common/istio-1-11/cluster-local-gateway/base | kubectl apply -f -
```

Optionally, you can install Knative Eventing which can be used for inference request logging:

```sh
kustomize build common/knative/knative-eventing/base | kubectl apply -f -
```

#### Kubeflow Namespace

Create the namespace where the Kubeflow components will live in. This namespace
is named `kubeflow`.

Install kubeflow namespace:

```sh
kustomize build common/kubeflow-namespace/base | kubectl apply -f -
```

#### Kubeflow Roles

Create the Kubeflow ClusterRoles, `kubeflow-view`, `kubeflow-edit` and
`kubeflow-admin`. Kubeflow components aggregate permissions to these
ClusterRoles.

Install kubeflow roles:

```sh
kustomize build common/kubeflow-roles/base | kubectl apply -f -
```

#### Kubeflow Istio Resources

Create the Istio resources needed by Kubeflow. This kustomization currently
creates an Istio Gateway named `kubeflow-gateway`, in namespace `kubeflow`.
If you want to install with your own Istio, then you need this kustomization as
well.

Install istio resources:

```sh
kustomize build common/istio-1-11/kubeflow-istio-resources/base | kubectl apply -f -
```

#### Kubeflow Pipelines

Install the [Multi-User Kubeflow Pipelines](https://www.kubeflow.org/docs/components/pipelines/multi-user/) official Kubeflow component:

```sh
kustomize build apps/pipeline/upstream/env/cert-manager/platform-agnostic-multi-user | kubectl apply -f -
```

If your container runtime is not docker, use pns executor instead:

```sh
kustomize build apps/pipeline/upstream/env/platform-agnostic-multi-user-pns | kubectl apply -f -
```

Refer to [argo workflow executor documentation](https://argoproj.github.io/argo-workflows/workflow-executors/#process-namespace-sharing-pns) for their pros and cons.

**Multi-User Kubeflow Pipelines dependencies**

* Istio + Kubeflow Istio Resources
* Kubeflow Roles
* OIDC Auth Service (or cloud provider specific auth service)
* Profiles + KFAM

**Alternative: Kubeflow Pipelines Standalone**

You can install [Kubeflow Pipelines Standalone](https://www.kubeflow.org/docs/components/pipelines/installation/standalone-deployment/) which

* does not support multi user separation
* has no dependencies on the other services mentioned here

You can learn more about their differences in [Installation Options for Kubeflow Pipelines
](https://www.kubeflow.org/docs/components/pipelines/installation/overview/).

Besides installation instructions in Kubeflow Pipelines Standalone documentation, you need to apply two virtual services to expose [Kubeflow Pipelines UI](https://github.com/kubeflow/pipelines/blob/1.7.0/manifests/kustomize/base/installs/multi-user/virtual-service.yaml) and [Metadata API](https://github.com/kubeflow/pipelines/blob/1.7.0/manifests/kustomize/base/metadata/options/istio/virtual-service.yaml) in kubeflow-gateway.

#### KServe / KFServing

KFServing was rebranded to KServe.

Install the KServe component:

```sh
kustomize build contrib/kserve/kserve | kubectl apply -f -
```

Install the Models web app:

```sh
kustomize build contrib/kserve/models-web-app/overlays/kubeflow | kubectl apply -f -
```

- ../contrib/kserve/models-web-app/overlays/kubeflow

For those not ready to migrate to KServe, you can still install KFServing v0.6.1 with
the following command, but we recommend migrating to KServe as soon as possible:

```sh
kustomize build apps/kfserving/upstream/overlays/kubeflow | kubectl apply -f -
```

#### Katib

Install the Katib official Kubeflow component:

```sh
kustomize build apps/katib/upstream/installs/katib-with-kubeflow | kubectl apply -f -
```

#### Central Dashboard

Install the Central Dashboard official Kubeflow component:

```sh
kustomize build apps/centraldashboard/upstream/overlays/kserve | kubectl apply -f -
```

#### Admission Webhook

Install the Admission Webhook for PodDefaults:

```sh
kustomize build apps/admission-webhook/upstream/overlays/cert-manager | kubectl apply -f -
```

#### Notebooks

Install the Notebook Controller official Kubeflow component:

```sh
kustomize build apps/jupyter/notebook-controller/upstream/overlays/kubeflow | kubectl apply -f -
```

Install the Jupyter Web App official Kubeflow component:

```sh
kustomize build apps/jupyter/jupyter-web-app/upstream/overlays/istio | kubectl apply -f -
```

#### Profiles + KFAM

Install the Profile Controller and the Kubeflow Access-Management (KFAM) official Kubeflow
components:

```sh
kustomize build apps/profiles/upstream/overlays/kubeflow | kubectl apply -f -
```

#### Volumes Web App

Install the Volumes Web App official Kubeflow component:

```sh
kustomize build apps/volumes-web-app/upstream/overlays/istio | kubectl apply -f -
```

#### Tensorboard

Install the Tensorboards Web App official Kubeflow component:

```sh
kustomize build apps/tensorboard/tensorboards-web-app/upstream/overlays/istio | kubectl apply -f -
```

Install the Tensorboard Controller official Kubeflow component:

```sh
kustomize build apps/tensorboard/tensorboard-controller/upstream/overlays/kubeflow | kubectl apply -f -
```

#### Training Operator

Install the Training Operator official Kubeflow component:

```sh
kustomize build apps/training-operator/upstream/overlays/kubeflow | kubectl apply -f -
```

#### User Namespace

Finally, create a new namespace for the the default user (named `kubeflow-user-example-com`).

```sh
kustomize build common/user-namespace/base | kubectl apply -f -
```

### Connect to your Kubeflow Cluster

After installation, it will take some time for all Pods to become ready. Make sure all Pods are ready before trying to connect, otherwise you might get unexpected errors. To check that all Kubeflow-related Pods are ready, use the following commands:

```sh
kubectl get pods -n cert-manager
kubectl get pods -n istio-system
kubectl get pods -n auth
kubectl get pods -n knative-eventing
kubectl get pods -n knative-serving
kubectl get pods -n kubeflow
kubectl get pods -n kubeflow-user-example-com
```

#### Port-Forward

The default way of accessing Kubeflow is via port-forward. This enables you to get started quickly without imposing any requirements on your environment. Run the following to port-forward Istio's Ingress-Gateway to local port `8080`:

```sh
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```

After running the command, you can access the Kubeflow Central Dashboard by doing the following:

1. Open your browser and visit `http://localhost:8080`. You should get the Dex login screen.
2. Login with the default user's credential. The default email address is `user@example.com` and the default password is `12341234`.

#### NodePort / LoadBalancer / Ingress

In order to connect to Kubeflow using NodePort / LoadBalancer / Ingress, you need to setup HTTPS. The reason is that many of our web apps (e.g., Tensorboard Web App, Jupyter Web App, Katib UI) use [Secure Cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies), so accessing Kubeflow with HTTP over a non-localhost domain does not work.

Exposing your Kubeflow cluster with proper HTTPS is a process heavily dependent on your environment. For this reason, please take a look at the available [Kubeflow distributions](https://www.kubeflow.org/docs/started/installing-kubeflow/#install-a-packaged-kubeflow-distribution), which are targeted to specific environments, and select the one that fits your needs.

---
**NOTE**

If you absolutely need to expose Kubeflow over HTTP, you can disable the `Secure Cookies` feature by setting the `APP_SECURE_COOKIES` environment variable to `false` in every relevant web app. This is not recommended, as it poses security risks.

---

### Change default user password

For security reasons, we don't want to use the default password for the default Kubeflow user when installing in security-sensitive environments. Instead, you should define your own password before deploying. To define a password for the default user:

1. Pick a password for the default user, with email `user@example.com`, and hash it using `bcrypt`:

    ```sh
    python3 -c 'from passlib.hash import bcrypt; import getpass; print(bcrypt.using(rounds=12, ident="2y").hash(getpass.getpass()))'
    ```

2. Edit `dex/base/config-map.yaml` and fill the relevant field with the hash of the password you chose:

    ```yaml
    ...
      staticPasswords:
      - email: user@example.com
        hash: <enter the generated hash here>
    ```

## Frequently Asked Questions

- **Q:** What versions of Istio, Knative, Cert-Manager, Argo, ... are compatible with Kubeflow 1.4? \
  **A:** Please refer to each individual component's documentation for a dependency compatibility range. For Istio, Knative, Dex, Cert-Manager and OIDC-AuthService, the versions in `common` are the ones we have validated.

- **Q:** Can I use the latest Kustomize version (`v4.x`)? \
  **A:** Kubeflow 1.4.0 is not compatible with the latest versions of of kustomize 4.x. This is due to changes in the order resources are sorted and printed. Please see [kubernetes-sigs/kustomize#3794](https://github.com/kubernetes-sigs/kustomize/issues/3794) and [kubeflow/manifests#1797](https://github.com/kubeflow/manifests/issues/1797). We know this is not ideal and are working with the upstream kustomize team to add support for the latest versions of kustomize as soon as we can.
