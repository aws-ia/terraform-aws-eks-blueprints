"""
A test configuration utility module
"""

import pytest
import time
import json
import os

from e2e.utils.utils import safe_open
from e2e.conftest import keep_successfully_created_resource, load_metadata_file

# Todo make this configurable
METADATA_FOLDER = "./.metadata"


class Metadata:
    """
    Models user configurable metadata that can be saved in a file
    and reloaded to resume test execution.

    For example, 'cluster_name' is being stored in metadata by the
    cluster fixture.
    When reading from a metadata file, if 'cluster_name' is present
    the test will skip cluster creation and use the cluster in
    'cluster_name'.
    """

    def __init__(self, params=None):
        if params:
            self.params = params
        else:
            self.params = {}

    def insert(self, key, value):
        self.params[key] = value

    def save(self, key, value):
        self.insert(key, value)
        file = self.to_file()
        print(f"Saved key: {key} value: {value} in metadata file {file}")

    def get(self, key):
        if key not in self.params:
            return None

        return self.params[key]

    def to_file(self):
        filename = "metadata-" + str(time.time_ns()) + ".json"
        filepath = os.path.abspath(os.path.join(METADATA_FOLDER, filename))

        with safe_open(filepath, "w") as file:
            json.dump(self.params, file, indent=4)

        return filepath

    def from_file(filepath):
        with open(filepath) as file:
            return Metadata(json.load(file))

    def log(self):
        print(json.dumps(self.params, indent=4))

@pytest.fixture(scope="class")
def metadata(request):
    """
    If `--metadata` argument is present, reads the metadata that is passed in.
    Else, created an empty metadata object.
    """

    metadata_file = load_metadata_file(request)
    if metadata_file:
        return Metadata.from_file(metadata_file)

    return Metadata()


def configure_resource_fixture(
    metadata, request, resource_details, metadata_key, on_create, on_delete
):
    """
    Helper method to create resources if required and configure them for teardown.

    If the resource is not present in the metadata a new resource will be created and added to
    the metadata.

    If a resource is present in the metadata it will not be created.

    If the `--keepsuccess` flag is specified, successfully created resources (e.g. those that
    did not raise an exception) will not be deleted.
    """
    successful_creation = False

    def delete():
        if successful_creation and keep_successfully_created_resource(request):
            return
        on_delete()

    request.addfinalizer(delete)

    if not metadata.get(metadata_key):
        on_create()
        metadata.save(metadata_key, resource_details)

    successful_creation = True
    return metadata.get(metadata_key)


def configure_env_file(env_file_path, env_dict):
    """
    Overwrite the contents of a .env file with the input env vars to configure with.
    E.g.
        Inputs:
        env_file_path='/path/to/file/params.env'
        env_dict={'DB_HOST': 'https://rds.amazon.com/abcde'}
        Contents of `env_file_path` will become:
            DB_HOST=https://rds.amazon.com/abcde
    """
    with open(env_file_path, "w") as file:
        for key, value in env_dict.items():
            file.write(f"{key}={value}\n")
