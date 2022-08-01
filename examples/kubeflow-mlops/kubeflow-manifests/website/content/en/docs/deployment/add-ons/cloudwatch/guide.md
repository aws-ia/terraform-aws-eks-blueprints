+++
title = "CloudWatch"
description = "Set up CloudWatch ContainerInsights on Amazon EKS"
weight = 30
+++

## Verify Prerequisites
The EKS cluster will need IAM service account roles associated with CloudWatchAgentServerPolicy attached.
 ```bash
export CLUSTER_NAME=<>
export CLUSTER_REGION=<>

eksctl utils associate-iam-oidc-provider --region=$CLUSTER_REGION --cluster=$CLUSTER_NAME --approve
eksctl create iamserviceaccount --name cloudwatch-agent --namespace amazon-cloudwatch --cluster $CLUSTER_NAME --region $CLUSTER_REGION cloudwatch-agent --approve --override-existing-serviceaccounts --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
eksctl create iamserviceaccount --name fluent-bit --namespace amazon-cloudwatch --cluster $CLUSTER_NAME --region $CLUSTER_REGION --approve --override-existing-serviceaccounts --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
```
## Install

To install an optimized QuickStart configuration, enter the following command:
```bash
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${CLUSTER_NAME}'/;s/{{region_name}}/'${CLUSTER_REGION}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f - 
```

To verify the installation, you can run the `list-metrics` command and check that metrics have been created. It may take up to 15 minutes for the metrics to populate.
```bash
aws cloudwatch list-metrics --namespace ContainerInsights --region $CLUSTER_REGION
```

An example of the logs that will be available after installation are the logs of the Pods on your cluster. This way, the Pod logs can still be accessed past their default storage time. This also allows for an easy way to view logs for all Pods on your cluster without having to directly connect to your EKS cluster. 

The logs can be accessed by through CloudWatch log groups ![cloudwatch](../../../../images/cloudwatch/cloudwatch-logs.png)

To view individual Pod logs, select `/aws/containerinsights/YOUR_CLUSTER_NAME/application`. ![application](../../../../images/cloudwatch/cloudwatch-application-logs.png)

The following image is an example of the `jupyter-web-app` Pod logs available through CloudWatch. ![jupyter-logs](../../../../images/cloudwatch/cloudwatch-pod-logs.png)

For a full list of metrics that are provided by default, see [Amazon EKS and Kubernetes Container Insights metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-metrics-EKS.html).

The metrics are grouped by varying parameters such as Cluster, Namespace, or PodName.
![cloudwatch-metrics](../../../../images/cloudwatch/cloudwatch-metrics.png)

The following image is an example of the graphed metrics for the `istio-system` namespace that deals with internet traffic.
![cloudwatch-namespace-metrics](../../../../images/cloudwatch/cloudwatch-namespace-metrics.png)

See [Viewing available metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html) for more information on CloudWatch metrics. Select the ContainerInsights metric namespace.

You can see the full list of logs and metrics through the [Amazon CloudWatch AWS Console](https://console.aws.amazon.com/cloudwatch/).

## Uninstall
To uninstall CloudWatch ContainerInsights, enter the following command:
```bash
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${LogRegion}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl delete -f -
```

## Additional information
For full documentation and additional configuration options, see [Quick Start setup for Container Insights on Amazon EKS and Kubernetes](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html).