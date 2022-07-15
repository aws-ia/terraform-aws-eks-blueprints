## EKS Cluster w/ Amazon Manged Workflows for Apache Airflopw (MWAA)

The example demonstrates how to use Amazon Managed Workflows for Apache Airflow (MWAA) with Amazon EKS.

This example was originated from the steps provided on MWAA documentation on the link below:
[mwaa-eks-example](https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-eks-example.html)

### Considerations

1. Ideally we recommend adding the steps to sync requirements/sync dags to the MWAA S3 Bucket as part of a CI/CD pipeline. Generally Dags development have a different lifecycle than the Terraform code to provision infrastructure.
However for simplicity we are providing steps for that using Terraform running AWS CLI commands on null_resource.

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply


## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the deployment.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. List the nodes running currently

```sh
kubectl get nodes

# Output should look like below
NAME                                        STATUS                        ROLES    AGE     VERSION
ip-10-0-30-125.us-west-2.compute.internal   Ready                         <none>   2m19s   v1.22.9-eks-810597c
```

3. Log into Apache Airflow UI

- Open the Environments page on the Amazon MWAA console
- Choose an environment
- Under the `Details` section, click the link for the Airflow UI

4. Triger the DAG workflow to execute

In the Airflow UI, enable the example and then trigger it.

![Enable the DAG kubernetes_pod_example ](images/kubernetes_pod_example_dag.png)

![Trigger the DAG kubernetes_pod_example ](images/dag_tree.png)

5. Verify that the pod was executed successfully

After it runs and completes successfully, use the following command to verify the pod:

```sh
kubectl get pods -n mwaa
```

You should see output similar to the following:

```sh
NAME                                             READY   STATUS      RESTARTS   AGE
mwaa-pod-test.4bed823d645844bc8e6899fd858f119d   0/1     Completed   0          25s
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -auto-approve
```
