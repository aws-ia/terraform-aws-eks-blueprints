# AWS Distro for OpenTelemetry

[AWS Distro for OpenTelemetry](https://aws.amazon.com/otel) is a secure, production-ready, AWS-supported distribution of the OpenTelemetry project. Part of the Cloud Native Computing Foundation, OpenTelemetry provides open source APIs, libraries, and agents to collect distributed traces and metrics for application monitoring.

For complete documentation, please visit the [AWS Distro for OpenTelemetry documentation site](https://aws-otel.github.io/).

## Usage

The AWS Distro for OpenTelemetry Collector can be deployed into an EKS cluster by enabling the add-on via the following.

```
aws_open_telemetry_enable = true
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
awsOtelCollector = {
  enable = true
}
```
