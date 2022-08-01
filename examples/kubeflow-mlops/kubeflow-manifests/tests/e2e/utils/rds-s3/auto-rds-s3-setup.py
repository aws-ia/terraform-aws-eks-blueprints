import argparse
import boto3
import subprocess
import json
import yaml

from importlib.metadata import metadata
from e2e.fixtures.cluster import create_iam_service_account
from e2e.utils.config import configure_env_file
from e2e.utils.utils import (
    get_ec2_client,
    get_rds_client,
    get_eks_client,
    get_s3_client,
    get_secrets_manager_client,
    kubectl_apply,
    print_banner,
    write_yaml_file,
    load_yaml_file,
    wait_for,
    WaitForCircuitBreakerError
)

from shutil import which


def main():
    verify_prerequisites()
    s3_client = get_s3_client(
        region=CLUSTER_REGION,
    )
    secrets_manager_client = get_secrets_manager_client(CLUSTER_REGION)
    setup_s3(s3_client, secrets_manager_client)
    rds_client = get_rds_client(CLUSTER_REGION)
    eks_client = get_eks_client(CLUSTER_REGION)
    ec2_client = get_ec2_client(CLUSTER_REGION)
    setup_rds(rds_client, secrets_manager_client, eks_client, ec2_client)
    setup_cluster_secrets()
    setup_kubeflow_pipeline()

    print_banner("RDS S3 Setup Complete")
    script_metadata = [
        f"bucket_name={S3_BUCKET_NAME}",
        f"db_instance_name={DB_INSTANCE_NAME}",
        f"db_subnet_group_name={DB_SUBNET_GROUP_NAME}",
        f"s3_secret_name={S3_SECRET_NAME}",
        f"rds_secret_name={RDS_SECRET_NAME}",
    ]
    script_metadata = {}
    script_metadata["S3"] = {"bucket": S3_BUCKET_NAME, "secretName": S3_SECRET_NAME}
    script_metadata["RDS"] = {
        "instanceName": DB_INSTANCE_NAME,
        "secretName": RDS_SECRET_NAME,
        "subnetGroupName": DB_SUBNET_GROUP_NAME,
    }
    script_metadata["CLUSTER"] = {"region": CLUSTER_REGION, "name": CLUSTER_NAME}
    write_yaml_file(
        yaml_content=script_metadata, file_path="utils/rds-s3/metadata.yaml"
    )


def verify_prerequisites():
    print_banner("Prerequisites Verification")
    verify_eksctl_is_installed()
    verify_kubectl_is_installed()


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


def setup_s3(s3_client, secrets_manager_client):
    print_banner("S3 Setup")
    setup_s3_bucket(s3_client)
    setup_s3_secrets(secrets_manager_client)


def setup_s3_bucket(s3_client):
    if not does_bucket_exist(s3_client):
        create_s3_bucket(s3_client)
    else:
        print(f"Skipping S3 bucket creation, bucket '{S3_BUCKET_NAME}' already exists!")


def does_bucket_exist(s3_client):
    buckets = s3_client.list_buckets()["Buckets"]
    return any(bucket["Name"] == S3_BUCKET_NAME for bucket in buckets)


def create_s3_bucket(s3_client):
    print("Creating S3 bucket...")

    args = {"ACL": "private", "Bucket": S3_BUCKET_NAME}
    # CreateBucketConfiguration is necessary to provide LocationConstraint unless using default region of us-east-1
    if CLUSTER_REGION != "us-east-1":
        args["CreateBucketConfiguration"] = {"LocationConstraint": CLUSTER_REGION}

    s3_client.create_bucket(**args)
    print("S3 bucket created!")


def setup_s3_secrets(secrets_manager_client):
    if not does_secret_already_exist(secrets_manager_client, S3_SECRET_NAME):
        create_s3_secret(secrets_manager_client, S3_SECRET_NAME)
    else:
        print(f"Skipping S3 secret creation, secret '{S3_SECRET_NAME}' already exists!")


def does_secret_already_exist(secrets_manager_client, secret_name):
    matching_secrets = secrets_manager_client.list_secrets(
        Filters=[{"Key": "name", "Values": [secret_name]}]
    )["SecretList"]

    return len(matching_secrets) > 0


