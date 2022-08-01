package aws_secrets_manager

import (
	"github.com/kubeflow/manifests/tests"
	"testing"
)

func TestKustomize(t *testing.T) {
	testCase := &tests.KustomizeTestCase{
		Package: "../../../../../awsconfigs/common/aws-secrets-manager",
		Expected: "test_data/expected",
	}

	tests.RunTestCase(t, testCase)
}