from e2e.utils.utils import kubectl_apply

RBAC_SECRETS_PROVIDER_CLASS = "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/rbac-secretproviderclass.yaml"

CSI_DRIVER_V_1_0_0 = "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/csidriver.yaml"

SECRETS_STORE_SECRETS_PROVIDER_CLASSES = "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/secrets-store.csi.x-k8s.io_secretproviderclasses.yaml"

SECRETS_STORE_SECRETS_PROVIDER_CLASS_POD_STATUSES = "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/secrets-store.csi.x-k8s.io_secretproviderclasspodstatuses.yaml"

SECRETS_STORE_CSI_DRIVER = "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/secrets-store-csi-driver.yaml"

RBAC_SECRETS_PROVIDER_SYNCING = "https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.0.0/deploy/rbac-secretprovidersyncing.yaml"


def install():
    kubectl_apply(RBAC_SECRETS_PROVIDER_CLASS)
    kubectl_apply(CSI_DRIVER_V_1_0_0)
    kubectl_apply(SECRETS_STORE_SECRETS_PROVIDER_CLASSES)
    kubectl_apply(SECRETS_STORE_SECRETS_PROVIDER_CLASS_POD_STATUSES)
    kubectl_apply(SECRETS_STORE_CSI_DRIVER)
    kubectl_apply(RBAC_SECRETS_PROVIDER_SYNCING)
