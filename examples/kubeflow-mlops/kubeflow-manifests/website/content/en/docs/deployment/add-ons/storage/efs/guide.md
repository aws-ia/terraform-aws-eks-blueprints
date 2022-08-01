+++
title = "EFS"
description = "Use Amazon EFS as persistent storage with Kubeflow on AWS"
weight = 10
+++

This guide describes how to use Amazon EFS as Persistent storage on top of an existing Kubeflow deployment.  

## 1.0 Prerequisites
For this guide, we assume that you already have an EKS Cluster with Kubeflow installed. The FSx CSI Driver can be installed and configured as a separate resource on top of an existing Kubeflow deployment. See the [deployment options]({{< ref "/docs/deployment" >}}) and [general prerequisites]({{< ref "/docs/deployment/vanilla/guide.md" >}}) for more information.

1. Check that you have the necessary [prerequisites]({{< ref "/docs/deployment/vanilla/guide.md" >}}).

> Important: You must make sure you have an [OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) for your cluster and that it was added from `eksctl` >= `0.56` or if you already have an OIDC provider in place, then you must make sure you have the tag `alpha.eksctl.io/cluster-name` with the cluster name as its value. If you don't have the tag, you can add it via the AWS Console by navigating to IAM->Identity providers->Your OIDC->Tags.

2. At this point, you have likely cloned the necessary repository and checked out the right branch. Save this path to help naviagte to different paths in the rest of this guide.
```bash
export GITHUB_ROOT=$(pwd)
export GITHUB_STORAGE_DIR="$GITHUB_ROOT/deployments/add-ons/storage/"
```

3. Make sure that the following environment variables are set. 
```bash
export CLUSTER_NAME=<clustername>
export CLUSTER_REGION=<clusterregion>
```

4. Based on your setup, export the name of the user namespace you are planning to use.
```bash
export PVC_NAMESPACE=kubeflow-user-example-com
```

5. Choose a name for the EFS claim that we will create. In this guide we will use this variable as the name for the PV as well the PVC. 
```bash
export CLAIM_NAME=<efs-claim>
```

## 2.0 Set up EFS

You can either use Automated or Manual setup to set up the resources required. If you choose the manual route, you get another choice between **static and dynamic provisioning**, so pick whichever suits you. On the other hand, for the automated script we currently only support **dynamic provisioning**. Whichever combination you pick, be sure to continue picking the appropriate sections through the rest of this guide. 

### 2.1 [Option 1] Automated setup
The script automates all the manual resource creation steps but is currently only available for **Dynamic Provisioning** option.  
It performs the required cluster configuration, creates an EFS file system and it also takes care of creating a storage class for dynamic provisioning. Once done, move to section 3.0. 
1. Run the following commands from the `tests/e2e` directory:
```bash
cd $GITHUB_ROOT/tests/e2e
```
2. Install the script dependencies.
```bash
pip install -r requirements.txt
```

3. Run the automated script.

> Note: If you want the script to create a new security group for EFS, specify a name here. On the other hand, if you want to use an existing Security group, you can specify that name too. We have used the same name as the claim we are going to create. 

```bash
export SECURITY_GROUP_TO_CREATE=$CLAIM_NAME

python utils/auto-efs-setup.py --region $CLUSTER_REGION --cluster $CLUSTER_NAME --efs_file_system_name $CLAIM_NAME --efs_security_group_name $SECURITY_GROUP_TO_CREATE
```

4. The script above takes care of creating the `StorageClass (SC)` which is a cluster scoped resource. In order to create the `PersistentVolumeClaim (PVC)` you can either use the yaml file provided in this directory or use the Kubeflow UI directly. 
The PVC needs to be in the namespace you will be accessing it from. Replace the `kubeflow-user-example-com` namespace specified the below with the namespace for your kubeflow user and edit the `efs/dynamic-provisioning/pvc.yaml` file accordingly. 
```bash
yq e '.metadata.namespace = env(PVC_NAMESPACE)' -i $GITHUB_STORAGE_DIR/efs/dynamic-provisioning/pvc.yaml
yq e '.metadata.name = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/efs/dynamic-provisioning/pvc.yaml

kubectl apply -f $GITHUB_STORAGE_DIR/efs/dynamic-provisioning/pvc.yaml
```

#### **Advanced customization**
The script applies some default values for the file system name, performance mode etc. If you know what you are doing, you can see which options are customizable by executing `python utils/auto-efs-setup.py --help`.

### 2.2 [Option 2] Manual setup
If you prefer to manually setup each component then you can follow this manual guide.  As mentioned, it you have two options between **Static and Dynamic provisioing** later in step 4 of this section.  

```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
```

