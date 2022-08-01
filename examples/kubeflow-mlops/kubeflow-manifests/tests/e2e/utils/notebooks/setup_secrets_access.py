import subprocess
import argparse
from e2e.utils.utils import kubectl_apply_kustomize
from e2e.utils.utils import load_yaml_file
from e2e.utils.utils import write_yaml_file
from e2e.utils.utils import print_banner
from e2e.utils.utils import kubectl_apply
from e2e.fixtures.cluster import create_iam_service_account

AWS_CONFIGS_PATH = "../../awsconfigs/"
SECRETS_MANAGER_KUSTOMIZE_FILE_BASE_PATH = f"{AWS_CONFIGS_PATH}common/aws-secrets-manager/"
SECRETS_MANAGER_KUSTOMIZE_FILE_PATH = f"{SECRETS_MANAGER_KUSTOMIZE_FILE_BASE_PATH}kustomization.yaml"
POD_DEFAULT_FILE_PATH = "utils/notebooks/pod-default.yaml"

def main():
    print_banner("AWS Secrets Setup")

    setup_secrets_manager_service_account()
    setup_secrets_manager_kustomize()
    setup_notebook_secrets()

    print_banner("AWS Secrets Setup Complete")

def setup_secrets_manager_service_account():
    print_banner("IAM Service Account Setup")

    create_iam_service_account(
        service_account_name="kubeflow-secrets-manager-sa",
        namespace=NAMESPACE,
        cluster_name=CLUSTER_NAME,
        region=CLUSTER_REGION,
        iam_policy_arns=[
            "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
            "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
        ]
    )

def setup_secrets_manager_kustomize():
    print_banner("Secrets Manager Setup")
    secrets_manager_kustomize_content = load_yaml_file(SECRETS_MANAGER_KUSTOMIZE_FILE_PATH)
    DEFAULT_NAMESPACE = secrets_manager_kustomize_content["namespace"]
    
    edit_secrets_manager_kustomize(secrets_manager_kustomize_content, NAMESPACE)
    kubectl_apply_kustomize(SECRETS_MANAGER_KUSTOMIZE_FILE_BASE_PATH)
    edit_secrets_manager_kustomize(secrets_manager_kustomize_content, DEFAULT_NAMESPACE)

def edit_secrets_manager_kustomize(edit_secrets_manager_kustomize_content, namespace):
    edit_secrets_manager_kustomize_content["namespace"] = namespace
    write_yaml_file(edit_secrets_manager_kustomize_content, SECRETS_MANAGER_KUSTOMIZE_FILE_PATH)

def setup_notebook_secrets():
    print_banner("Kubeflow Notebook Setup")

    print("Setting up PodDefault...")
    kubectl_apply(POD_DEFAULT_FILE_PATH, NAMESPACE)

parser = argparse.ArgumentParser()
parser.add_argument(
    '--region',
    type=str,
    metavar="CLUSTER_REGION",
    help='Your cluster region code (eg: us-east-2)',
    required=True
)
parser.add_argument(
    '--cluster',
    type=str,
    metavar="CLUSTER_NAME",
    help='Your cluster name (eg: mycluster-1)',
    required=True
)
parser.add_argument(
    '--profile-namespace',
    type=str,
    metavar="PROFILE_NAMESPACE",
    help=f"The namespace you want to setup secrets for (eg: kubeflow-user-example-com)",
    required=True
)
if __name__ == "__main__":
    args, _ = parser.parse_known_args()
    CLUSTER_REGION = args.region
    CLUSTER_NAME = args.cluster
    NAMESPACE = args.profile_namespace

    main()
