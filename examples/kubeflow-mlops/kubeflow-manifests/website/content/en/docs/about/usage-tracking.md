+++
title = "Usage Tracking"
description = "Learn about usage tracking for Kubeflow on AWS"
weight = 50
+++

AWS uses customer feedback and usage information to improve the quality of the services and software we offer to customers. We have added usage data collection to the AWS Kubeflow distribution in order to better understand customer usage and guide future improvements. Usage tracking for Kubeflow is activated by default, but is entirely voluntary and can be deactivated at any time. 

Usage tracking for Kubeflow on AWS collects the instance ID used by one of the worker nodes in a customer’s cluster. This data is sent back to AWS once per day. Usage tracking only collects the EC2 instance ID where Kubeflow is running and does not collect or export any other data to AWS. If you wish to deactivate this tracking, instructions are below. 

### Activate usage tracking

Usage tracking is activated by default. If you deactivated usage tracking for your Kubeflow deployment and would like to activate it after the fact, you can do so at any time with the following command:

```bash
kustomize build awsconfigs/common/aws-telemetry | kubectl apply -f -
```

### Deactivate usage tracking

**Before deploying Kubeflow:** 

You can deactivate usage tracking by skipping the telemetry component installation in one of two ways:

1. For single line installation, comment out the [`aws-telemetry` line](https://github.com/awslabs/kubeflow-manifests/blob/main/deployments/vanilla/kustomization.yaml#L59) in the `kustomization.yaml` file of your choosing:
    ```bash
    # ../../aws-telemetry
    ```
2. For individual component installation, **do not** install the `aws-telemetry` component: 
    ```bash
    # AWS Telemetry - This is an optional component. 
    kustomize build awsconfigs/common/aws-telemetry | kubectl apply -f -
    ```
**After deploying Kubeflow:**

To deactivate usage tracking on an existing deployment, delete the `aws-kubeflow-telemetry` cronjob with the following command:

```
kubectl delete cronjob -n kubeflow aws-kubeflow-telemetry
```

### Information collected by usage tracking

* **Instance ID** - We collect the instance ID used by one of the worker nodes in the customer’s EKS cluster. This collection occurs once per day.

### Learn more

The telemetry data we collect is in accordance with AWS data privacy policies. For more information, see the following:

* [AWS Service Terms](https://aws.amazon.com/service-terms/)
* [Data Privacy](https://aws.amazon.com/compliance/data-privacy-faq/)