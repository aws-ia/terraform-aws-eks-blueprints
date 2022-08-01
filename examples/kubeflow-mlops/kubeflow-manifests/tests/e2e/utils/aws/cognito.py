# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import boto3
import logging
import time

from botocore.exceptions import ClientError
from typing import Any

logger = logging.getLogger(__name__)


class CustomDomainCognitoUserPool:
    """
    Encapsulates functions to create a Cognito Userpool with custom domain
    """

    def __init__(
        self,
        userpool_name: str,
        userpool_domain: str,
        domain_cert_arn: str,
        userpool_id: str = None,
        region: str = "us-east-1",
        cognito_client: Any = None,
    ):
        self.userpool_name = userpool_name
        self.userpool_domain = userpool_domain
        self.domain_cert_arn = domain_cert_arn
        self.region = region
        self.cognito_client = cognito_client or boto3.client(
            "cognito-idp", region_name=region
        )
        self.userpool_id = userpool_id
        self.arn = None
        self.client_id = None
        self.cloudfront_domain = None

    def create_userpool(self) -> str:
        try:
            response = self.cognito_client.create_user_pool(PoolName=self.userpool_name,
            AliasAttributes=['email'],
            Schema=[
                {
                    "Name": "email",
                    "AttributeDataType": "String",
                    "Mutable": True,
                    "Required": True,
                }
            ],
            AdminCreateUserConfig={
                'AllowAdminCreateUserOnly': True
            })
        except ClientError:
            logger.exception(
                f"Failed to create userpool {self.userpool_name} in {self.region}"
            )
            raise
        else:
            self.userpool_id = response["UserPool"]["Id"]
            self.arn = response["UserPool"]["Arn"]
            logger.info(
                f"created userpool: {self.userpool_name} with id: {self.userpool_id}, arn: {self.arn}"
            )
            return self.arn

    def create_userpool_domain(self) -> str:
        try:
            response = self.cognito_client.create_user_pool_domain(
                Domain=self.userpool_domain,
                UserPoolId=self.userpool_id,
                CustomDomainConfig={"CertificateArn": self.domain_cert_arn},
            )
        except ClientError:
            logger.exception(f"failed to create custom domain {self.userpool_domain}")
            raise
        else:
            self.cloudfront_domain = response["CloudFrontDomain"]
            logger.info(
                f"created custom domain {self.userpool_domain} with cloudfront url: {self.cloudfront_domain}"
            )
            return self.cloudfront_domain

    def describe_userpool_domain(self) -> dict:
        try:
            response = self.cognito_client.describe_user_pool_domain(
                Domain=self.userpool_domain
            )
        except ClientError:
            logger.exception(
                f"failed to describe userpool domain {self.userpool_domain}"
            )
            raise
        else:
            return response

    def create_userpool_client(self, client_name: str, callback_urls: list, logout_urls: list) -> str:
        try:
            response = self.cognito_client.create_user_pool_client(
                UserPoolId=self.userpool_id,
                ClientName=client_name,
                GenerateSecret=True,
                SupportedIdentityProviders=["COGNITO"],
                CallbackURLs=callback_urls,
                LogoutURLs=logout_urls,
                AllowedOAuthFlowsUserPoolClient=True,
                AllowedOAuthFlows=["code"],
                AllowedOAuthScopes=[
                    "email",
                    "openid",
                    "aws.cognito.signin.user.admin",
                    "profile",
                ],
            )
        except ClientError:
            logger.exception(
                f"failed to create user pool client {client_name} in {self.arn}"
            )
            raise
        else:
            self.client_id = response["UserPoolClient"]["ClientId"]
            logger.info(f"created app client: {client_name} with id: {self.client_id}")
            return self.client_id

    def get_domain_status(self) -> str:
        return self.describe_userpool_domain()["DomainDescription"]["Status"]

    def wait_for_domain_status(
        self,
        expected_status: str = "ACTIVE",
        wait_periods: int = 34,
        period_length: int = 30,
    ):
        current_status = self.get_domain_status()
        logger.info(
            f"{self.userpool_domain}: waiting for domain status = {expected_status} ..."
        )
        for _ in range(wait_periods):
            if current_status == expected_status:
                break
            time.sleep(period_length)
            current_status = self.get_domain_status()
        else:
            raise Exception(
                f"timed out waiting for user user pool domain status: {expected_status} for domain. current status: {current_status}"
            )

    def delete_userpool_domain(self):
        try:
            self.cognito_client.delete_user_pool_domain(
                Domain=self.userpool_domain, UserPoolId=self.userpool_id
            )
            logger.info(f"deleted userpool domain {self.userpool_domain}")
        except ClientError:
            logger.exception(f"failed to delete userpool domain {self.userpool_domain}")
            raise

    def delete_userpool(self):
        try:
            self.cognito_client.delete_user_pool(UserPoolId=self.userpool_id)
            logger.info(f"deleted userpool {self.userpool_id}")
        except ClientError:
            logger.exception(f"failed to delete userpool {self.arn}")
            raise
