package base

import (
	"github.com/kubeflow/manifests/tests"
	"testing"
)

func TestKustomize(t *testing.T) {
	testCase := &tests.KustomizeTestCase{
		Package: "../../../../../../awsconfigs/common/aws-secrets-manager/base",
		Expected: "test_data/expected",
	}

	tests.RunTestCase(t, testCase)
}