def create_s3_secret(secrets_manager_client, s3_secret_name):
    print("Creating S3 secret...")

    secret_string = json.dumps(
        {"accesskey": f"{S3_ACCESS_KEY_ID}", "secretkey": f"{S3_SECRET_ACCESS_KEY}"}
    )

    secrets_manager_client.create_secret(
        Name=s3_secret_name,
        Description="Kubeflow S3 secret",
        SecretString=secret_string,
    )

    print("S3 secret created!")


def setup_rds(rds_client, secrets_manager_client, eks_client, ec2_client):
    print_banner("RDS Setup")

    rds_secret_exists = does_secret_already_exist(secrets_manager_client, RDS_SECRET_NAME)

    if not does_database_exist(rds_client):
        if rds_secret_exists:
            # Avoiding overwriting an existing secret with a new DB endpoint in case that secret is being used with an existing installation
            raise Exception(f"A RDS DB instance was not created because a secret with the name {RDS_SECRET_NAME} already exists. To create the instance, delete the existing secret or provide a unique name for a new secret to be created.")

        db_root_password = setup_db_instance(
            rds_client, secrets_manager_client, eks_client, ec2_client
        )

        create_rds_secret(secrets_manager_client, RDS_SECRET_NAME, db_root_password)
    else:
        print(f"Skipping RDS setup, DB instance '{DB_INSTANCE_NAME}' already exists!")

        # The username and password for the existing DB instance are unknown at this point (since they are only known during DB instance creation.)
        # So a new secret with the username and password values can't be created.
        if not rds_secret_exists:
            raise Exception(f"Secret {RDS_SECRET_NAME} was not created because the username and password of the instance {DB_INSTANCE_NAME} are hidden (in another secret) after creation. To create the secret, specify a new DB instance to be created or delete the existing DB instance.")


def does_database_exist(rds_client):
    matching_databases = rds_client.describe_db_instances(
        Filters=[{"Name": "db-instance-id", "Values": [DB_INSTANCE_NAME]}]
    )["DBInstances"]

    return len(matching_databases) > 0


def setup_db_instance(rds_client, secrets_manager_client, eks_client, ec2_client):
    setup_db_subnet_group(rds_client, eks_client, ec2_client)
    return create_db_instance(
        rds_client, secrets_manager_client, eks_client, ec2_client
    )


def setup_db_subnet_group(rds_client, eks_client, ec2_client):
    if not does_db_subnet_group_exist(rds_client):
        create_db_subnet_group(rds_client, eks_client, ec2_client)
    else:
        print(
            f"Skipping DB subnet group creation, DB subnet group '{DB_SUBNET_GROUP_NAME}' already exists!"
        )


def does_db_subnet_group_exist(rds_client):
    try:
        rds_client.describe_db_subnet_groups(DBSubnetGroupName=DB_SUBNET_GROUP_NAME)
        return True
    except rds_client.exceptions.DBSubnetGroupNotFoundFault:
        return False


def create_db_subnet_group(rds_client, eks_client, ec2_client):
    print("Creating DB subnet group...")

    subnet_ids = get_cluster_private_subnet_ids(eks_client, ec2_client)

    rds_client.create_db_subnet_group(
        DBSubnetGroupName=DB_SUBNET_GROUP_NAME,
        DBSubnetGroupDescription="Subnet group for Kubeflow metadata db",
        SubnetIds=subnet_ids,
    )

    print("DB subnet group created!")


def get_cluster_private_subnet_ids(eks_client, ec2_client):
    subnet_ids = eks_client.describe_cluster(name=CLUSTER_NAME)["cluster"][
        "resourcesVpcConfig"
    ]["subnetIds"]

    # TODO handle pagination
    subnets = ec2_client.describe_subnets(SubnetIds=subnet_ids)["Subnets"]
    private_subnets = []
    for subnet in subnets:
        for tags in subnet["Tags"]:
            if "SubnetPrivate" in tags["Value"]:
                private_subnets.append(subnet)

    def get_subnet_id(subnet):
        return subnet["SubnetId"]

    return list(map(get_subnet_id, private_subnets))


