# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import yaml
import logging

logger = logging.getLogger(__name__)

CONFIG_FILE = "./utils/cognito_bootstrap/config.yaml"

# For creating an alias record to other AWS resource, route53 needs hosted zone id and DNS name.
# Since CloudFront is a global service, there is only one hosted zone id
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-route53-aliastarget.html
CLOUDFRONT_HOSTED_ZONE_ID = "Z2FDTNDATAQYW2"
