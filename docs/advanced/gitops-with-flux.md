# Manage your cluster(s) configuration with Flux

Once you have deployed your EKS cluster(s) with Terraform, you can leverage [Flux](https://fluxcd.io) to manage your cluster's configuration with [GitOps](https://www.gitops.tech/), including the deployment of add-ons, cluster configuration (e.g. cluster policies) and applications. Using GitOps practices to manage your clusters configuration will simplify management, scaling the number of clusters you run and be able to easily recreate your clusters, treating them as ephemeral resources. Recreating your cluster is as simple as deploying a new cluster with Terraform and bootstrapping it with Flux pointing to the repository containing the configuration.

The [aws-samples/flux-eks-gitops-config](https://github.com/aws-samples/flux-eks-gitops-config) repository provides a sample configuration blueprint for configuring multiple Amazon EKS clusters belonging to different stages (`test` and `production`) using [GitOps](https://www.gitops.tech/) with [Flux v2](https://fluxcd.io/docs/). This repository installs a set of commonly used Kubernetes add-ons to perform policy enforcement, restrict network traffic with network policies, cluster monitoring, extend Kubernetes deployment capabilities enabling progressive Canary deployments for your applications...

You can use the above sample repository to experiment with the predefined cluster configurations and use it as a baseline to adjust it to your own needs.

This sample installs the following Kubernetes add-ons:

* **[metrics-server](https://github.com/kubernetes-sigs/metrics-server):** Aggregator of resource usage data in your cluster, commonly used by other Kubernetes add ons, such us [Horizontal Pod Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/horizontal-pod-autoscaler.html) or [Kubernetes Dashboard](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html).
* **[Calico](https://projectcalico.docs.tigera.io/about/about-calico):** Project Calico is a network policy engine for Kubernetes. Calico network policy enforcement allows you to implement network segmentation and tenant isolation. For more information check the [Amazon EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/calico.html).
* **[Kyverno](https://kyverno.io/):** Kubernetes Policy Management Engine. Kyverno allows cluster administrators to manage environment specific configurations independently of workload configurations and enforce configuration best practices for their clusters. Kyverno can be used to scan existing workloads for best practices, or can be used to enforce best practices by blocking or mutating API requests.
* **[Prometheus](https://prometheus.io/):** Defacto standard open-source systems monitoring and alerting toolkit for Kubernetes. This repository installs [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).
* **[Flagger](https://flagger.app/):** Progressive delivery operator for Flux. Flagger can run automated application analysis, testing, promotion and rollback for the following deployment strategies: Canary, A/B Testing and Blue/Green. For more details, check the [Flagger documentation](https://docs.flagger.app/).
* **[nginx-ingress-controller](https://kubernetes.github.io/ingress-nginx/):** Ingress controller to expose apps and enable [canary deployments and A/B testing with Flagger](https://docs.flagger.app/tutorials/nginx-progressive-delivery).

**NOTE:** The add-ons on the sample are not configured for a production-ready cluster (e.g. Prometheus would need to be configured for long term metric storage, nginx would need HPA and any custom settings you need...).

There're also a set of Kyverno cluster policies deployed to audit (test) or enforce (production) security settings on your workloads, as well as [podinfo](https://github.com/stefanprodan/podinfo) as a sample application, configured with [Flagger](https://flagger.app/) to perform progressive deployments. For further information, visit the [aws-samples/flux-eks-gitops-config](https://github.com/aws-samples/flux-eks-gitops-config) repository documentation.

## Bootstrap your cluster with Flux

The below instructions assume you have created a cluster with `eks-blueprints` with no add-ons other than aws-load-balancer-controller. If you're installing additional add-ons via terraform, the configuration may clash with the one on the sample repository. If you plan to leverage Flux, we recommend that you use Terraform to install and manage only add-ons that require additional AWS resources to be created (like IAM roles for Service accounts), and then use Flux to manage the rest.

### Prerequisites

The add-ons and configurations of this repository require Kubernetes 1.21 or higher (this is required by the version of kube-prometheus-stack that is installed, you can use 1.19+ installing previous versions of kube-prometheus-stack).

You'll also need the following:

* Install flux CLI on your computer following the instructions [here](https://fluxcd.io/docs/installation/). This repository has been tested with flux 0.22.
* A GitHub account and a [personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) that can create repositories.

### Bootstrap your cluster

Fork the [aws-samples/flux-eks-gitops-config](https://github.com/aws-samples/flux-eks-gitops-config) repository on your personal GitHub account and export your GitHub access token, username and repo name:

```sh
  export GITHUB_TOKEN=<your-token>
  export GITHUB_USER=<your-username>
  export GITHUB_REPO=<repository-name>
```

Define whether you want to bootstrap your cluster with the `TEST` or the `PRODUCTION` configuration:

```sh
  # TEST configuration
  export CLUSTER_ENVIRONMENT=test

  # PRODUCTION configuration
  export CLUSTER_ENVIRONMENT=production
```

Verify that your staging cluster satisfies the prerequisites with:

```sh
  flux check --pre
```

You can now bootstrap your cluster with Flux CLI.

```sh
  flux bootstrap github --owner=${GITHUB_USER} --repository=${GITHUB_REPO} --branch=main --path=clusters/${CLUSTER_ENVIRONMENT} --personal
```

The bootstrap command commits the manifests for the Flux components in `clusters/${CLUSTER_ENVIRONMENT}/flux-system` directory and creates a deploy key with read-only access on GitHub, so it can pull changes inside the cluster.

Confirm that Flux has finished applying the configuration to your cluster (it will take 3 or 4 minutes to sync everything):

```sh
  $ flux get kustomization
  NAME                READY MESSAGE                                                           REVISION                                        SUSPENDED
  apps                True  Applied revision: main/b7d10ca21be7cac0dcdd14c80353012ccfedd4fe   main/b7d10ca21be7cac0dcdd14c80353012ccfedd4fe   False
  calico-installation True  Applied revision: master/00a2f33ea55f2018819434175c09c8bd8f20741a master/00a2f33ea55f2018819434175c09c8bd8f20741a False
  calico-operator     True  Applied revision: master/00a2f33ea55f2018819434175c09c8bd8f20741a master/00a2f33ea55f2018819434175c09c8bd8f20741a False
  config              True  Applied revision: main/8fd33f531df71002f2da7bc9619ee75281a9ead0   main/8fd33f531df71002f2da7bc9619ee75281a9ead0   False
  flux-system         True  Applied revision: main/b7d10ca21be7cac0dcdd14c80353012ccfedd4fe   main/b7d10ca21be7cac0dcdd14c80353012ccfedd4fe   False
  infrastructure      True  Applied revision: main/b7d10ca21be7cac0dcdd14c80353012ccfedd4fe   main/b7d10ca21be7cac0dcdd14c80353012ccfedd4fe   False
```

Get the URL for the nginx ingress controller that has been deployed in your cluster (you will see two ingresses, since Flagger will create a canary ingress):

```sh
   $ kubectl get ingress -n podinfo
   NAME             CLASS   HOSTS          ADDRESS                               PORTS   AGE
   podinfo          nginx   podinfo.test   k8s-xxxxxx.elb.us-west-2.amazonaws.com   80      23h
   podinfo-canary   nginx   podinfo.test   k8s-xxxxxx.elb.us-west-2.amazonaws.com   80      23h
```

Confirm that podinfo can be correctly accessed via ingress:

```sh
  $ curl -H "Host: podinfo.test" k8s-xxxxxx.elb.us-west-2.amazonaws.com
  {
  "hostname": "podinfo-primary-65584c8f4f-d7v4t",
  "version": "6.0.0",
  "revision": "",
  "color": "#34577c",
  "logo": "https://raw.githubusercontent.com/stefanprodan/podinfo/gh-pages/cuddle_clap.gif",
  "message": "greetings from podinfo v6.0.0",
  "goos": "linux",
  "goarch": "amd64",
  "runtime": "go1.16.5",
  "num_goroutine": "10",
  "num_cpu": "2"
  }
```

Congratulations! Your cluster has sync'ed all the configuration defined on the repository. Continue exploring the deployed configuration following these docs:

* [Review the repository structure to understand the applied configuration](https://github.com/aws-samples/flux-eks-gitops-config/blob/main/docs/repository-structure.md)
* [Test the cluster policies configured with Kyverno](https://github.com/aws-samples/flux-eks-gitops-config/blob/main/docs/test-kyverno-policies.md)
* [Test progressive deployments with Flux, Flagger and nginx controller](https://github.com/aws-samples/flux-eks-gitops-config/blob/main/docs/flagger-canary-deployments.md)
