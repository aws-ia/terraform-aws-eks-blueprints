# gitlab CI/CD example

This pattern shows the example to dpeloy the EKS Clusters using gitlab CI/CD

### Step1: Clone this repo

```
git@github.com:aws-samples/aws-eks-accelerator-for-terraform.git
```

## Step2: Create a new gitlab repo

Copy this folder(`gitlab-ci-cd`) to your new gitlab repo. Rename the folder according to your naming convention.


    cd examples/advanced/gitlab-ci-cd
    gitlab-ci-cd

## Step3: Update CI/CD settings config

 - Login to gitlab console, click on your repo and navigate to `settings/ci_cd`
 - Add the following variables before triggering the pipeline

        AWS_ACCESS_KEY_ID           e.g., access key from devops admin iam role
        AWS_SECRET_ACCESS_KEY       e.g., secret key from devops admin iam role
        AWS_REGION                  e.g., eu-west-1
        GITLAB_BASE_URL             e.g., https://gitlab.aws.dev/api/v4/
        GITLAB_TOKEN                e.g., gitlab access token  

## Step5: Commit changes to verify the pipeline


<!--- BEGIN_TF_DOCS --->

<!--- END_TF_DOCS --->
