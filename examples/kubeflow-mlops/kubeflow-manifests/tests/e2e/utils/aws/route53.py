# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

from typing import Any, Dict
import boto3
import logging
import random
import string

from botocore.exceptions import ClientError, WaiterError
from typing import Dict

logger = logging.getLogger(__name__)


class Route53HostedZone:
    """
    Encapsulates route53 functions.
    """

    def __init__(
        self,
        domain: str,
        id: str = None,
        route53_client: Any = None,
        region: str = "us-east-1",
    ):
        """
        :param route53_client: A Boto3 route53 client.
        :param domain: domain corresponding to this reference
        """
        self.route53_client = route53_client or boto3.client(
            "route53", region_name=region
        )
        self.domain = domain
        self.id = id

    def create_zone(self) -> dict:
        randstr = "".join(
            random.choice(string.ascii_lowercase + string.digits) for _ in range(10)
        )
        try:
            response = self.route53_client.create_hosted_zone(
                Name=self.domain,
                CallerReference=f"{self.domain}-{randstr}",
            )
        except ClientError:
            logger.exception(
                f"failed to create hosted zone for {self.domain} with CallerReference: {randstr}"
            )
            raise
        else:
            self.id = response["HostedZone"]["Id"].split("/")[-1]
            logger.info(f"created hosted zone {self.domain} with id {self.id}")
            return response

    def get_zone(self) -> dict:
        try:
            response = self.route53_client.get_hosted_zone(Id=self.id)
        except ClientError:
            logger.exception(f"failed to describe hosted zone for {self.domain}")
            raise
        else:
            return response

    def get_name_servers(self) -> list:
        return self.get_zone()["DelegationSet"]["NameServers"]

    def generate_change_record(
        self,
        record_name: str,
        record_type: str,
        record_value: list,
        action: str = "UPSERT",
    ) -> dict:
        """
        UPSERT: If a record does not already exist, Amazon Web Services creates it. If a record does exist, Route 53 updates it with the values in the request.
        https://docs.aws.amazon.com/Route53/latest/APIReference/API_ChangeResourceRecordSets.html
        """
        resource_records = []
        for value in record_value:
            resource_records.append({"Value": value})
        return {
            "Action": action,
            "ResourceRecordSet": {
                "Name": record_name,
                "Type": record_type,
                "ResourceRecords": resource_records,
                "TTL": 300,
            },
        }

    def generate_change_record_type_alias_target(
        self,
        record_name: str,
        record_type: str,
        hosted_zone_id: str,
        dns_name: str,
        action: str = "UPSERT",
    ) -> dict:
        """
        UPSERT: If a record does not already exist, Amazon Web Services creates it. If a record does exist, Route 53 updates it with the values in the request.
        https://docs.aws.amazon.com/Route53/latest/APIReference/API_ChangeResourceRecordSets.html
        """
        return {
            "Action": action,
            "ResourceRecordSet": {
                "Name": record_name,
                "Type": record_type,
                "AliasTarget": {
                    "HostedZoneId": hosted_zone_id,
                    "DNSName": dns_name,
                    "EvaluateTargetHealth": False,
                },
            },
        }

    def wait_record_changed(self, change_id: str, records: list):
        waiter = self.route53_client.get_waiter("resource_record_sets_changed")
        try:
            logger.info(
                f"waiting for for change id: {change_id} to be IN_SYNC in hosted zone: {self.id}, domain: {self.domain}"
            )
            waiter.wait(Id=change_id)
        except WaiterError:
            logger.exception(
                f"timed out waiting for change id: {change_id} to be IN_SYNC. records: {records}"
            )

    def change_record_set(self, record_changes: list) -> dict:
        try:
            response = self.route53_client.change_resource_record_sets(
                HostedZoneId=self.id, ChangeBatch={"Changes": record_changes}
            )
            self.wait_record_changed(
                response["ChangeInfo"]["Id"].split("/")[-1], record_changes
            )
        except ClientError:
            logger.exception(f"failed to change record set for {record_changes}")
            raise
        else:
            return response

    def list_record_set(self) -> dict:
        try:
            response = self.route53_client.list_resource_record_sets(
                HostedZoneId=self.id
            )
        except ClientError:
            logger.exception(f"failed to list record set for {self.domain}")
            raise
        else:
            return response

    def delete_hosted_zone(self):
        records = self.list_record_set()["ResourceRecordSets"]
        change_set = []
        for record in records:
            if record["Type"] != "NS" and record["Type"] != "SOA":
                change_set.append({"Action": "DELETE", "ResourceRecordSet": record})
        if len(change_set) > 0:
            self.change_record_set(change_set)
        try:
            self.route53_client.delete_hosted_zone(Id=self.id)
            logger.info(f"deleted hosted zone {self.id}")
        except ClientError:
            logger.exception(f"failed to delete hosted zone {self.id}")
            raise
