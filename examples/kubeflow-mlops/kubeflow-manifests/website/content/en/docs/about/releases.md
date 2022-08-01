+++
title = "Releases and Versioning"
description = "Familiarize yourself with Kubeflow on AWS release cadences and version naming conventions"
weight = 20
+++

Kubeflow on AWS releases are built on top of open source Kubeflow releases and therefore use the following naming convention: `{KUBEFLOW_RELEASE_VERSION}-aws-b{BUILD_NUMBER}`.

* Ex: Kubeflow v1.3.1 on AWS version 1.0.0 will have the version `v1.3.1-aws-b1.0.0`.

`KUBEFLOW_RELEASE_VERSION` refers to [Kubeflow's released version](https://github.com/kubeflow/manifests/releases) and `BUILD_NUMBER` refers to the AWS build for that Kubeflow version. `BUILD_NUMBER` uses [semantic versioning](https://semver.org/) (SemVer) to indicate whether changes included in a particular release introduce features or bug fixes and whether or not features break backwards compatibility.

When a version of Kubeflow on AWS is released, a Git tag with the naming convention `{KUBEFLOW_RELEASE_VERSION}-aws-b{BUILD_NUMBER}` is created. These releases can be found in the Kubeflow on AWS repository [releases](https://github.com/awslabs/kubeflow-manifests/releases) section.

## v1.3.1

> Note: Documentation for Kubeflow on AWS v.1.3 can be found on the [Kubeflow website](https://v1-3-branch.kubeflow.org/docs/distributions/aws/). 

Although the distribution manifests are hosted in the [Kubeflow on AWS repository](https://github.com/awslabs/kubeflow-manifests), many of the overlays and configuration files in this repository have a dependency on the manifests published by the Kubeflow community in the [kubeflow/manifests](https://github.com/kubeflow/manifests) repository. Hence, the AWS distribution of Kubeflow for v1.3.1 was developed on a [fork](https://github.com/awslabs/kubeflow-manifests/tree/v1.3-branch) of the `v1.3-branch` of the `kubeflow/manifests` repository. This presented several challenges for ongoing maintenance as described in [Issue #76](https://github.com/awslabs/kubeflow-manifests/issues/76). 

## v1.4+

Starting with Kubeflow v1.4, the development of the AWS distribution of Kubeflow is done on the [`main`](https://github.com/awslabs/kubeflow-manifests/tree/main) branch. The `main` branch contains only the delta from the released manifests in the `kubeflow/manifests` repository and additional components required for the AWS distribution.
