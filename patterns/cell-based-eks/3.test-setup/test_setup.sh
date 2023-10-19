export CELL_1=cell-1
export CELL_2=cell-2
export AWS_DEFAULT_REGION=$(aws configure get region)
export AWS_ACCOUNT_NUMBER=$(aws sts get-caller-identity --query "Account" --output text)

aws eks update-kubeconfig --name $CELL_1 --region $AWS_DEFAULT_REGION
aws eks update-kubeconfig --name $CELL_2 --region $AWS_DEFAULT_REGION

export CTX_CELL_1=arn:aws:eks:$AWS_DEFAULT_REGION:${AWS_ACCOUNT_NUMBER}:cluster/$CELL_1
export CTX_CELL_2=arn:aws:eks:$AWS_DEFAULT_REGION:${AWS_ACCOUNT_NUMBER}:cluster/$CELL_2

bold=$(tput bold)
normal=$(tput sgr0)

alias kgn="kubectl get node -o custom-columns='NODE_NAME:.metadata.name,READY:.status.conditions[?(@.type==\"Ready\")].status,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,CAPACITY-TYPE:.metadata.labels.karpenter\.sh/capacity-type,AZ:.metadata.labels.topology\.kubernetes\.io/zone,VERSION:.status.nodeInfo.kubeletVersion,OS-IMAGE:.status.nodeInfo.osImage,INTERNAL-IP:.metadata.annotations.alpha\.kubernetes\.io/provided-node-ip'"

echo "------------${bold}Test the Cell-1 Setup${normal}-------------"

echo "${bold}Cell-1: Nodes before the scaling event${normal}"

kgn --context="${CTX_CELL_1}"

echo "${bold}Cell-1: Scaling the inflate deployment to 50 replicas${normal}"

kubectl scale deployment inflate --replicas 20 --context="${CTX_CELL_1}"

echo "${bold}Cell-1: Wait for karpenter to launch the worker nodes and pods become ready......${normal}"

kubectl wait --for=condition=ready pods --all --timeout 2m --context="${CTX_CELL_1}"

echo "${bold}Cell-1: Nodes after the scaling event${normal}"

kgn --context="${CTX_CELL_1}"

echo "------------${bold}Test the Cell-2 Setup${normal}-------------"

echo "${bold}Cell-2: Nodes before the scaling event${normal}"

kgn --context="${CTX_CELL_2}"

echo "${bold}Cell-2: Scaling the inflate deployment to 50 replicas${normal}"

kubectl scale deployment inflate --replicas 20 --context="${CTX_CELL_2}"

echo "${bold}Cell-2: Wait for karpenter to launch the worker nodes and pods become ready......${normal}"

kubectl wait --for=condition=ready pods --all --timeout 2m --context="${CTX_CELL_2}" 

echo "${bold}Cell-2: Nodes after the scaling event${normal}"

kgn --context="${CTX_CELL_2}"
