import argparse
import boto3
import subprocess
from shutil import which
from time import sleep
from utils import (
    rand_name,
    write_json_file,
    get_eks_client,
    get_ec2_client,
    get_iam_client,
    get_fsx_client,
    get_iam_resource,
    kubectl_apply_kustomize,
    kubectl_apply,
    write_yaml_file,
    load_yaml_file,
)

FSX_FILE_SYSTEM_ID = ""


def main():
    header()

    verify_prerequisites()

    setup_iam_authorization()
    setup_fsx_driver()
    setup_fsx_file_system()
    setup_fsx_provisioning()

    footer()


def header():
    print("=================================================================")
    print("                          FSx Setup")


def verify_prerequisites():
    print("=================================================================")
    print("                   Prerequisites Verification")
    print("=================================================================")

    verify_oidc_provider_prerequisite()
    verify_eksctl_is_installed()
    verify_kubectl_is_installed()


def verify_oidc_provider_prerequisite():
    print("Verifying OIDC provider...")

    if is_oidc_provider_present():
        print("OIDC provider found")
    else:
        raise Exception(
            f"Prerequisite not met : No OIDC provider found for cluster '{CLUSTER_NAME}'!"
        )


def is_oidc_provider_present() -> bool:
    iam_client = get_iam_client(CLUSTER_REGION)
    oidc_providers = iam_client.list_open_id_connect_providers()[
        "OpenIDConnectProviderList"
    ]

    if len(oidc_providers) == 0:
        return False

    for oidc_provider in oidc_providers:
        oidc_provider_tags = iam_client.get_open_id_connect_provider(
            OpenIDConnectProviderArn=oidc_provider["Arn"]
        )["Tags"]

        if any(
            tag["Key"] == "alpha.eksctl.io/cluster-name"
            and tag["Value"] == CLUSTER_NAME
            for tag in oidc_provider_tags
        ):
            return True

    return False


def verify_eksctl_is_installed():
    print("Verifying eksctl is installed...")

    is_prerequisite_met = which("eksctl") is not None

    if is_prerequisite_met:
        print("eksctl found!")
    else:
        raise Exception(
            "Prerequisite not met : eksctl could not be found, make sure it is installed or in your PATH!"
        )


def verify_kubectl_is_installed():
    print("Verifying kubectl is installed...")

    is_prerequisite_met = which("kubectl") is not None

    if is_prerequisite_met:
        print("kubectl found!")
    else:
        raise Exception(
            "Prerequisite not met : kubectl could not be found, make sure it is installed or in your PATH!"
        )


def setup_iam_authorization():
    print("=================================================================")
    print("                   IAM Authorization Setup")
    print("=================================================================")

    setup_fsx_iam_policy()
    setup_fsx_iam_service_account()


def setup_fsx_iam_policy():
    if does_need_to_create_fsx_iam_policy():
        create_fsx_iam_policy()
    else:
        print(
            f"Skipping FSx IAM policy creation, '{FSX_IAM_POLICY_NAME}' already exists!"
        )


def does_need_to_create_fsx_iam_policy():
    iam_resource = get_iam_resource(CLUSTER_REGION)
    try:
        iam_resource.Policy(FSX_IAM_POLICY_ARN).load()
        return False
    except iam_resource.meta.client.exceptions.NoSuchEntityException:
        return True


def create_fsx_iam_policy():
    print("Creating FSx IAM policy...")

    fsx_policy_document = get_fsx_iam_policy_document()
    iam_client = get_iam_client(CLUSTER_REGION)

    response = iam_client.create_policy(
        PolicyName=FSX_IAM_POLICY_NAME,
        PolicyDocument=fsx_policy_document,
        Description="FSx CSI Driver Policy",
    )
    assert response["Policy"]["Arn"] is not None
    print("fsx IAM policy created!")


