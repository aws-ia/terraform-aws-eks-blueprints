+++
title = "Katib"
description = "Get started with Katib on Amazon EKS"
weight = 15
+++

## Access AWS Services from Katib

In order to grant Katib experiment pods access to AWS resources, the corresponding profile in which the experiment is created needs to be configured with the `AwsIamForServiceAccount` plugin. To configure the `AwsIamForServiceAccount` plugin to work with Profiles, follow the steps below.

### Prerequisites

Steps to configure Profiles with AWS IAM permissions can be found in the [Profiles component guide]({{< ref "/docs/component-guides/profiles.md#configuration-steps" >}}). Follow those steps to configure the profile controller to work with the `AwsIamForServiceAccount` plugin.

The following is an example of a profile using the `AwsIamForServiceAccount` plugin:
```yaml
apiVersion: kubeflow.org/v1
kind: Profile
metadata:
  name: some_profile
spec:
  owner:
    kind: User
    name: some-user@kubeflow.org
  plugins:
  - kind: AwsIamForServiceAccount
    spec:
      awsIamRole: arn:aws:iam::123456789012:role/some-profile-role
```
The AWS IAM permissions granted to the experiment pods are specified in the profile's `awsIamRole`. 


### Configuration 

#### Verify Prerequisites

You can verify that the profile was configured correctly by running the following commands:
```bash
export PROFILE_NAME=<name of the created profile>

kubectl get serviceaccount -n ${PROFILE_NAME} default-editor -oyaml | grep "eks.amazonaws.com/role-arn"
```
The output should look similar to the following:
```bash
eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/some-profile-role
```

#### Experiment trial spec configuration

When creating Katib experiments, you must correctly configure the experiment trial spec. 

The `default-editor` service account needs to be added to the `trialSpec` section of an experiment spec.

