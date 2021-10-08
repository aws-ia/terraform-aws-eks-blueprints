# Helm Charts Modules

The framework leverage Terraform `Helm` provider to to deploy Kubernetes add-ons. All Helm modules can be found in the `helm` directory. Each module has a README with instructions on how to download the images from Docker Hub or third-party repos and upload it to your private ECR repo.

The supported Helm Modules are below

| Chart                         | Description                             |
|-------------------------------|-----------------------------------------|
| [Agones]                      | This is a description                   |   
| [Alert-manager]               | This is a description                   |
| [AWS for FluentBit]           | This is a description                   |
| [Fargate FluentBit]           | This is a description                   |
| [FluentBit for MNGs]          | This is a description                   |
| [kube-state-metrics]          | This is a description                   |
| [LB Ingress Controller]       | This is a description                   |
| [Metrics Server]              | This is a description                   |
| [OpenTelemetry]               | This is a description                   |
| [Prometheus]                  | This is a description                   |
| [Prometheus-node-exporter]    | This is a description                   |
| [Prometheus-pushgateway]      | This is a description                   |
| [Traefik Ingress Controller]  | This is a description                   |

[Agones]: https://agones.dev/site/
[Alert-manager]: https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager
[AWS for FLuentBit]: https://github.com/Kubernetes/autoscaler
[Fargate FluentBit]: https://aws.amazon.com/blogs/containers/fluent-bit-for-amazon-eks-on-aws-fargate-is-here/
[FluentBit for MNGs]: https://github.com/aws/aws-for-fluent-bit
[kube-state-metrics]: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics
[LB Ingress Controller]: https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
[Metrics Server]: https://github.com/Kubernetes-sigs/metrics-server
[OpenTelemetry]: https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector
[Prometheus]: https://github.com/prometheus-community/helm-charts
[Prometheus-node-exporter]: https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter
[Prometheus-pushgateway]: https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway
[Traefik Ingress Controller]: https://doc.traefik.io/traefik/providers/Kubernetes-ingress/