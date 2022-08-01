# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import json
import boto3
import logging

from botocore.exceptions import ClientError
from typing import Any

from e2e.utils.utils import wait_for

logger = logging.getLogger(__name__)


class IAMPolicy:
    """
    Encapsulates IAMPolicy functions.
    """

    def __init__(
        self, name: str = None, region: str = "us-east-1", iam_client: Any = None, arn: str = None,
    ):
        self.region = region
        self.iam_client = iam_client or boto3.client("iam", region_name=region)
        self.name = name
        self.arn = arn
        if not name and not arn:
            raise ValueError("Either policy name or arn should be defined")
    
    def create(
        self, policy_document: dict
    ):
        try:
            response = self.iam_client.create_policy(
                PolicyName=self.name,
                PolicyDocument=json.dumps(policy_document)
            )
        except ClientError:
            logger.exception(
                f"failed to create IAM policy {self.name}"
            )
            raise
        else:
            self.arn = response["Policy"]["Arn"]
            logger.info(
                f"created iam policy {self.arn}."
            )
            return self.arn
    
    def delete(self):
        try:
            self.iam_client.delete_policy(
                PolicyArn=self.arn
            )
            logger.info(f"deleted iam policy {self.arn}")
        except ClientError:
            logger.exception(f"failed to delete iam policy {self.arn}")
            raise
    
    def wait_for_policy_detachments(self):
        """
        Policies can't be deleted unless they are not attached to any IAM resources.

        Describes any IAM resources this policy is attached to. If not attached to any resources, the method returns successfully. Else, times out.
        """

        def callback():
            resp = self.iam_client.list_entities_for_policy(
                PolicyArn=self.arn
            )

            assert len(resp['PolicyGroups']) == 0
            assert len(resp['PolicyUsers']) == 0
            assert len(resp['PolicyRoles']) == 0
        
        wait_for(callback)
