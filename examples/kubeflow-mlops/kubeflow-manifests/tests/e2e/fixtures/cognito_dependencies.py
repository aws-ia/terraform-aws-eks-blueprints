import pytest

from e2e.utils.cognito_bootstrap.cognito_pre_deployment import (
    
    create_certificates_cognito,
    create_cognito_userpool,
    configure_ingress,
    configure_aws_authservice,
)
from e2e.utils.load_balancer.setup_load_balancer import (
    create_subdomain_hosted_zone,
    configure_load_balancer_controller,
)

from e2e.utils.cognito_bootstrap.cognito_resources_cleanup import (
    delete_cognito_dependency_resources,
)
from e2e.utils.cognito_bootstrap.cognito_post_deployment import (
    update_hosted_zone_with_alb,
)
from e2e.utils.config import configure_resource_fixture
from e2e.utils.utils import (
    rand_name,
    wait_for,
)
from e2e.utils.custom_resources import get_ingress


@pytest.fixture(scope="class")
def cognito_bootstrap(
    metadata, region, request, cluster, root_domain_name, root_domain_hosted_zone_id
):
    if not root_domain_name or not root_domain_hosted_zone_id:
        pytest.fail(
            "--root-domain-name and --root-domain-hosted-zone-id required for cognito related tests"
        )

    subdomain_name = rand_name("platform") + "." + root_domain_name
    cognito_deps = {"cluster": {"region": region, "name": cluster}}

    def on_create():
        root_hosted_zone, subdomain_hosted_zone = create_subdomain_hosted_zone(
            subdomain_name,
            root_domain_name,
            region,
            root_domain_hosted_zone_id,
        )
        cognito_deps["route53"] = {
            "rootDomain": {
                "name": root_hosted_zone.domain,
                "hostedZoneId": root_hosted_zone.id,
            },
            "subDomain": {
                "name": subdomain_hosted_zone.domain,
                "hostedZoneId": subdomain_hosted_zone.id,
            },
        }

        (
            root_certificate,
            subdomain_cert_n_virginia,
            subdomain_cert_deployment_region,
        ) = create_certificates_cognito(region, subdomain_hosted_zone, root_hosted_zone)

        cognito_deps["route53"]["rootDomain"]["certARN"] = root_certificate.arn

        cognito_deps["route53"]["subDomain"][
            "us-east-1-certARN"
        ] = subdomain_cert_n_virginia.arn
        cognito_deps["route53"]["subDomain"][
            region + "-certARN"
        ] = subdomain_cert_deployment_region.arn

        userpool_name = subdomain_name
        cognito_userpool, _ = create_cognito_userpool(
            userpool_name,
            region,
            subdomain_hosted_zone,
            subdomain_cert_n_virginia.arn,
        )

        cognito_deps["cognitoUserpool"] = {
            "name": cognito_userpool.userpool_name,
            "ARN": cognito_userpool.arn,
            "appClientId": cognito_userpool.client_id,
            "domain": cognito_userpool.userpool_domain,
            "domainAliasTarget": cognito_userpool.cloudfront_domain,
        }

        configure_ingress(cognito_userpool, subdomain_cert_deployment_region.arn)
        configure_aws_authservice(cognito_userpool, subdomain_hosted_zone.domain)
        alb_sa_details = configure_load_balancer_controller(region, cluster)
        cognito_deps["kubeflow"] = {"alb": alb_sa_details}

    def on_delete():
        cfg = metadata.get("cognito_dependencies") or cognito_deps
        delete_cognito_dependency_resources(cfg)

    return configure_resource_fixture(
        metadata, request, cognito_deps, "cognito_dependencies", on_create, on_delete
    )


def wait_for_alb_dns(cluster, region):
    def callback():
        ingress = get_ingress(cluster, region)

        assert ingress.get("status") is not None
        assert ingress["status"]["loadBalancer"] is not None
        assert len(ingress["status"]["loadBalancer"]["ingress"]) > 0
        assert (
            ingress["status"]["loadBalancer"]["ingress"][0].get("hostname", None)
            is not None
        )

    wait_for(callback)


@pytest.fixture(scope="class")
def post_deployment_dns_update(
    metadata, region, request, cluster, cognito_bootstrap, kustomize
):

    wait_for_alb_dns(cluster, region)
    ingress = get_ingress(cluster, region)
    alb_dns = ingress["status"]["loadBalancer"]["ingress"][0]["hostname"]
    update_hosted_zone_with_alb(
        subdomain_name=cognito_bootstrap["route53"]["subDomain"]["name"],
        subdomain_hosted_zone_id=cognito_bootstrap["route53"]["subDomain"][
            "hostedZoneId"
        ],
        alb_dns=alb_dns,
        deployment_region=region,
    )
