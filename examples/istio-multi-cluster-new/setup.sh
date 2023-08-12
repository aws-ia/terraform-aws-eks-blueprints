export CTX_SHARED=arn:aws:eks:eu-west-1:481121494044:cluster/shared
export CTX_TENANT=arn:aws:eks:eu-west-1:481121494044:cluster/tenant-cluter

# in istio cloned repo
mkdir -p certs
pushd certs
make -f ../tools/certs/Makefile.selfsigned.mk shared-cacerts
make -f ../tools/certs/Makefile.selfsigned.mk tenant-cluster-cacerts

kubectl --context $CTX_SHARED create secret generic cacerts -n istio-system \
      --from-file=shared/ca-cert.pem \
      --from-file=shared/ca-key.pem \
      --from-file=shared/root-cert.pem \
      --from-file=shared/cert-chain.pem

kubectl --context $CTX_TENANT create secret generic cacerts -n istio-system \
      --from-file=tenant-cluter/ca-cert.pem \
      --from-file=tenant-cluter/ca-key.pem \
      --from-file=tenant-cluter/root-cert.pem \
      --from-file=tenant-cluter/cert-chain.pem

kubectl create --context="${CTX_TENANT}" namespace sample
kubectl create --context="${CTX_SHARED}" namespace sample

kubectl label --context="${CTX_TENANT}" namespace sample \
    istio-injection=enabled
kubectl label --context="${CTX_SHARED}" namespace sample \
    istio-injection=enabled

kubectl apply --context="${CTX_TENANT}" \
    -f istio-helloworld.yaml \
    -l service=helloworld -n sample
kubectl apply --context="${CTX_SHARED}" \
    -f istio-helloworld.yaml \
    -l service=helloworld -n sample


kubectl apply --context="${CTX_TENANT}" \
    -f istio-helloworld.yaml \
    -l version=v1 -n sample

kubectl apply --context="${CTX_SHARED}" \
    -f istio-helloworld.yaml \
    -l version=v2 -n sample


kubectl apply --context="${CTX_TENANT}" \
    -f istio-sleep.yaml -n sample
kubectl apply --context="${CTX_SHARED}" \
    -f istio-sleep.yaml -n sample

istioctl x create-remote-secret \
    --context="${CTX_TENANT}" \
    --name=tenant-cluster | \
    kubectl apply -f - --context="${CTX_SHARED}"

istioctl x create-remote-secret \
    --context="${CTX_SHARED}" \
    --name=shared | \
    kubectl apply -f - --context="${CTX_TENANT}"
# add cross cluster traffic

