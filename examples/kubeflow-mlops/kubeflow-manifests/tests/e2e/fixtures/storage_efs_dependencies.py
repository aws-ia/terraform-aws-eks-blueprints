import pytest
import subprocess
import boto3
import os
import stat
import sys

from e2e.utils.config import metadata
from e2e.fixtures.kustomize import kustomize, configure_manifests
from e2e.conftest import region
from e2e.fixtures.cluster import cluster
from e2e.utils.utils import rand_name
from e2e.utils.config import configure_resource_fixture
from e2e.fixtures.cluster import associate_iam_oidc_provider, create_iam_service_account
from e2e.utils.utils import (
    rand_name,
    wait_for,
    get_iam_client,
    get_eks_client,
    get_ec2_client,
    get_efs_client,
    curl_file_to_path,
    kubectl_apply,
    kubectl_delete,
    kubectl_apply_kustomize,
    kubectl_delete_kustomize,
    load_yaml_file,
    write_yaml_file,
    get_security_group_id_from_name,
)
from e2e.utils.constants import (
    DEFAULT_USER_NAMESPACE,
    DEFAULT_SYSTEM_NAMESPACE,
)


def get_file_system_id_from_name(efs_client, file_system_name):
    def name_matches(filesystem):
        return filesystem["Name"] == file_system_name

    file_systems = efs_client.describe_file_systems()["FileSystems"]

    file_system = next(filter(name_matches, file_systems))

    return file_system["FileSystemId"]


def wait_on_efs_status(desired_status, efs_client, file_system_id):
    def callback():
        response = efs_client.describe_file_systems(
            FileSystemId=file_system_id,
        )
        filesystem_status = response["FileSystems"][0]["LifeCycleState"]
        print(f"{file_system_id} {filesystem_status} .... waiting")
        assert filesystem_status == desired_status

    wait_for(callback)


def wait_on_efs_deletion(efs_client, file_system_id):
    def callback():
        try:
            response = efs_client.describe_file_systems(
                FileSystemId=file_system_id,
            )
            number_of_file_systems_with_id = len(response["FileSystems"])
            print(
                f"{file_system_id} has {number_of_file_systems_with_id} results .... waiting"
            )
            assert number_of_file_systems_with_id == 0
        except efs_client.exceptions.FileSystemNotFound:
            return True

    wait_for(callback)


def wait_on_mount_target_status(desired_status, efs_client, file_system_id):
    def callback():
        response = efs_client.describe_file_systems(
            FileSystemId=file_system_id,
        )
        number_of_mount_targets = response["FileSystems"][0]["NumberOfMountTargets"]
        print(
            f"{file_system_id} has {number_of_mount_targets} mount targets .... waiting"
        )
        if desired_status == "deleted":
            assert number_of_mount_targets == 0
        else:
            assert number_of_mount_targets > 0

    wait_for(callback)


@pytest.fixture(scope="class")
def install_efs_csi_driver(metadata, region, request, cluster, kustomize):
    efs_driver = {}
    EFS_DRIVER_VERSION = "v1.3.4"
    EFS_CSI_DRIVER = f"github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=tags/{EFS_DRIVER_VERSION}"

    def on_create():
        kubectl_apply_kustomize(EFS_CSI_DRIVER)
        efs_driver["driver_version"] = EFS_DRIVER_VERSION

    def on_delete():
        kubectl_delete_kustomize(EFS_CSI_DRIVER)

    return configure_resource_fixture(
        metadata, request, efs_driver, "efs_driver", on_create, on_delete
    )


@pytest.fixture(scope="class")
def create_efs_driver_sa(
    metadata, region, request, cluster, account_id, install_efs_csi_driver
):
    # TODO: Existing IAM Client with Region does not seem to work.
    efs_deps = {}
    iam_client = boto3.client("iam")

    EFS_IAM_POLICY = "https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/v1.3.4/docs/iam-policy-example.json"
    policy_name = rand_name("efs-iam-policy-")
    policy_arn = [f"arn:aws:iam::{account_id}:policy/{policy_name}"]

    def on_create():
        associate_iam_oidc_provider(cluster, region)
        curl_file_to_path(EFS_IAM_POLICY, "iam-policy-example.json")
        with open("iam-policy-example.json", "r") as myfile:
            policy = myfile.read()

        response = iam_client.create_policy(
            PolicyName=policy_name,
            PolicyDocument=policy,
        )
        assert response["Policy"]["Arn"] is not None

        create_iam_service_account(
            "efs-csi-controller-sa",
            DEFAULT_SYSTEM_NAMESPACE,
            cluster,
            region,
            policy_arn,
        )
        efs_deps["efs_iam_policy_name"] = policy_name

    def on_delete():
        details_efs_deps = metadata.get("efs_deps") or efs_deps
        policy_arn = details_efs_deps["efs_iam_policy_arn"]
        iam_client.delete_policy(
            PolicyArn=policy_arn[0],
        )

    return configure_resource_fixture(
        metadata, request, efs_deps, "efs_deps", on_create, on_delete
    )


