"""E2E Kubeflow test that tesst Pipelines, Katib, TFJobs and KFServing.

Requires:
pip install kfp==1.8.4
pip install kubeflow-katib==0.12.0
"""
import kfp
import kfp.dsl as dsl
from kubernetes import config

import settings
from utils import isvc, katib, kfserving, tfjob

config.load_kube_config()


@dsl.pipeline(
    name="End to End Pipeline",
    description="An end to end mnist example including hyperparameter tuning, "
                "train and inference",
)
def mnist_pipeline(name=settings.PIPELINE_NAME,
                   namespace=settings.NAMESPACE,
                   training_steps=settings.TRAINING_STEPS):
    # Run the hyperparameter tuning with Katib.
    katib_op = katib.create_katib_experiment_task(
        name, namespace, training_steps)

    # Create volume to train and serve the model.
    model_volume_op = dsl.VolumeOp(
        name="model-volume",
        resource_name="model-volume",
        size="1Gi",
        modes=dsl.VOLUME_MODE_RWO,
    )

    # Run the distributive training with TFJob.
    tfjob_op = tfjob.create_tfjob_task(name, namespace, training_steps,
                                       katib_op, model_volume_op)

    # Create the KFServing inference.
    kfserving.create_kfserving_task(name, namespace, tfjob_op,
                                    model_volume_op)


if __name__ == "__main__":
    # Run the Kubeflow Pipeline in the user's namespace.
    kfp_client = kfp.Client(host="http://localhost:3000",
                            namespace="kubeflow-user-example-com")
    kfp_client.runs.api_client.default_headers.update(
        {"kubeflow-userid": "kubeflow-user-example-com"})

    # create the KFP run
    run_id = kfp_client.create_run_from_pipeline_func(
        mnist_pipeline,
        namespace=settings.NAMESPACE,
        arguments={},
    ).run_id
    print("Run ID: ", run_id)

    katib.wait_to_create(name=settings.EXPERIMENT_NAME,
                         namespace=settings.NAMESPACE,
                         timeout=settings.TIMEOUT)

    tfjob.wait_to_create(name=settings.EXPERIMENT_NAME,
                         namespace=settings.NAMESPACE,
                         timeout=settings.TIMEOUT)

    tfjob.wait_to_succeed(name=settings.TFJOB_NAME,
                          namespace=settings.NAMESPACE,
                          timeout=settings.TIMEOUT)

    katib.wait_to_succeed(name=settings.EXPERIMENT_NAME,
                          namespace=settings.NAMESPACE,
                          timeout=settings.TIMEOUT)

    isvc.wait_to_create(settings.ISVC_NAME,
                        namespace=settings.NAMESPACE,
                        timeout=settings.TIMEOUT)

    isvc.wait_to_succeed(settings.ISVC_NAME,
                         namespace=settings.NAMESPACE,
                         timeout=settings.TIMEOUT)
