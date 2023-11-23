##!/bin/bash
DBHOST="$(terraform output -json postgres_host | jq -r '.[0]')"
DBUSER="$(terraform output -raw postgres_username)"
DBPASSWORD="$(terraform output -raw postgres_password)"
DBPORT="$(terraform output -raw postgres_port)"
DBNAME="$(terraform output -raw postgres_db_name)"
DBSCHEMA=analytics


CLUSTER_2=cluster2
AWS_DEFAULT_REGION=$(aws configure get region)
AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity --query "Account" --output text)


aws eks update-kubeconfig --name $CLUSTER_2 --region $AWS_DEFAULT_REGION
export CTX_CLUSTER_2=arn:aws:eks:$AWS_DEFAULT_REGION:${AWS_ACCOUNT_NUMBER}:cluster/$CLUSTER_2



# setting up the cluster cluster secrets
kubectl create --context="${CTX_CLUSTER_2}" ns apps
kubectl create --context="${CTX_CLUSTER_2}" secret generic postgres-credentials \
--from-literal=POSTGRES_HOST="${DBHOST}" \
--from-literal=POSTGRES_USER="${DBUSER}" \
--from-literal=POSTGRES_PASSWORD="${DBPASSWORD}" \
--from-literal=POSTGRES_DATABASE=amazon \
--from-literal=POSTGRES_PORT=5432 \
--from-literal=POSTGRES_TABLEPREFIX=popularity_bucket_  -n apps





