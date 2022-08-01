# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import logging
import subprocess
import time

from e2e.fixtures import cluster
from e2e.utils.load_balancer import common

from e2e.utils.aws.acm import AcmCertificate
from e2e.utils.aws.elbv2 import ElasticLoadBalancingV2
from e2e.utils.aws.iam import IAMPolicy
from e2e.utils.aws.route53 import Route53HostedZone
from e2e.utils.utils import (
    kubectl_delete_kustomize,
    print_banner,
    load_yaml_file,
    wait_for,
)


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def delete_cert(acm_certificate):
    try:
        acm_certificate.delete()
    except Exception:
        pass


def clean_root_domain(domain_name, hosted_zone_id, subdomain_hosted_zone):
    root_hosted_zone = Route53HostedZone(
        domain=domain_name,
        id=hosted_zone_id,
    )

    try:
        # delete the subdomain entry from the root domain
        subdomain_NS_record = subdomain_hosted_zone.generate_change_record(
            record_name=subdomain_hosted_zone.domain,
            record_type="NS",
            record_value=subdomain_hosted_zone.get_name_servers(),
            action="DELETE",
        )
        root_hosted_zone.change_record_set([subdomain_NS_record])
    except Exception:
        pass


def delete_alb(alb_dns: str, region: str):
    subprocess.call(f"kubectl delete ingress -n istio-system istio-ingress".split())
    # load balancer controller does not place a finalizer on the ingress and so deleting the attached load balancer is asynhronous
    # adding a random wait to allow controller to delete the load balancer
    alb = ElasticLoadBalancingV2(dns=alb_dns, region=region)
    logger.info(f"{alb_dns}: waiting for deletion ...")

    def callback():
        assert alb.describe() is None

    wait_for(callback)


def delete_policy(arn: str, region: str):
    try:
        policy = IAMPolicy(arn=arn, region=region)
        # retry because of delay in IAM service for the role deletion to free up in the policy attachments
        def callback():
            policy.delete()

        wait_for(callback)
    except Exception:
        pass


def delete_ingress():
    kubectl_delete_kustomize(path=common.LB_KUSTOMIZE_PATH)


def delete_lb_resources(cfg: dict):
    deployment_region = cfg["cluster"]["region"]
    cluster_name = cfg["cluster"]["name"]
    subdomain_hosted_zone_id = cfg["route53"]["subDomain"].get("hostedZoneId", None)
    root_domain_hosted_zone_id = cfg["route53"]["rootDomain"].get("hostedZoneId", None)

    subdomain_hosted_zone = None

    if subdomain_hosted_zone_id:
        subdomain_name = cfg["route53"]["subDomain"]["name"]
        subdomain_hosted_zone = Route53HostedZone(
            domain=subdomain_name,
            id=subdomain_hosted_zone_id,
        )

        if root_domain_hosted_zone_id:
            clean_root_domain(
                domain_name=cfg["route53"]["rootDomain"]["name"],
                hosted_zone_id=root_domain_hosted_zone_id,
                subdomain_hosted_zone=subdomain_hosted_zone,
            )
            root_cert_arn = cfg["route53"]["rootDomain"].get("certARN", None)
            if root_cert_arn:
                delete_cert(
                    acm_certificate=AcmCertificate(
                        arn=root_cert_arn, region=deployment_region
                    )
                )

        subdomain_cert_deployment_region_arn = cfg["route53"]["subDomain"].get(
            "certARN", None
        )

        if subdomain_cert_deployment_region_arn:
            subdomain_cert_deployment_region = AcmCertificate(
                arn=subdomain_cert_deployment_region_arn, region=deployment_region
            )

        # delete ALB
        if "kubeflow" in cfg.keys():
            alb = cfg["kubeflow"].get("alb", None)
            alb_dns = alb.get("dns", None)
            if alb:
                if alb_dns:
                    delete_alb(alb_dns=alb_dns, region=deployment_region)
                alb_sa = alb.get("serviceAccount", None)
                if alb_sa:
                    cluster.delete_iam_service_account(
                        alb_sa["name"], alb_sa["namespace"], cluster_name, deployment_region
                    )
                    alb_controller_policy_arn = alb_sa["policyArn"]
                    delete_policy(arn=alb_controller_policy_arn, region=deployment_region)

        # delete subdomain certs
        delete_cert(acm_certificate=subdomain_cert_deployment_region)

        # delete hosted zone
        subdomain_hosted_zone.delete_hosted_zone()

        # delete installed components
        delete_ingress()


if __name__ == "__main__":
    config_file_path = common.CONFIG_FILE
    print_banner("Reading Config")
    cfg = load_yaml_file(file_path=config_file_path)
    delete_lb_resources(cfg)
