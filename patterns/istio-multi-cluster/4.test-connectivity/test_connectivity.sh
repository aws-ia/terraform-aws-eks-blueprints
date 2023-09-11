export CLUSTER_1=cluster-1
export CLUSTER_2=cluster-2
export AWS_DEFAULT_REGION=$(aws configure get region)
export AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity --query "Account" --output text)

aws eks update-kubeconfig --name $CLUSTER_1 --region $AWS_DEFAULT_REGION
aws eks update-kubeconfig --name $CLUSTER_2 --region $AWS_DEFAULT_REGION

export CTX_CLUSTER_1=arn:aws:eks:$AWS_DEFAULT_REGION:${AWS_ACCOUNT_NUMBER}:cluster/$CLUSTER_1
export CTX_CLUSTER_2=arn:aws:eks:$AWS_DEFAULT_REGION:${AWS_ACCOUNT_NUMBER}:cluster/$CLUSTER_2


kubectl exec --context="${CTX_CLUSTER_1}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER_1}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
kubectl exec --context="${CTX_CLUSTER_1}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER_1}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
kubectl exec --context="${CTX_CLUSTER_1}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER_1}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
kubectl exec --context="${CTX_CLUSTER_1}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER_1}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello


kubectl exec --context="${CTX_CLUSTER_2}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER_2}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
kubectl exec --context="${CTX_CLUSTER_2}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER_2}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
kubectl exec --context="${CTX_CLUSTER_2}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER_2}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
kubectl exec --context="${CTX_CLUSTER_2}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER_2}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl -sS helloworld.sample:5000/hello
