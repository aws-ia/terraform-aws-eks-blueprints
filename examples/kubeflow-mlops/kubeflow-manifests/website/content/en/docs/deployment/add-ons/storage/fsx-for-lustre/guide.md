+++
title = "FSx for Lustre"
description = "Use Amazon FSx as persistent storage with Kubeflow on AWS"
weight = 20
+++

This guide describes how to use Amazon FSx as Persistent storage on top of an existing Kubeflow deployment.  

## 1.0 Prerequisites
For this guide, we assume that you already have an EKS Cluster with Kubeflow installed. The FSx CSI Driver can be installed and configured as a separate resource on top of an existing Kubeflow deployment. See the [deployment options]({{< ref "/docs/deployment" >}}) and [general prerequisites]({{< ref "/docs/deployment/vanilla/guide.md" >}}) for more information.

1. Check that you have the necessary [prerequisites]({{< ref "/docs/deployment/vanilla/guide.md" >}}).

> Important: You must make sure you have an [OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) for your cluster and that it was added from `eksctl` >= `0.56` or if you already have an OIDC provider in place, then you must make sure you have the tag `alpha.eksctl.io/cluster-name` with the cluster name as its value. If you don't have the tag, you can add it via the AWS Console by navigating to IAM->Identity providers->Your OIDC->Tags.

2. At this point, you have likely cloned the necessary repository and checked out the right branch. Save this path to help us navigate to different paths in the rest of this guide.
```bash
export GITHUB_ROOT=$(pwd)
export GITHUB_STORAGE_DIR="$GITHUB_ROOT/deployments/add-ons/storage/"
```

3. Make sure the following environment variables are set. 
```bash
export CLUSTER_NAME=<clustername>
export CLUSTER_REGION=<clusterregion>
```

4. Based on your setup, export the name of the user namespace you are planning to use.
```bash
export PVC_NAMESPACE=kubeflow-user-example-com
```

5. Choose a name for the FSx claim that we will create. In this guide, we will use this variable as the name for the PV as well the PVC. 
```bash
export CLAIM_NAME=<fsx-claim>
```

## 2.0 Setup FSx for Lustre
You can either use Automated or Manual setup. We currently only support **Static provisioning** for FSx.  

### 2.1 [Option 1] Automated setup
The script automates all the manual resource creation steps but is currently only available for **Static Provisioning** option.  
It performs the required cluster configuration, creates an FSx file system and it also takes care of creating a storage class for static provisioning. Once done, move to section 3.0. 
1. Run the following commands from the `tests/e2e` directory:
```bash
cd $GITHUB_ROOT/tests/e2e
```
2. Install the script dependencies 
```bash
pip install -r requirements.txt
```
3. Run the automated script as follows.   

Note: If you want the script to create a new security group for FSx, specify a name for `SECURITY_GROUP_TO_CREATE`. On the other hand, if you want to use an existing Security group, you can specify that name too.
```bash
export SECURITY_GROUP_TO_CREATE=$CLAIM_NAME

python utils/auto-fsx-setup.py --region $CLUSTER_REGION --cluster $CLUSTER_NAME --fsx_file_system_name $CLAIM_NAME --fsx_security_group_name $SECURITY_GROUP_TO_CREATE
```

4. The script above takes care of creating the `PersistentVolume (PV)` which is a cluster scoped resource. In order to create the `PersistentVolumeClaim (PVC)` you can either use the yaml file provided in this directory or use the Kubeflow UI directly but the PVC needs to be in the user namespace you will be accessing it from. 
```bash
yq e '.metadata.namespace = env(PVC_NAMESPACE)' -i $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pvc.yaml
yq e '.metadata.name = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pvc.yaml
yq e '.spec.volumeName = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pvc.yaml

kubectl apply -f $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pvc.yaml

```

#### **Advanced customization**
The script applies some default values for the file system name, performance mode etc. If you know what you are doing, you can see which options are customizable by executing `python utils/auto-fsx-setup.py --help`.

### 2.2 [Option 2] Manual setup
If you prefer to manually setup each component then you can follow this manual guide.  

