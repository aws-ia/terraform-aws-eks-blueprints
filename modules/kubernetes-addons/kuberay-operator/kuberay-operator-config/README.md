# KubeRay Operator

Kuberay-operator: A simple Helm chart

Run a deployment of Ray Operator.

Deploy ray operator first, then deploy ray cluster.

## Helm

Make sure helm version is v3+
```console
$ helm version
version.BuildInfo{Version:"v3.6.2", GitCommit:"ee407bdf364942bcb8e8c665f82e15aa28009b71", GitTreeState:"dirty", GoVersion:"go1.16.5"}
```

## Installing the Chart

To avoid duplicate CRD definitions in this repo, we reuse CRD config in `ray-operator`:
```console
$ kubectl create -k "github.com/ray-project/kuberay/ray-operator/config/crd?ref=v0.3.0&timeout=90s"
```
> Note that we must use `kubectl create` to install the CRDs.
> The corresponding `kubectl apply` command will not work. See [KubeRay issue #271](https://github.com/ray-project/kuberay/issues/271).

Use the following command to install the chart:
```console
$ helm install kuberay-operator --namespace ray-system --create-namespace $(curl -s https://api.github.com/repos/ray-project/kuberay/releases/tags/v0.3.0 | grep '"browser_download_url":' | sort | grep -om1 'https.*helm-chart-kuberay-operator.*tgz')
```

## List the Chart

To list the `my-release` deployment:

```console
$ helm list -n ray-system
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete kuberay-operator -n ray-system
```

The command removes nearly all the Kubernetes components associated with the
chart and deletes the release.

## Working with Argo CD

If you are using [Argo CD](https://argoproj.github.io) to manage the operator, you will encounter the issue which complains the CRDs too long. Same with [this issue](https://github.com/prometheus-operator/prometheus-operator/issues/4439).
The recommended solution is to split the operator into two Argo apps, such as:

* The first app just for installing the CRDs with `Replace=true` directly, snippet:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ray-operator-crds
spec:
  project: default
  source:
    repoURL: https://github.com/ray-project/kuberay
    targetRevision: v0.3.0
    path: helm-chart/kuberay-operator/crds
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    syncOptions:
    - Replace=true
...
```

* The second app that installs the Helm chart with `skipCrds=true` (new feature in Argo CD 2.3.0), snippet:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ray-operator
spec:
  source:
    repoURL: https://github.com/ray-project/kuberay
    targetRevision: v0.3.0
    path: helm-chart/kuberay-operator
    helm:
      skipCrds: true
  destination:
    server: https://kubernetes.default.svc
    namespace: ray-operator
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
...
```
