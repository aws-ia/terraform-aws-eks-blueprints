package cognito

import (
	"github.com/kubeflow/manifests/tests"
	"testing"
)

func TestKustomize(t *testing.T) {
	testCase := &tests.KustomizeTestCase{
		Package: "../../../../../../../awsconfigs/common/istio-ingress/overlays/cognito",
		Expected: "test_data/expected",
	}

	tests.RunTestCase(t, testCase)
}