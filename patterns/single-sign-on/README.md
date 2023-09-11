# Single Sign-On for Amazon EKS Cluster

These examples demonstrates how to deploy an Amazon EKS cluster that is deployed on the AWS Cloud, integrated with an external Identity Provider (IdP) for Single Sign-On (SSO) authentication. The authorization configuration still being done using Kubernetes Role-based access control (RBAC). At this time we have integration with the following IdPs.

- [IAM Identity Center (successor to AWS Single Sign-On)](https://aws.amazon.com/iam/identity-center/)
- [Okta](https://www.okta.com/)
