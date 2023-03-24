pushd ../../../..
git clone https://github.com/aws-samples/eks-blueprints-workloads.git
git clone https://git-codecommit.$AWS_REGION.amazonaws.com/v1/repos/eks-blueprints-workloads-cc
cd eks-blueprints-workloads-cc
git checkout -b main
cd ..
rsync -av eks-blueprints-workloads/ eks-blueprints-workloads-cc --exclude .git
cd eks-blueprints-workloads-cc
git add . && git commit -m "initial commit" && git push --set-upstream origin main
popd
