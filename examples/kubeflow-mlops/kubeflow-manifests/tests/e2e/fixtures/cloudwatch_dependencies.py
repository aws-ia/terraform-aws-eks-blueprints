import os
import re
import subprocess
import time
import pytest

from e2e.utils.config import metadata, configure_resource_fixture
from e2e.conftest import region
from e2e.fixtures.cluster import cluster
from e2e.utils.utils import get_eks_client, get_iam_client, kubectl_apply


@pytest.fixture(scope="class")
def cloudwatch_bootstrap(metadata, region, request, cluster):

    cloudwatch_deps = {"cluster": {"region": region, "name": cluster}}

    def get_eks_nodegroup_role(ClusterName):
        eks_client = get_eks_client(region)
        nodegroup = eks_client.list_nodegroups(clusterName=ClusterName)["nodegroups"]
        nodegroup = eks_client.describe_nodegroup(
            clusterName=ClusterName, nodegroupName=nodegroup[0]
        )
        nodeRole = nodegroup["nodegroup"]["nodeRole"].split("/")[1]
        return nodeRole

    def attach_cloudwatch_policy(nodeRole):
        iam_client = get_iam_client(region)
        iam_client.attach_role_policy(
            RoleName=nodeRole,
            PolicyArn="arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        )

    def detach_cloudwatch_policy(nodeRole):
        iam_client = get_iam_client(region)
        iam_client.detach_role_policy(
            RoleName=nodeRole,
            PolicyArn="arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        )

    def install_cloudwatch_container_insights(ClusterName):
        LogRegion = region
        FluentBitHttpPort = '"2020"'
        FluentBitReadFromHead = '"Off"'
        FluentBitHttpServer = '"On"'
        FluentBitReadFromTail = '"On"'
        replacements = [
            ("{{cluster_name}}", ClusterName),
            ("{{region_name}}", LogRegion),
            ("{{http_server_port}}", FluentBitHttpPort),
            ("{{http_server_toggle}}", FluentBitHttpServer),
            ("{{read_from_tail}}", FluentBitReadFromTail),
            ("{{read_from_head}}", FluentBitReadFromHead),
        ]
        cwagent_cmd = "curl -O https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml".split()
        subprocess.call(cwagent_cmd)
        with open("cwagent-fluent-bit-quickstart.yaml", "r") as quickstart:
            replacements = [
                ("{{cluster_name}}", ClusterName),
                ("{{region_name}}", LogRegion),
                ("{{http_server_port}}", FluentBitHttpPort),
                ("{{http_server_toggle}}", FluentBitHttpServer),
                ("{{read_from_tail}}", FluentBitReadFromTail),
                ("{{read_from_head}}", FluentBitReadFromHead),
            ]
            substitute_env_vars = quickstart.read()
            for old, new in replacements:
                substitute_env_vars = re.sub(old, new, substitute_env_vars)
        with open("cwagent-fluent-bit-quickstart.yaml", "w") as quickstart:
            quickstart.write(substitute_env_vars)
        kubectl_apply("cwagent-fluent-bit-quickstart.yaml")

    def on_create():
        ClusterName = metadata.get("cluster_name")
        nodeRole = get_eks_nodegroup_role(ClusterName)
        attach_cloudwatch_policy(nodeRole)
        install_cloudwatch_container_insights(ClusterName)

    def on_delete():
        ClusterName = metadata.get("cluster_name")
        cmd = []
        cmd += "kubectl delete namespace amazon-cloudwatch".split()
        subprocess.call(cmd)
        nodeRole = get_eks_nodegroup_role(ClusterName)
        detach_cloudwatch_policy(nodeRole)
        try:
            os.remove("cwagent-fluent-bit-quickstart.yaml")
        except:
            print("File not found")

    return configure_resource_fixture(
        metadata,
        request,
        cloudwatch_deps,
        "cloudwatch_dependencies",
        on_create,
        on_delete,
    )


def wait_for_cloudwatch_logs(cloudwatch, ClusterName):
    def wait(period_length=10, periods=10):
        for _ in range(periods):
            fluent_bit_log_groups = cloudwatch.describe_log_groups(
                logGroupNamePrefix=f"/aws/containerinsights/{ClusterName}"
            )
            if len(fluent_bit_log_groups["logGroups"]) != 0:
                return True
            time.sleep(period_length)
        return False

    return wait()


def wait_for_cloudwatch_metrics(cloudwatch, ClusterName):
    def wait(period_length=10, periods=10):
        for _ in range(periods):
            cloudwatch_metrics = cloudwatch.list_metrics(
                MetricName="IncomingLogEvents", Namespace="AWS/Logs"
            )["Metrics"]
            for metric in cloudwatch_metrics:
                if (
                    len(metric["Dimensions"]) > 0
                    and metric["Dimensions"][0]["Value"]
                    == f"/aws/containerinsights/{ClusterName}/application"
                ):
                    return True
            time.sleep(period_length)
        return False

    return wait()
