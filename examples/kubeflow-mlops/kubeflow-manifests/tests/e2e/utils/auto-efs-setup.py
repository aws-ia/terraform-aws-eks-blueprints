import argparse
import boto3
import subprocess
import string
import random
import yaml
import urllib.request
from shutil import which
from time import sleep


def main():
    header()

    verify_prerequisites()

    setup_iam_authorization()
    setup_efs_driver()
    setup_efs_file_system()
    setup_efs_provisioning()

    footer()


def header():
    print("=================================================================")
    print("                          EFS Setup")


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
    iam_client = get_iam_client()
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


def get_iam_client():
    return boto3.client("iam", region_name=CLUSTER_REGION)


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

    setup_efs_iam_policy()
    setup_efs_iam_service_account()


def setup_efs_iam_policy():
    if does_need_to_create_efs_iam_policy():
        create_efs_iam_policy()
    else:
        print(
            f"Skipping EFS IAM policy creation, '{EFS_IAM_POLICY_NAME}' already exists!"
        )


def does_need_to_create_efs_iam_policy():
    iam_resource = get_iam_resource()
    try:
        iam_resource.Policy(EFS_IAM_POLICY_ARN).load()
        return False
    except iam_resource.meta.client.exceptions.NoSuchEntityException:
        return True


def get_iam_resource():
    return boto3.resource("iam", region_name=CLUSTER_REGION)


def create_efs_iam_policy():
    print("Creating EFS IAM policy...")

    policy_document = get_efs_iam_policy_document()

    iam_client = get_iam_client()
    iam_client.create_policy(
        PolicyName=EFS_IAM_POLICY_NAME,
        PolicyDocument=policy_document,
        Description="EFS CSI Driver Policy",
    )

    print("EFS IAM policy created!")


def get_efs_iam_policy_document():
    url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/v1.3.6/docs/iam-policy-example.json"
    response = urllib.request.urlopen(url)
    data = response.read()
    return data.decode("utf-8")


def setup_efs_iam_service_account():
    create_efs_iam_service_account()


def create_efs_iam_service_account():
    print("Creating EFS IAM service account...")

    subprocess.run(
        [
            "eksctl",
            "create",
            "iamserviceaccount",
            "--name",
            "efs-csi-controller-sa",
            "--namespace",
            "kube-system",
            "--cluster",
            CLUSTER_NAME,
            "--attach-policy-arn",
            EFS_IAM_POLICY_ARN,
            "--approve",
            "--override-existing-serviceaccounts",
            "--region",
            CLUSTER_REGION,
        ]
    )

    print("EFS IAM service account created!")


def setup_efs_driver():
    print("=================================================================")
    print("                      EFS Driver Setup")
    print("=================================================================")

    install_efs_driver()


def install_efs_driver():
    print("Installing EFS driver...")

    kubectl_kustomize_apply(
        "https://github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=tags/v1.3.6"
    )

    print("EFS driver installed!")


def kubectl_kustomize_apply(file_name: str):
    subprocess.run(["kubectl", "apply", "-k", file_name])


def kubectl_apply(file_name: str):
    subprocess.run(["kubectl", "apply", "-f", file_name, "--force"])


def setup_efs_file_system():
    print("=================================================================")
    print("                      EFS File System Setup")
    print("=================================================================")

    if does_need_to_create_efs_file_system():
        if does_need_to_create_efs_security_group():
            create_efs_security_group()
        else:
            print(
                f"Skipping EFS security group creation, security group '{EFS_SECURITY_GROUP_NAME}' already exists!"
            )

        create_efs_file_system()
    else:
        print(
            f"Skipping EFS file system creation, file system '{EFS_FILE_SYSTEM_NAME}' already exists!"
        )


def does_need_to_create_efs_file_system() -> bool:
    efs_client = get_efs_client()
    efs_file_systems = efs_client.describe_file_systems()["FileSystems"]

    return not any(
        file_system.get("Name", "") == EFS_FILE_SYSTEM_NAME
        for file_system in efs_file_systems
    )


