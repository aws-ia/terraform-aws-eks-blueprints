# Okta Single Sign-On for Amazon EKS Cluster

This example demonstrates how to deploy an Amazon EKS cluster that is deployed on the AWS Cloud, integrated with Okta as an the Identity Provider (IdP) for Single Sign-On (SSO) authentication. The configuration for authorization is done using Kubernetes Role-based access control (RBAC).

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

After the `terraform` commands are executed successfully, check if the newly created users are active.

To do that use the link provided in the email invite if you added a valid email address for your users, or go to the [Okta Admin Dashboard](https://dev-ORGID-admin.okta.com/admin/users/), select the user, and click on *Set Password and Activate* button.

With the active users, use the `terraform output` example to setup your `kubeconfig` profile to authenticate through Okta.

```
configure_kubeconfig = <<EOT
    kubectl config set-credentials oidc \
      --exec-api-version=client.authentication.k8s.io/v1beta1 \
      --exec-command=kubectl \
      --exec-arg=oidc-login \
      --exec-arg=get-token \
      --exec-arg=--oidc-issuer-url=https://dev-ORGID.okta.com/oauth2/1234567890abcdefghij \
      --exec-arg=--oidc-client-id=1234567890abcdefghij
      --exec-arg=--oidc-extra-scope="email offline_access profile openid"
```

With the `kubeconfig` configured, you'll be able to run `kubectl` commands in your Amazon EKS Cluster using the `--user` cli option to impersonate the Okta authenticated user. When `kubectl` command is issued with the `--user` option for the first time, your browser window will open and require you to authenticate.

The read-only user has a `cluster-viewer` Kubernetes role bound to it's group, whereas the admin user, has the `admin` Kubernetes role bound to it's group.

```
kubectl get pods -A
NAMESPACE          NAME                        READY   STATUS    RESTARTS   AGE
amazon-guardduty   aws-guardduty-agent-bl2v2   1/1     Running   0          3h54m
amazon-guardduty   aws-guardduty-agent-s1vcx   1/1     Running   0          3h54m
amazon-guardduty   aws-guardduty-agent-w8gfc   1/1     Running   0          3h54m
kube-system        aws-node-m9hmd              1/1     Running   0          3h53m
kube-system        aws-node-w42b8              1/1     Running   0          3h53m
kube-system        aws-node-wm6rm              1/1     Running   0          3h53m
kube-system        coredns-6ff9c46cd8-94jlr    1/1     Running   0          3h59m
kube-system        coredns-6ff9c46cd8-nw2rb    1/1     Running   0          3h59m
kube-system        kube-proxy-7fb86            1/1     Running   0          3h54m
kube-system        kube-proxy-p4f5g            1/1     Running   0          3h54m
kube-system        kube-proxy-qk2mc            1/1     Running   0          3h54m
```

You can also use the `configure_kubectl` output to assume the *Cluster creator* role with `cluster-admin` access.

```
configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name okta"
```

It's also possible to pre-configure your `kubeconfig` using the `okta_login` output. This will also require you to authenticate in a browser window.

```
okta_login = "kubectl oidc-login setup --oidc-issuer-url=https://dev-ORGID.okta.com/oauth2/1234567890abcdefghij--oidc-client-id=1234567890abcdefghij"
```

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