def create_db_instance(rds_client, secrets_manager_client, eks_client, ec2_client):
    print("Creating DB instance...")

    vpc_security_group_id = get_vpc_security_group_id(eks_client)

    db_root_password = get_db_root_password_or_generate_one(secrets_manager_client)

    rds_client.create_db_instance(
        DBName=DB_NAME,
        DBInstanceIdentifier=DB_INSTANCE_NAME,
        AllocatedStorage=DB_INITIAL_STORAGE,
        DBInstanceClass=DB_INSTANCE_TYPE,
        Engine="mysql",
        MasterUsername=DB_ROOT_USER,
        MasterUserPassword=db_root_password,
        VpcSecurityGroupIds=[vpc_security_group_id],
        DBSubnetGroupName=DB_SUBNET_GROUP_NAME,
        BackupRetentionPeriod=DB_BACKUP_RETENTION_PERIOD,
        MultiAZ=True,
        PubliclyAccessible=False,
        StorageType=DB_STORAGE_TYPE,
        DeletionProtection=True,
        MaxAllocatedStorage=DB_MAX_STORAGE,
    )

    print("DB instance created!")

    wait_for_rds_db_instance_to_become_available(rds_client)

    return db_root_password


def get_db_root_password_or_generate_one(secrets_manager_client):
    if DB_ROOT_PASSWORD is None:
        return secrets_manager_client.get_random_password(
            PasswordLength=32,
            ExcludeNumbers=False,
            ExcludePunctuation=True,
            ExcludeUppercase=False,
            ExcludeLowercase=False,
            IncludeSpace=False,
        )["RandomPassword"]
    else:
        return DB_ROOT_PASSWORD


def get_vpc_security_group_id(eks_client):
    security_group_id = eks_client.describe_cluster(name=CLUSTER_NAME)["cluster"][
        "resourcesVpcConfig"
    ]["clusterSecurityGroupId"]

    # Note : We only need to return 1 security group because we use the shared node security group, this fixes https://github.com/awslabs/kubeflow-manifests/issues/137
    return security_group_id


def wait_for_rds_db_instance_to_become_available(rds_client):

    print("Waiting for RDS DB instance to become available...")

    def callback():
        status = rds_client.describe_db_instances(
            DBInstanceIdentifier=DB_INSTANCE_NAME
        )["DBInstances"][0]["DBInstanceStatus"]
        if status == "failed":
            raise WaitForCircuitBreakerError(
                "An unexpected error occurred while waiting for the RDS DB instance to become available!"
            )
        assert status == "available"
        if status == "available":
            print("RDS DB instance is available!")

    wait_for(callback, 900)


def create_rds_secret(secrets_manager_client, rds_secret_name, rds_root_password):
    print("Creating RDS secret...")

    db_instance_info = get_db_instance_info()

    secret_string = json.dumps(
        {
            "username": f"{db_instance_info['MasterUsername']}",
            "password": f"{rds_root_password}",
            "database": f"{db_instance_info['DBName']}",
            "host": f"{db_instance_info['Endpoint']['Address']}",
            "port": f"{db_instance_info['Endpoint']['Port']}",
        }
    )

    secrets_manager_client.create_secret(
        Name=rds_secret_name,
        Description="Kubeflow RDS secret",
        SecretString=secret_string,
    )

    print("RDS secret created!")


def get_db_instance_info():
    rds_client = get_rds_client(CLUSTER_REGION)

    return rds_client.describe_db_instances(DBInstanceIdentifier=DB_INSTANCE_NAME)[
        "DBInstances"
    ][0]


def setup_cluster_secrets():
    print_banner("Cluster Secrets Setup")

    setup_iam_service_account()
    setup_secrets_provider()


def setup_iam_service_account():
    create_secrets_iam_service_account()


