import boto3
import os

nlbClient = boto3.client('elbv2')

targetGroupARN = os.environ['TARGET_GROUP_ARN']

def lambda_handler(event, context):

    # Check if the event is of the type CreateNetworkInterface
    if event["detail"]["eventName"] == "CreateNetworkInterface":

        # Extract the Private IP address of the newly created ENI
        ip = event['detail']['responseElements']['networkInterface']['privateIpAddress']

        # We directly add the extracted Private IP address of the ENI as a 
        # target to the target group 
        try:
            response = nlbClient.register_targets(
                TargetGroupArn = targetGroupARN,
                Targets=[{
                    'Id': ip,
                    'Port': 443
                }]
            )
            print(response)
            return(response)
        except Exception as e:
            print(e)
            raise(e)
        
    return 