Specifically, the `serviceAccountName` field needs to be added under the [`Pod spec`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#service-account) section with a value of `default-editor`.

For example, in the following experiment spec, the `serviceAccountName` field is added under the `Pod spec` of the `Job spec`:
  ```yaml
  apiVersion: kubeflow.org/v1beta1
  kind: Experiment
  metadata:
    namespace: some-profile
    name: some-name
  spec:
    objective:
    ...
  trialTemplate:
  ...
  trialSpec:
    apiVersion: batch/v1
    kind: Job
    spec:
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "false"
        spec:
          containers:
            - name: training-container
              image: public.ecr.aws/z1j2m4o4/kubeflow-katib-mxnet-mnist:latest
              command:
              ...  
          restartPolicy: Never
          serviceAccountName: default-editor    # This addition is necessary
  ```

As another example, in the following experiment spec the `serviceAccountName` field is added under the `Pod spec` of the `TFJob spec`:
  ```yaml
  apiVersion: kubeflow.org/v1beta1
  kind: Experiment
  metadata:
    namespace: some-profile
    name: some-name
  spec:
    objective:
    ...
  trialTemplate:
  ...
  trialSpec:
    apiVersion: kubeflow.org/v1
    kind: TFJob
    metadata:
      generateName: tfjob
      namespace: your-user-namespace
    spec:
      tfReplicaSpecs:
        PS:
          replicas: 1
          ...
          spec:
            containers:
              - name: tensorflow
                image: gcr.io/your-project/your-image
                command:
                ...
            serviceAccountName: default-editor    # This addition is necessary
        Worker:
          replicas: 3
          ...
          spec:
            containers:
              - name: tensorflow
                image: gcr.io/your-project/your-image
                command:
                ...
            serviceAccountName: default-editor    # This addition is necessary
  ```
#### Config map configuration for `katib-config` 

**This configuration is only required if your Katib [algorithm](https://www.kubeflow.org/docs/components/katib/experiment/#search-algorithms-in-detail) pod needs access to AWS services.**

The [`katib-config`](https://www.kubeflow.org/docs/components/katib/katib-config/) component contains configurations involving metrics collection, tuning algorithms, and early stopping algorithms.

By default, pods that will run the tuning ([suggestion](https://www.kubeflow.org/docs/components/katib/katib-config/#suggestion-settings)) algorithm are created under the `default` service account present in the profile namespace. However, the `AwsIamForServiceAccount` plugin annotates the `default-editor` service account with the profile's `awsIamRole`, which means that only pods created under the `default-editor` service account will be granted the desired AWS permissions.

The below steps will modify the `katib-config` to create pods under the `default-editor` service account so that the pods will be granted the desired permissions.

1. Open the `katib-config` config map for editing.
    ```bash
    kubectl edit configMap katib-config -n kubeflow
    ```

2. Navigate to the `suggestion` volume settings. The settings will look similar to the following:
    ```yaml
    suggestion: |-
    {
      "random": {
        "image": "docker.io/kubeflowkatib/suggestion-hyperopt",
        ...
      },
      "tpe": {
        "image": "docker.io/kubeflowkatib/suggestion-hyperopt:v0.13.0",
        ...
      }
      ...
    }
    ```

3. For each algorithm (e.g `random`, `tpe`, etc.) add a key for `serviceAccountName` with a value of `default-editor`:
    ```yaml
    suggestion: |-
    {
      "random": {
        "image": "docker.io/kubeflowkatib/suggestion-hyperopt",
        "serviceAccountName": "default-editor"
        ...
      },
      "tpe": {
        "image": "docker.io/kubeflowkatib/suggestion-hyperopt:v0.13.0",
        "serviceAccountName": "default-editor"
        ...
      }
      ...
    }
    ```

4. Close the edit window. This will apply the configuration.


### Example: S3 Access from Katib experiment pods

The following steps walk through creating an experiment with pods that have permissions to list buckets in S3.

#### Prerequisites
Make sure that you have completed the [configuration steps]({{< ref "/docs/component-guides/katib.md#configuration" >}}).

#### Steps

1. Export the name of the profile created in the [configuration steps]({{< ref "/docs/component-guides/katib.md#configuration" >}}):
   ```bash
    export PROFILE_NAME=<the created profile name>
    ```

2. Create the following Katib experiment yaml file:

    ```bash
    cat <<EOF > experiment.yaml

    apiVersion: kubeflow.org/v1beta1
    kind: Experiment
    metadata:
      namespace: ${PROFILE_NAME}
      name: test
    spec:
      objective:
        type: maximize
        goal: 0.90
        objectiveMetricName: Validation-accuracy
        additionalMetricNames:
          - Train-accuracy
      algorithm:
        algorithmName: random
      parallelTrialCount: 3
      maxTrialCount: 12
      maxFailedTrialCount: 1
      parameters:
        - name: lr
          parameterType: double
          feasibleSpace:
           min: "0.01"
            max: "0.03"
        - name: num-layers
          parameterType: int
          feasibleSpace:
           min: "2"
           max: "5"
       - name: optimizer
          parameterType: categorical
          feasibleSpace:
           list:
              - sgd
             - adam
             - ftrl
      trialTemplate:
        primaryContainerName: training-container
        trialParameters:
          - name: learningRate
           description: Learning rate for the training model
            reference: lr
          - name: numberLayers
           description: Number of training model layers
            reference: num-layers
         - name: optimizer
           description: Training model optimizer (sdg, adam or ftrl)
            reference: optimizer
        trialSpec:
          apiVersion: batch/v1
          kind: Job
          spec:
            template:
              metadata:
                annotations:
                  sidecar.istio.io/inject: "false"
              spec:
                containers:
                  - name: training-container
                    image: public.ecr.aws/z1j2m4o4/kubeflow-katib-mxnet-mnist:latest
                    command:
                      - "python3"
                      - "/opt/mxnet-mnist/list_s3_buckets.py"
                      - "&&"
                      - "python3"
                      - "/opt/mxnet-mnist/mnist.py"
                      - "--batch-size=64"
                      - "--lr=\${trialParameters.learningRate}"
                      - "--num-layers=\${trialParameters.numberLayers}"
                      - "--optimizer=\${trialParameters.optimizer}"
                restartPolicy: Never
                serviceAccountName: default-editor
    EOF
    ```

3. Create the experiment.

    ```bash
    kubectl apply -f experiment.yaml
    ```

4. Describe the experiment.

    ```bash
    kubectl describe experiments -n ${PROFILE_NAME} test
    ```

    After around five minutes, the status should be successful.
