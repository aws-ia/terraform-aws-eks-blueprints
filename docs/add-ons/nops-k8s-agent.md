# Nops k8s Agent

This add-on configures [nops-k8s-agent](https://github.com/nops-io/nops-k8s-agent)

Worker contains database to keep users entries and pulls metadata from their accounts on a scheduled basis.


## Usage

[nOps Agent](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/nops-k8s-agent) can be deployed by enabling the add-on via the following.

```hcl
enable_nops_k8s_agent = true

Deploy Nops Agent with custom `values.yaml`


#All the apps_nops variable values needs to be pass 

default_helm_values = [templatefile("${path.module}/values.yaml", {
    operating_system = "linux"
    region           = var.addon_context.aws_region_name,
    app_nops_k8s_collector_api_key = var.app_nops_k8s_collector_api_key,
    app_nops_k8s_collector_aws_account_number = var.app_nops_k8s_collector_aws_account_number
    app_prometheus_server_endpoint = var.app_prometheus_server_endpoint
    app_nops_k8s_agent_clusterid  = var.app_nops_k8s_agent_clusterid
    app_nops_k8s_collector_skip_ssl = var.app_nops_k8s_collector_skip_ssl
    app_nops_k8s_agent_prom_token = var.app_nops_k8s_agent_prom_token
    
      })]

These are required variables defination:

    APP_PROMETHEUS_SERVER_ENDPOINT - Depends on your Prometheus stack installation (different for every person and every cluster).
    APP_NOPS_K8S_AGENT_CLUSTER_ID - needs to match with your cluster id
    APP_NOPS_K8S_COLLECTOR_API_KEY - See, nOps Developer API to learn how to get your API key. https://docs.nops.io/en/articles/5955764-getting-started-with-the-nops-developer-api
    APP_NOPS_K8S_COLLECTOR_AWS_ACCOUNT_NUMBER - The 12-digit unique account number of the AWS account, which is configured within nOps.


```
These above values if changed in the directory will become the new default. You can override these values during deployment of the agent via helm repo.

Once deployed, you can see nops agent pod in the `nops-k8s-agent` namespace.

```sh
$ kubectl get cronjob -n nops-k8s-agent

NAME                                                          READY   UP-TO-DATE   AVAILABLE   AGE
nops-k8s-agent-high                                           1/1     1            1           20m
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
nops_k8s_agent = {
  enable = true
}
```
