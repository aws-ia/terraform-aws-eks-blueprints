"""
EKS cluster fixture module 
"""

import subprocess
import pytest

from e2e.utils.utils import rand_name
from e2e.utils.config import configure_resource_fixture

# Todo load from yaml and replace values
def create_cluster(cluster_name, region, cluster_version="1.19"):
    cmd = []
    cmd += "eksctl create cluster".split()
    cmd += f"--name {cluster_name}".split()
    cmd += f"--version {cluster_version}".split()
    cmd += f"--region {region}".split()
    cmd += "--node-type m5.xlarge".split()
    cmd += "--nodes 5".split()
    cmd += "--nodes-min 1".split()
    cmd += "--nodes-max 10".split()
    cmd += "--managed".split()

    retcode = subprocess.call(cmd)
    assert retcode == 0


def delete_cluster(cluster_name, region):
    cmd = []
    cmd += "eksctl delete cluster".split()
    cmd += f"--name {cluster_name}".split()
    cmd += f"--region {region}".split()

    retcode = subprocess.call(cmd)
    assert retcode == 0


def associate_iam_oidc_provider(cluster_name, region):
    cmd = []
    cmd += "eksctl utils associate-iam-oidc-provider".split()
    cmd += f"--region {region}".split()
    cmd += f"--cluster {cluster_name}".split()
    cmd += "--approve".split()

    subprocess.call(cmd)


def create_iam_service_account(
    service_account_name, namespace, cluster_name, region, iam_policy_arns=[], iam_role_arn=None
):
    cmd = []
    cmd += "eksctl create iamserviceaccount".split()
    cmd += f"--name {service_account_name}".split()
    cmd += f"--namespace {namespace}".split()
    cmd += f"--cluster {cluster_name}".split()
    cmd += f"--region {region}".split()

    for arn in iam_policy_arns:
        cmd += f"--attach-policy-arn {arn}".split()

    if iam_role_arn != None:
        cmd += f"--attach-role-arn {iam_role_arn}".split()

    cmd += "--override-existing-serviceaccounts".split()
    cmd += "--approve".split()

    retcode = subprocess.call(cmd)
    assert retcode == 0

def delete_iam_service_account(service_account_name, namespace, cluster_name, region):
    cmd = []
    cmd += "eksctl delete iamserviceaccount".split()
    cmd += f"--name {service_account_name}".split()
    cmd += f"--namespace {namespace}".split()
    cmd += f"--cluster {cluster_name}".split()
    cmd += f"--region {region}".split()

    retcode = subprocess.call(cmd)
    assert retcode == 0

def delete_iam_service_account(service_account_name, namespace, cluster_name, region):
    cmd = []
    cmd += "eksctl delete iamserviceaccount".split()
    cmd += f"--name {service_account_name}".split()
    cmd += f"--namespace {namespace}".split()
    cmd += f"--cluster {cluster_name}".split()
    cmd += f"--region {region}".split()

    subprocess.call(cmd)

def update_kubeconfig(cluster_name, region):
    cmd = f"aws eks update-kubeconfig --name {cluster_name}  --region {region}".split()

    subprocess.call(cmd)

@pytest.fixture(scope="class")
def cluster(metadata, region, request):
    """
    This fixture is created once for each test class.

    Before all tests are run, a cluster is created if `cluster_name` was not provided in the metadata.

    After all tests are run, deletes the cluster if the flag `--keepsuccess` was not provided as a pytest
    argument.
    """

    cluster_name = rand_name("e2e-test-cluster-")

    def on_create():
        create_cluster(cluster_name, region)
        update_kubeconfig(cluster_name, region)

    def on_delete():
        name = metadata.get("cluster_name") or cluster_name
        delete_cluster(name, region)

    return configure_resource_fixture(
        metadata, request, cluster_name, "cluster_name", on_create, on_delete
    )
