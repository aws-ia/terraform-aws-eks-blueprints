## Update Manifest

flink-operator manifest comes from [GoogleCloudPlatform/flink-on-k8s-operator](https://github.com/GoogleCloudPlatform/flink-on-k8s-operator)


Kubeflow flink-operator manifest generates from [flink-operator Helm Chart](https://github.com/GoogleCloudPlatform/flink-on-k8s-operator/tree/master/helm-chart) with some minor changes.

```
helm template  flink-operator-repo/flink-operator --set operatorImage.name=gcr.io/flink-operator/flink-operator:latest  --set flinkOperatorNamespace=kubeflow --set rbac.create=true > flink.yaml
```