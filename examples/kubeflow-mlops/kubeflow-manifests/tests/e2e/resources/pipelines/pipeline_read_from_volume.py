"""
A Kubeflow Pipeline Function which reads a file with dummy content at a specified path.
The Pipeline is run with a specified PVC volume mount. 
"""

import kfp
from kfp import components
from kfp import dsl
from kfp.components import create_component_from_func

MOUNT_PATH = ""
CLAIM_NAME = ""


def read_volume(mount_path: str):
    import os

    file_name = "write-to-volume.md"
    file_path = mount_path + file_name
    print("Reading from volume")
    output = os.listdir(mount_path)

    assert file_name in output

    with open(file_path, "r") as fp:
        content = fp.read()

    assert "dummy" in content


read_volume_op = create_component_from_func(
    read_volume, base_image="python", packages_to_install=["boto3"]
)


@dsl.pipeline(
    name="Reading from Volume KFP Component",
    description="Read from Volume",
)
def read_from_volume_pipeline(mount_path=MOUNT_PATH, claim_name=CLAIM_NAME):
    read_volume_op(mount_path).set_display_name(
        "Read Volume KFP Component"
    ).add_pvolumes({mount_path: dsl.PipelineVolume(pvc=claim_name)})
