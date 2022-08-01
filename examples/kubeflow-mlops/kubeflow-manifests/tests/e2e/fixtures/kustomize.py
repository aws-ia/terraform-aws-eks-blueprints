"""
Kustomize fixture module
"""

import subprocess
import tempfile
import time
import pytest
import os

from e2e.utils.config import configure_resource_fixture
from e2e.utils.constants import KUBEFLOW_VERSION
from e2e.utils.utils import wait_for


def apply_kustomize(path):
    """
    Equivalent to:

    while ! kustomize build <PATH> | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done

    but creates a temporary file instead of piping.
    """
    with tempfile.NamedTemporaryFile() as tmp:
        build_retcode = subprocess.call(f"kustomize build {path} -o {tmp.name}".split())
        assert build_retcode == 0
        apply_retcode = subprocess.call(f"kubectl apply -f {tmp.name}".split())
        assert apply_retcode == 0


def delete_kustomize(path):
    """
    Equivalent to:

    kustomize build <PATH> | kubectl delete -f -

    but creates a temporary file instead of piping.
    """
    with tempfile.NamedTemporaryFile() as tmp:
        build_retcode = subprocess.call(f"kustomize build {path} -o {tmp.name}".split())
        assert build_retcode == 0


@pytest.fixture(scope="class")
def configure_manifests():
    pass


@pytest.fixture(scope="class")
def clone_upstream():
    upstream_path = "../../upstream"
    if not os.path.isdir(upstream_path):
        retcode = subprocess.call(
            f"git clone --branch {KUBEFLOW_VERSION} https://github.com/kubeflow/manifests.git ../../upstream".split()
        )
        assert retcode == 0
    else:
        print("upstream directory already exists, skipping clone ...")


@pytest.fixture(scope="class")
def kustomize(
    metadata, cluster, clone_upstream, configure_manifests, kustomize_path, request
):
    """
    This fixture is created once for each test class.

    Before all tests are run, installs kubeflow using the manifest at `kustomize_path`
    if `kustomize_path` was not provided in the metadata.

    After all tests are run, uninstalls kubeflow using the manifest at `kustomize_path`
    if the flag `--keepsuccess` was not provided as a pytest argument.
    """

    def on_create():
        wait_for(lambda: apply_kustomize(kustomize_path), timeout=20 * 60)
        time.sleep(5 * 60)  # wait a bit for all pods to be running
        # TODO: verify this programmatically

    def on_delete():
        # deleting the kubeflow deployment deletes the load balancer controller at the same time as ingress
        # the problem with this is the ingress managed load balacer does not get cleaned up as there is no controller 
        subprocess.call(f"kubectl delete ingress -n istio-system --all".split())
        # load balancer controller does not place a finalizer on the ingress and so deleting the attached load balancer is asynhronous
        # adding a random wait to allow controller to delete the load balancer
        # TODO: implement a better check
        time.sleep(2 * 60)

        delete_kustomize(kustomize_path)

    configure_resource_fixture(
        metadata, request, kustomize_path, "kustomize_path", on_create, on_delete
    )
