import pytest

from e2e.utils.config import metadata
from e2e.fixtures.cluster import cluster
from e2e.fixtures.cloudwatch_dependencies import (
    wait_for_cloudwatch_logs,
    cloudwatch_bootstrap,
    wait_for_cloudwatch_metrics,
)
from e2e.utils.utils import get_logs_client, get_cloudwatch_client


class TestCloudWatch:
    @pytest.fixture(scope="class")
    def setup(self, metadata):
        metadata_file = metadata.to_file()
        metadata.log()
        print("Created metadata file for TestSanity", metadata_file)

    def test_cloudwatch_logs(self, setup, region, cloudwatch_bootstrap, metadata):
        ClusterName = metadata.get("cluster_name")
        cloudwatch_logs = get_logs_client(region)
        cloudwatch_metrics = get_cloudwatch_client(region)
        assert wait_for_cloudwatch_logs(cloudwatch_logs, ClusterName)
        assert wait_for_cloudwatch_metrics(cloudwatch_metrics, ClusterName)
