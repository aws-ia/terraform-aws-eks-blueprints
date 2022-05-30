variable "environment_name" {
  description = "Name of MWAA Environment"
}

variable "airflow_version" {
  description = "Airflow version of the MWAA environment"
}

variable "environment_class" {
  description = "Environment class for the cluster. Possible options are mw1.small, mw1.medium, mw1.large."
}

variable "dag_s3_path" {
  description = "The relative path to the DAG folder on your Amazon S3 storage bucket."
  default     = "dags"
}

variable "plugins_s3_path" {
  description = "The relative path to the plugins.zip file on your Amazon S3 storage bucket. For example, plugins.zip."
  default     = "plugins.zip"
}

variable "requirements_s3_path" {
  description = "The relative path to the requirements.txt file on your Amazon S3 storage bucket. For example, requirements.txt."
  default     = "requirements.txt"
}

variable "logging_configuration" {
  description = "The Apache Airflow logs you want to send to Amazon CloudWatch Logs."
  type        = any
}

variable "airflow_configuration_options" {
  description = "The airflow_configuration_options parameter specifies airflow override options."
  type        = any
}

variable "min_workers" {
  description = "The minimum number of workers that you want to run in your environment. Will be 1 by default."
  default     = 1
}

variable "max_workers" {
  description = "The maximum number of workers that can be automatically scaled up. Value need to be between 1 and 25. Will be 10 by default."
  default     = 10
}

variable "vpc_id" {
  description = "VPC ID to deploy the MWAA Environment."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnet IDs in which the environment should be created. MWAA requires two subnets."
}

variable "vpn_cidr" {
  description = "VPN CIDR Access for Airflow UI"
}

variable "webserver_access_mode" {
  description = "Specifies whether the webserver should be accessible over the internet or via your specified VPC. Possible options: PRIVATE_ONLY (default) and PUBLIC_ONLY."
}

