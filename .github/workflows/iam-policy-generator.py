import json
import boto3
import os

iam_actions = []
s3 = boto3.resource('s3')
bucket_name = os.getenv('BUCKET_NAME')
bucket = s3.Bucket(bucket_name)
bucket_files = [x.key for x in bucket.objects.all()]

# Read all the files from the bucket
for file in bucket_files:
    obj = s3.Object(bucket_name, file)
    f = obj.get()['Body'].read()
    data = json.loads(f)
    # Merge all policies actions, keep them unique with 'set'
    for statement in data['Statement']:
        iam_actions = list(set(iam_actions + statement['Action']))

# Skeleton IAM policy template , wild card all resources for now.
template = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
            ],
            "Resource": "*"
        }
    ]
}

# Apply merged actions to the skeleton IAM policy
template['Statement'][0]['Action'] = sorted(iam_actions)
print(json.dumps(template, indent=4))
