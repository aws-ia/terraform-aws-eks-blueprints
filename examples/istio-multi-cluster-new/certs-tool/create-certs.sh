# https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/#plug-in-certificates-and-key-into-the-cluster
mkdir certs
cd certs
make -f ../Makefile.selfsigned.mk root-ca
make -f ../Makefile.selfsigned.mk cluster-1-cacerts
make -f ../Makefile.selfsigned.mk cluster-2-cacerts