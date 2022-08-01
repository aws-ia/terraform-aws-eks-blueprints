import json

import pytest

from e2e.utils.utils import kubectl_apply

from e2e.fixtures.cluster import (
    associate_iam_oidc_provider,
    create_iam_service_account,
    delete_iam_service_account,
)
from e2e.utils.k8s_core_api import create_namespace

from e2e.utils.constants import (
    KUBEFLOW_NAMESPACE,
)

from e2e.resources.external import (
    secrets_store_csi_driver,
    secrets_store_csi_driver_provider_aws,
)

KUBEFLOW_SERVICE_ACCOUNT_NAME = "kubeflow-secrets-manager-sa"
IAM_AWS_SSM_READ_ONLY_POLICY = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
IAM_SECRETS_MANAGER_READ_WRITE_POLICY = (
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
)


@pytest.fixture(scope="class")
def aws_secrets_driver(cluster, region):

    associate_iam_oidc_provider(cluster, region)
    create_namespace(cluster, region, "kubeflow")

    iam_policies = [IAM_AWS_SSM_READ_ONLY_POLICY, IAM_SECRETS_MANAGER_READ_WRITE_POLICY]

    delete_iam_service_account(
        KUBEFLOW_SERVICE_ACCOUNT_NAME, KUBEFLOW_NAMESPACE, cluster, region
    )
    create_iam_service_account(
        KUBEFLOW_SERVICE_ACCOUNT_NAME, KUBEFLOW_NAMESPACE, cluster, region, iam_policies
    )

    secrets_store_csi_driver.install()
    secrets_store_csi_driver_provider_aws.install()


def create_secret_string(secrets_dict):
    return json.dumps(secrets_dict)
