# Docker upload to Elastic Container Registry

Download the docker image to your local Mac/Laptop

```
$ docker pull <image name>:<image tag>
```

Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:

```
$ aws ecr get-login-password --region <aws region> | docker login --username AWS --password-stdin <account id>.dkr.ecr.<aws region>.amazonaws.com
```

Create an ECR repo for your image.

```
$ aws ecr create-repository --repository-name <image name> --image-scanning-configuration scanOnPush=true
```

After the repo is created in ECR, tag your image so, you can push the image to this repository:

```
$ docker tag <image name>:<image tag> <account id>.dkr.ecr.<aws region.amazonaws.com/<image name>:<image tag>
```

Step 6: Run the following command to push this image to your newly created AWS repository:

```
$ docker push <account id>.dkr.ecr.<aws region.amazonaws.com/<image name>:<image tag>
```
