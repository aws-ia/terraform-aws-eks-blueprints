# How to deploy and test the k8s manifest with Nginx Ingress Controller

## Step1: Apply Manifest

    kubectl apply -f on_demand_deployment.yaml
    kubectl apply -f spot_deployment.yaml
    
    
## Step2: Get DNS Name

    Get the DNS name for AWS LB created by the Nginx Ingress Controller deployment from EC2 Console.
    

## Step3: Test the Service

Open browser with the following URLs to test the deployment,

        To Access On-Demand Deployment Service,
                http://a16f13ce05b034a2cbec789b6b492c3c-127201056.eu-west-1.elb.amazonaws.com/
    
        To Access Spot Deployment service,
                http://a16f13ce05b034a2cbec789b6b492c3c-127201056.eu-west-1.elb.amazonaws.com/spot-greeting/?name=ulag


