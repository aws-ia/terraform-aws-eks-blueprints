# Knative

## Knative-Serving

The manifests for Knative Serving are based off the following:

  - [Knative serving (v0.22.1)](https://github.com/knative/serving/releases/download/v0.22.1/serving-core.yaml)
  - [Knative ingress controller for Istio (v0.22.1)](https://github.com/knative-sandbox/net-istio/releases/download/v0.22.1/net-istio.yaml)


1. Download the knative-serving manifests with the following commands:

    ```sh
    # No need to install serving-crds.
    # See: https://github.com/knative/serving/issues/9945
    wget -O knative-serving/base/upstream/serving-core.yaml 'https://github.com/knative/serving/releases/download/v0.22.1/serving-core.yaml'
    wget -O knative-serving/base/upstream/net-istio.yaml 'https://github.com/knative-sandbox/net-istio/releases/download/v0.22.1/net-istio.yaml'
    wget -O knative-serving-post-install-jobs/base/serving-post-install-jobs.yaml https://github.com/knative/serving/releases/download/v0.22.1/serving-post-install-jobs.yaml
    ```

1. Remove all comments, since `yq` does not handle them correctly. See:
   https://github.com/mikefarah/yq/issues/788

    ```sh
    yq eval -i '... comments=""' knative-serving/base/upstream/serving-core.yaml
    yq eval -i '... comments=""' knative-serving/base/upstream/net-istio.yaml
    yq eval -i '... comments=""' knative-serving-post-install-jobs/base/serving-post-install-jobs.yaml
    ```

1. Remove all YAML anchors and aliases, as kustomize does not support them. See:
   https://github.com/kubernetes-sigs/kustomize/issues/3614
   https://github.com/kubernetes-sigs/kustomize/issues/3446

    ```sh
    yq eval -i 'explode(.)' knative-serving/base/upstream/serving-core.yaml
    yq eval -i 'explode(.)' knative-serving/base/upstream/net-istio.yaml
    yq eval -i 'explode(.)' knative-serving-post-install-jobs/base/serving-post-install-jobs.yaml
    ```

1. Remove the `knative-ingress-gateway` Gateway, since we use the Kubeflow
   gateway. We will make this into a patch once we update kustomize to v4,
   which supports removing CRs with patches. See:
   https://github.com/kubernetes-sigs/kustomize/issues/3694

    ```sh
    yq eval -i 'select((.kind == "Gateway" and .metadata.name == "knative-ingress-gateway") | not)' knative-serving/base/upstream/net-istio.yaml
    ```

1. Set `metadata.name` in the serving post-install job, to be deploy-able with
   `kustomize` and `kubectl apply`:

    ```sh
    # We are not using the '|=' operator because it generates an empty object
    # ({}) which crashes kustomize.
    yq eval -i 'select(.kind == "Job" and .metadata.generateName == "storage-version-migration-serving-") | .metadata.name = "storage-version-migration-serving"' knative-serving-post-install-jobs/base/serving-post-install-jobs.yaml
    ```

### Changes from upstream

- In `knative-serving/base/upstream/net-istio.yaml`, the `knative-ingress-gateway` Gateway is removed since we use the Kubeflow gateway.
- In `config-istio`, the Knative gateway is set to use `gateway.kubeflow.kubeflow-gateway`.
- In `config-deployment`, `progressDeadline` is set to `600s` as sometimes large models need longer than
  the default of `120s` to start the containers.
- In `knative-serving/base/upstream/net-istio.yaml` we explicitly changed the
  `portLevelMtls.8443` keys to be string. This was necessary to make these
  manifests work with kustomize 4.2 https://github.com/kubernetes-sigs/kustomize/issues/3446

## Knative-Eventing

The manifests for Knative Eventing are based off the the [v0.22.1 release](https://github.com/knative/eventing/releases/tag/v0.22.1).

  - [Eventing Core](https://github.com/knative/eventing/releases/download/v0.22.1/eventing-core.yaml)
  - [In-Memory Channel](https://github.com/knative/eventing/releases/download/v0.22.1/in-memory-channel.yaml)
  - [MT Channel Broker](https://github.com/knative/eventing/releases/download/v0.22.1/mt-channel-broker.yaml)


1. Download the knative-serving manifests with the following commands:

    ```sh
    wget -O knative-eventing/base/upstream/eventing-core.yaml 'https://github.com/knative/eventing/releases/download/v0.22.1/eventing-core.yaml'
    wget -O knative-eventing/base/upstream/in-memory-channel.yaml 'https://github.com/knative/eventing/releases/download/v0.22.1/in-memory-channel.yaml'
    wget -O knative-eventing/base/upstream/mt-channel-broker.yaml 'https://github.com/knative/eventing/releases/download/v0.22.1/mt-channel-broker.yaml'
    wget -O knative-eventing-post-install-jobs/base/eventing-post-install-jobs.yaml https://github.com/knative/eventing/releases/download/v0.22.1/eventing-post-install-jobs.yaml
    ```

1. Remove all comments, since `yq` does not handle them correctly. See:
   https://github.com/mikefarah/yq/issues/788

    ```sh
    yq eval -i '... comments=""' knative-eventing/base/upstream/eventing-core.yaml
    yq eval -i '... comments=""' knative-eventing/base/upstream/in-memory-channel.yaml
    yq eval -i '... comments=""' knative-eventing/base/upstream/mt-channel-broker.yaml
    yq eval -i '... comments=""' knative-eventing-post-install-jobs/base/eventing-post-install-jobs.yaml
    ```

1. Remove all YAML anchors and aliases, as kustomize does not support them. See:
   https://github.com/kubernetes-sigs/kustomize/issues/3614
   https://github.com/kubernetes-sigs/kustomize/issues/3446

    ```sh
    yq eval -i 'explode(.)' knative-eventing/base/upstream/eventing-core.yaml
    yq eval -i 'explode(.)' knative-eventing/base/upstream/in-memory-channel.yaml
    yq eval -i 'explode(.)' knative-eventing/base/upstream/mt-channel-broker.yaml
    yq eval -i 'explode(.)' knative-eventing-post-install-jobs/base/eventing-post-install-jobs.yaml
    ```

## Copyright

The files under the folders `knative-serving/base/upstream` and
`knative-eventing/base/upstream` are downloaded from upstream Knative repos, as
we mentioned above.
Because `yq` does not handle comments correctly, we are removing comments from
the downloaded manifests. For this reason, we include the copyright comment
here verbatim, as it appears in the original files:

```
Copyright 2018 The Knative Authors
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    https://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
