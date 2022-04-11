# Terratest for EKS Blueprints

## Configure and run Terratest

### Step1: Install

golang (for macos you can use brew)

### Step2: Change directory into the test folder.

```shell
cd test
```

### Step3: Initialize your test

```shell
go mod init github.com/aws-ia/terraform-aws-eks-blueprints

go mod tidy -go=1.17
```

### Step4: Build and Run E2E Test

```shell
cd src

go get -v -t -d && go mod tidy -compat=1.17

go test -v -timeout 60m -tags=e2e
```
