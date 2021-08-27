
# aws-quickstart/ssp-amazon-eks-terraform

In this workshop, we will learn how to use Aamzon EKS Terraform QuickStart repo to deploy the following services

 - **Step1**: Deploy VPC, Private and Public Subnets and all the necessary VPC endpoints
 - **Step2**: Deploy Amazon EKS Cluster (Control Plane only)
 - **Step3**: Deploy three Managed Node groups  (ON-DEMAND, SPOT and BOTTLEROCKET)
 - **Step4**: Deploy multiple Fargate profiles
 - **Step5**: Deploy Addons using Helm Module (e.g., Metrci Server, Cluster Autoscaler, FluentBit etc.)
 - **Step6**: Finally Cleanup the deployed resources


# Deployment Steps

Execute **Step1** only when you are running this workshop using AWS EventEngine. Workshop conducted by the AWS teams at Customer sites

## Step1: Login to Event Engine as advised by AWS team. You may need a temporary AWS Account token for this step

    https://www.eksworkshop.com/020_prerequisites/aws_event/portal/
    
## Step2: Create [Cloud9 IDE in AWS Environment](https://www.eksworkshop.com/020_prerequisites/workspace/#region-1) and install Pre-requisites

Use the following link to install Cloud9 IDE and all the pre-requisites Kubernetes tools

    https://www.eksworkshop.com/020_prerequisites/workspace/#region-1
    
### Step2.1: Install [Kubernetes Tools](https://www.eksworkshop.com/020_prerequisites/k8stools/)
    https://www.eksworkshop.com/020_prerequisites/k8stools/
    
### Step2.2: Create [IAM Role for Workspaces](https://www.eksworkshop.com/020_prerequisites/iamrole/)
    https://www.eksworkshop.com/020_prerequisites/iamrole/
    
### Step2.3: Attach IAM role to Cloud9 IDE and update IAM settings
    https://www.eksworkshop.com/020_prerequisites/ec2instance/
    https://www.eksworkshop.com/020_prerequisites/workspaceiam/ 
    
## Step3: Install `aws-iam-authenticator` in Cloud9 IDE
     curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator
    
     openssl sha1 -sha256 aws-iam-authenticator
    
     chmod +x ./aws-iam-authenticator
    
     mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
    
     echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
    
     Verify the installation
    
     aws-iam-authenticator help

## Step4: Install Terraform in Cloud9 IDE

    sudo yum remove -y terraform

    sudo yum install -y yum-utils
    
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    
    sudo yum -y install terraform-1.0.1
    
    sudo terraform version
    
## Step5: Clone AWS Terraform AWS Accelerator from GITHUB Repo

    git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
    
    cd aws-eks-accelerator-for-terraform/
    
## Step6: Run Terraform init for sample Dev Cluster Configuration
`live/preprod/eu-west-1/application/dev/base.tfvars` file contains the configuration data to create VPC, Subnets, EKS CLuster and Helm Chart for this workshop

`live/preprod/eu-west-1/gaming/test/backend.conf` file contains the config for setting up Terraform backend state. For this workshop we will be using local backend state to avoid creating a new S3 bucket to copy the state files.

To initialize a working directory with configuration files. 

     terraform init -backend-config ./live/preprod/eu-west-1/gaming/test/backend.conf
    
## Step7: Run Terraform plan 
To verify the resources created by this execution

     terraform plan -var-file ./live/preprod/eu-west-1/gaming/test/base.tfvars

## Step8: Finally, Terraform apply 
This step may take up-to 15 to 17 mins to create AWS VPC resources, EKS Cluster and necessary Addons using Helm Provider

     terraform apply -var-file ./live/preprod/eu-west-1/gaming/test/base.tfvars

## Step9: 
     aws eks --region <region> update-kubeconfig --name <eks cluster name>
    
    e.g., $ aws eks --region eu-west-1 update-kubeconfig --name gaming-preprod-test-eks
    
## Step10: Install K9s 
This step is to install K9s client tool to interact with EKS Cluster 

     curl -sS https://webinstall.dev/k9s | bash

Just type k9s after the installation and then you will see the output like this 

         k9s
        
![Alt Text](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/blob/9c6f8ea3e710f7b0137be07835653a2bf4f9fdfe/images/k9s-agones-cluster.png "K9s") 

## Step11: Add EKS Workshop IAM role as EKS Cluster Administrator
    
    $ aws sts get-caller-identity
    
    ROLE="    - rolearn: arn:aws:iam::${ACCOUNT_ID}:role/TeamRole\n      username: admin\n      groups:\n        - system:masters"
    
    kubectl get -n kube-system configmap/aws-auth -o yaml | awk "/mapRoles: \|/{print;print \"$ROLE\";next}1" > /tmp/aws-auth-patch.yml
    
    kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yml)"


   