def get_efs_client():
    return boto3.client("efs", region_name=CLUSTER_REGION)


def does_need_to_create_efs_security_group() -> bool:
    ec2_client = get_ec2_client()
    efs_security_groups_with_matching_name = ec2_client.describe_security_groups(
        Filters=[{"Name": "group-name", "Values": [EFS_SECURITY_GROUP_NAME]}]
    )["SecurityGroups"]

    return len(efs_security_groups_with_matching_name) == 0


def get_ec2_client():
    return boto3.client("ec2", region_name=CLUSTER_REGION)


def create_efs_security_group():
    print(f"Creating security group '{EFS_SECURITY_GROUP_NAME}'...")

    eks_client = get_eks_client()
    ec2_client = get_ec2_client()

    vpc_id = get_vpc_id(eks_client)
    print("VPC_ID:  ", vpc_id)
    cidr_block_ip = get_cidr_block_ip(ec2_client, vpc_id)
    print("CIDR: ", cidr_block_ip)
    security_group_id = create_security_group_resource(ec2_client, vpc_id)
    authorize_security_group_ingress(cidr_block_ip, ec2_client, security_group_id)

    print("Security group created!")


def get_eks_client():
    return boto3.client("eks", region_name=CLUSTER_REGION)


def get_cluster_info(eks_client):
    return eks_client.describe_cluster(name=CLUSTER_NAME)["cluster"]


def get_vpc_id(eks_client):
    response = eks_client.describe_cluster(name=CLUSTER_NAME)
    return response["cluster"]["resourcesVpcConfig"]["vpcId"]


def get_cidr_block_ip(ec2_client, vpc_id):
    # Get CIDR Range
    response = ec2_client.describe_vpcs(
        VpcIds=[
            vpc_id,
        ]
    )
    return response["Vpcs"][0]["CidrBlock"]


def create_security_group_resource(ec2_client, vpc_id):
    return ec2_client.create_security_group(
        Description="Kubeflow EFS security group",
        GroupName=EFS_SECURITY_GROUP_NAME,
        VpcId=vpc_id,
    )["GroupId"]


def authorize_security_group_ingress(cidr_block_ip, ec2_client, security_group_id):
    tcp_port = 2049
    ec2_client.authorize_security_group_ingress(
        CidrIp=cidr_block_ip,
        FromPort=tcp_port,
        ToPort=tcp_port,
        GroupId=security_group_id,
        IpProtocol="tcp",
    )


def create_efs_file_system():
    print("Creating EFS file system...")

    efs_client = get_efs_client()

    efs_file_system_creation_token = generate_creation_token()

    efs_client.create_file_system(
        CreationToken=efs_file_system_creation_token,
        PerformanceMode=EFS_FILE_SYSTEM_PERFORMANCE_MODE,
        Encrypted=True,
        ThroughputMode=EFS_FILE_SYSTEM_THROUGHPUT_MODE,
        Backup=False,
        Tags=[
            {"Key": "Name", "Value": EFS_FILE_SYSTEM_NAME},
        ],
    )
    wait_for_efs_file_system_to_become_available(efs_file_system_creation_token)
    file_system_id = get_file_system_id_from_name(efs_client)
    print(
        f"EFS filesystem {EFS_FILE_SYSTEM_NAME} created! filesystem id: {file_system_id}"
    )
    create_efs_mount_targets(file_system_id)


def generate_creation_token(size=64, chars=string.ascii_uppercase) -> str:
    return "".join(random.choice(chars) for _ in range(size))


def wait_for_efs_file_system_to_become_available(efs_file_system_creation_token):
    efs_client = get_efs_client()

    status = None

    print("Waiting for EFS file system to become available...")

    while status != "available":

        status = efs_client.describe_file_systems(
            CreationToken=efs_file_system_creation_token
        )["FileSystems"][0]["LifeCycleState"]

        if status == "error":
            raise Exception(
                "An unexpected error occurred while waiting for the EFS file system to become available!"
            )

        sleep(1)

    print("EFS file system is available!")