@pytest.fixture(scope="class")
def create_efs_volume(metadata, region, request, cluster, create_efs_driver_sa):
    efs_volume = {}
    eks_client = get_eks_client(region)
    ec2_client = get_ec2_client(region)
    efs_client = get_efs_client(region)

    def on_create():
        # Get VPC ID
        response = eks_client.describe_cluster(name=cluster)
        vpc_id = response["cluster"]["resourcesVpcConfig"]["vpcId"]

        # Get CIDR Range
        response = ec2_client.describe_vpcs(
            VpcIds=[
                vpc_id,
            ]
        )
        cidr_ip = response["Vpcs"][0]["CidrBlock"]

        # Create Security Group
        security_group_name = rand_name("efs-security-group-")
        response = ec2_client.create_security_group(
            VpcId=vpc_id,
            GroupName=security_group_name,
            Description="My EFS security group",
        )
        security_group_id = response["GroupId"]
        efs_volume["security_group_id"] = security_group_id

        # Open Port for CIDR Range
        response = ec2_client.authorize_security_group_ingress(
            GroupId=security_group_id,
            FromPort=2049,
            ToPort=2049,
            CidrIp=cidr_ip,
            IpProtocol="tcp",
        )

        # Create an Amazon EFS FileSystem for your EKS Cluster
        response = efs_client.create_file_system(
            PerformanceMode="generalPurpose",
        )
        file_system_id = response["FileSystemId"]

        # Check for status of filesystem to be "available" before creating mount targets
        wait_on_efs_status("available", efs_client, file_system_id)

        # Get Subnet Ids
        response = ec2_client.describe_subnets(
            Filters=[
                {
                    "Name": "vpc-id",
                    "Values": [
                        vpc_id,
                    ],
                },
            ]
        )

        # Create Mount Targets for each subnet - TODO: Check how many subnets this needs to be added to.
        subnets = response["Subnets"]
        for subnet in subnets:
            subnet_id = subnet["SubnetId"]
            response = efs_client.create_mount_target(
                FileSystemId=file_system_id,
                SecurityGroups=[
                    security_group_id,
                ],
                SubnetId=subnet_id,
            )

        # Write the FileSystemId to the metadata file
        efs_volume["file_system_id"] = file_system_id

    def on_delete():
        # Get FileSystem_ID
        details_efs_volume = metadata.get("efs_volume") or efs_volume
        fs_id = details_efs_volume["file_system_id"]
        sg_id = details_efs_volume["security_group_id"]

        # Delete the Mount Targets
        response = efs_client.describe_mount_targets(
            FileSystemId=fs_id,
        )
        existing_mount_targets = response["MountTargets"]
        for mount_target in existing_mount_targets:
            mount_target_id = mount_target["MountTargetId"]
            efs_client.delete_mount_target(
                MountTargetId=mount_target_id,
            )

        wait_on_mount_target_status("deleted", efs_client, fs_id)

        # Delete the Filesystem

        efs_client.delete_file_system(
            FileSystemId=fs_id,
        )
        wait_on_efs_status("deleting", efs_client, fs_id)
        wait_on_efs_deletion(efs_client, fs_id)

        # Delete the Security Group
        ec2_client.delete_security_group(GroupId=sg_id)

    return configure_resource_fixture(
        metadata, request, efs_volume, "efs_volume", on_create, on_delete
    )