def get_fsx_iam_policy_document():
    FSx_POLICY_DOCUMENT = "../../deployments/add-ons/storage/fsx-for-lustre/fsx-csi-driver-policy.json"
    with open(FSx_POLICY_DOCUMENT, "r") as myfile:
        policy = myfile.read()

    return policy


def setup_fsx_iam_service_account():
    create_fsx_iam_service_account()


def create_fsx_iam_service_account():
    print("Creating FSx IAM service account...")

    subprocess.run(
        [
            "eksctl",
            "create",
            "iamserviceaccount",
            "--name",
            "fsx-csi-controller-sa",
            "--namespace",
            "kube-system",
            "--cluster",
            CLUSTER_NAME,
            "--attach-policy-arn",
            FSX_IAM_POLICY_ARN,
            "--approve",
            "--override-existing-serviceaccounts",
            "--region",
            CLUSTER_REGION,
        ]
    )

    print("FSx IAM service account created!")


def setup_fsx_driver():
    print("=================================================================")
    print("                      FSx Driver Setup")
    print("=================================================================")

    install_fsx_driver()


def install_fsx_driver():
    print("Installing FSx driver...")

    FSx_DRIVER_VERSION = "v0.7.1"
    FSx_CSI_DRIVER = f"github.com/kubernetes-sigs/aws-fsx-csi-driver/deploy/kubernetes/overlays/stable/?ref=tags/{FSx_DRIVER_VERSION}"

    kubectl_apply_kustomize(FSx_CSI_DRIVER)

    print("FSx driver installed!")


def setup_fsx_file_system():
    print("=================================================================")
    print("                      FSx File System Setup")
    print("=================================================================")

    if does_need_to_create_fsx_file_system():
        if does_need_to_create_fsx_security_group():
            create_fsx_security_group()
        else:
            print(
                f"Skipping fsx security group creation, security group '{FSX_SECURITY_GROUP_NAME}' already exists!"
            )

        create_fsx_file_system()
    else:
        print(
            f"Skipping fsx file system creation, file system '{FSX_FILE_SYSTEM_NAME}' already exists!"
        )


def does_need_to_create_fsx_file_system() -> bool:
    fsx_client = get_fsx_client(CLUSTER_REGION)
    fsx_file_systems = fsx_client.describe_file_systems()["FileSystems"]

    return not any(
        file_system.get("Name", "") == FSX_FILE_SYSTEM_NAME
        for file_system in fsx_file_systems
    )


def does_need_to_create_fsx_security_group() -> bool:
    ec2_client = get_ec2_client(CLUSTER_REGION)
    fsx_security_groups_with_matching_name = ec2_client.describe_security_groups(
        Filters=[{"Name": "group-name", "Values": [FSX_SECURITY_GROUP_NAME]}]
    )["SecurityGroups"]

    return len(fsx_security_groups_with_matching_name) == 0


def create_fsx_security_group():
    print(f"Creating security group '{FSX_SECURITY_GROUP_NAME}'...")

    eks_client = get_eks_client(CLUSTER_REGION)
    ec2_client = get_ec2_client(CLUSTER_REGION)

    cluster_info = get_cluster_info(eks_client)

    vpc_id = get_vpc_id(cluster_info)
    cluster_security_group = get_cluster_security_group(cluster_info)

    FSX_SECURITY_GROUP_ID = create_security_group_resource(ec2_client, vpc_id)
    authorize_security_group_ingress(
        ec2_client, FSX_SECURITY_GROUP_ID, FSX_SECURITY_GROUP_ID
    )
    authorize_security_group_ingress(
        ec2_client, FSX_SECURITY_GROUP_ID, cluster_security_group
    )
    print("Security group created!")


def get_cluster_info(eks_client):
    return eks_client.describe_cluster(name=CLUSTER_NAME)["cluster"]


def get_vpc_id(cluster_info):
    return cluster_info["resourcesVpcConfig"]["vpcId"]


def get_cluster_security_group(cluster_info):
    return cluster_info["resourcesVpcConfig"]["clusterSecurityGroupId"]


