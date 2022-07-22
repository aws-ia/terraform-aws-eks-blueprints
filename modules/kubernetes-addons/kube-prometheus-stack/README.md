# kube-prometheus-stack Helm Chart

## Introduction

[kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) is a a collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator.

The default values.yaml file in this add-on has disabled the components that are unreachable in EKS environments, and an EBS Volume for Persistent Storage.
