import boto3
import os

nlbClient = boto3.client('elbv2')
ec2Client = boto3.client('ec2')

targetGroupARN = os.environ['TARGET_GROUP_ARN']
eksClusterName = os.environ['EKS_CLUSTER_NAME']

def lambda_handler(event, context):
        
    unhealthyTargetIPAddresses   = []
    eksApiEndpointEniIPAddresses = []
    unhealthyTargetsToDeregister = []

    targetHealthDescriptions = nlbClient.describe_target_health(
        TargetGroupArn=targetGroupARN,
    )['TargetHealthDescriptions']

    if targetHealthDescriptions is None:
        print("Did not find any TargetHealthDescriptions, quitting!")
        return

    # Iterate over the list of TargetHealthDescriptions and extract the list of 
    # unhealthy targets
    for targetHealthDescription in targetHealthDescriptions:
        if targetHealthDescription["TargetHealth"]["State"] == "unhealthy":
            unhealthyTargetIPAddress = targetHealthDescription["Target"]["Id"]
            unhealthyTargetIPAddresses.append(unhealthyTargetIPAddress)

    networkInterfaces = ec2Client.describe_network_interfaces(
        Filters=[
            {
                'Name': 'description',
                'Values': [
                    'Amazon EKS '+eksClusterName,
                ]
            },
        ],
    )['NetworkInterfaces']

    if networkInterfaces is None:
        print("Did not find any EKS API ENIs to compare with, quitting!")
        return
   
    for networkInterface in networkInterfaces:
        eksApiEndpointEniIPAddresses.append(
            networkInterface["PrivateIpAddress"]
        )
    
    for unhealthyTargetIPAddress in unhealthyTargetIPAddresses:
        if unhealthyTargetIPAddress not in eksApiEndpointEniIPAddresses:
            unhealthyTarget = {
                'Id': unhealthyTargetIPAddress,
                'Port': 443                
            }
            unhealthyTargetsToDeregister.append(unhealthyTarget)
    
    if len(unhealthyTargetsToDeregister) == 0:
        print("There are no unhealthy targets to deregister, quitting!")
        return

    print("Targets are to be deregistered \n"+str(unhealthyTargetsToDeregister))

    try:
        response = nlbClient.deregister_targets(
            TargetGroupArn = targetGroupARN,
            Targets=unhealthyTargetsToDeregister
        )
        print(response)
    except Exception as e:
        print(e)
        raise(e)    

    return 
