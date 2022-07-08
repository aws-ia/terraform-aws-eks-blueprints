from airflow import DAG
from datetime import datetime
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import (
    KubernetesPodOperator,
)

default_args = {
    "owner": "aws",
    "depends_on_past": False,
    "start_date": datetime(2019, 2, 20),
    "provide_context": True,
}

dag = DAG("kubernetes_pod_example", default_args=default_args, schedule_interval=None)

# use a kube_config stored in s3 dags folder for now
kube_config_path = "/usr/local/airflow/dags/kube_config.yaml"

podRun = KubernetesPodOperator(
    namespace="mwaa",
    image="ubuntu:18.04",
    cmds=["bash"],
    arguments=["-c", "ls"],
    labels={"foo": "bar"},
    name="mwaa-pod-test",
    task_id="pod-task",
    get_logs=True,
    dag=dag,
    is_delete_operator_pod=False,
    config_file=kube_config_path,
    in_cluster=False,
    cluster_context="mwaa", # Must match kubeconfig context
)
