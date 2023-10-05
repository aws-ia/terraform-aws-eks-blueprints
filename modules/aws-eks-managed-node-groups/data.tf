locals{
  managed_ng_assume_role_policy_json = jsonencode({
      Statement = [
        {
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = {
                Service = "${local.ec2_principal}"
              }
            Sid       = "EKSWorkerAssumeRole"
          },
      ]
      Version   = "2012-10-17"
    })
}
