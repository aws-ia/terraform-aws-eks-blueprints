"""
Temporary test file to test kustomize manifests build successfully.
Todo: These scenarios should be tested by our unit tests.
"""

import pytest
import subprocess

from e2e.fixtures.kustomize import clone_upstream

def kustomize_build(manifest_path):
    return subprocess.call(f"kustomize build {manifest_path}".split())

TO_ROOT = "../../"
DEPLOYMENTS_FOLDER = TO_ROOT + "deployments/"

class TestManifestBuilds:
    @pytest.fixture(scope="class")
    def setup(self, clone_upstream):
        print("Cloning upstream")

    def test_vanilla(self, setup):
        manifest_path = DEPLOYMENTS_FOLDER + "vanilla"
        retcode = kustomize_build(manifest_path)
        assert retcode == 0

    def test_rds_s3(self, setup):
        manifest_path = DEPLOYMENTS_FOLDER + "rds-s3/base"
        retcode = kustomize_build(manifest_path)
        assert retcode == 0

    def test_rds(self, setup):
        manifest_path = DEPLOYMENTS_FOLDER + "rds-s3/rds-only"
        retcode = kustomize_build(manifest_path)
        assert retcode == 0

    def test_s3(self, setup):
        manifest_path = DEPLOYMENTS_FOLDER + "rds-s3/s3-only"
        retcode = kustomize_build(manifest_path)
        assert retcode == 0

    def test_cognito(self, setup):
        manifest_path = DEPLOYMENTS_FOLDER + "cognito"
        retcode = kustomize_build(manifest_path)
        assert retcode == 0

    def test_cognito_rds_s3(self, setup):
        manifest_path = DEPLOYMENTS_FOLDER + "cognito-rds-s3"
        retcode = kustomize_build(manifest_path)
        assert retcode == 0