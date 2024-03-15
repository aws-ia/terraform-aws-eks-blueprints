# IAM Identity Center Single Sign-On for Amazon EKS Cluster with Cluster Access Manager

This example demonstrates how to deploy an Amazon EKS cluster that is deployed on the AWS Cloud, integrated with IAM Identity Center (former AWS SSO) as an the Identity Provider (IdP) for Single Sign-On (SSO) authentication having [Cluster Access Manager](https://aws.amazon.com/about-aws/whats-new/2023/12/amazon-eks-controls-iam-cluster-access-management/) as the entry point API. The configuration to provide authorization for users is simplified using a combination of [Access Entries](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html) and Kubernetes Role-based access control (RBAC).

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

After the `terraform` commands are executed successfully, check if the newly created users are active.

To do that use the link provided in the email invite - *if you added a valid email address for your users either in your Terraform code or IAM Identity Center Console* - or go to the [IAM Identity Center Console](https://console.aws.amazon.com/singlesignon/home/), in the *Users* dashboard on the left hand side menu, then select the user, and click on *Reset password* button on the upper right corner. Choose the option to *Generate a one-time password and share the password with the user*.

With the active users, use one of the `terraform output` examples to configure your AWS credentials for SSO, as shown in the examples below. After you choose the *SSO registration scopes*, your browser windows will appear and request to login using your IAM Identity Center username and password.

### Admin user example

```sh
configure_sso_admin = <<EOT
  # aws configure sso --profile EKSClusterAdmin
  SSO session name (Recommended): <SESSION_NAME>
  SSO start URL [None]: https://d-1234567890.awsapps.com/start
  SSO region [None]: us-west-2
  SSO registration scopes [sso:account:access]:
  Attempting to automatically open the SSO authorization page in your default browser.
  If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

  https://device.sso.us-west-2.amazonaws.com/

  Then enter the code:

  The only AWS account available to you is: 123456789012
  Using the account ID 123456789012
  The only role available to you is: EKSClusterAdmin
  Using the role name EKSClusterAdmin
  CLI default client Region [us-west-2]: us-west-2
  CLI default output format [json]: json
  CLI profile name [EKSClusterAdmin-123456789012]:

  To use this profile, specify the profile name using --profile, as shown:

  aws eks --region us-west-2 update-kubeconfig --name iam-identity-center --profile EKSClusterAdmin


EOT
```

### Read-only user example

```sh
configure_sso_user = <<EOT
  # aws configure sso --profile EKSClusterUser
  SSO session name (Recommended): <SESSION_NAME>
  SSO start URL [None]: https://d-1234567890.awsapps.com/start
  SSO region [None]: us-west-2
  SSO registration scopes [sso:account:access]:
  Attempting to automatically open the SSO authorization page in your default browser.
  If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

  https://device.sso.us-west-2.amazonaws.com/

  Then enter the code:

  The only AWS account available to you is: 123456789012
  Using the account ID 123456789012
  The only role available to you is: EKSClusterUser
  Using the role name EKSClusterUser
  CLI default client Region [us-west-2]: us-west-2
  CLI default output format [json]: json
  CLI profile name [EKSClusterUser-123456789012]:

  To use this profile, specify the profile name using --profile, as shown:

  aws eks --region us-west-2 update-kubeconfig --name iam-identity-center --profile EKSClusterUser

EOT
```

With the `kubeconfig` configured, you'll be able to run `kubectl` commands in your Amazon EKS Cluster with the impersonated user. The read-only user has a `cluster-viewer` Kubernetes role bound to it's group, whereas the admin user, has the `admin` Kubernetes role bound to it's group.

```sh
kubectl get pods -A
NAMESPACE          NAME                        READY   STATUS    RESTARTS   AGE
amazon-guardduty   aws-guardduty-agent-bl2v2   1/1     Running   0          3h54m
amazon-guardduty   aws-guardduty-agent-s2vcx   1/1     Running   0          3h54m
amazon-guardduty   aws-guardduty-agent-w8gfc   1/1     Running   0          3h54m
kube-system        aws-node-m9hmd              1/1     Running   0          3h53m
kube-system        aws-node-w42b8              1/1     Running   0          3h53m
kube-system        aws-node-wm6rm              1/1     Running   0          3h53m
kube-system        coredns-6ff9c46cd8-94jlr    1/1     Running   0          3h59m
kube-system        coredns-6ff9c46cd8-n2mrb    1/1     Running   0          3h59m
kube-system        kube-proxy-7fb86            1/1     Running   0          3h54m
kube-system        kube-proxy-p4f5g            1/1     Running   0          3h54m
kube-system        kube-proxy-q1fmc            1/1     Running   0          3h54m
```

If not revoked after the cluster creation, it's possible to use the `configure_kubectl` output to assume the *Cluster creator* role with `cluster-admin` access.

```sh
configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name iam-identity-center"
```

## Destroy

If you revoked the *Cluster creator* `cluster-admin` permission, you may need to re-associate the `AmazonEKSClusterAdminPolicy` access entry to run `terraform destroy`.

```sh
terraform destroy -target module.developers_team -auto-approve
terraform destroy -target module.eks -auto-approve
terraform destroy -auto-approve
```
