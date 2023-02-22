# E2E tests

We use GitHub Actions to run an end-to-end tests to verify all PRs. The GitHub Actions used are a combination of `aws-actions/configure-aws-credentials` and `hashicorp/setup-terraform@v1`.

## Setup

1. Use the following CloudFormation template to setup a new IAM role.

```yaml
Parameters:
  GitHubOrg:
    Type: String
  RepositoryName:
    Type: String
  OIDCProviderArn:
    Description: Arn for the GitHub OIDC Provider.
    Default: ""
    Type: String

Conditions:
  CreateOIDCProvider: !Equals
    - !Ref OIDCProviderArn
    - ""

Resources:
  Role:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Statement:
          - Effect: Allow
            Action: sts:AssumeRoleWithWebIdentity
            Principal:
              Federated: !If
                - CreateOIDCProvider
                - !Ref GithubOidc
                - !Ref OIDCProviderArn
            Condition:
              StringLike:
                token.actions.githubusercontent.com:sub: !Sub repo:${GitHubOrg}/${RepositoryName}:*

  GithubOidc:
    Type: AWS::IAM::OIDCProvider
    Condition: CreateOIDCProvider
    Properties:
      Url: https://token.actions.githubusercontent.com
      ClientIdList:
        - sts.amazonaws.com
      ThumbprintList:
        - a031c46782e6e6c662c2c87c76da9aa62ccabd8e

Outputs:
  Role:
    Value: !GetAtt Role.Arn
```

2. Add a permissible IAM Policy to the above create role. For our purpose `AdministratorAccess` works the best.

3. Setup a GitHub repo secret called `ROLE_TO_ASSUME` and set it to ARN of the role created in 1.

4. We use an S3 backend for the e2e tests. This allows us to recover from any failures during the `apply` stage. If you are setting up your own CI pipeline change the s3 bucket name in backend configuration of the example.
