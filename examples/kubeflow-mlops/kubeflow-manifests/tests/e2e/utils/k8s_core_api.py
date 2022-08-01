"""
Module for helper methods to create and delete kubernetes core api resources (e.g. pods, namespaces, etc.)
"""

import subprocess

from kubernetes.client import V1Namespace
from kubernetes.client.exceptions import ApiException

from e2e.fixtures.clients import create_k8s_core_api_client


def create_namespace(cluster, region, namespace_name):
    client = create_k8s_core_api_client(cluster, region)
    try:
        client.create_namespace(V1Namespace(metadata=dict(name=namespace_name)))
    except ApiException as e:
        if "Conflict" != e.reason:
            raise e

def upload_file_as_configmap(namespace, configmap_name, file_path):
    subprocess.call(
        f"kubectl create configmap -n {namespace} {configmap_name} --from-file {file_path}".split()
    )

def delete_configmap(namespace, configmap_name):
    subprocess.call(f"kubectl delete configmap -n {namespace} {configmap_name}".split())

def patch_configmap(namespace, configmap_name, patch_file_path):
    subprocess.call(
        f"kubectl patch configmap -n {namespace} {configmap_name} --patch-file {patch_file_path}".split()
    )