def create_efs_mount_targets(file_system_id):
    efs_client = get_efs_client()

    eks_client = get_eks_client()
    ec2_client = get_ec2_client()
    efs_security_group_id = get_efs_security_group_id(ec2_client)
    subnet_ids = get_nodegroup_subnet_ids(eks_client)

    mount_target_ids = create_mount_targets(
        efs_client, efs_security_group_id, file_system_id, subnet_ids
    )
    wait_for_mount_target_to_become_available(efs_client, mount_target_ids)


def get_file_system_id_from_creation_token(efs_client, efs_file_system_creation_token):
    return efs_client.describe_file_systems(
        CreationToken=efs_file_system_creation_token
    )["FileSystems"][0]["FileSystemId"]


def get_efs_security_group_id(ec2_client):
    return ec2_client.describe_security_groups(
        Filters=[{"Name": "group-name", "Values": [EFS_SECURITY_GROUP_NAME]}]
    )["SecurityGroups"][0]["GroupId"]


def get_nodegroup_subnet_ids(eks_client):
    nodegroups = get_cluster_nodegroup(eks_client)
    print(f"CLUSTER NODEGROUPS:  {nodegroups}")
    cluster_public_subnets = []

    for nodegroup in nodegroups:
        ng_subnets = eks_client.describe_nodegroup(
            clusterName=CLUSTER_NAME, nodegroupName=nodegroup
        )["nodegroup"]["subnets"]

        for subnet in ng_subnets:
            cluster_public_subnets.append(subnet)

    print("CLUSTER PUBLIC SUBNETS:  ", cluster_public_subnets)
    return cluster_public_subnets


def get_cluster_nodegroup(eks_client):
    return eks_client.list_nodegroups(clusterName=CLUSTER_NAME)["nodegroups"]


def create_mount_targets(efs_client, efs_security_group_id, file_system_id, subnet_ids):
    mount_target_ids = []

    for subnet_id in subnet_ids:
        print(f"Creating mount target in subnet {subnet_id}...")

        mount_target_id = efs_client.create_mount_target(
            FileSystemId=file_system_id,
            SubnetId=subnet_id,
            SecurityGroups=[efs_security_group_id],
        )["MountTargetId"]

        print(f"Mount target {mount_target_id} created!")
        mount_target_ids.append(mount_target_id)

    return mount_target_ids


def wait_for_mount_target_to_become_available(efs_client, mount_target_ids):
    for mount_target_id in mount_target_ids:

        status = None

        print(f"Waiting for EFS mount target {mount_target_id} to become available...")

        while status != "available":
            status = efs_client.describe_mount_targets(MountTargetId=mount_target_id)[
                "MountTargets"
            ][0]["LifeCycleState"]

            if status == "error":
                raise Exception(
                    f"An unexpected error occurred while waiting for the mount target {mount_target_id}!"
                )

            sleep(1)

        print(f"{mount_target_id} mount target is available!")


def setup_efs_provisioning():
    print("=================================================================")
    print("                      EFS Provisioning Setup")
    print("=================================================================")

    setup_dynamic_provisioning()


def setup_dynamic_provisioning():
    print("Setting up dynamic provisioning...")

    update_dynamic_provisioning_storage_class_file()
    apply_dynamic_provisioning_storage_class()

    print("Dynamic provisioning setup done!")


def update_dynamic_provisioning_storage_class_file():
    efs_client = get_efs_client()
    file_system_id = get_file_system_id_from_name(efs_client)

    storage_class_file_yaml_content = (
        read_dynamic_provisioning_storage_class_file_content()
    )

    edit_dynamic_provisioning_storage_class_fields(
        file_system_id, storage_class_file_yaml_content
    )


def read_dynamic_provisioning_storage_class_file_content():
    with open(EFS_DYNAMIC_PROVISIONING_STORAGE_CLASS_FILE_PATH, "r") as file:
        storage_class_file_content = file.read()

    return yaml.safe_load(storage_class_file_content)


