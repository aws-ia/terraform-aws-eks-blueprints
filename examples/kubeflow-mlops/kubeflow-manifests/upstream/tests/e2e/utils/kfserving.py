from kfp import components


KFSERVING_URL = "https://raw.githubusercontent.com/kubeflow/pipelines/master/components/kubeflow/kfserving/component.yaml"


# You should define the model name, namespace, output of the TFJob and model
# volume tasks in the arguments.
def create_kfserving_task(model_name, model_namespace, tfjob_op,
                          model_volume_op):
    inference_service = '''
apiVersion: "serving.kubeflow.org/v1beta1"
kind: "InferenceService"
metadata:
  name: {}
  namespace: {}
  annotations:
    "sidecar.istio.io/inject": "false"
spec:
  predictor:
    tensorflow:
      storageUri: "pvc://{}/"
'''.format(model_name, model_namespace, str(model_volume_op.outputs["name"]))

    kfserving_launcher_op = components.load_component_from_url(KFSERVING_URL)
    kfserving_launcher_op(
        action="create",
        inferenceservice_yaml=inference_service,
    ).after(tfjob_op)
