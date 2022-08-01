# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import boto3
import logging

from botocore.exceptions import ClientError
from typing import Any

logger = logging.getLogger(__name__)


class ElasticLoadBalancingV2:
    """
    Encapsulates ELBv2 functions.
    """

    def __init__(
        self, dns: str = None, region: str = "us-east-1", elbv2_client: Any = None
    ):
        self.dns = dns
        self.region = region
        self.elbv2_client = elbv2_client or boto3.client("elbv2", region_name=region)
        self.name = self.get_name_from_dns(dns)

    def describe(self) -> dict:
        try:
            response = self.elbv2_client.describe_load_balancers(
                Names=[
                    self.name,
                ]
            )
        except ClientError:
            logger.exception(f"Failed to describe load balancer {self.name}")
        else:
            return response["LoadBalancers"][0]

    def get_name_from_dns(self, dns: str):
        """
        Workaround to extract load balancer name from dns.

        If ALB DNS is 72d70454-istiosystem-istio-2ab2-xxxxxxxxxx.us-east-1.elb.amazonaws.com
        ALB name is 72d70454-istiosystem-istio-2ab2
        """
        dns_prefix = dns.split(".")[0]
        last_hypen_index = dns_prefix.rfind("-")
        if last_hypen_index != -1:
            return dns[:last_hypen_index]
        else:
            return dns_prefix
