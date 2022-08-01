"""
Installs the vanilla distribution of kubeflow and validates FSx for Lustre integration by:
    - Installing the FSx CSI Driver from upstream
    - Creating the required IAM Policy, Role and Service Account
    - Creating the FSx for Lustre Volume 
    - Creating a StorageClass, PersistentVolume and PersistentVolumeClaim using Static Provisioning
"""

import pytest
import subprocess

from e2e.utils.config import metadata

from e2e.conftest import region

from e2e.fixtures.cluster import cluster
from e2e.fixtures.clients import (
    account_id,
    create_k8s_admission_registration_api_client,
    kfp_client,
    host,
    port_forward,
    client_namespace,
    session_cookie,
    login,
    password,
    patch_kfp_to_disable_cache,
)

from e2e.fixtures.kustomize import kustomize, configure_manifests, clone_upstream

from e2e.fixtures.storage_fsx_dependencies import (
    static_provisioning,
)
from e2e.utils.constants import (
    DEFAULT_USER_NAMESPACE,
    DEFAULT_SYSTEM_NAMESPACE,
)
from e2e.utils.utils import (
    unmarshal_yaml,
    rand_name,
    wait_for_kfp_run_succeeded_from_run_id,
)
from e2e.utils.custom_resources import get_pvc_status, get_service_account, get_pod_from_label
from e2e.resources.pipelines.pipeline_read_from_volume import read_from_volume_pipeline
from e2e.resources.pipelines.pipeline_write_to_volume import write_to_volume_pipeline

GENERIC_KUSTOMIZE_MANIFEST_PATH = "../../deployments/vanilla"
DISABLE_PIPELINE_CACHING_PATCH_FILE = (
    "./resources/custom-resource-templates/patch-disable-pipeline-caching.yaml"
)
MOUNT_PATH = "/home/jovyan/"


@pytest.fixture(scope="class")
def kustomize_path():
    return GENERIC_KUSTOMIZE_MANIFEST_PATH


class TestFSx:
    @pytest.fixture(scope="class")
    def setup(self, metadata, kustomize, patch_kfp_to_disable_cache, port_forward, static_provisioning):

        metadata_file = metadata.to_file()
        print(metadata.params)  # These needed to be logged
        print("Created metadata file for TestFSx_Static", metadata_file)

    def test_pvc_with_volume(
        self,
        metadata,
        account_id,
        setup,
        kfp_client,
        static_provisioning,
    ):
        driver_list = subprocess.check_output("kubectl get csidriver".split()).decode()
        assert "fsx.csi.aws.com" in driver_list

        name, status = get_pod_from_label(cluster, region, DEFAULT_SYSTEM_NAMESPACE, "app","fsx-csi-controller")
        assert "fsx-csi-controller" in name
        assert status == "Running"

        sa_account = get_service_account(
            cluster, region, DEFAULT_SYSTEM_NAMESPACE, "fsx-csi-controller-sa"
        )
        assert sa_account.split("/")[0] == f"arn:aws:iam::{account_id}:role" 

        fs_id = static_provisioning["file_system_id"]
        assert "fs-" in fs_id

        CLAIM_NAME = static_provisioning["claim_name"]
        pvc_name, claim_status = get_pvc_status(
            cluster, region, DEFAULT_USER_NAMESPACE, CLAIM_NAME
        )
        assert pvc_name == CLAIM_NAME
        assert claim_status == "Bound"

        # TODO: The following can be put into a method or split this into different tests
        # Create two Pipelines both mounted with the same volume claim.
        # The first one writes a file to the volume, the second one reads it and verifies content.
        experiment_name = rand_name("fsx-static-experiment-")
        experiment_description = rand_name("fsx-description-")
        experiment = kfp_client.create_experiment(
            experiment_name,
            description=experiment_description,
            namespace=DEFAULT_USER_NAMESPACE,
        )
        arguments = {"mount_path": MOUNT_PATH, "claim_name": CLAIM_NAME}

        # Write Pipeline Run
        write_run_id = kfp_client.create_run_from_pipeline_func(
            write_to_volume_pipeline,
            experiment_name=experiment_name,
            namespace=DEFAULT_USER_NAMESPACE,
            arguments=arguments,
        ).run_id
        print(f"write_pipeline run id is {write_run_id}")
        wait_for_kfp_run_succeeded_from_run_id(kfp_client, write_run_id)

        # Read Pipeline Run
        read_run_id = kfp_client.create_run_from_pipeline_func(
            read_from_volume_pipeline,
            experiment_name=experiment_name,
            namespace=DEFAULT_USER_NAMESPACE,
            arguments=arguments,
        ).run_id
        print(f"read_pipeline run id is {read_run_id}")
        wait_for_kfp_run_succeeded_from_run_id(kfp_client, read_run_id)

        pvc_name, claim_status = get_pvc_status(
            cluster, region, DEFAULT_USER_NAMESPACE, CLAIM_NAME
        )
        assert pvc_name == CLAIM_NAME
        assert claim_status == "Bound"

        write_pod_name, _ = get_pod_from_label(cluster, region, DEFAULT_USER_NAMESPACE, "pipeline/runid",write_run_id)
        read_pod_name, _ = get_pod_from_label(cluster, region, DEFAULT_USER_NAMESPACE, "pipeline/runid",read_run_id)
        subprocess.run(f"kubectl delete pod -n {DEFAULT_USER_NAMESPACE} {write_pod_name}".split())
        subprocess.run(f"kubectl delete pod -n {DEFAULT_USER_NAMESPACE} {read_pod_name}".split())
