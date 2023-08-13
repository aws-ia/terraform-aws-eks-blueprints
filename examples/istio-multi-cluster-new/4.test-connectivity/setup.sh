export CLUSTER_1=cluster-1
export CLUSTER_2=cluster-2
export AWS_DEFAULT_REGION=$(aws configure get region)
export AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity --query "Account" --output text)

aws eks update-kubeconfig --name $CLUSTER_1 --region $AWS_DEFAULT_REGION
aws eks update-kubeconfig --name $CLUSTER_2 --region $AWS_DEFAULT_REGION

export CTX_CLUSTER_1=arn:aws:eks:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_NUMBER:cluster/$CLUSTER_1
export CTX_CLUSTER_2=arn:aws:eks:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_NUMBER:cluster/$CLUSTER_2

kubectl create --context="${CTX_CLUSTER_1}" namespace sample
kubectl create --context="${CTX_CLUSTER_2}" namespace sample

kubectl label --context="${CTX_CLUSTER_1}" namespace sample \
    istio-injection=enabled
kubectl label --context="${CTX_CLUSTER_2}" namespace sample \
    istio-injection=enabled

kubectl apply --context="${CTX_CLUSTER_1}" \
    -f istio-helloworld.yaml \
    -l service=helloworld -n sample
kubectl apply --context="${CTX_CLUSTER_2}" \
    -f istio-helloworld.yaml \
    -l service=helloworld -n sample


kubectl apply --context="${CTX_CLUSTER_1}" \
    -f istio-helloworld.yaml \
    -l version=v1 -n sample

kubectl apply --context="${CTX_CLUSTER_2}" \
    -f istio-helloworld.yaml \
    -l version=v2 -n sample


kubectl apply --context="${CTX_CLUSTER_1}" \
    -f istio-sleep.yaml -n sample
kubectl apply --context="${CTX_CLUSTER_2}" \
    -f istio-sleep.yaml -n sample

# istioctl x create-remote-secret \
#     --context="${CTX_CLUSTER_1}" \
#     --name=tenant-cluster | \
#     kubectl apply -f - --context="${CTX_CLUSTER_2}"

# istioctl x create-remote-secret \
#     --context="${CTX_CLUSTER_2}" \
#     --name=shared | \
#     kubectl apply -f - --context="${CTX_CLUSTER_1}"
# add cross cluster traffic