#### 1. Install the EFS CSI driver
We recommend installing the EFS CSI Driver v1.3.4 directly from the [the aws-efs-csi-driver github repo](https://github.com/kubernetes-sigs/aws-efs-csi-driver) as follows:

```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=tags/v1.3.4"
```

You can confirm that EFS CSI Driver was installed into the default kube-system namespace for you. You can check using the following command:
```bash
kubectl get csidriver

NAME              ATTACHREQUIRED   PODINFOONMOUNT   MODES        AGE
efs.csi.aws.com   false            false            Persistent   5d17h
```

#### 2. Create the IAM Policy for the CSI driver
The CSI driver's service account (created during installation) requires IAM permission to make calls to AWS APIs on your behalf. Here, we will be annotating the Service Account `efs-csi-controller-sa` with an IAM Role which has the required permissions.

1. Download the IAM policy document from GitHub as follows.

```bash
curl -o iam-policy-example.json https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/v1.3.4/docs/iam-policy-example.json
```

2. Create the policy.
```bash
aws iam create-policy \
    --policy-name AmazonEKS_EFS_CSI_Driver_Policy \
    --policy-document file://iam-policy-example.json
```

3. Create an IAM role and attach the IAM policy to it. Annotate the Kubernetes service account with the IAM role ARN and the IAM role with the Kubernetes service account name. You can create the role using eksctl as follows:

```bash
eksctl create iamserviceaccount \
    --name efs-csi-controller-sa \
    --namespace kube-system \
    --cluster $CLUSTER_NAME \
    --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT_ID:policy/AmazonEKS_EFS_CSI_Driver_Policy \
    --approve \
    --override-existing-serviceaccounts \
    --region $CLUSTER_REGION
```

4. You can verify by describing the specified service account to check if it has been correctly annotated:
```bash
kubectl describe -n kube-system serviceaccount efs-csi-controller-sa
```

#### 3. Manually create an instance of the EFS filesystem
Please refer to the official [AWS EFS CSI Document](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html#efs-create-filesystem) for detailed instructions on creating an EFS filesystem. 

> Note: For this guide, we assume that you are creating your EFS Filesystem in the same VPC as your EKS Cluster. 
  
#### Choose between dynamic and static provisioning  
In the following section, you have to choose between setting up [dynamic provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/) or setting up static provisioning.

#### 4. [Option 1] Dynamic provisioning  
1. Use the `$file_system_id` you recorded in section 3 above or use the AWS Console to get the filesystem id of the EFS file system you want to use. Now edit the `dynamic-provisioning/sc.yaml` file by chaning `<YOUR_FILE_SYSTEM_ID>` with your `fs-xxxxxx` file system id. You can also change it using the following command :  
```bash
file_system_id=$file_system_id yq e '.parameters.fileSystemId = env(file_system_id)' -i $GITHUB_STORAGE_DIR/efs/dynamic-provisioning/sc.yaml
```  
  
2. Create the storage class using the following command :  
```bash
kubectl apply -f $GITHUB_STORAGE_DIR/efs/dynamic-provisioning/sc.yaml
```  
3. Verify your setup by checking which storage classes are created for your cluster. You can use the following command  
```bash
kubectl get sc
```  
4. The `StorageClass` is a cluster scoped resources but the `PersistentVolumeClaim` needs to be in the namespace you will be accessing it from. Let's edit the pvc.yaml accordingly 
```bash
yq e '.metadata.namespace = env(PVC_NAMESPACE)' -i $GITHUB_STORAGE_DIR/efs/dynamic-provisioning/pvc.yaml
yq e '.metadata.name = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/efs/dynamic-provisioning/pvc.yaml

kubectl apply -f $GITHUB_STORAGE_DIR/efs/dynamic-provisioning/pvc.yaml
```

Note : The `StorageClass` is a cluster scoped resource which means we only need to do this step once per cluster. 

#### 4. [Option 2] Static Provisioning
Using [this sample](https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/examples/kubernetes/multiple_pods), we provided the required spec files in the sample subdirectory. However, you can create the PVC another way. 

1. Use the `$file_system_id` you recorded in section 3 above or use the AWS Console to get the filesystem id of the EFS file system you want to use. Now edit the last line of the static-provisioning/pv.yaml file to specify the `volumeHandle` field to point to your EFS filesystem. Replace `$file_system_id` if it is not already set. 
```bash
file_system_id=$file_system_id yq e '.spec.csi.volumeHandle = env(file_system_id)' -i $GITHUB_STORAGE_DIR/efs/static-provisioning/pv.yaml
yq e '.metadata.name = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/efs/static-provisioning/pv.yaml
```

2. The `PersistentVolume` and `StorageClass` are cluster scoped resources but the `PersistentVolumeClaim` needs to be in the namespace you will be accessing it from. Replace the `kubeflow-user-example-com` namespace specified the below with the namespace for your kubeflow user and edit the `static-provisioning/pvc.yaml` file accordingly. 
```bash
yq e '.metadata.namespace = env(PVC_NAMESPACE)' -i $GITHUB_STORAGE_DIR/efs/static-provisioning/pvc.yaml
yq e '.metadata.name = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/efs/static-provisioning/pvc.yaml
```

3. Now create the required persistentvolume, persistentvolumeclaim and storageclass resources as -
```bash
kubectl apply -f $GITHUB_STORAGE_DIR/efs/static-provisioning/sc.yaml
kubectl apply -f $GITHUB_STORAGE_DIR/efs/static-provisioning/pv.yaml
kubectl apply -f $GITHUB_STORAGE_DIR/efs/static-provisioning/pvc.yaml
```

### 2.3 Check your setup
Use the following commands to ensure all resources have been deployed as expected and the PersistentVolume is correctly bound to the PersistentVolumeClaim
```bash
# Only for Static Provisioning
kubectl get pv

NAME    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                 STORAGECLASS   REASON   AGE
efs-pv  5Gi        RWX            Retain           Bound    kubeflow-user-example-com/efs-claim   efs-sc                  5d16h
```

```bash
# Both Static and Dynamic Provisioning
kubectl get pvc -n $PVC_NAMESPACE

NAME        STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
efs-claim   Bound    efs-pv   5Gi        RWX            efs-sc         5d16h
```

## 3.0 Using EFS storage in Kubeflow
In the following two sections we will be using this PVC to create a notebook server with Amazon EFS mounted as the workspace volume, download training data into this filesystem and then deploy a TFJob to train a model using this data. 

### 3.1 Connect to the Kubeflow dashboard
Once you have everything setup, Port Forward as needed and Login to the Kubeflow dashboard. At this point, you can also check the `Volumes` tab in Kubeflow and you should be able to see your PVC is available for use within Kubeflow. 

For more details on how to access your Kubeflow dashboard, refer to one of the [deployment option guides]({{< ref "/docs/deployment" >}}) based on your setup. If you used the vanilla deployment, see [Connect to your Kubeflow cluster]({{< ref "/docs/deployment/vanilla/guide.md#connect-to-your-kubeflow-cluster" >}}).

### 3.2 Changing the default Storage Class
After installing Kubeflow, you can change the default Storage Class from `gp2` to the efs storage class you created during the setup. For instance, if you followed the automatic or manual steps, you should have a storage class named `efs-sc`. You can check your storage classes by running `kubectl get sc`.  
  
This is can be useful if your notebook configuration is set to use the default storage class (it is the case by default). By changing the default storage class, when creating workspace volumes for your notebooks, it will use your EFS storage class automatically. This is not mandatory as you can also manually create a PVC and select the `efs-sc` class via the Volume UI but can facilitate the notebook creation process and automatically select this class when creating volume in the UI. You can also decide to keep using `gp2` for workspace volumes and keep the EFS storage class for datasets/data volumes only.
  
To learn more about how to change the default Storage Class, you can refer to the [official Kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/#changing-the-default-storageclass).  
  
For instance, if you have a default class set to `gp2` and another class `efs-sc`, then you would need to do the following : 
1. Remove `gp2` as your default storage class
```bash
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```
2. Set `efs-sc` as your default storage class
```bash
kubectl patch storageclass efs-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

Note: As mentioned, make sure to change your default storage class only after you have completed your Kubeflow deployment. The default Kubeflow components may not work well with a different storage class. 

### 3.3 Note about permissions
This step may not be necessary but you might need to specify some additional directory permissions on your worker node before you can use these as mount points. By default, new Amazon EFS file systems are owned by root:root, and only the root user (UID 0) has read-write-execute permissions. If your containers are not running as root, you must change the Amazon EFS file system permissions to allow other users to modify the file system. The set-permission-job.yaml is an example of how you could set these permissions to be able to use the efs as your workspace in your kubeflow notebook. Modify it accordingly if you run into similar permission issues with any other job pod. 

```bash
yq e '.metadata.name = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/notebook-sample/set-permission-job.yaml
yq e '.metadata.namespace = env(PVC_NAMESPACE)' -i $GITHUB_STORAGE_DIR/notebook-sample/set-permission-job.yaml
yq e '.spec.template.spec.volumes[0].persistentVolumeClaim.claimName = env(CLAIM_NAME)' -i $GITHUB_STORAGE_DIR/notebook-sample/set-permission-job.yaml

kubectl apply -f $GITHUB_STORAGE_DIR/notebook-sample/set-permission-job.yaml
```

### 3.4 Use existing EFS volume as workspace or data volume for a Notebook

Spin up a new Kubeflow notebook server and specify the name of the PVC to be used as the workspace volume or the data volume and specify your desired mount point. We'll assume you created a PVC with the name `efs-claim` via Kubeflow Volumes UI or via the manual setup step [Static Provisioning](#4-option-2-static-provisioning). For our example here, we are using the AWS Optimized Tensorflow 2.6 CPU image provided in the Notebook configuration options (`public.ecr.aws/c9e4w0g3/notebook-servers/jupyter-tensorflow`). Additionally, use the existing `efs-claim` volume as the workspace volume at the default mount point `/home/jovyan`. The server might take a few minutes to come up. 

In case the server does not start up in the expected time, do make sure to check:
1. The Notebook Controller Logs
2. The specific notebook server instance pod's logs


### 3.6 Use EFS volume for a TrainingJob using TFJob Operator
The following section re-uses the PVC and the Tensorflow Kubeflow Notebook created in the previous steps to download a dataset to the EFS Volume. Then we spin up a TFjob which runs a image classification job using the data from the shared volume. 
Source: https://www.tensorflow.org/tutorials/load_data/images

Note: The following steps are run from the terminal on your gateway node connected to your EKS cluster and not from the Kubeflow Notebook to test the PVC allowed sharing of data as expected. 

#### 1. Download the dataset to the EFS Volume 
In the Kubeflow Notebook created above, use the following snippet to download the data into the `/home/jovyan/.keras` directory (which is mounted onto the EFS Volume). 
```python
import pathlib
import tensorflow as tf
dataset_url = "https://storage.googleapis.com/download.tensorflow.org/example_images/flower_photos.tgz"
data_dir = tf.keras.utils.get_file(origin=dataset_url,
                                   fname='flower_photos',
                                   untar=True)
data_dir = pathlib.Path(data_dir)
```

#### 2. Build and push the Docker image
In the `training-sample` directory, we have provided a sample training script and Dockerfile which you can use as follows to build a docker image. Be sure to point the `$IMAGE_URI` to your registry and specify an appropriate tag.
```bash
export IMAGE_URI=<dockerimage:tag>
cd training-sample

# You will need to login to ECR for the following steps
docker build -t $IMAGE_URI .
docker push $IMAGE_URI
cd -
```

#### 3. Configure the TFjob spec file
Once the docker image is built, replace the `<dockerimage:tag>` in the `tfjob.yaml` file, line #17. 
```bash
yq e '.spec.tfReplicaSpecs.Worker.template.spec.containers[0].image = env(IMAGE_URI)' -i training-sample/tfjob.yaml
```
Also, specify the name of the PVC you created.
```bash
yq e '.spec.tfReplicaSpecs.Worker.template.spec.volumes[0].persistentVolumeClaim.claimName = env(CLAIM_NAME)' -i training-sample/tfjob.yaml
```
Make sure to run it in the same namespace as the claim:
```bash
yq e '.metadata.namespace = env(PVC_NAMESPACE)' -i training-sample/tfjob.yaml
```

#### 4. Create the TFjob and use the provided commands to check the training logs 
At this point, we are ready to train the model using the `training-sample/training.py` script and the data available on the shared volume with the Kubeflow TFJob operator as -
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
Login to the dashboard to stop and/or terminate any kubeflow notebooks you created for this session or use the following command:
```bash
kubectl delete notebook -n $PVC_NAMESPACE <notebook-name>
``` 
Use the following command to delete the permissions job:
```bash
kubectl delete pod -n $PVC_NAMESPACE $CLAIM_NAME
```

### 4.3 Delete PVC, PV, and SC in the following order
```bash
kubectl delete pvc -n $PVC_NAMESPACE $CLAIM_NAME
kubectl delete pv efs-pv
kubectl delete sc efs-sc
```

### 4.4 Delete the EFS mount targets, filesystem, and security group
Use the steps in this [AWS Guide](https://docs.aws.amazon.com/efs/latest/ug/delete-efs-fs.html) to delete the EFS filesystem that you created.

## 5.0 Known issues
1. When you re-run the `eksctl create iamserviceaccount` to create and annotate the same service account multiple times, sometimes the role does not get overwritten. In this case, you may need to do one or both of the following:
    a. Delete the CloudFormation stack associated with this add-on role.
    b. Delete the `efs-csi-controller-sa` service account and then re-run the required steps. If you used the auto-script, you can re-run it by specifying the same `filesystem-name` such that a new one is not created. 
