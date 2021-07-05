# How to deploy and test the k8s manifest with AWS LB Ingress Controller

## Step1: Apply Manifest

    kubectl apply -f fargate_sample_nginx_stack.yaml
    kubectl apply -f fargate_sample_nginx_deployment_nlb.yaml
    
## Step2: Get DNS Name

    Get the DNS name for AWS ALB created by the ALB Ingress Controller deployment
    
    e.g., http://k8s-default-ingressn-sdf34343-1523530034.eu-west-1.elb.amazonaws.com/

## Step3: Test the Service

Open browser with the following URLs to test the deployment 

    http://k8s-default-ingressn-2e2fea27bc-1523530034.eu-west-1.elb.amazonaws.com/app1/index.html
    
    http://k8s-default-ingressn-2e2fea27bc-1523530034.eu-west-1.elb.amazonaws.com/app2/index.html