def get_subnet_id(cluster_info):
    return cluster_info["resourcesVpcConfig"]["subnetIds"][0]


def create_security_group_resource(ec2_client, vpc_id):
    return ec2_client.create_security_group(
        Description="Kubeflow FSX security group",
        GroupName=FSX_SECURITY_GROUP_NAME,
        VpcId=vpc_id,
    )["GroupId"]


def authorize_security_group_ingress(
    ec2_client, security_group_id, security_group_id_2
):
    ec2_client.authorize_security_group_ingress(
        GroupId=security_group_id,
        IpPermissions=[
            {
                "FromPort": 988,
                "ToPort": 988,
                "IpProtocol": "tcp",
                "UserIdGroupPairs": [{"GroupId": security_group_id_2}],
            },
        ],
    )


def create_fsx_file_system():
    print("Creating fsx file system...")

    fsx_client = get_fsx_client(CLUSTER_REGION)
    eks_client = get_eks_client(CLUSTER_REGION)
    ec2_client = get_ec2_client(CLUSTER_REGION)
    cluster_info = get_cluster_info(eks_client)
    subnet_id = get_subnet_id(cluster_info)
    security_group_id = get_fsx_security_group_id(ec2_client)

    response = fsx_client.create_file_system(
        FileSystemType="LUSTRE",
        SubnetIds=[subnet_id],
        SecurityGroupIds=[security_group_id],
        StorageCapacity=1200,
        LustreConfiguration={"DeploymentType": "SCRATCH_2"},
        Tags=[
            {"Key": "Name", "Value": FSX_FILE_SYSTEM_NAME},
        ],
    )
    global FSX_FILE_SYSTEM_ID
    FSX_FILE_SYSTEM_ID = response["FileSystem"]["FileSystemId"]
    write_fsx_config_to_file(security_group_id, FSX_FILE_SYSTEM_ID)
    wait_for_fsx_file_system_to_become_available(FSX_FILE_SYSTEM_ID)
    print(f"fsx {FSX_FILE_SYSTEM_ID} created!")


def write_fsx_config_to_file(sg_id, fs_id):
    data_dict = {}
    data_dict["security_group_id"] = sg_id
    data_dict["file_system_id"] = fs_id
    if WRITE_TO_FILE == "True" or WRITE_TO_FILE:
        write_json_file(CONFIG_FILENAME, data_dict)


def wait_for_fsx_file_system_to_become_available(file_system_id):
    fsx_client = get_fsx_client(CLUSTER_REGION)

    status = None

    while status != "AVAILABLE":

        print(f"{file_system_id} {status} .... waiting")
        status = fsx_client.describe_file_systems(FileSystemIds=[file_system_id])[
            "FileSystems"
        ][0]["Lifecycle"]

        if status == "error":
            raise Exception(
                "An unexpected error occurred while waiting for the fsx file system to become available!"
            )

        sleep(10)

    print("fsx file system is available!")


def get_fsx_security_group_id(ec2_client):
    return ec2_client.describe_security_groups(
        Filters=[{"Name": "group-name", "Values": [FSX_SECURITY_GROUP_NAME]}]
    )["SecurityGroups"][0]["GroupId"]


def setup_fsx_provisioning():
    print("=================================================================")
    print("                      fsx Provisioning Setup")
    print("=================================================================")

    setup_static_provisioning()


def setup_static_provisioning():
    print("Setting up static provisioning...")
    apply_static_provisioning_storage_class()
    apply_static_provisioning_persistent_volume()
    print("Static provisioning setup done!")


def apply_static_provisioning_storage_class():
    print("Creating storage class...")
    kubectl_apply(FSX_STATIC_PROVISIONING_FILE_PATH + "/sc.yaml")
    print("Storage class created!")


