+++
title = "Profiles"
description = "Use AWS IAM for Kubeflow Profiles"
weight = 40
+++

## Kubeflow Profiles

A [Kubeflow Profile](https://github.com/kubeflow/kubeflow/tree/master/components/profile-controller#kubeflow-profile) is a unique configuration for a user that determines their access privileges and is defined by the Administrator. Kubeflow uses Profiles to control all policies, roles, and bindings involved, and to guarantee consistency. Resources belonging to a Profile are contained within a Profile namespace.

## Profile plugins

Use `Profile Plugins` to interface with the Identity and Access Management (IAM) services that manage permissions for external resources outside of Kubernetes.

The `AwsIamForServiceAccount` plugin allows the use of [AWS IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html) access control for Profile users in order to grant or limit access to AWS resources and services.

### IAM roles for service accounts

In order for the Profile controller to get the necessary permissions, the Profile controller pod must be recognized as an entity that can interface with AWS IAM. This is done by using [IAM roles for service accounts (IRSA)](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/).

IRSA allows the use of AWS IAM permission boundaries at the Kubernetes pod level. A Kubernetes service account (SA) is associated with an IAM role with a role policy that scopes the IAM permissions (e.g. S3 read/write access, etc.). When a pod in the SA namespace is annotated with the SA name, EKS injects the IAM role ARN and a token is used to get the credentials so that the pod can make requests to AWS services within the scope of the role policy associated with the IRSA.

For more information, see [Amazon EKS IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).

### Admin considerations

- Kubeflow admins will need to create an IAM role for each Profile with the desired scoped permissions.
- The Profile controller does not have the permissions specified in the Profile roles.
- The Profile controller has permissions to modify the Profile roles, which it will do to grant assume role permissions to the `default-editor` service account (SA) present in the Profile's namespace.
- A `default-editor` SA exists in every Profile's namespace and will be annotated with the role ARN created for the profile. Pods annotated with the SA name will be granted the Profile role permissions.
- The `default-editor` SA is used by various services in Kubeflow to launch resources in Profile namespaces. However, not all services do this by default.

### Component-level implementations

The following components have been tested to work with the `AwsIamForServiceAccount` plugin:

- Notebooks
- Kubeflow Pipelines SDK

Integration with the `AwsIamForServiceAccount` plugin is actively being worked on for all components with [Profile-level support](https://www.kubeflow.org/docs/components/multi-tenancy/overview/#current-integration).

You can find documentation about the `AwsIamForServiceAccount` plugin for specific components in the individual [component guides]({{< ref "/docs/component-guides" >}}). Read on for general configuration instructions.

## Configuration steps

After installing Kubeflow on AWS with one of the available [deployment options]({{< ref "/docs/deployment" >}}), you can configure Kubeflow Profiles with the following steps:

1. Define the following environment variables:

   ```bash
   export CLUSTER_NAME=<your cluster name>
   export CLUSTER_REGION=<your region>
   export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
   export PROFILE_NAME=<the name of the profile to be created>
   export PROFILE_CONTROLLER_POLICY_NAME=<the name of the profile controller policy to be created>
   ```

2. Create an IAM policy using the [IAM Profile controller policy](https://github.com/awslabs/kubeflow-manifests/blob/main/awsconfigs/infra_configs/iam_profile_controller_policy.json) file.

   ```bash
   aws iam create-policy \
   --region $CLUSTER_REGION \
   --policy-name ${PROFILE_CONTROLLER_POLICY_NAME} \
   --policy-document file://awsconfigs/infra_configs/iam_profile_controller_policy.json
   ```

   As a principle of least privilege, we recommend scoping the resources in the [IAM Profile controller policy](https://github.com/awslabs/kubeflow-manifests/blob/main/awsconfigs/infra_configs/iam_profile_controller_policy.json) to the specific policy arns of the policies created in step 6.

3. Associate IAM OIDC with your cluster.

   ```bash
   aws --region $CLUSTER_REGION eks update-kubeconfig --name $CLUSTER_NAME

   eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --region $CLUSTER_REGION --approve
   ```

4. Create an IRSA for the Profile controller using the policy.

   ```bash
   eksctl create iamserviceaccount \
   --cluster=$CLUSTER_NAME \
   --name="profiles-controller-service-account" \
   --namespace=kubeflow \
   --attach-policy-arn="arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${PROFILE_CONTROLLER_POLICY_NAME}" \
   --region=$CLUSTER_REGION \
   --override-existing-serviceaccounts \
   --approve
   ```

5. Create an IAM trust policy to authorize federated requests from the OIDC provider.

   ```bash
   export OIDC_URL=$(aws eks describe-cluster --region $CLUSTER_REGION --name $CLUSTER_NAME  --query "cluster.identity.oidc.issuer" --output text | cut -c9-)

   cat <<EOF > trust.json
   {
   "Version": "2012-10-17",
   "Statement": [
       {
       "Effect": "Allow",
       "Principal": {
           "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_URL}"
       },
       "Action": "sts:AssumeRoleWithWebIdentity",
       "Condition": {
           "StringEquals": {
           "${OIDC_URL}:aud": "sts.amazonaws.com"
           }
       }
       }
   ]
   }
   EOF
   ```

6. [Create an IAM policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create.html) to scope the permissions for the Profile. For simplicity, we will use the `arn:aws:iam::aws:policy/AmazonS3FullAccess` policy as an example.

7. [Create an IAM role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create.html) for the Profile using the scoped policy from the previous step.

   ```bash
   aws iam create-role --role-name $PROFILE_NAME-$CLUSTER_NAME-role --assume-role-policy-document file://trust.json

   aws iam attach-role-policy --role-name $PROFILE_NAME-$CLUSTER_NAME-role --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
   ```

8. Create a user in your configured auth provider (e.g. Cognito or Dex) or use an existing user.

   Export the user as an environment variable. For simplicity, we will use the `user@example.com` user that is created by default by most of our provided deployment options.

   ```bash
   export PROFILE_USER="user@example.com"
   ```

9. Create a Profile using the `PROFILE_NAME`.

   ```bash
   cat <<EOF > profile_iam.yaml
   apiVersion: kubeflow.org/v1
   kind: Profile
   metadata:
     name: ${PROFILE_NAME}
   spec:
     owner:
       kind: User
       name: ${PROFILE_USER}
     plugins:
     - kind: AwsIamForServiceAccount
       spec:
         awsIamRole: $(aws iam get-role --role-name $PROFILE_NAME-$CLUSTER_NAME-role --output text --query 'Role.Arn')
   EOF

   kubectl apply -f profile_iam.yaml
   ```

## Use Kubeflow Profiles with Notebooks

Verify your configuration by [creating and running]({{< ref "/docs/component-guides/notebooks.md#try-it-out" >}}) a [Kubeflow Notebook](https://www.kubeflow.org/docs/components/notebooks/quickstart-guide/).
