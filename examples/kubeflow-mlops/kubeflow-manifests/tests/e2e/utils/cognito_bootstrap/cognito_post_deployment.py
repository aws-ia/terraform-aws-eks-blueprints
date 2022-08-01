# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import logging
from e2e.utils.cognito_bootstrap import common

from e2e.utils.aws.elbv2 import ElasticLoadBalancingV2
from e2e.utils.aws.route53 import Route53HostedZone
from e2e.utils.utils import print_banner, load_yaml_file

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def update_hosted_zone_with_alb(
    subdomain_name: str,
    subdomain_hosted_zone_id: str,
    alb_dns: str,
    deployment_region: str,
):
    subdomain_hosted_zone = Route53HostedZone(
        domain=subdomain_name, id=subdomain_hosted_zone_id
    )

    _platform_record = subdomain_hosted_zone.generate_change_record(
        record_name="*." + subdomain_name, record_type="CNAME", record_value=[alb_dns]
    )

    # https://aws.amazon.com/premiumsupport/knowledge-center/alias-resource-record-set-route53-cli/
    # creating a alias type record for ELB
    # dual stack prefix is needed when creating an alias dns record for ELB
    alb = ElasticLoadBalancingV2(dns=alb_dns, region=deployment_region)
    alb_details = alb.describe()
    updated_subdomain_A_record = (
        subdomain_hosted_zone.generate_change_record_type_alias_target(
            record_name=subdomain_name,
            record_type="A",
            hosted_zone_id=alb_details["CanonicalHostedZoneId"],
            dns_name="dualstack." + alb_dns,
        )
    )

    subdomain_hosted_zone.change_record_set(
        [
            _platform_record,
            updated_subdomain_A_record,
        ]
    )


if __name__ == "__main__":
    config_file_path = common.CONFIG_FILE
    print_banner("Reading Config")
    cfg = load_yaml_file(file_path=config_file_path)

    deployment_region = cfg["cluster"]["region"]
    subdomain_name = cfg["route53"]["subDomain"]["name"]
    subdomain_hosted_zone_id = cfg["route53"]["subDomain"].get("hostedZoneId", None)
    alb_dns = cfg["kubeflow"]["alb"]["dns"]

    print_banner("Updating hosted zone with ALB DNS")
    update_hosted_zone_with_alb(
        subdomain_name, subdomain_hosted_zone_id, alb_dns, deployment_region
    )
