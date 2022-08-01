# Kustomize Manifest Tests

## E2E

There are 2 goals for the e2e tests:
1. Verify that core components can be applied and become Ready
2. Verify that core CRDs can be created and succeed

### Components

The e2e are installing everything by using the [single-install
command](../README.md#install-with-a-single-command). This means that all of
the core and common (Istio, Knativ, Cert Manager) are being installed and
included in the tests.

### Test Suite

The e2e tests are completely independent of the underlying K8s cluster, as well
as the platform of the cluster. These tests should be able to run in real
world clusters, as well as ephemeral ones like KinD.

The tests are also explicitly bypassing any authentication system of the
installation. The goal of these tests are to ensure that a common use case that
deploys all of Kubeflow's components can succeed. Thus we only want to test
that the core CRDs can be successfully applied and complete.
