# ---------------------------------------------------------------------------------------------------------------------
# MWAA Environment
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_mwaa_environment" "mwaa" {
  name              = var.environment_name
  airflow_version   = var.airflow_version
  environment_class = var.environment_class
  min_workers       = var.min_workers
  max_workers       = var.max_workers

  execution_role_arn = aws_iam_role.mwaa_role.arn

  airflow_configuration_options = {
    # DAG timeout and log level
    "core.dagbag_import_timeout"        = var.airflow_configuration_options["dag_timeout"]
    "core.default_task_retries"         = var.airflow_configuration_options["core.default_task_retries"]
    "core.check_slas"                   = var.airflow_configuration_options["core.check_slas"]
    "core.dag_concurrency"              = var.airflow_configuration_options["core.dag_concurrency"]
    "core.dag_file_processor_timeout"   = var.airflow_configuration_options["core.dag_file_processor_timeout"]
    "core.dagbag_import_timeout"        = var.airflow_configuration_options["core.dagbag_import_timeout"]
    "core.max_active_runs_per_dag"      = var.airflow_configuration_options["core.max_active_runs_per_dag"]
    "core.parallelism"                  = var.airflow_configuration_options["core.parallelism"]
    "celery.worker_autoscale"           = var.airflow_configuration_options["celery.worker_autoscale"]
    "scheduler.processor_poll_interval" = var.airflow_configuration_options["scheduler.processor_poll_interval"]

    "logging.logging_level" = var.airflow_configuration_options["log_level"]

    # Airflow webserver timeout
    "webserver.web_server_master_timeout" = var.airflow_configuration_options["webserver_timeout"]["master"]
    "webserver.web_server_worker_timeout" = var.airflow_configuration_options["webserver_timeout"]["worker"]

  }

  logging_configuration {
    dag_processing_logs {
      enabled   = var.logging_configuration["dag_processing_logs"]["enabled"]
      log_level = var.logging_configuration["dag_processing_logs"]["log_level"]
    }

    scheduler_logs {
      enabled   = var.logging_configuration["scheduler_logs"]["enabled"]
      log_level = var.logging_configuration["scheduler_logs"]["log_level"]
    }

    task_logs {
      enabled   = var.logging_configuration["task_logs"]["enabled"]
      log_level = var.logging_configuration["task_logs"]["log_level"]
    }

    webserver_logs {
      enabled   = var.logging_configuration["webserver_logs"]["enabled"]
      log_level = var.logging_configuration["webserver_logs"]["log_level"]
    }

    worker_logs {
      enabled   = var.logging_configuration["worker_logs"]["enabled"]
      log_level = var.logging_configuration["worker_logs"]["log_level"]
    }
  }

  dag_s3_path          = var.dag_s3_path
  plugins_s3_path      = var.plugins_s3_path
  requirements_s3_path = var.requirements_s3_path

  network_configuration {
    security_group_ids = [aws_security_group.mwaa_sg.id]
    subnet_ids         = var.private_subnet_ids
  }

  lifecycle {
    ignore_changes = [
      plugins_s3_object_version,
      requirements_s3_object_version
    ]
  }

  source_bucket_arn     = aws_s3_bucket.mwaa_content.arn
  webserver_access_mode = var.webserver_access_mode
}

# ---------------------------------------------------------------------------------------------------------------------
# MWAA Role
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "mwaa_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["airflow.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["airflow-env.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mwaa_role" {
  name               = "mwaa-executor-${var.environment_name}-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.mwaa_assume_role.json
}

resource "aws_iam_role_policy" "mwaa_policy" {
  name   = "mwaa-executor-policy-${var.environment_name}-${data.aws_region.current.name}"
  role   = aws_iam_role.mwaa_role.id
  policy = data.aws_iam_policy_document.mwaa_policy.json
}

data "aws_iam_policy_document" "mwaa_policy" {
  statement {
    effect = "Allow"
    actions = [
      "airflow:PublishMetrics",
      "airflow:CreateWebLoginToken"
    ]
    resources = [
      "arn:aws:airflow:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:environment/${var.environment_name}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.mwaa_content.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.mwaa_content.bucket}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.environment_name}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
      "cloudwatch:PutMetricData",
      "batch:DescribeJobs",
      "batch:ListJobs",
      "eks:*"
    ]
    resources = [
      "*"
    ]
  }


  statement {
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    resources = [
      "arn:aws:sqs:${data.aws_region.current.name}:*:airflow-celery-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt"
    ]
    not_resources = [
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*"
    ]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"

      values = [
        "sqs.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Describe*",
      "dynamodb:PartiQLSelect",
      "dynamodb:Get*",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:BatchGetItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:List*",
    ]
    resources = [
      "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "batch:*",
    ]
    resources = [
      "arn:aws:batch:*:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  # Policy to grant acces to SSM
  statement {
    effect = "Allow"
    actions = [
      "ssm:*"
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
    ]
  }

  # Policy to grant access to LogEvents
  statement {
    effect = "Allow"
    actions = [
      "logs:*"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"]
  }

  # Policy to grant access to CloudWatch
  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:*"]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MWAA S3 Bucket
# ---------------------------------------------------------------------------------------------------------------------

# Amazon MWAA constraints
#  - S3 bucket needs to start with prefix "airflow"
#  - Mandatory to set Block Public Access
resource "aws_s3_bucket" "mwaa_content" {
  bucket = "mwaa-${var.environment_name}-${data.aws_region.current.name}"
}

resource "aws_s3_bucket_acl" "mwaa_content" {
  bucket = aws_s3_bucket.mwaa_content.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "mwaa_content" {
  bucket = aws_s3_bucket.mwaa_content.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "mwaa_public_access_block" {
  bucket = aws_s3_bucket.mwaa_content.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_object" "plugins" {
  key    = "plugins.zip"
  bucket = aws_s3_bucket.mwaa_content.id
}

resource "aws_s3_object" "python_requirements" {
  key    = "requirements.txt"
  bucket = aws_s3_bucket.mwaa_content.id
}

resource "aws_security_group" "mwaa_sg" {
  name   = "mwaa-${var.environment_name}"
  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MWAA Security Group
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "mwaa_sg_inbound" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "all"
  source_security_group_id = aws_security_group.mwaa_sg.id
  security_group_id        = aws_security_group.mwaa_sg.id
  description              = "Amazon MWAA inbound access"
}

resource "aws_security_group_rule" "mwaa_sg_inbound_vpn" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = tolist(var.vpn_cidr)
  security_group_id = aws_security_group.mwaa_sg.id
  description       = "VPN Access for Airflow UI"
}

resource "aws_security_group_rule" "mwaa_sg_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mwaa_sg.id
  description       = "Amazon MWAA outbound access"
}