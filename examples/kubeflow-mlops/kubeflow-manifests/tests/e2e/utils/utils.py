"""
Generic helper methods module
"""

import json
import os
import subprocess
import time
import random
import string
import yaml
import boto3
import mysql.connector
import subprocess


def safe_open(filepath, mode="r"):
    """
    Creates a directory if one does not exist when opening a file.
    """

    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    return open(filepath, mode)


def unmarshal_yaml(yaml_file, replacements={}):
    """
    Unmarshals yaml into a python object.

    `replacements` allow substituting values in the yaml file.

    Ex:

        replacements = {"NAMESPACE", "kubeflow"}

        metadata:
            - name: ...
            - namespace: ${NAMESPACE}

        will become

        metadata:
            - name: ...
            - namespace: kubeflow
    """

    with open(yaml_file) as file:
        contents = file.read()

    for r_key, r_value in replacements.items():
        contents = contents.replace(f"${{{r_key}}}", r_value)

    return yaml.safe_load(contents)


class WaitForCircuitBreakerError(Exception):
    """
    When this exception is thrown, the below wait_for function
    will exit immediately. Useful to escape a retry loop in failure scenarios
    where the only other option would be to wait for an eventual timeout.
    """

    pass


def wait_for(callback, timeout=300, interval=30):
    """
    Provide a function with no arguments as a callback.

    Repeatedly calls the callback on an interval until the timeout duration
    or until the callback returns without raising an exception.

    If the timeout duration is exceeded raises the last raised exception
    """

    start = time.time()
    while True:
        try:
            return callback()
        except WaitForCircuitBreakerError as we:
            raise we
        except Exception as e:
            if time.time() - start >= timeout:
                raise e
            time.sleep(interval)


def wait_for_kfp_run_succeeded_from_run_id(kfp_client, run_id):
    def callback():
        resp = kfp_client.get_run(run_id)
        status = resp.run.status

        if "Failed" == status:
            print(resp.run)
            raise WaitForCircuitBreakerError("Pipeline run Failed")

        print(f"{run_id} {status} .... waiting")
        assert status == "Succeeded"
        return resp

    return wait_for(callback, 600)


def rand_name(prefix):
    """
    Returns a random string of 10 ascii lowercase characters appended to the prefix
    """
    suffix = "".join(
        random.choice(string.ascii_lowercase + string.digits) for _ in range(10)
    )
    return prefix + suffix


def write_json_file(filepath, data):
    with open(filepath, "w") as file:
        json.dump(data, file)


def load_json_file(filepath):
    with open(filepath) as file:
        return json.load(file)


def get_eks_client(region):
    return boto3.client("eks", region_name=region)


def get_iam_client(region):
    return boto3.client("iam", region_name=region)


def get_iam_resource(region):
    return boto3.resource("iam", region_name=region)


def get_ec2_client(region):
    return boto3.client("ec2", region_name=region)


def get_cfn_client(region):
    return boto3.client("cloudformation", region_name=region)


def get_s3_client(region):
    return boto3.client("s3", region_name=region)


def get_logs_client(region):
    return boto3.client("logs", region_name=region)


def get_cloudwatch_client(region):
    return boto3.client("cloudwatch", region_name=region)


def get_secrets_manager_client(region):
    return boto3.client("secretsmanager", region_name=region)


def get_rds_client(region):
    return boto3.client("rds", region_name=region)


def get_mysql_client(user, password, host, database) -> mysql.connector.MySQLConnection:
    return mysql.connector.connect(
        user=user, password=password, host=host, database=database
    )


def get_efs_client(region):
    return boto3.client("efs", region_name=region)


def get_fsx_client(region):
    return boto3.client("fsx", region_name=region)


def curl_file_to_path(file, path):
    cmd = f"curl -o {path} {file}".split()
    subprocess.call(cmd)


def kubectl_apply(path, namespace=None):
    if namespace:
        cmd = f"kubectl apply -f {path} -n {namespace}".split()
    else:
        cmd = f"kubectl apply -f {path}".split()
    subprocess.call(cmd)


def kubectl_delete(path):
    cmd = f"kubectl delete -f {path}".split()
    subprocess.call(cmd)


def kubectl_apply_kustomize(path):
    cmd = f"kubectl apply -k {path}".split()
    subprocess.call(cmd)


def kubectl_delete_kustomize(path):
    cmd = f"kubectl delete -k {path}".split()
    subprocess.call(cmd)


def load_yaml_file(file_path: str):
    with open(file_path, "r") as file:
        content = file.read()

    return yaml.safe_load(content)


def write_yaml_file(yaml_content, file_path: str):
    with open(file_path, "w") as file:
        file.write(yaml.dump(yaml_content))


def print_banner(step_name: str):
    width = 65
    print("=" * width)
    print(step_name.center(width))
    print("=" * width)


def get_security_group_id_from_name(
    ec2_client, eks_client, security_group_name, cluster_name
):
    cluster_info = eks_client.describe_cluster(name=cluster_name)["cluster"]
    vpc_id = cluster_info["resourcesVpcConfig"]["vpcId"]

    response = ec2_client.describe_security_groups(
        Filters=[
            {
                "Name": "vpc-id",
                "Values": [
                    vpc_id,
                ],
            },
            {
                "Name": "group-name",
                "Values": [
                    security_group_name,
                ],
            },
        ]
    )
    return response["SecurityGroups"][0]["GroupId"]
