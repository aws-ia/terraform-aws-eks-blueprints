"""
Module for helper methods to create and delete kubernetes custom resources (e.g. katib experiments, etc.)
"""

from e2e.utils.utils import (
    unmarshal_yaml,
    wait_for,
    WaitForCircuitBreakerError
)
from e2e.fixtures.clients import (
    create_k8s_custom_objects_api_client,
    create_k8s_core_api_client,
)

from e2e.utils.constants import KUBEFLOW_GROUP


def create_namespaced_resource_from_yaml(
    cluster, region, yaml_file, group, version, plural, namespace, replacements={}
):
    body = unmarshal_yaml(yaml_file, replacements)
    client = create_k8s_custom_objects_api_client(cluster, region)

    return client.create_namespaced_custom_object(
        group=group, version=version, namespace=namespace, plural=plural, body=body
    )


def get_namespaced_resource(cluster, region, group, version, plural, namespace, name):
    client = create_k8s_custom_objects_api_client(cluster, region)

    return client.get_namespaced_custom_object(
        group=group, version=version, namespace=namespace, plural=plural, name=name
    )


def delete_namespaced_resource(
    cluster, region, group, version, plural, namespace, name
):
    client = create_k8s_custom_objects_api_client(cluster, region)
    return client.delete_namespaced_custom_object(
        group=group, version=version, namespace=namespace, plural=plural, name=name
    )


def create_katib_experiment_from_yaml(
    cluster, region, yaml_file, namespace, replacements={}
):
    return create_namespaced_resource_from_yaml(
        cluster,
        region,
        yaml_file,
        group=KUBEFLOW_GROUP,
        version="v1beta1",
        namespace=namespace,
        plural="experiments",
        replacements=replacements,
    )


def get_katib_experiment(cluster, region, namespace, name):
    return get_namespaced_resource(
        cluster,
        region,
        group=KUBEFLOW_GROUP,
        version="v1beta1",
        namespace=namespace,
        plural="experiments",
        name=name,
    )


def delete_katib_experiment(cluster, region, namespace, name):
    return delete_namespaced_resource(
        cluster,
        region,
        group=KUBEFLOW_GROUP,
        version="v1beta1",
        namespace=namespace,
        plural="experiments",
        name=name,
    )


def get_ingress(cluster, region, name="istio-ingress", namespace="istio-system"):
    return get_namespaced_resource(
        cluster,
        region,
        group="networking.k8s.io",
        version="v1beta1",
        namespace=namespace,
        plural="ingresses",
        name=name,
    )


def get_pvc_status(cluster, region, namespace, name):
    client = create_k8s_core_api_client(cluster, region)

    pvc = client.read_namespaced_persistent_volume_claim_status(
        namespace=namespace, name=name, pretty=True
    )

    return pvc.spec.volume_name, pvc.status.phase


def get_service_account(cluster, region, namespace, name):
    client = create_k8s_core_api_client(cluster, region)

    service_account = client.read_namespaced_service_account(
        namespace=namespace, name=name, pretty=True
    )

    return service_account.metadata.annotations["eks.amazonaws.com/role-arn"]


def get_pod_from_label(cluster, region, namespace, label_key, label_value):
    client = create_k8s_core_api_client(cluster, region)

    pod = client.list_namespaced_pod(
        namespace=namespace, label_selector=f"{label_key}={label_value}", pretty=True
    )
    name = pod.items[0].metadata.name
    status = pod.items[0].status.phase

    return name, status

def wait_for_katib_experiment_succeeded(cluster, region, namespace, name):
    def callback():
        resp = get_katib_experiment(cluster, region, namespace, name)

        assert resp["kind"] == "Experiment"
        assert resp["metadata"]["name"] == name
        assert resp["metadata"]["namespace"] == namespace

        assert resp["status"]["completionTime"] != None
        condition_types = {
            condition["type"] for condition in resp["status"]["conditions"]
        }

        if "Failed" in condition_types:
            print(resp)
            raise WaitForCircuitBreakerError("Katib experiment Failed")

        assert "Succeeded" in condition_types

    wait_for(callback)