def apply_static_provisioning_persistent_volume():
    print("Creating persistent volume...")
    fsx_pv_filepath = FSX_STATIC_PROVISIONING_FILE_PATH + "/pv.yaml"
    print(f"THis is filesystem id {FSX_FILE_SYSTEM_ID}")
    dns_name = get_fsx_dns_name()
    mount_name = get_fsx_mount_name()

    fsx_pv = load_yaml_file(fsx_pv_filepath)
    fsx_pv["spec"]["csi"]["volumeHandle"] = FSX_FILE_SYSTEM_ID
    fsx_pv["metadata"]["name"] = FSX_FILE_SYSTEM_NAME
    fsx_pv["spec"]["csi"]["volumeAttributes"]["dnsname"] = dns_name
    fsx_pv["spec"]["csi"]["volumeAttributes"]["mountname"] = mount_name
    write_yaml_file(fsx_pv, fsx_pv_filepath)
    kubectl_apply(fsx_pv_filepath)
    print("Persistent Volume created!")


def get_fsx_dns_name():
    fsx_client = get_fsx_client(CLUSTER_REGION)
    response = fsx_client.describe_file_systems(FileSystemIds=[FSX_FILE_SYSTEM_ID])
    return response["FileSystems"][0]["DNSName"]


def get_fsx_mount_name():
    fsx_client = get_fsx_client(CLUSTER_REGION)
    response = fsx_client.describe_file_systems(FileSystemIds=[FSX_FILE_SYSTEM_ID])
    return response["FileSystems"][0]["LustreConfiguration"]["MountName"]


def footer():
    print("=================================================================")
    print("                      fsx Setup Complete")
    print("=================================================================")


parser = argparse.ArgumentParser()
parser.add_argument(
    "--region",
    type=str,
    metavar="CLUSTER_REGION",
    help="Your cluster region code (eg: us-east-2)",
    required=True,
)
parser.add_argument(
    "--cluster",
    type=str,
    metavar="CLUSTER_NAME",
    help="Your cluster name (eg: mycluster-1)",
    required=True,
)
FSX_FILE_SYSTEM_NAME_DEFAULT = "Kubeflow-fsx"
parser.add_argument(
    "--fsx_file_system_name",
    type=str,
    default=FSX_FILE_SYSTEM_NAME_DEFAULT,
    help=f"Default is set to {FSX_FILE_SYSTEM_NAME_DEFAULT}",
    required=False,
)
FSX_SECURITY_GROUP_NAME_DEFAULT = "KubeflowfsxSecurityGroup"
parser.add_argument(
    "--fsx_security_group_name",
    type=str,
    default=FSX_SECURITY_GROUP_NAME_DEFAULT,
    help=f"Default is set to {FSX_SECURITY_GROUP_NAME_DEFAULT}",
    required=False,
)
parser.add_argument(
    "--write_to_file",
    type=str,
    default="False",
    help=f"Specify True if you want some parameters to be written to a file.",
    required=False,
)
parser.add_argument(
    "--config_filename",
    type=str,
    default="fsx-config.json",
    help=f"Specify the name of the config file. Default is `fsx-config.json`.",
    required=False,
)


args, _ = parser.parse_known_args()

if __name__ == "__main__":
    CLUSTER_REGION = args.region
    CLUSTER_NAME = args.cluster
    FSX_FILE_SYSTEM_NAME = args.fsx_file_system_name
    FSX_SECURITY_GROUP_NAME = args.fsx_security_group_name
    WRITE_TO_FILE = args.write_to_file
    CONFIG_FILENAME = args.config_filename

    AWS_ACCOUNT_ID = boto3.client("sts").get_caller_identity()["Account"]
    FSX_IAM_POLICY_NAME = "fsx-csi-driver-policy" + FSX_FILE_SYSTEM_NAME
    FSX_IAM_POLICY_ARN = f"arn:aws:iam::{AWS_ACCOUNT_ID}:policy/{FSX_IAM_POLICY_NAME}"
    FSX_STATIC_PROVISIONING_FILE_PATH = (
        "../../deployments/add-ons/storage/fsx-for-lustre/static-provisioning"
    )
    FSX_SECURITY_GROUP_ID = ""

    main()
