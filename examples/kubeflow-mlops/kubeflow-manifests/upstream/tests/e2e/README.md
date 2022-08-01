# E2E Mnist

We've converted the community's [E2E Notebook](https://github.com/kubeflow/pipelines/blob/master/samples/contrib/kubeflow-e2e-mnist/kubeflow-e2e-mnist.ipynb) into a python script. This test can be used to ensure the core Kubeflow CRDs can be applied and complete.

This test is using the following Kubeflow CRDs:
1. Kubeflow Pipelines
2. Katib Experiments
3. TFJobs
4. KFServing InferenceServices

## How to run

The heart of this test is the `mnist.py` python script, which applies and waits
for the CRDs to complete. The python scripts are all expecting that
1. `kubectl` is configured with access to a Kubeflow cluster
2. `kustomize` 3.2.0 is available
3. The KFP backend is proxied to localhost

While the `mnist.py` is used for running the test, it is advised to use the
`runner.sh` script instead. The `runner.sh` script will be running the python
script, but also ensure the KFP backend is port-forwarded and will clean up
afterwards.

## Failures

Both the python and the bash scripts are designed to be failing early. If any
intermediate command fails, then the whole test will fail.
