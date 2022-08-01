from e2e.utils.utils import kubectl_apply

AWS_PROVIDER_INSTALLER = "https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml"


def install():
    kubectl_apply(AWS_PROVIDER_INSTALLER)
