import argparse
from time import sleep
import boto3
from e2e.fixtures.cluster import delete_iam_service_account

from e2e.utils.utils import (
    get_rds_client,
    get_s3_client,
    get_secrets_manager_client,
    load_yaml_file,
    kubectl_delete,
)


def main():
    metadata = load_yaml_file("utils/rds-s3/metadata.yaml")
    region = metadata["CLUSTER"]["region"]
    cluster_name = metadata["CLUSTER"]["name"]
    secrets_manager_client = get_secrets_manager_client(region)
    delete_s3_bucket(metadata, secrets_manager_client, region)
    delete_rds(metadata, secrets_manager_client, region)
    uninstall_secrets_manager(region, cluster_name)


def delete_s3_bucket(metadata, secrets_manager_client, region):
    s3_client = get_s3_client(region)
    s3_resource = boto3.resource("s3")
    bucket_name = metadata["S3"]["bucket"]

    print("Deleting S3 bucket...")

    bucket = s3_resource.Bucket(bucket_name)
    bucket.objects.all().delete()
    s3_client.delete_bucket(Bucket=bucket_name)

    secrets_manager_client.delete_secret(
        SecretId=metadata["S3"]["secretName"], ForceDeleteWithoutRecovery=True
    )


def delete_rds(metadata, secrets_manager_client, region):
    rds_client = get_rds_client(region)
    db_instance_name = metadata["RDS"]["instanceName"]
    db_subnet_group_name = metadata["RDS"]["subnetGroupName"]

    print("Deleting RDS instance...")

    rds_client.modify_db_instance(
        DBInstanceIdentifier=db_instance_name,
        DeletionProtection=False,
        ApplyImmediately=True,
    )
    rds_client.delete_db_instance(
        DBInstanceIdentifier=db_instance_name, SkipFinalSnapshot=True
    )
    wait_periods = 30
    period_length = 30
    for _ in range(wait_periods):
        try:
            if (
                rds_client.describe_db_instances(DBInstanceIdentifier=db_instance_name)
                is not None
            ):
                sleep(period_length)
        except:
            print("RDS instance has been successfully deleted")
            break

    print("Deleting DB Subnet Group...")

    rds_client.delete_db_subnet_group(DBSubnetGroupName=db_subnet_group_name)
    print("DB Subnet Group has been successfully deleted")

    secrets_manager_client.delete_secret(
        SecretId=metadata["RDS"]["secretName"], ForceDeleteWithoutRecovery=True
    )


def uninstall_secrets_manager(region, cluster_name):
    kubectl_delete(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/rbac-secretproviderclass.yaml"
    )
    kubectl_delete(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/csidriver.yaml"
    )
    kubectl_delete(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml"
    )
    kubectl_delete(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml"
    )
    kubectl_delete(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/secrets-store-csi-driver.yaml"
    )
    kubectl_delete(
        "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/rbac-secretprovidersyncing.yaml"
    )
    kubectl_delete(
        "https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml"
    )
    print("Secrets Manager Driver successfully deleted")

    delete_iam_service_account(
        service_account_name="kubeflow-secrets-manager-sa",
        namespace="kubeflow",
        cluster_name=cluster_name,
        region=region,
    )
    print("IAM service account kubeflow-secrets-manager-sa successfully deleted")


if __name__ == "__main__":
    main()
