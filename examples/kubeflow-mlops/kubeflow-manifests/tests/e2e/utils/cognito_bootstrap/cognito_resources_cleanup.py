import logging
from e2e.utils.cognito_bootstrap import common

from e2e.utils.aws.acm import AcmCertificate
from e2e.utils.aws.cognito import CustomDomainCognitoUserPool
from e2e.utils.aws.route53 import Route53HostedZone
from e2e.utils.utils import print_banner, load_yaml_file
from e2e.utils.load_balancer.lb_resources_cleanup import (
    delete_cert,
    delete_policy,
    clean_root_domain,
)
from e2e.fixtures import cluster

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def delete_userpool(
    domain: str,
    userpool_name: str,
    userpool_arn: str,
    domain_alias: str,
    domain_cert_arn: str,
    region: str,
) -> None:
    userpool_domain = "auth." + domain
    userpool_id = userpool_arn.split("/")[-1]
    userpool_cloudfront_alias = domain_alias
    cognito_userpool = CustomDomainCognitoUserPool(
        userpool_name=userpool_name,
        userpool_domain=userpool_domain,
        userpool_id=userpool_id,
        domain_cert_arn=domain_cert_arn,
        region=region,
    )
    try:
        if userpool_cloudfront_alias:
            cognito_userpool.delete_userpool_domain()
        cognito_userpool.delete_userpool()
    except Exception:
        pass


def delete_cognito_dependency_resources(cfg: dict):
    deployment_region = cfg["cluster"]["region"]
    cluster_name = cfg["cluster"]["name"]
    subdomain_hosted_zone_id = cfg["route53"]["subDomain"].get("hostedZoneId", None)
    root_domain_hosted_zone_id = cfg["route53"]["rootDomain"].get("hostedZoneId", None)

    subdomain_hosted_zone = None
    root_hosted_zone = None

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
                delete_cert(acm_certificate=AcmCertificate(arn=root_cert_arn, region=deployment_region))

        subdomain_cert_deployment_region = subdomain_cert_n_virginia = None
        subdomain_cert_deployment_region_arn = cfg["route53"]["subDomain"].get(
            deployment_region + "-certARN", None
        )
        subdomain_cert_n_virginia_arn = cfg["route53"]["subDomain"].get(
            "us-east-1-certARN", None
        )
        if subdomain_cert_n_virginia_arn:
            subdomain_cert_deployment_region = (
                subdomain_cert_n_virginia
            ) = AcmCertificate(arn=subdomain_cert_n_virginia_arn)
        if deployment_region != "us-east-1" and subdomain_cert_deployment_region_arn:
            subdomain_cert_deployment_region = AcmCertificate(
                arn=subdomain_cert_deployment_region_arn, region=deployment_region
            )

        # delete userpool domain and userpool
        cognito_userpool_arn = cfg["cognitoUserpool"].get("ARN", None)
        if cognito_userpool_arn and subdomain_cert_deployment_region:
            delete_userpool(
                domain=subdomain_name,
                userpool_name=cfg["cognitoUserpool"]["name"],
                userpool_arn=cognito_userpool_arn,
                domain_alias=cfg["cognitoUserpool"]["domainAliasTarget"],
                domain_cert_arn=subdomain_cert_deployment_region.arn,
                region=deployment_region,
            )

        # delete ALB
        if "kubeflow" in cfg.keys():
            alb = cfg["kubeflow"].get("alb", None)
            if alb:
                alb_sa = alb.get("serviceAccount", None)
                if alb_sa:
                    cluster.delete_iam_service_account(
                        alb_sa["name"], alb_sa["namespace"], cluster_name, deployment_region
                    )
                    alb_controller_policy_arn = alb_sa["policyArn"]
                    delete_policy(arn=alb_controller_policy_arn, region=deployment_region)

        # delete subdomain certs
        if deployment_region != "us-east-1":
            delete_cert(acm_certificate=subdomain_cert_deployment_region)
        delete_cert(acm_certificate=subdomain_cert_n_virginia)

        # delete hosted zone
        subdomain_hosted_zone.delete_hosted_zone()


if __name__ == "__main__":
    config_file_path = common.CONFIG_FILE
    print_banner("Reading Config")
    cfg = load_yaml_file(file_path=config_file_path)
    delete_cognito_dependency_resources(cfg)
