from kfp import components

from . import katib, watch

TFJOB_URL = "https://raw.githubusercontent.com/kubeflow/pipelines/master/components/kubeflow/launcher/component.yaml"

GROUP = "kubeflow.org"
PLURAL = "tfjobs"
VERSION = "v1"


def wait_to_create(name, namespace, timeout):
    """Wait until the specified TFJob gets created."""
    return watch.wait_created_cr(name, namespace,
                                 timeout=timeout, group=GROUP, plural=PLURAL,
                                 version=VERSION)


def wait_to_succeed(name, namespace, timeout):
    """Wait until the specified TFJob succeeds."""
    return watch.wait_to_succeed(name=name, namespace=namespace,
                                 timeout=timeout, group=GROUP, plural=PLURAL,
                                 version=VERSION)


# You should define the TFJob name, namespace, number of training steps, output
# of Katib and model volume tasks in the arguments.
def create_tfjob_task(tfjob_name, tfjob_namespace, training_steps, katib_op,
                      model_volume_op):
    import json

    # Get parameters from the Katib Experiment.
    # Parameters are in the format
    #    "--tf-learning-rate=0.01 --tf-batch-size=100"
    convert_katib_results_op = components.func_to_container_op(
        katib.convert_katib_results,
    )
    best_hp_op = convert_katib_results_op(katib_op.output)
    best_hps = str(best_hp_op.output)

    # Create the TFJob Chief and Worker specification with the best
    # Hyperparameters.
    # TODO (andreyvelich): Use community image for the mnist example.
    tfjob_chief_spec = {
        "replicas": 1,
        "restartPolicy": "OnFailure",
        "template": {
            "metadata": {
                "annotations": {
                    "sidecar.istio.io/inject": "false",
                },
            },
            "spec": {
                "containers": [
                    {
                        "name": "tensorflow",
                        "image": "docker.io/liuhougangxa/tf-estimator-mnist",
                        "command": [
                            "sh",
                            "-c",
                        ],
                        "args": [
                            "python /opt/model.py "
                            "--tf-export-dir=/mnt/export "
                            "--tf-train-steps={} {}".format(training_steps,
                                                            best_hps),
                        ],
                        "volumeMounts": [
                            {
                                "mountPath": "/mnt/export",
                                "name": "model-volume",
                            },
                        ],
                    },
                ],
                "volumes": [
                    {
                        "name": "model-volume",
                        "persistentVolumeClaim": {
                            "claimName": str(model_volume_op.outputs["name"]),
                        },
                    },
                ],
            },
        },
    }

    tfjob_worker_spec = {
        "replicas": 1,
        "restartPolicy": "OnFailure",
        "template": {
            "metadata": {
                "annotations": {
                    "sidecar.istio.io/inject": "false",
                },
            },
            "spec": {
                "containers": [
                    {
                        "name": "tensorflow",
                        "image": "docker.io/liuhougangxa/tf-estimator-mnist",
                        "command": [
                            "sh",
                            "-c",
                        ],
                        "args": [
                            "python /opt/model.py "
                            "--tf-export-dir=/mnt/export "
                            "--tf-train-steps={} {}".format(training_steps,
                                                            best_hps),
                        ],
                    },
                ],
            },
        },
    }

    # Create the KFP task for the TFJob.
    tfjob_launcher_op = components.load_component_from_url(TFJOB_URL)
    op = tfjob_launcher_op(
        name=tfjob_name,
        namespace=tfjob_namespace,
        chief_spec=json.dumps(tfjob_chief_spec),
        worker_spec=json.dumps(tfjob_worker_spec),
        tfjob_timeout_minutes=60,
        delete_finished_tfjob=False)
    return op