#### 1. Install the FSx CSI Driver
We recommend installing the FSx CSI Driver v0.7.1 directly from the [the aws-fsx-csi-driver GitHub repository](https://github.com/kubernetes-sigs/aws-fsx-csi-driver) as follows:

```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-fsx-csi-driver/deploy/kubernetes/overlays/stable/?ref=tags/v0.7.1"
```

You can confirm that FSx CSI Driver was installed using the following command:
```bash
kubectl get csidriver -A

NAME              ATTACHREQUIRED   PODINFOONMOUNT   MODES        AGE
fsx.csi.aws.com   false            false            Persistent   14s
```

#### 2. Create the IAM Policy for the CSI Driver
The CSI driver's service account (created during installation) requires IAM permission to make calls to AWS APIs on your behalf. Here, we will be annotating the Service Account `fsx-csi-controller-sa` with an IAM Role which has the required permissions.

1. Create the policy using the json file provided as follows:
```bash
aws iam create-policy \
    --policy-name Amazon_FSx_Lustre_CSI_Driver \
    --policy-document file://fsx-for-lustre/fsx-csi-driver-policy.json
```

2. Create an IAM role and attach the IAM policy to it. Annotate the Kubernetes service account with the IAM role ARN and the IAM role with the Kubernetes service account name. You can create the role using eksctl as follows:

```bash
eksctl create iamserviceaccount \
    --name fsx-csi-controller-sa \
    --namespace kube-system \
    --cluster $CLUSTER_NAME \
    --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/Amazon_FSx_Lustre_CSI_Driver \
    --region $CLUSTER_REGION \
    --approve \
    --override-existing-serviceaccounts 
```

3. You can verify by describing the specified service account to check if it has been correctly annotated:
```bash
kubectl describe -n kube-system serviceaccount fsx-csi-controller-sa
```

#### 3. Create an instance of the FSx Filesystem
Please refer to the official [AWS FSx CSI documentation](https://docs.aws.amazon.com/fsx/latest/LustreGuide/getting-started-step1.html) for detailed instructions on creating an FSx filesystem. 

Note: For this guide, we assume that you are creating your FSx Filesystem in the same VPC as your EKS Cluster. 

#### 4. Static provisioning
[Using this sample from official Kubeflow Docs](https://www.kubeflow.org/docs/distributions/aws/customizing-aws/storage/#amazon-fsx-for-lustre) 

1. Use the AWS Console to get the filesystem id of the FSx volume you want to use. You could also use the following command to list all the volumes available in your region. Either way, make sure that `file_system_id` is set. 
```bash
aws fsx describe-file-systems --query "FileSystems[*].FileSystemId" --output text --region $CLUSTER_REGION
```

```bash
export file_system_id=<fsx-id-to-use>
```

2. Once you have the filesystem id, Use the following command to retrieve DNSName, and MountName values.
```bash
export dns_name=$(aws fsx describe-file-systems --file-system-ids $file_system_id --query "FileSystems[0].DNSName" --output text --region $CLUSTER_REGION)

export mount_name=$(aws fsx describe-file-systems --file-system-ids $file_system_id --query "FileSystems[0].LustreConfiguration.MountName" --output text --region $CLUSTER_REGION)
```

3. Now edit the `fsx-for-lustre/static-provisioning/pv.yaml` to replace <file_system_id>, <dns_name>, and <mount_name> with your values.
```bash
yq e '.spec.csi.volumeHandle = env(file_system_id)' -i $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pv.yaml
yq e '.spec.csi.volumeAttributes.dnsname = env(dns_name)' -i $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pv.yaml
yq e '.spec.csi.volumeAttributes.mountname = env(mount_name)' -i $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pv.yaml
```

4. The `PersistentVolume` is a cluster scoped resource but the `PersistentVolumeClaim` needs to be in the namespace you will be accessing it from. Replace the `kubeflow-user-example-com` namespace specified the below with the namespace for your kubeflow user and edit the `fsx-for-lustre/static-provisioning/pvc.yaml` file accordingly. 
```bash
yq e '.spec.volumeName = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pvc.yaml
yq e '.metadata.name = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pvc.yaml
yq e '.metadata.namespace = env(PVC_NAMESPACE)' -i $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pvc.yaml
```

5. Now create the required `PersistentVolume` and `PersistentVolumeClaim` resources as -
```bash
kubectl apply -f $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pv.yaml
kubectl apply -f $GITHUB_STORAGE_DIR/fsx-for-lustre/static-provisioning/pvc.yaml
```

### 2.3 Check your setup 
Use the following commands to ensure all resources have been deployed as expected and the PersistentVolume is correctly bound to the PersistentVolumeClaim
```bash
kubectl get pv

NAME    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                 STORAGECLASS   REASON   AGE
fsx-pv  1200Gi     RWX            Recycle          Bound    kubeflow-user-example-com/fsx-claim                           11s
```

```bash
kubectl get pvc -n $PVC_NAMESPACE

NAME        STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
fsx-claim   Bound    fsx-pv   1200Gi     RWX                           83s
```

## 3.0 Using FSx storage in Kubeflow
In the following two sections we will be using this PVC to create a notebook server with Amazon FSx mounted as the workspace volume, download training data into this filesystem and then deploy a TFJob to train a model using this data. 

### 3.1 Connect to the Kubeflow dashboard
Once you have everything setup, Port Forward as needed and Login to the Kubeflow dashboard. At this point, you can also check the `Volumes` tab in Kubeflow and you should be able to see your PVC is available for use within Kubeflow. 
For more details on how to access your Kubeflow dashboard, refer to one of the [deployment option guides]({{< ref "/docs/deployment" >}}) based on your setup. If you used the vanilla deployment, see [Connect to your Kubeflow cluster]({{< ref "/docs/deployment/vanilla/guide.md#connect-to-your-kubeflow-cluster" >}}).

### 3.2 Note about permissions
This step may not be necessary but you might need to specify some additional directory permissions on your worker node before you can use these as mount points. By default, new Amazon FSx file systems are owned by root:root, and only the root user (UID 0) has read-write-execute permissions. If your containers are not running as root, you must change the Amazon FSx file system permissions to allow other users to modify the file system. The set-permission-job.yaml is an example of how you could set these permissions to be able to use the fsx as your workspace in your kubeflow notebook. Modify it accordingly if you run into similar permission issues with any other job pod. 

```bash
yq e '.metadata.name = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/notebook-sample/set-permission-job.yaml
yq e '.metadata.namespace = env(PVC_NAMESPACE)' -i $GITHUB_STORAGE_DIR/notebook-sample/set-permission-job.yaml
yq e '.spec.template.spec.volumes[0].persistentVolumeClaim.claimName = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/notebook-sample/set-permission-job.yaml

kubectl apply -f $GITHUB_STORAGE_DIR/notebook-sample/set-permission-job.yaml
```

### 3.2 Using FSx volume as workspace or data volume for a notebook server 
Spin up a new Kubeflow notebook server and specify the name of the PVC to be used as the workspace volume or the data volume and specify your desired mount point. For our example here, we are using the AWS-optimized Tensorflow 2.6 CPU image provided in the Notebook configuration options (`public.ecr.aws/c9e4w0g3/notebook-servers/jupyter-tensorflow`). Additionally, use the existing PVC as the workspace volume at the default mount point `/home/jovyan`. The server might take a few minutes to come up. 

In case the server does not start up in the expected time, do make sure to check:
1. The Notebook Controller Logs
2. The specific notebook server instance pod's logs

### 3.3 Using FSx volume for a TrainingJob using TFJob Operator
The following section re-uses the PVC and the Tensorflow Kubeflow Notebook created in the previous steps to download a dataset to the FSx Volume. Then we spin up a TFjob which runs a image classification job using the data from the shared volume. 
Source: https://www.tensorflow.org/tutorials/load_data/images

Note: The following steps are run from the terminal on your gateway node connected to your EKS cluster and not from the Kubeflow Notebook to test the PVC allowed sharing of data as expected. 

### 1. Download the dataset to the FSx Volume 
In the Kubeflow Notebook created above, use the following snippet to download the data into the `/home/jovyan/.keras` directory (which is mounted onto the FSx Volume). 
```python
import pathlib
import tensorflow as tf
dataset_url = "https://storage.googleapis.com/download.tensorflow.org/example_images/flower_photos.tgz"
data_dir = tf.keras.utils.get_file(origin=dataset_url,
                                   fname='flower_photos',
                                   untar=True)
data_dir = pathlib.Path(data_dir)
```

### 2. Build and push the Docker image
In the `training-sample` directory, we have provided a sample training script and Dockerfile which you can use as follows to build a docker image. Be sure to point the `$IMAGE_URI` to your registry and specify an appropriate tag:
```bash
export IMAGE_URI=<dockerimage:tag>
cd training-sample

# You will need to login to ECR for the following steps
docker build -t $IMAGE_URI .
docker push $IMAGE_URI
cd -
```

### 3. Configure the TFjob spec file
Once the docker image is built, replace the `<dockerimage:tag>` in the `tfjob.yaml` file, line #17. 
```bash
yq e '.spec.tfReplicaSpecs.Worker.template.spec.containers[0].image = env(IMAGE_URI)' -i training-sample/tfjob.yaml
```
Also, specify the name of the PVC you created:
```bash
export CLAIM_NAME=fsx-claim
yq e '.spec.tfReplicaSpecs.Worker.template.spec.volumes[0].persistentVolumeClaim.claimName = env(CLAIM_NAME)' -i training-sample/tfjob.yaml
```
Make sure to run it in the same namespace as the claim:
```bash
yq e '.metadata.namespace = env(PVC_NAMESPACE)' -i training-sample/tfjob.yaml
```

### 4. Create the TFjob and use the provided commands to check the training logs 
At this point, we are ready to train the model using the `training-sample/training.py` script and the data available on the shared volume with the Kubeflow TFJob operator.
```bash
kubectl apply -f training-sample/tfjob.yaml
```

In order to check that the training job is running as expected, you can check the events in the TFJob describe response as well as the job logs.
```bash
kubectl describe tfjob image-classification-pvc -n $PVC_NAMESPACE
kubectl logs -n $PVC_NAMESPACE image-classification-pvc-worker-0 -f
```

## 4.0 Cleanup
This section cleans up the resources created in this guide. To clean up other resources, such as the Kubeflow deployment, see [Uninstall Kubeflow]({{< ref "/docs/deployment/uninstall-kubeflow.md" >}}).

### 4.1 Clean up the TFJob
```bash
kubectl delete tfjob -n $PVC_NAMESPACE image-classification-pvc
```

### 4.2 Delete the Kubeflow Notebook
Log in to the dashboard to stop and/or terminate any Kubeflow Notebooks that you created for this session or use the following commands: 
```bash
kubectl delete notebook -n $PVC_NAMESPACE <notebook-name>
``` 
```bash
kubectl delete pod -n $PVC_NAMESPACE $CLAIM_NAME
```

### 4.3 Delete PVC, PV, and SC in the following order
```bash
kubectl delete pvc -n $PVC_NAMESPACE $CLAIM_NAME
kubectl delete pv fsx-pv
```

### 4.4 Delete the FSx filesystem
```bash
aws fsx delete-file-system --file-system-id $file_system_id
```
Make sure to delete any other resources that you have created such as security groups via the AWS Console or using the AWS CLI. 

## 5.0 Known issues
 
 When you re-run the `eksctl create iamserviceaccount` to create and annotate the same service account multiple times, sometimes the role does not get overwritten. In this case, you may need to do one or both of the following: 
    1. Delete the CloudFormation stack associated with this add-on role.
    2. Delete the `fsx-csi-controller-sa` service account and then re-run the required steps. If you used the auto-script, you can re-run it by specifying the same `filesystem-name` so that a new one is not created. 

 When using an FSx volume in a Kubeflow Notebook, the same PVC claim can be mounted to the same Notebook only once as either the workspace volume or the data volume. Create two seperate PVCs on your FSx volume if you need to attach it twice to the Notebook.  