def create_secrets_iam_service_account():
    print("Creating secrets IAM service account...")
    iam_policies = [
        "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
        "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    ]

    create_iam_service_account(
        service_account_name="kubeflow-secrets-manager-sa",
        namespace="kubeflow",
        cluster_name=CLUSTER_NAME,
        region=CLUSTER_REGION,
        iam_policy_arns=iam_policies,
    )

    print("Secrets IAM service account created!")


def setup_secrets_provider():
    print("Installing secrets provider...")
    install_secrets_store_csi_driver()
    print("Secrets provider install done!")


def install_secrets_store_csi_driver():
    kubectl_apply(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/rbac-secretproviderclass.yaml"
    )
    kubectl_apply(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/csidriver.yaml"
    )
    kubectl_apply(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml"
    )
    kubectl_apply(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml"
    )
    kubectl_apply(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/secrets-store-csi-driver.yaml"
    )
    kubectl_apply(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/rbac-secretprovidersyncing.yaml"
    )
    kubectl_apply(
        "https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml"
    )


def setup_kubeflow_pipeline():
    print("Setting up Kubeflow Pipeline...")

    print("Retrieving DB instance info...")
    db_instance_info = get_db_instance_info()

    pipeline_rds_params_env_file = "../../awsconfigs/apps/pipeline/rds/params.env"
    pipeline_rds_secret_provider_class_file = (
        "../../awsconfigs/common/aws-secrets-manager/rds/secret-provider.yaml"
    )

    rds_params = {
        "dbHost": db_instance_info["Endpoint"]["Address"],
        "mlmdDb": "metadb",
    }
    edit_pipeline_params_env_file(rds_params, pipeline_rds_params_env_file)

    update_secret_provider_class(
        pipeline_rds_secret_provider_class_file, RDS_SECRET_NAME
    )

    pipeline_s3_params_env_file = "../../awsconfigs/apps/pipeline/s3/params.env"
    pipeline_s3_secret_provider_class_file = (
        "../../awsconfigs/common/aws-secrets-manager/s3/secret-provider.yaml"
    )

    s3_params = {
        "bucketName": S3_BUCKET_NAME,
        "minioServiceRegion": CLUSTER_REGION,
        "minioServiceHost": "s3.amazonaws.com",
    }
    edit_pipeline_params_env_file(s3_params, pipeline_s3_params_env_file)

    update_secret_provider_class(pipeline_s3_secret_provider_class_file, S3_SECRET_NAME)

    print("Kubeflow pipeline setup done!")


def edit_pipeline_params_env_file(params_env, pipeline_params_env_file):
    print(f"Editing {pipeline_params_env_file} with appropriate values...")

    configure_env_file(pipeline_params_env_file, params_env)


def update_secret_provider_class(secret_provider_class_file, secret_name):
    secret_provider = load_yaml_file(secret_provider_class_file)

    secret_provider_objects = yaml.safe_load(
        secret_provider["spec"]["parameters"]["objects"]
    )
    secret_provider_objects[0]["objectName"] = secret_name
    secret_provider["spec"]["parameters"]["objects"] = yaml.dump(
        secret_provider_objects
    )

    write_yaml_file(secret_provider, secret_provider_class_file)


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
parser.add_argument(
    "--bucket",
    type=str,
    metavar="S3_BUCKET",
    help="Your S3 bucket name (eg: mybucket)",
    required=True,
)
DB_ROOT_USER_DEFAULT = "admin"
parser.add_argument(
    "--db_root_user",
    type=str,
    default=DB_ROOT_USER_DEFAULT,
    help=f"Default is set to {DB_ROOT_USER_DEFAULT}",
    required=False,
)
parser.add_argument(
    "--db_root_password",
    type=str,
    help="AWS will generate a random password using secrets manager if no password is provided",
    required=False,
)
DB_INSTANCE_NAME_DEFAULT = "kubeflow-db"
parser.add_argument(
    "--db_instance_name",
    type=str,
    default=DB_INSTANCE_NAME_DEFAULT,
    help=f"Unique identifier for the RDS database instance. Default is set to {DB_INSTANCE_NAME_DEFAULT}",
    required=False,
)
DB_NAME_DEFAULT = "kubeflow"
parser.add_argument(
    "--db_name",
    type=str,
    default=DB_NAME_DEFAULT,
    help=f"Name of the metadata database. Default is set to {DB_NAME_DEFAULT}",
    required=False,
)
DB_INSTANCE_TYPE_DEFAULT = "db.m5.large"
parser.add_argument(
    "--db_instance_type",
    type=str,
    default=DB_INSTANCE_TYPE_DEFAULT,
    help=f"Default is set to {DB_INSTANCE_TYPE_DEFAULT}",
    required=False,
)
DB_INITIAL_STORAGE_DEFAULT = 50
parser.add_argument(
    "--db_initial_storage",
    type=int,
    default=DB_INITIAL_STORAGE_DEFAULT,
    help=f"Initial storage capacity in GB. Default is set to {DB_INITIAL_STORAGE_DEFAULT}",
    required=False,
)
DB_MAX_STORAGE_DEFAULT = 1000
parser.add_argument(
    "--db_max_storage",
    type=int,
    default=DB_MAX_STORAGE_DEFAULT,
    help=f"Maximum storage capacity in GB. Default is set to {DB_MAX_STORAGE_DEFAULT}",
    required=False,
)
DB_BACKUP_RETENTION_PERIOD_DEFAULT = 7
parser.add_argument(
    "--db_backup_retention_period",
    type=int,
    default=DB_BACKUP_RETENTION_PERIOD_DEFAULT,
    help=f"Default is set to {DB_BACKUP_RETENTION_PERIOD_DEFAULT}",
    required=False,
)
DB_STORAGE_TYPE_DEFAULT = "gp2"
parser.add_argument(
    "--db_storage_type",
    type=str,
    default=DB_STORAGE_TYPE_DEFAULT,
    help=f"Default is set to {DB_STORAGE_TYPE_DEFAULT}",
    required=False,
)
DB_SUBNET_GROUP_NAME_DEFAULT = "kubeflow-db-subnet-group"
parser.add_argument(
    "--db_subnet_group_name",
    type=str,
    default=DB_SUBNET_GROUP_NAME_DEFAULT,
    help=f"Default is set to {DB_SUBNET_GROUP_NAME_DEFAULT}",
    required=False,
)
parser.add_argument(
    "--s3_aws_access_key_id",
    type=str,
    help="""
    This parameter allows to explicitly specify the access key ID to use for the setup.
    The access key ID is used to create the S3 bucket and is saved using the secrets manager.
    """,
    required=True,
)
parser.add_argument(
    "--s3_aws_secret_access_key",
    type=str,
    help="""
    This parameter allows to explicitly specify the secret access key to use for the setup.
    The secret access key is used to create the S3 bucket and is saved using the secrets manager.
    """,
    required=True,
)
RDS_SECRET_NAME = "rds-secret"
parser.add_argument(
    "--rds_secret_name",
    type=str,
    default=RDS_SECRET_NAME,
    help=f"Name of the secret containing RDS related credentials. Default is set to {RDS_SECRET_NAME}",
    required=False,
)
S3_SECRET_NAME = "s3-secret"
parser.add_argument(
    "--s3_secret_name",
    type=str,
    default=S3_SECRET_NAME,
    help=f"Name of the secret containing S3 related credentials. Default is set to {S3_SECRET_NAME}",
    required=False,
)

args, _ = parser.parse_known_args()

if __name__ == "__main__":
    CLUSTER_REGION = args.region
    CLUSTER_NAME = args.cluster
    S3_BUCKET_NAME = args.bucket
    S3_ACCESS_KEY_ID = args.s3_aws_access_key_id
    S3_SECRET_ACCESS_KEY = args.s3_aws_secret_access_key
    DB_ROOT_USER = args.db_root_user
    DB_ROOT_PASSWORD = args.db_root_password
    DB_INSTANCE_NAME = args.db_instance_name
    DB_NAME = args.db_name
    DB_INSTANCE_TYPE = args.db_instance_type
    DB_INITIAL_STORAGE = args.db_initial_storage
    DB_MAX_STORAGE = args.db_max_storage
    DB_BACKUP_RETENTION_PERIOD = args.db_backup_retention_period
    DB_STORAGE_TYPE = args.db_storage_type
    DB_SUBNET_GROUP_NAME = args.db_subnet_group_name
    RDS_SECRET_NAME = args.rds_secret_name
    S3_SECRET_NAME = args.s3_secret_name

    main()
