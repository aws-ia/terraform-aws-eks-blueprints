Not Working:
arn:aws:iam::015299085168:role/hub-cluster-argocd-hub

Trust
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::015299085168:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/EB2FE3D3ADC646C08395960942AD4E4F"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.us-west-2.amazonaws.com/id/EB2FE3D3ADC646C08395960942AD4E4F:sub": "system:serviceaccount:argocd:argocd-*",
                    "oidc.eks.us-west-2.amazonaws.com/id/EB2FE3D3ADC646C08395960942AD4E4F:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}

Policy
{
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Resource": "*",
            "Sid": ""
        }
    ],
    "Version": "2012-10-17"
}

