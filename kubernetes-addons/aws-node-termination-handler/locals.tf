locals {
  queue_policy = jsonencode({
    Version : "2012-10-17"
    Id : "NTHQueuePolicy"
    Statement : [{
      Effect : "Allow"
      Principal : {
        Service : ["events.amazonaws.com", "sqs.amazonaws.com"]
      }
      Action : "sqs:SendMessage"
      Resource : [
        aws_sqs_queue.aws_node_termination_handler_queue.arn
      ]
    }]
  })
  namespace            = "kube-system"

  service_account_name = "aws-node-termination-handler-sa"

  event_rules = [
    {
      name          = "NTHASGTermRule",
      event_pattern = <<EOF
{"source":["aws.autoscaling"],"detail-type":["EC2 Instance-terminate Lifecycle Action"]}
EOF
    },
    {
      name          = "NTHSpotTermRule",
      event_pattern = <<EOF
{"source": ["aws.ec2"],"detail-type": ["EC2 Spot Instance Interruption Warning"]}
EOF
    },
    {
      name          = "NTHRebalanceRule",
      event_pattern = <<EOF
{"source": ["aws.ec2"],"detail-type": ["EC2 Instance Rebalance Recommendation"]}
EOF
    },
    {
      name          = "NTHInstanceStateChangeRule",
      event_pattern = <<EOF
{"source": ["aws.ec2"],"detail-type": ["EC2 Instance State-change Notification"]}
EOF
    },
    {
      name          = "NTHScheduledChangeRule",
      event_pattern = <<EOF
{"source": ["aws.health"],"detail-type": ["AWS Health Event"]}
EOF
    }
  ]

  irsa_policy = jsonencode({
    Statement: {
      Effect: "Allow"
      Resources: ["*"]

      Actions: [
        "autoscaling:CompleteLifecycleAction",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeTags",
        "ec2:DescribeInstances",
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage"
      ]
    }
  })
}