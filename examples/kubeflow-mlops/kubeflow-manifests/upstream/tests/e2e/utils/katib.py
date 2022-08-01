"""Katib helper functions to create a Pipeline task."""
from kfp import components
from kubeflow.katib import (ApiClient, V1beta1AlgorithmSpec,
                            V1beta1ExperimentSpec, V1beta1FeasibleSpace,
                            V1beta1ObjectiveSpec, V1beta1ParameterSpec,
                            V1beta1TrialParameterSpec, V1beta1TrialTemplate)

from . import watch

TFJOB_IMAGE = "docker.io/liuhougangxa/tf-estimator-mnist"
KATIB_LAUNCHER_URL = "https://raw.githubusercontent.com/kubeflow/pipelines/1.8.0-rc.1/components/kubeflow/katib-launcher/component.yaml"

GROUP = "kubeflow.org"
PLURAL = "experiments"
VERSION = "v1beta1"


def wait_to_create(name, namespace, timeout):
    """Wait until the specified Katib Experiment gets created."""
    return watch.wait_created_cr(name, namespace,
                                 timeout=timeout, group=GROUP, plural=PLURAL,
                                 version=VERSION)


def wait_to_succeed(name, namespace, timeout):
    """Wait until the specified Katib Experiment succeeds."""
    return watch.wait_to_succeed(name=name, namespace=namespace,
                                 timeout=timeout, group=GROUP, plural=PLURAL,
                                 version=VERSION)


# This function converts Katib Experiment HP results to args.
def convert_katib_results(katib_results) -> str:
    import json
    import pprint
    katib_results_json = json.loads(katib_results)
    print("Katib results:")
    pprint.pprint(katib_results_json)
    best_hps = []
    for pa in katib_results_json["currentOptimalTrial"]["parameterAssignments"]:
        if pa["name"] == "learning_rate":
            best_hps.append("--tf-learning-rate=" + pa["value"])
        elif pa["name"] == "batch_size":
            best_hps.append("--tf-batch-size=" + pa["value"])
    print("Best Hyperparameters: {}".format(best_hps))
    return " ".join(best_hps)


# You should define the Experiment name, namespace and number of training steps
# in the arguments.
def create_katib_experiment_task(experiment_name, experiment_namespace,
                                 training_steps):
    # Trial count specification.
    max_trial_count = 5
    max_failed_trial_count = 3
    parallel_trial_count = 2

    # Objective specification.
    objective = V1beta1ObjectiveSpec(
        type="minimize",
        goal=0.001,
        objective_metric_name="loss",
    )

    # Algorithm specification.
    algorithm = V1beta1AlgorithmSpec(
        algorithm_name="random",
    )

    # Experiment search space.
    # In this example we tune learning rate and batch size.
    parameters = [
        V1beta1ParameterSpec(
            name="learning_rate",
            parameter_type="double",
            feasible_space=V1beta1FeasibleSpace(
                min="0.01",
                max="0.05",
            ),
        ),
        V1beta1ParameterSpec(
            name="batch_size",
            parameter_type="int",
            feasible_space=V1beta1FeasibleSpace(
                min="80",
                max="100",
            ),
        ),
    ]

    # Experiment Trial template.
    # TODO (andreyvelich): Use community image for the mnist example.
    trial_spec = {
        "apiVersion": "kubeflow.org/v1",
        "kind": "TFJob",
        "spec": {
            "tfReplicaSpecs": {
                "Chief": {
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
                                    "image": TFJOB_IMAGE,
                                    "command": [
                                        "python",
                                        "/opt/model.py",
                                        "--tf-train-steps="
                                            + str(training_steps),
                                        "--tf-learning-rate=${trialParameters.learningRate}",
                                        "--tf-batch-size=${trialParameters.batchSize}"
                                    ]
                                }
                            ]
                        }
                    }
                },
                "Worker": {
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
                                        "python",
                                        "/opt/model.py",
                                        "--tf-train-steps="
                                            + str(training_steps),
                                        "--tf-learning-rate=${trialParameters.learningRate}",
                                        "--tf-batch-size=${trialParameters.batchSize}"
                                    ]
                                }
                            ]
                        }
                    }
                }
            }
        }
    }

    # Configure parameters for the Trial template.
    trial_template = V1beta1TrialTemplate(
        primary_container_name="tensorflow",
        primary_pod_labels={"training.kubeflow.org/job-role": "master"},
        trial_parameters=[
            V1beta1TrialParameterSpec(
                name="learningRate",
                description="Learning rate for the training model",
                reference="learning_rate",
            ),
            V1beta1TrialParameterSpec(
                name="batchSize",
                description="Batch size for the model",
                reference="batch_size",
            ),
        ],
        trial_spec=trial_spec,
    )

    # Create an Experiment from the above parameters.
    experiment_spec = V1beta1ExperimentSpec(
        max_trial_count=max_trial_count,
        max_failed_trial_count=max_failed_trial_count,
        parallel_trial_count=parallel_trial_count,
        objective=objective,
        algorithm=algorithm,
        parameters=parameters,
        trial_template=trial_template,
    )

    # Create the KFP task for the Katib Experiment.
    # Experiment Spec should be serialized to a valid Kubernetes object.
    katib_experiment_launcher_op = components.load_component_from_url(
        KATIB_LAUNCHER_URL,
    )

    op = katib_experiment_launcher_op(
        experiment_name=experiment_name,
        experiment_namespace=experiment_namespace,
        experiment_spec=ApiClient().sanitize_for_serialization(experiment_spec),
        experiment_timeout_minutes=60,
        delete_finished_experiment=False)

    return op