def edit_dynamic_provisioning_storage_class_fields(
    file_system_id, storage_class_file_yaml_content
):
    print("Editing storage class with appropriate values...")

    storage_class_file_yaml_content["parameters"]["fileSystemId"] = file_system_id

    with open(EFS_DYNAMIC_PROVISIONING_STORAGE_CLASS_FILE_PATH, "w") as file:
        file.write(yaml.dump(storage_class_file_yaml_content))


def get_file_system_id_from_name(efs_client):
    def name_matches(filesystem):
        return filesystem["Name"] == EFS_FILE_SYSTEM_NAME

    file_systems = efs_client.describe_file_systems()["FileSystems"]

    file_system = next(filter(name_matches, file_systems))

    return file_system["FileSystemId"]


def apply_dynamic_provisioning_storage_class():
    print("Creating storage class...")
    kubectl_apply(EFS_DYNAMIC_PROVISIONING_STORAGE_CLASS_FILE_PATH)
    print("Storage class created!")


def footer():
    print("=================================================================")
    print("                      EFS Setup Complete")
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
EFS_FILE_SYSTEM_NAME_DEFAULT = "Kubeflow-efs"
parser.add_argument(
    "--efs_file_system_name",
    type=str,
    default=EFS_FILE_SYSTEM_NAME_DEFAULT,
    help=f"Default is set to {EFS_FILE_SYSTEM_NAME_DEFAULT}",
    required=False,
)
EFS_SECURITY_GROUP_NAME_DEFAULT = "KubeflowEfsSecurityGroup"
parser.add_argument(
    "--efs_security_group_name",
    type=str,
    default=EFS_SECURITY_GROUP_NAME_DEFAULT,
    help=f"Default is set to {EFS_SECURITY_GROUP_NAME_DEFAULT}",
    required=False,
)
EFS_PERFORMANCE_MODE_DEFAULT = "generalPurpose"
parser.add_argument(
    "--efs_performance_mode",
    type=str,
    default=EFS_PERFORMANCE_MODE_DEFAULT,
    help=f"Default is set to {EFS_PERFORMANCE_MODE_DEFAULT}",
    required=False,
)
EFS_THROUGHPUT_MODE_DEFAULT = "bursting"
parser.add_argument(
    "--efs_throughput_mode",
    type=str,
    default=EFS_THROUGHPUT_MODE_DEFAULT,
    help=f"Default is set to {EFS_THROUGHPUT_MODE_DEFAULT}",
    required=False,
)
DEFAULT_DIRECTORY_PATH = ""
parser.add_argument(
    "--directory",
    type=str,
    default=DEFAULT_DIRECTORY_PATH,
    help=f"Specify the path to the source files if different. Default is set to empty.",
    required=False,
)

args, _ = parser.parse_known_args()

if __name__ == "__main__":
    CLUSTER_REGION = args.region
    CLUSTER_NAME = args.cluster
    EFS_FILE_SYSTEM_NAME = args.efs_file_system_name
    EFS_SECURITY_GROUP_NAME = args.efs_security_group_name
    EFS_FILE_SYSTEM_PERFORMANCE_MODE = args.efs_performance_mode
    EFS_FILE_SYSTEM_THROUGHPUT_MODE = args.efs_throughput_mode
    DIRECTORY_PATH = args.directory

    AWS_ACCOUNT_ID = boto3.client("sts").get_caller_identity()["Account"]
    EFS_IAM_POLICY_NAME = "AmazonEKS_EFS_CSI_Driver_Policy" + EFS_FILE_SYSTEM_NAME
    EFS_IAM_POLICY_ARN = f"arn:aws:iam::{AWS_ACCOUNT_ID}:policy/{EFS_IAM_POLICY_NAME}"

    EFS_DYNAMIC_PROVISIONING_STORAGE_CLASS_FILE_PATH = (
        DIRECTORY_PATH
        + "../../deployments/add-ons/storage/efs/dynamic-provisioning/sc.yaml"
    )

    main()
