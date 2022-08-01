import time
import pytest
import subprocess
import boto3
import os, stat, sys

from e2e.utils.config import metadata
from e2e.fixtures.kustomize import kustomize, configure_manifests
from e2e.conftest import region
from e2e.fixtures.cluster import cluster, associate_iam_oidc_provider
from e2e.fixtures.clients import account_id
from e2e.utils.utils import rand_name
from e2e.utils.config import configure_resource_fixture
from e2e.utils.utils import (
    rand_name,
    get_ec2_client,
    get_fsx_client,
    kubectl_apply,
    kubectl_delete,
    load_json_file,
    load_yaml_file,
    write_yaml_file,
    wait_for,
)

from e2e.utils.constants import (
    DEFAULT_USER_NAMESPACE,
)

def get_fsx_dns_name(fsx_client, file_system_id):
    response = fsx_client.describe_file_systems(FileSystemIds=[file_system_id])
    return response["FileSystems"][0]["DNSName"]


def get_fsx_mount_name(fsx_client, file_system_id):
    response = fsx_client.describe_file_systems(FileSystemIds=[file_system_id])
    return response["FileSystems"][0]["LustreConfiguration"]["MountName"]

def wait_on_fsx_deletion(fsx_client, file_system_id):
    def callback():
        try:
            response = fsx_client.describe_file_systems(
                FileSystemIds=[file_system_id],
            )
            number_of_file_systems_with_id = len(response["FileSystems"])
            print(f"{file_system_id} has {number_of_file_systems_with_id} results .... waiting")
            assert number_of_file_systems_with_id == 0 
        except fsx_client.exceptions.FileSystemNotFound:
            return True

    wait_for(callback)


@pytest.fixture(scope="class")
def static_provisioning(metadata, region, request, cluster):
    associate_iam_oidc_provider(cluster, region)
    claim_name = rand_name("fsx-claim-")
    fsx_pv_filepath = "../../deployments/add-ons/storage/fsx-for-lustre/static-provisioning/pv.yaml"
    fsx_pvc_filepath = "../../deployments/add-ons/storage/fsx-for-lustre/static-provisioning/pvc.yaml"
    fsx_auto_script_filepath = "utils/auto-fsx-setup.py"
    fsx_client = get_fsx_client(region)
    ec2_client = get_ec2_client(region)
    config_filename = ".metadata/fsx-config.json"
    fsx_claim = {}

    def on_create():
        # Run the automated script to create the EFS Filesystem and the SC
        fsx_auto_script_absolute_filepath = os.path.join(
            os.path.abspath(sys.path[0]), "../" + fsx_auto_script_filepath
        )

        path_status = os.stat(fsx_auto_script_filepath)
        os.chmod(fsx_auto_script_filepath, path_status.st_mode | stat.S_IEXEC)
        subprocess.call(
            [
                "python",
                fsx_auto_script_absolute_filepath,
                "--region",
                region,
                "--cluster",
                cluster,
                "--fsx_file_system_name",
                claim_name,
                "--fsx_security_group_name",
                claim_name + "sg",
                "--write_to_file",
                "True",
                "--config_filename",
                config_filename,
            ]
        )

        fsx_config = load_json_file(config_filename)
        security_group_id = fsx_config["security_group_id"]
        file_system_id = fsx_config["file_system_id"]
        dns_name = get_fsx_dns_name(fsx_client, file_system_id)
        mount_name = get_fsx_mount_name(fsx_client, file_system_id)

        # Add the filesystem_id to the pv.yaml file
        fsx_pv = load_yaml_file(fsx_pv_filepath)
        fsx_pv["spec"]["csi"]["volumeHandle"] = file_system_id
        fsx_pv["metadata"]["name"] = claim_name
        fsx_pv["spec"]["csi"]["volumeAttributes"]["dnsname"] = dns_name
        fsx_pv["spec"]["csi"]["volumeAttributes"]["mountname"] = mount_name
        write_yaml_file(fsx_pv, fsx_pv_filepath)

        # Update the values in the pvc.yaml file
        fsx_pvc = load_yaml_file(fsx_pvc_filepath)
        fsx_pvc["metadata"]["namespace"] = DEFAULT_USER_NAMESPACE
        fsx_pvc["metadata"]["name"] = claim_name
        fsx_pvc["spec"]["volumeName"] = claim_name
        write_yaml_file(fsx_pvc, fsx_pvc_filepath)

        kubectl_apply(fsx_pv_filepath)
        kubectl_apply(fsx_pvc_filepath)

        fsx_claim["claim_name"] = claim_name
        fsx_claim["file_system_id"] = file_system_id
        fsx_claim["security_group_id"] = security_group_id

    def on_delete():
        kubectl_delete(fsx_pvc_filepath)
        kubectl_delete(fsx_pv_filepath)

        details_fsx_volume = metadata.get("fsx_claim") or fsx_claim
        file_system_id = details_fsx_volume["file_system_id"]
        sg_id = details_fsx_volume["security_group_id"]

        print(f"deleting filesystem {file_system_id}")
        # delete the filesystem
        fsx_client.delete_file_system(
            FileSystemId=file_system_id,
        )

        wait_on_fsx_deletion(fsx_client, file_system_id)
        print(f"deleted filesystem {file_system_id}")

        # delete the security group
        ec2_client.delete_security_group(GroupId=sg_id)

        # Delete the config file
        os.remove(config_filename)

    return configure_resource_fixture(
        metadata, request, fsx_claim, "fsx_claim", on_create, on_delete
    )
