import os
import boto3

REGION = os.environ.get('AWS_DEFAULT_REGION', 'us-west-2')
CLIENT = boto3.client('logs', region_name=REGION)

def delete_log_groups():
    """Delete all log groups in the region that start with `/aws/eks/`"""
    response = CLIENT.describe_log_groups(
        logGroupNamePrefix='/aws/eks/',
        limit=50
    )

    for log_group in [log.get('logGroupName') for log in response.get('logGroups', {})]:
        CLIENT.delete_log_group(
            logGroupName=log_group
        )


if __name__ == '__main__':
    delete_log_groups()
