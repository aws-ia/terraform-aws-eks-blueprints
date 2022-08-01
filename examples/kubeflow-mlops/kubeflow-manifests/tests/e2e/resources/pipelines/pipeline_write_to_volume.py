"""
A Kubeflow Pipeline Function which creates a file with dummy content at a specified path.
The Pipeline is run with a specified PVC volume mount. 
"""

import kfp
from kfp import components
from kfp import dsl
from kfp.components import create_component_from_func

MOUNT_PATH = ""
CLAIM_NAME = ""


def write_volume(mount_path: str):
    import os

    print("Writing a file on the Volume")
    file_path = mount_path + "write-to-volume.md"
    with open(file_path, "w") as fp:
        fp.write("dummy content ! ")


write_volume_op = create_component_from_func(
    write_volume, base_image="python", packages_to_install=["boto3"]
)


@dsl.pipeline(
    name="Writing to Volume Component",
    description="Write to Volume",
)
def write_to_volume_pipeline(mount_path=MOUNT_PATH, claim_name=CLAIM_NAME):
    write_volume_op(mount_path).set_display_name("Write KFP Component").add_pvolumes(
        {mount_path: dsl.PipelineVolume(pvc=claim_name)}
    )
