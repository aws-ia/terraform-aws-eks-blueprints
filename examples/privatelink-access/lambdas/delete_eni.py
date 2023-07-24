import boto3
import logging
import os
import json

ELBV2_CLIENT = boto3.client('elbv2')
EC2_CLIENT = boto3.client('ec2')

TARGET_GROUP_ARN = os.environ['TARGET_GROUP_ARN']


class StructuredMessage:
    def __init__(self, message, /, **kwargs):
        self.message = message
        self.kwargs = kwargs

    def __str__(self):
        return '%s >>> %s' % (self.message, json.dumps(self.kwargs))

_ = StructuredMessage # optional, to improve readability
logging.basicConfig(level=logging.DEBUG, format='%(message)s')


def handler(event, context):

    unhealthyTargetIPAddresses   = []
    eksApiEndpointEniIPAddresses = []
    unhealthyTargetsToDeregister = []

    targetHealthDescriptions = ELBV2_CLIENT.describe_target_health(
        TargetGroupArn=TARGET_GROUP_ARN,
    )['TargetHealthDescriptions']

    if not targetHealthDescriptions:
        logging.info("Did not find any TargetHealthDescriptions, quitting!")
        return

    # Iterate over the list of TargetHealthDescriptions and extract the list of
    # unhealthy targets
    for targetHealthDescription in targetHealthDescriptions:
        if targetHealthDescription["TargetHealth"]["State"] == "unhealthy":
            unhealthyTargetIPAddress = targetHealthDescription["Target"]["Id"]
            unhealthyTargetIPAddresses.append(unhealthyTargetIPAddress)

    networkInterfaces = EC2_CLIENT.describe_network_interfaces(
        Filters=[
            {
                'Name': 'description',
                'Values': [
                    f'Amazon EKS {os.environ["EKS_CLUSTER_NAME"]}',
                ]
            },
        ],
    )['NetworkInterfaces']

    if not networkInterfaces:
        logging.info("Did not find any EKS API ENIs to compare with, quitting!")
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

    if not unhealthyTargetsToDeregister:
        logging.info("There are no unhealthy targets to deregister, quitting!")
        return

    logging.info("Targets are to be deregistered: %s", unhealthyTargetsToDeregister)

    try:
        response = ELBV2_CLIENT.deregister_targets(
            TargetGroupArn = TARGET_GROUP_ARN,
            Targets=unhealthyTargetsToDeregister
        )
        logging.info(_(response))
    except Exception as e:
        logging.error(_(e))
        raise(e)
