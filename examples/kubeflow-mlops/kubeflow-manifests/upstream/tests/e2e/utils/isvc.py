from . import watch

GROUP = "serving.kubeflow.org"
PLURAL = "inferenceservices"
VERSION = "v1beta1"


# wait_for_ready(name, namespace, timeout):
def wait_to_create(name, namespace, timeout):
    """Wait until the specified InferenceService gets created."""
    return watch.wait_created_cr(name, namespace,
                                 timeout=timeout, group=GROUP, plural=PLURAL,
                                 version=VERSION)


def wait_to_succeed(name, namespace, timeout):
    """Wait until the specified InferenceService succeeds."""
    return watch.wait_to_succeed(name=name, namespace=namespace,
                                 timeout=timeout, group=GROUP, plural=PLURAL,
                                 version=VERSION)
