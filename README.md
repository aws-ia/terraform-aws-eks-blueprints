# aws-eks-accelerator-for-terraform

# Main Purpose
This project provides a framework for deploying best-practice multi-tenant [EKS Clusters](https://aws.amazon.com/eks) with [Kubernetes Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons/), provisioned via [Hashicorp Terraform](https://www.terraform.io/) and [Helm charts](https://helm.sh/) on [AWS](https://aws.amazon.com/).

# Overview
The AWS EKS Accelerator for Terraform module helps you to provision [EKS Clusters](https://aws.amazon.com/eks), [Managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) with [On-Demand](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-on-demand-instances.html) and [Spot Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html), [AWS Fargate profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html), and all the necessary Kubernetes add-ons for a production-ready EKS cluster. The [Terraform Helm provider](https://github.com/hashicorp/terraform-provider-helm) is used to deploy common Kubernetes Addons with publicly available [Helm Charts](https://artifacthub.io/). 
This project leverages the official [terrafor-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc) and [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) community modules to create VPC and EKS Cluster.

The intention of this framework is to help you design config driven solution. This will help you to create EKS clusters for various environments and AWS accounts across multiple regions with a **unique Terraform configuration and state file** per EKS cluster.  

The top-level `deploy` folder provides an example of how you can structure your folders and files to define multiple EKS Cluster environments and consume this accelerator module. This approach is suitable for large projects, with clearly defined sub directory and file structure.
This can be modified the way that suits your requirement. You can define a unique configuration for each EKS Cluster and making this module as central source of truth. Please note that `deploy` folder can be moved to a dedicated repo and consume this module using `main.tf` file([see example file here](deploy/live/preprod/eu-west-1/application/dev/dev.tfvars) ).

        
e.g. folder/file structure for defining multiple clusters

        ├── deploy
        │   └── live
        │       └── preprod                      
        │           └── eu-west-1                    
        │               └── application               
        │                   └── dev       
        │                       └── backend.conf              
        │                       └── dev.tfvars       
        │                       └── main.tf       
        │                       └── variables.tf    
        │                       └── outputs.tf         
        │                   └── test    
        │                       └── backend.conf              
        │                       └── test.tfvars    
        │       └── prod                      
        │           └── eu-west-1                    
        │               └── application               
        │                   └── prod       
        │                       └── backend.conf              
        │                       └── prod.tfvars       
        │                       └── main.tf       
        │                       └── variables.tf    
        │                       └── outputs.tf        

Each folder under `live/<region>/application` represents an EKS cluster environment(e.g., dev, test, load etc.).
This folder contains `backend.conf` and `<env>.tfvars`, used to create a unique Terraform state for each cluster environment.
Terraform backend configuration can be updated in `backend.conf` and cluster common configuration variables in `<env>.tfvars`

* `eks.tf` - [EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/clusters.html) resources and [Amazon EKS Addon](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) resources
* `fargate-profiles.tf`  - [AWS EKS Fargate profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
* `managed-nodegroups.tf` - [Amazon Managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) resources
* `self-managed-nodegroups.tf` - [Self-managed nodes](https://docs.aws.amazon.com/eks/latest/userguide/worker.html) resources
* `kubernetes-addons.tf` - contains resources to deploy multiple Kubernetes Addons
* `vpc.tf` - VPC and endpoints resources

* `modules` - folder contains all the AWS resource sub modules used in this module
* `kubernetes-addons` - folder contains all the Helm charts and Kubernetes resources for deploying Kubernetes Addons
* `examples` - folder contains sample template files with `<env>.tfvars` which can be used to deploy EKS cluster with multiple node groups and Kubernetes add-ons

# EKS Cluster Deployment Options
This module provisions the following EKS resources

## EKS Cluster Networking Resources

1. [VPC and Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html)
    - [Public Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
    - [Private Subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
2. [VPC endpoints for fully private EKS Clusters](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)
3. [NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
4. [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)

NOTE: VPC/Subnets creation can be disabled using `create_vpc = false` in TFVARS file and import the existing VPC resources 

## EKS Cluster resources

1. [EKS Cluster with multiple networking options](https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/)
   1. [Fully Private EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)
   2. [Public + Private EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html)
   3. [Public Cluster](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html))
2. [Amazon EKS Addons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) -
   - [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
   - [Kube-Proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html)
   - [VPC-CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
3. [Managed Node Groups with On-Demand](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) - AWS Managed Node Groups with On-Demand Instances
4. [Managed Node Groups with Spot](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) - AWS Managed Node Groups with Spot Instances
5. [AWS Fargate Profiles](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html) - AWS Fargate Profiles
6. [Launch Templates](https://aws.amazon.com/blogs/containers/introducing-launch-template-and-custom-ami-support-in-amazon-eks-managed-node-groups/) - Deployed through launch templates to Managed Node Groups
7. [Bottlerocket OS](https://github.com/bottlerocket-os/bottlerocket) - Managed Node Groups with Bottlerocket OS and Launch Templates
8. [Amazon Managed Service for Prometheus (AMP)](https://aws.amazon.com/prometheus/) - AMP makes it easy to monitor containerized applications at scale
9. [Self-managed Node Group with Windows support](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html) - Ability to create a self-managed node group for Linux or Windows workloads.

## Kubernetes Addons using [Helm Charts](https://helm.sh/docs/topics/charts/)

1. [Metrics Server](https://github.com/Kubernetes-sigs/metrics-server)
2. [Cluster Autoscaler](https://github.com/Kubernetes/autoscaler)
3. [AWS LB Ingress Controller](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
4. [Traefik Ingress Controller](https://doc.traefik.io/traefik/providers/Kubernetes-ingress/)
5. [Nginix Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
6. [FluentBit to CloudWatch for Nodes](https://github.com/aws/aws-for-fluent-bit)
7. [FluentBit to CloudWatch for Fargate Containers](https://aws.amazon.com/blogs/containers/fluent-bit-for-amazon-eks-on-aws-fargate-is-here/)
8. [Agones](https://agones.dev/site/) - Host, Run and Scale dedicated game servers on Kubernetes
9. [Prometheus](https://github.com/prometheus-community/helm-charts)
10. [Kube-state-metrics](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics)
11. [Alert-manager](https://github.com/prometheus-community/helm-charts/tree/main/charts/alertmanager)
12. [Prometheus-node-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter)
13. [Prometheus-pushgateway](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway)
14. [OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector)
15. [AWS Distro for OpenTelemetry Collector(AWS OTel Collector) ](https://github.com/aws-observability/aws-otel-collector)

# Node Group Modules
This module contains dedicated sub modules for creating [AWS Managed Node Groups](modules/aws-eks-managed-node-groups), [Self-managed Node groups](modules/aws-eks-self-managed-node-groups) and [Fargate profiles](modules/aws-eks-fargate-profiles).
Mixed Node groups with Fargate profiles can be defined simply as a map variable in `<env>.tfvars`. 
This approach provides flexibility to add or remove managed/self-managed node groups/fargate profiles by just adding/removing map of values to the existing `<env>.tfvars`. This allows you to define unique node configuraton for each EKS Cluster in the same account. AWS auth config map handled by this module to ensure new node groups successfully joined with the Cluster. 
Each Node Group can have dedicated IAM role, Security Group and Launch template to improve the security.

Please refer to the `dev.tfvars` for full example.

**Managed Node Groups Example**

    enable_managed_nodegroups = true
    managed_node_groups = {
      mg_m4 = {
        # 1> Node Group configuration
        node_group_name        = "managed-ondemand"
        create_launch_template = true              # false will use the default launch template
        custom_ami_type        = "amazonlinux2eks" # amazonlinux2eks or windows or bottlerocket
        public_ip              = false             # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
        pre_userdata           = <<-EOT
                yum install -y amazon-ssm-agent
                systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent"
            EOT
        # 2> Node Group scaling configuration
        desired_size    = 3
        max_size        = 3
        min_size        = 3
        max_unavailable = 1 # or percentage = 20
    
        # 3> Node Group compute configuration
        ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
        capacity_type  = "ON_DEMAND"  # ON_DEMAND or SPOT
        instance_types = ["m4.large"] # List of instances used only for SPOT type
        disk_size      = 50
    
        # 4> Node Group network configuration
        subnet_type = "private" # private or public
        subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']
    
        k8s_taints = []
    
        k8s_labels = {
          Environment = "preprod"
          Zone        = "dev"
          WorkerType  = "ON_DEMAND"
        }
        additional_tags = {
          ExtraTag    = "m4-on-demand"
          Name        = "m4-on-demand"
          subnet_type = "private"
        }
        create_worker_security_group = true
      },
      mg_m5 = {...}
     }

**Fargate Profiles Example**

    enable_fargate = true
    
    fargate_profiles = {
      default = {
        fargate_profile_name = "default"
        fargate_profile_namespaces = [{
          namespace = "default"
          k8s_labels = {
            Environment = "preprod"
            Zone        = "dev"
            env         = "fargate"
          }
        }]
    
        subnet_ids = [] # Provide list of private subnets
    
        additional_tags = {
          ExtraTag = "Fargate"
        }
      },
        finance = {...}
      }
      
# Kubernetes Addons Module
Kubernetes Addons Module within this framework allows you to deploy Kubernetes Addons using Terraform Helm provider and Kubernetes provider with simple **true/false** feature in `<env>.tfvars`.

e.g., `<env>.tfvars` config for enabling AWS LB INGRESS CONTROLLER. Refer to example [dev.tfvars](deploy/live/preprod/eu-west-1/application/dev/dev.tfvars) to enable other Kubernetes Addons

    #---------------------------------------------------------//
    # ENABLE AWS LB INGRESS CONTROLLER
    #---------------------------------------------------------//
    aws_lb_ingress_controller_enable = true
    aws_lb_image_repo_name       = "amazon/aws-load-balancer-controller"
    aws_lb_image_tag             = "v2.2.4"
    aws_lb_helm_chart_version    = "1.2.7"
    aws_lb_helm_repo_url         = "https://aws.github.io/eks-charts"
    aws_lb_helm_helm_chart_name  = "aws-load-balancer-controller"
    
This module currently configured to fetch the Helm Charts from Open Source repos and Docker images from Docker Hub/Public ECR repos which requires outbound Internet connection from your EKS Cluster.  Alternatively you can download the Docker images for each Addon and push it to AWS ECR repo and this can be accessed within VPC using ECR endpoint. 
You can find the README for each Helm module with instructions on how to download the images from Docker Hub or third-party repos and upload it to your private ECR repo. This module provides the option to use internal Helm and Docker image repos from `<env>.tfvars`. 

For example, [ALB Ingress Controller](kubernetes-addons/lb-ingress-controller/README.md) for AWS LB Ingress Controller module.

## Ingress Controller Modules
Ingress is an API object that defines the traffic routing rules (e.g., load balancing, SSL termination, path-based routing, protocol), whereas the Ingress Controller is the component responsible for fulfilling those requests.

* [ALB Ingress Controller](kubernetes-addons/lb-ingress-controller/README.md) can be deployed by enabling the add-on in `<env>.tfvars` file.
**AWS LB Ingress controller** triggers the creation of an LB Ingress Controller, and the necessary supporting AWS resources whenever a Kubernetes user declares an Ingress resource in the cluster.
[ALB Docs](https://Kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)

* [Traefik Ingress Controller](kubernetes-addons/traefik-ingress/README.md) can be deployed by enabling the add-on in `<env>.tfvars` file.
**Traefik is an open source Kubernetes Ingress Controller**. The Traefik Kubernetes Ingress provider is a Kubernetes Ingress controller; that is to say, it manages access to cluster services by supporting the Ingress specification. For more details about [Traefik can be found here](https://doc.traefik.io/traefik/providers/Kubernetes-ingress/)

* [Nginx Ingress Controller](kubernetes-addons/nginx-ingress/README.md) can be deployed by enabling the add-on in `<env>.tfvars` file.
**Nginx is an open source Kubernetes Ingress Controller**. The Nginx Kubernetes Ingress provider is a Kubernetes Ingress controller; that is to say, it manages access to cluster services by supporting the Ingress specification. For more details about [Nginx can be found here](https://kubernetes.github.io/ingress-nginx/)

## Autoscaling Modules 
**Cluster Autoscaler** and **Metric Server** Helm Modules gets deployed by default with the EKS Cluster.

* [Cluster Autoscaler](kubernetes-addons/cluster-autoscaler/README.md) can be deployed by enabling the add-on in `<env>.tfvars` file.
The Kubernetes  Cluster Autoscaler automatically adjusts the number of nodes in your cluster when pods fail or are rescheduled onto other nodes. It's not deployed by default in EKS clusters.
That is, the AWS Cloud Provider implementation within the Kubernetes  Cluster Autoscaler controls the **DesiredReplicas** field of Amazon EC2 Auto Scaling groups.
The Cluster Autoscaler is typically installed as a **Deployment** in your cluster. It uses leader election to ensure high availability, but scaling is one done by a single replica at a time.

* [Metrics Server](kubernetes-addons/metrics-server/README.md) can be deployed by enabling the add-on in `<env>.tfvars` file.
The Kubernetes  Metrics Server, used to gather metrics such as cluster CPU and memory usage over time, is not deployed by default in EKS clusters.

## Logging and Monitoring
**FluentBit** is an open source Log Processor and Forwarder which allows you to collect any data like metrics and logs from different sources, enrich them with filters and send them to multiple destinations.

* [aws-for-fluent-bit](kubernetes-addons/aws-for-fluent-bit/README.md) can be deployed by enabling the add-on in `<env>.tfvars` file.
AWS provides a Fluent Bit image with plugins for both CloudWatch Logs and Kinesis Data Firehose. The AWS for Fluent Bit image is available on the Amazon ECR Public Gallery.
For more details, see [aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit) on the Amazon ECR Public Gallery.

* [fargate-fluentbit](kubernetes-addons/fargate-fluentbit) can be deployed by enabling the add-on in `<env>.tfvars` file.
This module ships the Fargate Container logs to CloudWatch

## Bottlerocket OS

[Bottlerocket](https://aws.amazon.com/bottlerocket/) is an open source operating system specifically designed for running containers. Bottlerocket build system is based on Rust. It's a container host OS and doesn't have additional software's or package managers other than what is needed for running containers hence its very light weight and secure. Container optimized operating systems are ideal when you need to run applications in Kubernetes  with minimal setup and do not want to worry about security or updates, or want OS support from  cloud provider. Container operating systems does updates transactionally.

Bottlerocket has two containers runtimes running. Control container **on** by default used for AWS Systems manager and remote API access. Admin container **off** by default for deep debugging and exploration.

Bottlerocket [Launch templates userdata](modules/aws-eks-managed-node-groups/templates/userdata-bottlerocket.tpl) uses the TOML format with Key-value pairs. 
Remote API access API via SSM agent. You can launch trouble shooting container via user data `[settings.host-containers.admin] enabled = true`.

### Features
* [Secure](https://github.com/bottlerocket-os/bottlerocket/blob/develop/SECURITY_FEATURES.md) - Opinionated, specialized and highly secured
* **Flexible** - Multi cloud and multi orchestrator
* **Transactional** -  Image based upgraded and rollbacks
* **Isolated** - Separate container Runtimes

### Updates
Bottlerocket can be updated automatically via Kubernetes  Operator

```shell script
    kubectl apply -f Bottlerocket_k8s.csv.yaml
    kubectl get ClusterServiceVersion Bottlerocket_k8s | jq.'status'
```

# How to Deploy

## Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deployment Steps
The following steps walks you through the deployment of example [DEV cluster](deploy/live/preprod/eu-west-1/application/dev/dev.tfvars) configuration. This config deploys a private EKS cluster with public and private subnets.

Two managed worker nodes with On-Demand and Spot instances along with one fargate profile for default namespace placed in private subnets. ALB placed in Public subnets created by AWS LB Ingress controller.

It also deploys few kubernetes apps i.e., AWS LB Ingress Controller, Metrics Server, Cluster Autoscaler, aws-for-fluent-bit CloudWatch logging for Managed node groups, FluentBit CloudWatch logging for Fargate etc.

### Provision VPC (optional) and EKS cluster with enabled Kubernetes Addons

#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step2: Update <env>.tfvars file

Update `~/aws-eks-accelerator-for-terraform/live/preprod/eu-west-1/application/dev/dev.tfvars` file with the instructions specified in the file (OR use the default values). 
You can choose to use an existing VPC ID and Subnet IDs or create a new VPC and subnets by providing CIDR ranges in `dev.tfvars` file

####  Step3: Update Terraform backend config file

Update `~/aws-eks-accelerator-for-terraform/live/preprod/eu-west-1/application/dev/backend.conf` with your local directory path or s3 path. 
[state.tf](state.tf) file contains backend config.

Local terraform state backend config variables

```hcl-terraform
    path = "local_tf_state/ekscluster/preprod/application/dev/terraform-main.tfstate"
```

It's highly recommended to use remote state in S3 instead of using local backend. The following variables needs filling for S3 backend.

```hcl-terraform
    bucket = "<s3 bucket name>"
    region = "<aws region>"
    key    = "ekscluster/preprod/application/dev/terraform-main.tfstate"
```

#### Step4: Assume IAM role before creating a EKS cluster.
This role will become the Kubernetes  Admin by default. Please see this document for [assuming a role](https://aws.amazon.com/premiumsupport/knowledge-center/iam-assume-role-cli/)

#### Step5: Run Terraform INIT
to initialize a working directory with configuration files

```shell script
terraform init -backend-config deploy/live/preprod/eu-west-1/application/dev/backend.conf
```


#### Step6: Run Terraform PLAN
to verify the resources created by this execution

```shell script
terraform plan -var-file deploy/live/preprod/eu-west-1/application/dev/dev.tfvars
```

#### Step7: Finally, Terraform APPLY
to create resources

```shell script
terraform apply -var-file deploy/live/preprod/eu-west-1/application/dev/<env>.tfvars
```

**Alternatively you can use Makefile to deploy by skipping Step5, Step6 and Step7**

### Deploy EKS Cluster using [Makefile](Makefile)

#### Executing Terraform PLAN
    $ make tf-plan-eks env=<env> region=<region> account=<account> subenv=<subenv>
    e.g.,
    $ make tf-plan-eks env=preprod region=eu-west-1 account=application subenv=dev

#### Executing Terraform APPLY
    $ make tf-apply-eks env=<env> region=<region> account=<account> subenv=<subenv>
    e.g.,
    $ make tf-apply-eks env=preprod region=eu-west-1 account=application subenv=dev

#### Executing Terraform DESTROY
    $ make tf-destroy-eks env=<env> region=<region> account=<account> subenv=<subenv>
    e.g.,
    make tf-destroy-eks env=preprod region=eu-west-1 account=application subenv=dev

### Configure kubectl and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step8: Run update-kubeconfig command.

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region eu-west-1 update-kubeconfig --name <cluster-name>

#### Step9: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step10: List all the pods running in kube-system namespace

    $ kubectl get pods -n kube-system

## Deploying example templates
The `examples` folder contains multiple cluster templates with pre-populated `.tfvars` which can be used as a quick start. Reuse the templates from `examples` and follow the above Deployment steps as mentioned above.

# EKS Addons update
Amazon EKS doesn't modify any of your Kubernetes add-ons when you update a cluster to newer versions.
It's important to upgrade EKS Addons [Amazon VPC CNI](https://github.com/aws/amazon-vpc-cni-k8s), [DNS (CoreDNS)](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html) and [KubeProxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html) for each EKS release.

This [README](eks_cluster_addons_upgrade/README.md) guides you to update the EKS Cluster and the addons for newer versions that matches with your EKS cluster version

Updating a EKS cluster instructions can be found in [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html).

# Important note
This module tested only with **Kubernetes v1.20 version**. Kubernetes addons modules aligned with k8s v1.20. If you are looking to use this code to deploy different versions of Kubernetes then ensure Helm charts and docker images aligned with k8s version.

The `Kubernetes_version="1.20"` is the required variable in `<env>.tfvars`. Kubernetes  is evolving a lot, and each major version includes new features, fixes, or changes.

Always check [Kubernetes Release Notes](https://Kubernetes.io/docs/setup/release/notes/) before updating the major version. You also need to ensure your applications and Helm addons updated,
or workloads could fail after the upgrade is complete. For action, you may need to take before upgrading, see the steps in the EKS documentation.

# Notes:
If you are using an existing VPC then you may need to ensure that the following tags added to the VPC and subnet resources

Add Tags to **VPC**

```hcl-terraform
    Key = Kubernetes .io/cluster/${local.cluster_name} Value = Shared
```

Add Tags to **Public Subnets tagging** requirement

```hcl-terraform
      public_subnet_tags = {
        "Kubernetes .io/cluster/${local.cluster_name}" = "shared"
        "Kubernetes .io/role/elb"                      = "1"
      }
```

Add Tags to **Private Subnets tagging** requirement

```hcl-terraform
      private_subnet_tags = {
        "Kubernetes .io/cluster/${local.cluster_name}" = "shared"
        "Kubernetes .io/role/internal-elb"             = "1"
      }
```

For fully Private EKS clusters requires the following VPC endpoints to be created to communicate with AWS services. This module will create these endpoints if you choose to create VPC. If you are using an existing VPC then you may need to ensure these endpoints are created.

    com.amazonaws.region.aps-workspaces            - For AWS Managed Prometheus Workspace
    com.amazonaws.region.ssm                       - Secrets Management
    com.amazonaws.region.ec2
    com.amazonaws.region.ecr.api
    com.amazonaws.region.ecr.dkr
    com.amazonaws.region.logs                       – For CloudWatch Logs
    com.amazonaws.region.sts                        – If using AWS Fargate or IAM roles for service accounts
    com.amazonaws.region.elasticloadbalancing       – If using Application Load Balancers
    com.amazonaws.region.autoscaling                – If using Cluster Autoscaler
    com.amazonaws.region.s3                         – Creates S3 gateway


# Author
Created by [Vara Bonthu](https://github.com/vara-bonthu). Maintained by [Ulaganathan N](https://github.com/UlaganathanNamachivayam), [Jomcy Pappachen](https://github.com/jomcy-amzn)

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