@pytest.fixture(scope="class")
def static_provisioning(metadata, region, request, cluster, create_efs_volume):
    details_efs_volume = metadata.get("efs_volume")
    fs_id = details_efs_volume["file_system_id"]
    claim_name = rand_name("efs-claim-")
    efs_sc_filepath = (
        "../../deployments/add-ons/storage/efs/static-provisioning/sc.yaml"
    )
    efs_pv_filepath = (
        "../../deployments/add-ons/storage/efs/static-provisioning/pv.yaml"
    )
    efs_pvc_filepath = (
        "../../deployments/add-ons/storage/efs/static-provisioning/pvc.yaml"
    )
    efs_permissions_filepath = (
        "../../deployments/add-ons/storage/notebook-sample/set-permission-job.yaml"
    )
    efs_claim = {}

    def on_create():
        # Add the filesystem_id to the pv.yaml file
        efs_pv = load_yaml_file(efs_pv_filepath)
        efs_pv["spec"]["csi"]["volumeHandle"] = fs_id
        efs_pv["metadata"]["name"] = claim_name
        write_yaml_file(efs_pv, efs_pv_filepath)

        # Update the values in the pvc.yaml file
        efs_pvc = load_yaml_file(efs_pvc_filepath)
        efs_pvc["metadata"]["namespace"] = DEFAULT_USER_NAMESPACE
        efs_pvc["metadata"]["name"] = claim_name
        write_yaml_file(efs_pvc, efs_pvc_filepath)

        # Update the values in the permissions file
        # Statically provisioned volume needs extra permissions
        efs_permission = load_yaml_file(efs_permissions_filepath)
        efs_permission["metadata"]["namespace"] = DEFAULT_USER_NAMESPACE
        efs_permission["metadata"]["name"] = "permissions" + claim_name
        efs_permission["spec"]["template"]["spec"]["volumes"][0][
            "persistentVolumeClaim"
        ]["claimName"] = claim_name
        write_yaml_file(efs_permission, efs_permissions_filepath)

        kubectl_apply(efs_sc_filepath)
        kubectl_apply(efs_pv_filepath)
        kubectl_apply(efs_pvc_filepath)
        kubectl_apply(efs_permissions_filepath)

        efs_claim["claim_name"] = claim_name

    def on_delete():
        kubectl_delete(efs_permissions_filepath)
        kubectl_delete(efs_pvc_filepath)
        kubectl_delete(efs_pv_filepath)
        kubectl_delete(efs_sc_filepath)

    return configure_resource_fixture(
        metadata, request, efs_claim, "efs_claim", on_create, on_delete
    )


@pytest.fixture(scope="class")
def dynamic_provisioning(metadata, region, request, cluster):
    associate_iam_oidc_provider(cluster, region)
    claim_name = rand_name("efs-claim-auto-dyn-")
    security_group_name = claim_name + "-sg"
    efs_pvc_filepath = (
        "../../deployments/add-ons/storage/efs/dynamic-provisioning/pvc.yaml"
    )
    efs_sc_filepath = (
        "../../deployments/add-ons/storage/efs/dynamic-provisioning/sc.yaml"
    )
    efs_permissions_filepath = (
        "../../deployments/add-ons/storage/notebook-sample/set-permission-job.yaml"
    )
    efs_auto_script_filepath = "utils/auto-efs-setup.py"
    efs_claim_dyn = {}
    efs_client = get_efs_client(region)
    ec2_client = get_ec2_client(region)
    eks_client = get_eks_client(region)

    def on_create():
        # Run the automated script to create the EFS Filesystem and the SC
        efs_auto_script_absolute_filepath = os.path.join(
            os.path.abspath(sys.path[0]), "../" + efs_auto_script_filepath
        )

        st = os.stat(efs_auto_script_filepath)
        os.chmod(efs_auto_script_filepath, st.st_mode | stat.S_IEXEC)
        subprocess.call(
            [
                "python",
                efs_auto_script_absolute_filepath,
                "--region",
                region,
                "--cluster",
                cluster,
                "--efs_file_system_name",
                claim_name,
                "--efs_security_group_name",
                security_group_name,
            ]
        )

        file_system_id = get_file_system_id_from_name(efs_client, claim_name)

        # PVC creation is not a part of the script
        # Update the values in the pvc.yaml file
        efs_pvc = load_yaml_file(efs_pvc_filepath)
        efs_pvc["metadata"]["namespace"] = DEFAULT_USER_NAMESPACE
        efs_pvc["metadata"]["name"] = claim_name
        write_yaml_file(efs_pvc, efs_pvc_filepath)

        kubectl_apply(efs_pvc_filepath)

        efs_claim_dyn["efs_claim_dyn"] = claim_name
        efs_claim_dyn["file_system_id"] = file_system_id

    def on_delete():
        kubectl_delete(efs_pvc_filepath)
        kubectl_delete(efs_sc_filepath)

        # Get FileSystem_ID
        efs_claim_dyn = metadata.get("efs_claim_dyn") or efs_claim_dyn
        fs_id = efs_claim_dyn["file_system_id"]

        # Delete the Mount Targets
        response = efs_client.describe_mount_targets(
            FileSystemId=fs_id,
        )
        existing_mount_targets = response["MountTargets"]
        for mount_target in existing_mount_targets:
            mount_target_id = mount_target["MountTargetId"]
            efs_client.delete_mount_target(
                MountTargetId=mount_target_id,
            )

        wait_on_mount_target_status("deleted", efs_client, fs_id)

        # Delete the Filesystem

        efs_client.delete_file_system(
            FileSystemId=fs_id,
        )
        wait_on_efs_deletion(efs_client, fs_id)

        security_group_id = get_security_group_id_from_name(
            ec2_client, eks_client, security_group_name, cluster
        )
        ec2_client.delete_security_group(GroupId=security_group_id)

    return configure_resource_fixture(
        metadata, request, efs_claim_dyn, "efs_claim_dyn", on_create, on_delete
    )
