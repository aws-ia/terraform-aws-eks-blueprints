# Feast Kustomize

## Installing with Kustomize

### Standalone

```
kustomize build feast/base | kubectl apply -n feast -f -
```

### With Kubeflow

If installing Feast as a component of Kubeflow, use the `kubeflow` overlay.

```
kustomize build feast/overlays/kubeflow | kubectl apply -f -
```

## Updating

The Feast Kustomize configuration in this folder is built from the Feast Helm charts and a custom `values.yaml` file.

Run the following command to regenerate the configuration:
```
make feast/base
```
