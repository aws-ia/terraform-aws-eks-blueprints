+++
title = "Deployment"
description = "Deploy Kubeflow on AWS"
weight = 10
+++
Kubeflow on AWS provides its own Kubeflow manifests that support integrations with various AWS services that are highly available and scalable. This reduces the operational overhead of maintaining the Kubeflow platform. 

If you want to deploy Kubeflow with minimal changes, but optimized for [Amazon Elastic Kubernetes Service](https://aws.amazon.com/eks/) (Amazon EKS), then consider the [vanilla]({{< ref "/docs/deployment/vanilla/guide.md" >}}) deployment option. The Kubeflow control plane is installed on top of Amazon EKS, which is a managed container service used to run and scale Kubernetes applications in the cloud.

To take greater advantage of the distribution and make use of the AWS managed services, choose one of the following deployment options according to your organization's requirements:
- Kubeflow on AWS provides integration with the [Amazon Relational Database Service](https://aws.amazon.com/rds/) (RDS) for highly scalable and available pipelines and metadata store. RDS removes the need to manage a local MYSQL database service and storage. For more information, see the [RDS deployment guide]({{< ref "/docs/deployment/rds-s3/guide.md#using-only-rds-or-only-s3" >}}). 
- Integrate your deployment with [Amazon Simple Storage Service](https://aws.amazon.com/s3/) (S3) for an easy-to-use pipeline artifacts store. S3 removes the need to host the local object storage MinIO. For more information, see the [S3 deployment guide]({{< ref "/docs/deployment/rds-s3/guide.md#using-only-rds-or-only-s3" >}}). 
- You can also deploy Kubeflow on AWS with both RDS and S3 integrations using the [RDS and S3 deployment guide]({{< ref "/docs/deployment/rds-s3/guide.md" >}}).
- Use [AWS Cognito](https://aws.amazon.com/cognito/) for Kubeflow user authentication, which removes the complexity of managing users or [Dex connectors](https://dexidp.io/docs/connectors/) in Kubeflow’s native Dex authentication service. For more information, see the [Cognito deployment guides]({{< ref "/docs/deployment/cognito" >}}). 
- You can also deploy Kubeflow on AWS with all three service integrations by following the [Cognito, RDS, and S3 deployment guide]({{< ref "/docs/deployment/cognito-rds-s3/guide.md" >}}). 

Kubeflow on AWS offers add-ons for additional service integrations, which can be used with any of the available deployment options. 
- If you want to expose your Kubeflow dashboard to external traffic, then use [AWS Application Load Balancer](https://aws.amazon.com/elasticloadbalancing/application-load-balancer/) (ALB) for secure traffic management by following the [Load Balancer add-on guide]({{< ref "/docs/deployment/add-ons/load-balancer/guide.md" >}}).
- Use [Amazon Elastic File System](https://aws.amazon.com/efs/) (EFS) backed persistent volumes with Kubeflow Notebooks or your training and inference workloads (Jupyter, model training, model tuning) to create a persistent, scalable, and shareable workspace that automatically grows and shrinks as you add and remove files with no need for management. See the [EFS add-on guide]({{< ref "/docs/deployment/add-ons/storage/efs/guide.md" >}}) for more information.
- Use [Amazon FSx for Lustre](https://aws.amazon.com/fsx/lustre/) (Amazon FSx) volumes to cache training data with direct connectivity to Amazon S3 as the backing store. These volumes can support Jupyter notebook servers or distributed training. FSx for Lustre provides consistent submillisecond latencies and high concurrency, and can scale to TB/s of throughput and millions of IOPS. Refer to the [FSx add-on guide]({{< ref "/docs/deployment/add-ons/storage/fsx-for-lustre/guide.md" >}}) for more information. 
- Integrate with [Amazon CloudWatch](https://aws.amazon.com/cloudwatch/) for persistent log management, which addresses the default K8s log limits and improves your log availability and monitoring capabilities. For more information, see the [CloudWatch add-on guide]({{< ref "/docs/deployment/add-ons/cloudwatch/guide.md" >}}). 
