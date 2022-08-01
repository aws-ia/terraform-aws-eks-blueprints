"""
Add additional pytest supported test configurations.

https://docs.pytest.org/en/6.2.x/example/simple.html
"""

import pytest


def pytest_addoption(parser):
    parser.addoption(
        "--metadata", action="store", help="Metadata file to resume a test class from."
    )
    parser.addoption(
        "--keepsuccess",
        action="store_true",
        default=False,
        help="Keep successfully created resources on delete.",
    )
    parser.addoption(
        "--region",
        action="store",
        help="Region to run the tests in. Will be overriden if metadata is provided and region is present.",
    )
    parser.addoption(
        "--root-domain-name",
        action="store",
        help="Root domain name for which subdomain will be created. Required for tests which use cognito",
    )
    parser.addoption(
        "--root-domain-hosted-zone-id",
        action="store",
        help="Hosted zone id of the root domain. Required for tests which use cognito",
    )
    parser.addoption(
        "--accesskey",
        action="store",
        help="AWS account accesskey",
    )
    parser.addoption(
        "--secretkey",
        action="store",
        help="AWS account secretkey",
    )


def keep_successfully_created_resource(request):
    return request.config.getoption("--keepsuccess")


def load_metadata_file(request):
    return request.config.getoption("--metadata")


def get_accesskey(request):
    access_key = request.config.getoption("--accesskey")
    if not access_key:
        pytest.fail("--accesskey is required")
    return access_key


def get_secretkey(request):
    secret_key = request.config.getoption("--secretkey")
    if not secret_key:
        pytest.fail("--secretkey is required")
    return secret_key


@pytest.fixture(scope="class")
def region(metadata, request):
    """
    Test region.
    """

    if metadata.get("region"):
        return metadata.get("region")

    region = request.config.getoption("--region")
    if not region:
        pytest.fail("--region is required")
    metadata.insert("region", region)
    return region


@pytest.fixture(scope="class")
def root_domain_name(metadata, request):
    cognito_deps = metadata.get("cognito_dependencies")
    if cognito_deps:
        return cognito_deps["route53"]["rootDomain"]["name"]

    return request.config.getoption("--root-domain-name")


@pytest.fixture(scope="class")
def root_domain_hosted_zone_id(metadata, request):
    cognito_deps = metadata.get("cognito_dependencies")
    if cognito_deps:
        return cognito_deps["route53"]["rootDomain"]["hostedZoneId"]

    return request.config.getoption("--root-domain-hosted-zone-id")
