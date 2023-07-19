import boto3
import os

nlbClient = boto3.client('elbv2')

targetGroupARN = os.environ['TARGET_GROUP_ARN']

def handler(event, context):
    # Only modify on CreateNetworkInterface events
    if event["detail"]["eventName"] == "CreateNetworkInterface":
        ip = event['detail']['responseElements']['networkInterface']['privateIpAddress']

        # Add the extracted private IP address of the ENI as an IP target in the target group
        try:
            response = nlbClient.register_targets(
                TargetGroupArn = targetGroupARN,
                Targets=[{
                    'Id': ip,
                    'Port': 443
                }]
            )
            print(response)
        except Exception as e:
            print(e)
            raise(e)
