# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import logging

from e2e.fixtures import cluster
from e2e.utils.load_balancer import common
from e2e.utils.config import configure_env_file
from e2e.utils.custom_resources import get_ingress
from e2e.utils.aws.acm import AcmCertificate
from e2e.utils.aws.elbv2 import ElasticLoadBalancingV2
from e2e.utils.aws.iam import IAMPolicy
from e2e.utils.aws.route53 import Route53HostedZone
from e2e.fixtures.kustomize import apply_kustomize
from e2e.utils.utils import (
    kubectl_apply_kustomize,
    load_json_file,
    get_eks_client,
    get_ec2_client,
    rand_name,
    print_banner,
    load_yaml_file,
    write_yaml_file,
    wait_for,
)

from typing import Tuple


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


# Step 1: Create a subdomain for kubeflow deployment
def create_subdomain_hosted_zone(
    subdomain_name: str,
    root_domain_name: str,
    deployment_region: str,
    root_domain_hosted_zone_id: str = None,
) -> Tuple[Route53HostedZone, Route53HostedZone]:
    subdomain_hosted_zone = Route53HostedZone(
        domain=subdomain_name, region=deployment_region
    )

    subdomain_hosted_zone.create_zone()

    subdomain_name_servers = subdomain_hosted_zone.get_name_servers()
    subdomains_NS_record = subdomain_hosted_zone.generate_change_record(
        record_name=subdomain_name,
        record_type="NS",
        record_value=subdomain_name_servers,
    )
    root_hosted_zone = None
    if root_domain_hosted_zone_id:
        root_hosted_zone = Route53HostedZone(
            domain=root_domain_name,
            id=root_domain_hosted_zone_id,
            region=deployment_region,
        )
        root_hosted_zone.change_record_set([subdomains_NS_record])
    else:
        logger.info(
            f"Since your {root_domain_name} hosted zone is not managed by route53, you will need to manually create a NS type record in {root_domain_name} for {subdomain_name} with value {subdomain_name_servers}"
        )
        input("Press any key once this step is complete")

    return root_hosted_zone, subdomain_hosted_zone


# Step 2: Create certificates
def create_certificates(
    deployment_region: str,
    subdomain_hosted_zone: Route53HostedZone,
    root_hosted_zone: Route53HostedZone = None,
) -> Tuple[AcmCertificate, AcmCertificate]:
    root_certificate = None
    if root_hosted_zone:
        root_certificate = AcmCertificate(
            domain="*." + root_hosted_zone.domain,
            hosted_zone=root_hosted_zone,
            region=deployment_region,
        )
        root_certificate.request_validation()
        validation_record = root_certificate.generate_domain_validation_record()
        root_certificate.create_domain_validation_records(validation_record)
        root_certificate.wait_for_certificate_validation()
    else:
        logger.info(
            f"Since your {root_hosted_zone.domain} hosted zone is not managed by route53, please create a certificate for *.{root_hosted_zone.domain} by following this document: https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html#request-public-console."
            "Make sure you validate your ceritificate using one of the methods mentioned in this document: https://docs.aws.amazon.com/acm/latest/userguide/domain-ownership-validation.html"
        )
        input("Press any key once the certificate status is ISSUED")

    subdomain_cert_deployment_region = AcmCertificate(
        domain="*." + subdomain_hosted_zone.domain,
        hosted_zone=subdomain_hosted_zone,
        region=deployment_region,
    )
    subdomain_cert_deployment_region.request_validation()
    validation_record = (
        subdomain_cert_deployment_region.generate_domain_validation_record()
    )
    subdomain_cert_deployment_region.create_domain_validation_records(validation_record)
    subdomain_cert_deployment_region.wait_for_certificate_validation()

    return root_certificate, subdomain_cert_deployment_region


# Step 3: Configure Ingress
def configure_ingress_manifest(tls_cert_arn: str):

    # annotate the ingress with ALB listener rule parameters
    configure_env_file(
        env_file_path="../../awsconfigs/common/istio-ingress/overlays/https/params.env",
        env_dict={
            "certArn": tls_cert_arn,
        },
    )


