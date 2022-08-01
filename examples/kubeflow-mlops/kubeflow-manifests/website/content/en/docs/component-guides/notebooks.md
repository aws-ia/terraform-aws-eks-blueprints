+++
title = "Notebooks"
description = "Use Notebooks with Kubeflow on AWS to experiment with model development"
weight = 10
+++

[Kubeflow Notebooks](https://www.kubeflow.org/docs/components/notebooks/) provide a way to run web-based development environments inside your Kubernetes cluster by running them inside Pods. Users can create Notebook containers directly in the cluster, rather than locally on their workstations. Access control is managed by Kubeflow’s RBAC, enabling easier notebook sharing across the organization. 

You can use Notebooks with Kubeflow on AWS to: 
* Experiment on training scripts and model development.
* Manage Kubeflow pipeline runs.
* Integrate with Tensorboard for visualization.
* Use EFS and FSx to share data and models across nodes.
* USE EFS and FSx for dynamic volume sizing.

## AWS-optimized Kubeflow Notebook servers

Use AWS-optimized Kubeflow Notebook server images to quickly get started with a range of framework, library, and hardware options. These images are built on top of the [AWS Deep Learning Containers](https://docs.aws.amazon.com/deep-learning-containers/latest/devguide/what-is-dlc.html) along with other Kubeflow specific packages. 

These container images are available on the [Amazon Elastic Container Registry (Amazon ECR)](https://gallery.ecr.aws/c9e4w0g3/). The following images are available as part of this release, however you can always find the latest updated images in the linked ECR repository. 

```
public.ecr.aws/c9e4w0g3/notebook-servers/jupyter-tensorflow:2.6.3-gpu-py38-cu112-ubuntu20.04-v1.8
public.ecr.aws/c9e4w0g3/notebook-servers/jupyter-tensorflow:2.6.3-cpu-py38-ubuntu20.04-v1.8
public.ecr.aws/c9e4w0g3/notebook-servers/jupyter-pytorch:1.11.0-gpu-py38-cu115-ubuntu20.04-e3-v1.1
public.ecr.aws/c9e4w0g3/notebook-servers/jupyter-pytorch:1.11.0-cpu-py38-ubuntu20.04-e3-v1.1
```

AWS Deep Learning Containers provide optimized environments with popular machine learning frameworks such as TensorFlow and PyTorch, and are available in the Amazon ECR. For more information on AWS Deep Learning Container options, see [Available Deep Learning Containers Images](https://github.com/aws/deep-learning-containers/blob/master/available_images.md).

Along with specific machine learning frameworks, these container images have additional pre-installed packages:
- `kfp`
- `kfserving` 
- `h5py`
- `pandas`
- `awscli`
- `boto3`

For more information on gettings started with Kubeflow Notebooks, see the [Quickstart Guide](https://www.kubeflow.org/docs/components/notebooks/quickstart-guide/).

## Access AWS Services from Notebooks

Use [AWS IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html) to securely access AWS resources through Kubeflow Notebooks.

### Configuration

Prerequisites for setting up AWS IAM for Kubeflow Profiles can be found in the [Profiles component guide]({{< ref "/docs/component-guides/profiles.md#configuration-steps" >}}). These steps go through creating a profile that uses the `AwsIamForServiceAccount` plugin. No additional configuration steps are required.

### Try it out

1. Create a Notebook server through the central dashboard.
2. Navigate to the top left drop down menu and select the profile name for the profile that you created.
3. Create a Notebook using the [Verify Profile IAM](https://github.com/awslabs/kubeflow-manifests/blob/main/deployments/samples/notebooks/verify_profile_iam_notebook.ipynb) Notebook sample.
4. Run the Notebook. You should see the S3 buckets present in your account.
## RDS and S3 credentials for Kubeflow Pipelines and Notebooks

Set up RDS and S3 credential access to be able to:

- Use `boto3` or AWS libraries that require credentials in a Notebook, specify credentials without hard coding them, and access the credentials through environment variables.  
- Explore metadata using [ml-metadata](https://github.com/google/ml-metadata/blob/master/g3doc/get_started.md) in a Notebook and specify the necessary credentials using environment variables.
- Use [ml-metadata](https://github.com/google/ml-metadata/blob/master/g3doc/get_started.md) to query metadata during a pipeline run by passing a Kubernetes Secret to a pipeline component.  
- Use `boto3` or AWS libraries that require credentials in a Kubeflow Pipelines component. 

The following steps create a Kubernetes `mysql-secret` and `mlpipeline-minio-artifact` Secret with RDS and S3 credentials specified in the AWS Secrets Manager created while deploying the platform. This is a sample for demonstrating how you can use [`PodDefault` resource](https://github.com/kubeflow/kubeflow/blob/master/components/admission-webhook/README.md) and Secrets in Notebooks to access the metadata database and and artifacts in S3 bucket created by pipelines. Make sure you create separate database and IAM users and corresponding secrets in Secrets Manager for your users if you want fine grain access control and auditing.  

### Set up Secrets access
1. Verify that your are in the root of your repository by running the `pwd` command. The path should be `PATH/kubeflow-manifests`.
```
pwd
```

2. Navigate to the test scripts directory and install the dependencies.
```shell
cd tests/e2e
pip install -r requirements.txt
```

3. Replace `YOUR_CLUSTER_REGION`, `YOUR_CLUSTER_NAME` and `YOUR_NAMESPACE` with the appropriate values and run the script. 

> Note: `YOUR_NAMESPACE` represents the namespace that the Secrets will be set up in. For example, if your Notebooks and pipelines will be in the `kubeflow-user-example-com` namespace, then you would use `kubeflow-user-example-com` in place of `YOUR_NAMESPACE`. The namespace must exist before executing the script. 

```shell
PYTHONPATH=.. python utils/notebooks/setup_secrets_access.py --region YOUR_CLUSTER_REGION --cluster YOUR_CLUSTER_NAME --profile-namespace YOUR_NAMESPACE
```  

Use the help flag to learn more about available parameters:
```bash
PYTHONPATH=.. python utils/notebooks/setup_secrets_access.py --help
```

### (Optional) Update default Notebook configurations

No Kubeflow Notebook configuration is selected by default. You can make the `PodDefault` resources that you created the default credential configuration when creating a Notebook. If you do not follow this step, you must manually select this in the Notebook UI. For more information on set up details, see the [Detailed Steps](https://www.kubeflow.org/docs/components/notebooks/quickstart-guide/#detailed-steps) in the Kubeflow Notebooks Quickstart Guide. 
  
> Note: Making this configuration default introduces a dependency. The Secrets and PodDefault must be available in all Profile namespaces. If the Secrets and PodDefault resources are not available in a Profile namespaces, newly created Notebook servers in that Profile namespace will fail.

Update the default Kubeflow Notebook configuration either before or after installing Kubeflow. 

#### Option 1: Before installing Kubeflow
Modify the file `awsconfigs/apps/jupyter-web-app/configs/spawner_ui_config.yaml`
```yaml
  configurations:
    # List of labels to be selected, these are the labels from PodDefaults
    value:
      - add-aws-secret
```  
#### Option 2: After installing Kubeflow
Update the Notebook configuration at runtime with the following command:  
```bash
kubectl edit $(kubectl get cm -n kubeflow -l app=jupyter-web-app -o=name | grep 'web-app-config') -n kubeflow
```  

Modify the configuration:  
```yaml
  configurations:
    # List of labels to be selected, these are the labels from PodDefaults
    value:
      - add-aws-secret
```  
  
Save and exit your editor. Then, restart the Notebook deployment to apply the changes.   

```shell
kubectl rollout restart deployment jupyter-web-app-deployment -n kubeflow
```
### Verify Notebook credentials

Find `PodDefault` in the Notebook creation page to verify that your setup was done successfully. 
![](https://user-images.githubusercontent.com/26939775/155630906-0eecf1d9-3fb1-4d01-a85e-1cff46dc37e9.png)  

Create a Notebook and check that the environment variables are accessible.
```python
import os

print(os.environ['port'])
```  

