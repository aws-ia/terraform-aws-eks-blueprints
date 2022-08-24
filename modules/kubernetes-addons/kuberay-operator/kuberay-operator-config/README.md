# KubeRay Operator (Alpha)

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
$ kubectl apply -k "github.com/ray-project/kuberay/ray-operator/config/crd?ref=v0.3.0"
```

Please use command below:
```console
$ helm install kuberay-operator --namespace ray-system --create-namespace $(curl -s https://api.github.com/repos/ray-project/kuberay/releases/latest | grep '"browser_download_url":' | sort | grep -om1 'https.*helm-chart-kuberay-operator.*tgz')
```

## List the Chart

To list the `my-release` deployment:

```console
$ helm list -n kuberay-operator
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete kuberay-operator -n ray-system
```

The command removes nearly all the Kubernetes components associated with the
chart and deletes the release.
