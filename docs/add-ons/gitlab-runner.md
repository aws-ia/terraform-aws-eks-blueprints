# gitlab-runner

The GitLab runner Helm Chart is the official way of deploying a GitLab runner on a Kubernetes cluster. The chart configures a GitLab runner which runs using the Kubernetes executor. For each new job, it provisions a pod within the specified namespace.

For complete project documentation, please see [GitLab's documentation](https://docs.gitlab.com/runner/install/kubernetes.html). 

## Usage

The GitLab Runner can be deployed by enabling the add-on via the following:

```hcl
enable_gitlab_runner = true
```

At minimum a runner token must be supplied. This can be done directly, as a deploy-time value:

```hcl
  gitlab_runner_helm_config = {
    set_sensitive = [
      { name = "runnerRegistrationToken", value = "someTokenValue" },
    ]
  }
```

or using an existing secret, such as:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-runner-secret
type: Opaque
data:
  runner-registration-token: "NlZrN1pzb3NxUXlmcmVBeFhUWnIK" #base64 encoded registration token
  runner-token: ""
```
and passing it to the chart:

```hcl
  gitlab_runner_helm_config = {
    set = [
      { name = "runners.secret", value = "gitlab-runner-secret" }
    ]
  }
```

By default the runner is registered on the cloud instance `gitlab.com`. An self-hosted instance can also be configured:

```hcl
  gitlab_runner_helm_config = {
    set = [
      { name = "gitlabUrl", value = "https://mygitlab.com" }
    ]
  }
```