# Step 4: Configure load balancer controller manifests and create an IAM role for controller service account
def configure_load_balancer_controller(
    region: str, cluster_name: str, policy_name: str = None
) -> Tuple[str, str]:
    policy_name = policy_name or rand_name(f"alb_ingress_controller_{cluster_name}")
    ec2_client = get_ec2_client(region)
    eks_client = get_eks_client(region)

    # create an iam service account with required permissions for the controller
    cluster.associate_iam_oidc_provider(cluster_name, region)
    alb_policy = IAMPolicy(name=policy_name, region=region)
    alb_policy.create(
        policy_document=load_json_file(
            "../../awsconfigs/infra_configs/iam_alb_ingress_policy.json"
        )
    )

    alb_sa_name = "aws-load-balancer-controller"
    alb_sa_namespace = "kube-system"
    cluster.create_iam_service_account(
        alb_sa_name, alb_sa_namespace, cluster_name, region, [alb_policy.arn]
    )

    # tag cluster subnet with kubernetes.io/cluster/<cluster_name> tag
    # see prerequisites in https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    cluster_desc = eks_client.describe_cluster(name=cluster_name)
    ec2_client.create_tags(
        Resources=cluster_desc["cluster"]["resourcesVpcConfig"]["subnetIds"],
        Tags=[
            {"Key": f"kubernetes.io/cluster/{cluster_name}", "Value": "shared"},
        ],
    )

    # substitute the cluster_name for the load balancer controller
    configure_env_file(
        env_file_path="../../awsconfigs/common/aws-alb-ingress-controller/base/params.env",
        env_dict={
            "clusterName": cluster_name,
        },
    )

    return {
        "serviceAccount": {
            "name": alb_sa_name,
            "namespace": alb_sa_namespace,
            "policyArn": alb_policy.arn,
        }
    }


def wait_for_alb_dns(cluster_name: str, region: str):
    logger.info("waiting for ALB creation ...")

    def callback():
        ingress = get_ingress(cluster_name, region)

        assert ingress.get("status") is not None
        assert ingress["status"]["loadBalancer"] is not None
        assert len(ingress["status"]["loadBalancer"]["ingress"]) > 0
        assert (
            ingress["status"]["loadBalancer"]["ingress"][0].get("hostname", None)
            is not None
        )

    wait_for(callback)


def wait_for_alb_status(alb_dns: str, region: str, expected_status: str = "active"):
    logger.info(f" {alb_dns} waiting for ALB status = {expected_status} ...")

    alb = ElasticLoadBalancingV2(dns=alb_dns, region=region)
    def callback():
        assert alb.describe()["State"]["Code"] == expected_status

    wait_for(callback)


def create_ingress():
    def callback():
        apply_kustomize(path=common.LB_KUSTOMIZE_PATH)

    wait_for(callback)


def dns_update(
    region: str, cluster_name: str, subdomain_hosted_zone: Route53HostedZone
) -> str:

    wait_for_alb_dns(cluster_name, region)
    ingress = get_ingress(cluster_name, region)
    alb_dns = ingress["status"]["loadBalancer"]["ingress"][0]["hostname"]
    wait_for_alb_status(alb_dns, region)

    _platform_record = subdomain_hosted_zone.generate_change_record(
        record_name="kubeflow." + subdomain_hosted_zone.domain,
        record_type="CNAME",
        record_value=[alb_dns],
    )

    subdomain_hosted_zone.change_record_set([_platform_record])
    return alb_dns


if __name__ == "__main__":
    config_file_path = common.CONFIG_FILE
    print_banner("Reading Config")
    cfg = load_yaml_file(file_path=config_file_path)

    deployment_region = cfg["cluster"]["region"]
    cluster_name = cfg["cluster"]["name"]
    subdomain_name = cfg["route53"]["subDomain"]["name"]
    root_domain_name = cfg["route53"]["rootDomain"]["name"]
    root_domain_hosted_zone_id = cfg["route53"]["rootDomain"].get("hostedZoneId", None)

    print_banner("Creating Subdomain in Route 53")
    root_hosted_zone, subdomain_hosted_zone = create_subdomain_hosted_zone(
        subdomain_name,
        root_domain_name,
        deployment_region,
        root_domain_hosted_zone_id,
    )
    cfg["route53"]["subDomain"]["hostedZoneId"] = subdomain_hosted_zone.id
    write_yaml_file(yaml_content=cfg, file_path=config_file_path)

    print_banner("Creating Certificate in ACM")
    (
        root_certificate,
        subdomain_cert_deployment_region,
    ) = create_certificates(deployment_region, subdomain_hosted_zone, root_hosted_zone)

    if root_certificate:
        cfg["route53"]["rootDomain"]["certARN"] = root_certificate.arn
    cfg["route53"]["subDomain"]["certARN"] = subdomain_cert_deployment_region.arn
    write_yaml_file(yaml_content=cfg, file_path=config_file_path)

    print_banner("Configuring Ingress and load balancer controller manifests")
    configure_ingress_manifest(subdomain_cert_deployment_region.arn)
    alb_sa_details = configure_load_balancer_controller(deployment_region, cluster_name)
    cfg["kubeflow"] = {"alb": alb_sa_details}
    write_yaml_file(yaml_content=cfg, file_path=config_file_path)

    print_banner("Creating Ingress, load balancer and updating the domain's DNS record")
    create_ingress()
    alb_dns = dns_update(deployment_region, cluster_name, subdomain_hosted_zone)
    cfg["kubeflow"]["alb"]["dns"] = alb_dns
    write_yaml_file(yaml_content=cfg, file_path=config_file_path)
