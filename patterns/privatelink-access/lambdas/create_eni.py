import boto3
import logging
import os
import json

ELBV2_CLIENT = boto3.client('elbv2')

TARGET_GROUP_ARN = os.environ['TARGET_GROUP_ARN']


class StructuredMessage:
    def __init__(self, message, /, **kwargs):
        self.message = message
        self.kwargs = kwargs

    def __str__(self):
        return '%s >>> %s' % (self.message, json.dumps(self.kwargs))

_ = StructuredMessage # optional, to improve readability
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

def handler(event, context):
    # Only modify on CreateNetworkInterface events
    if event["detail"]["eventName"] == "CreateNetworkInterface":
        ip = event['detail']['responseElements']['networkInterface']['privateIpAddress']

        # Add the extracted private IP address of the ENI as an IP target in the target group
        try:
            logger.info('IP address %s is identified as belonging to one of the cluster endpoint ENIs', ip)
            response = ELBV2_CLIENT.register_targets(
                TargetGroupArn = TARGET_GROUP_ARN,
                Targets=[{
                    'Id': ip,
                    'Port': 443
                }]
            )
            logger.info(_(response))
        except Exception as e:
            logger.error(_(e))
            raise(e)
