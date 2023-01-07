//go:build e2e
// +build e2e

package src

import (
	internal "github.com/aws-ia/terraform-aws-eks-blueprints/aws"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	core "k8s.io/api/core/v1"
	"testing"
	"time"
)

var (
	//Test Driven tests Inputs https://github.com/golang/go/wiki/TableDrivenTests
	testCases = []struct {
		name        string
		region      string
		eks_cluster string
		values      map[string]string
	}{
		{
			"fargate-serverless",
			"us-west-2",
			"aws-terra-test-eks",
			map[string]string{
				"rootFolder":        "../..",
				"exampleFolderPath": "examples/fargate-serverless"},
		},
	}

	destroyModules = []string{
		"module.eks_blueprints_kubernetes_addons",
		"module.eks",
		"full_destroy",
	}

	/*EKS API Validation*/
	expectedEKSWorkerNodes = 3

	/*Update the expected Deployments names and the namespace*/
	expectedDeployments = [...]Deployment{
		{"aws-load-balancer-controller", "kube-system"},
		{"coredns", "kube-system"},
	}

	/*Update the expected K8s Services names and the namespace*/
	expectedServices = [...]Services{
		{"kube-dns", "kube-system", "ClusterIP"},
		{"kubernetes", "default", "ClusterIP"},
	}
)

type Outputs struct {
	OutputVariable      string
	ExpectedOutputValue string
	AssertType          string
}

type Deployment struct {
	Name      string
	Namespace string
}

type DaemonSet struct {
	Name      string
	Namespace string
}

type Services struct {
	Name      string
	Namespace string
	Type      core.ServiceType
}

func TestEksBlueprintsE2E(t *testing.T) {
	t.Parallel()

	for _, testCase := range testCases {
		testCase := testCase
		t.Run(testCase.name, func(subT *testing.T) {
			subT.Parallel()
			/*This allows running multiple tests in parallel against the same terraform module*/
			tempExampleFolder := test_structure.CopyTerraformFolderToTemp(t, testCase.values["rootFolder"], testCase.values["exampleFolderPath"])
			//Uncomment for debugging the test code
			//os.Setenv("SKIP_destroy", "true")

			inputTfOptions := &terraform.Options{
				/*The path to where our Terraform code is located*/
				TerraformDir: tempExampleFolder,
				Vars: map[string]interface{}{
					"cluster_name": "aws-terra-test-eks",
				},
			}

			terratestOptions := getTerraformOptions(t, inputTfOptions)

			/* At the end of the test, run `terraform destroy` to clean up any resources that were created */
			defer test_structure.RunTestStage(t, "destroy", func() {
				for _, target := range destroyModules {
					if target != "full_destroy" {
						destroyTFOptions := &terraform.Options{
							/*The path to where our Terraform code is located*/
							TerraformDir: tempExampleFolder,
							Vars: map[string]interface{}{
								"cluster_name": "aws-terra-test-eks",
							},
							Targets: []string{target},
							NoColor: true,
						}
						terraformOptions := getTerraformOptions(t, destroyTFOptions)
						terraform.Destroy(t, terraformOptions)
						time.Sleep(2 * time.Minute) // Workaround for cleaning up dangling ENIs
					} else {
						terraformOptions := getTerraformOptions(t, inputTfOptions)
						terraform.Destroy(t, terraformOptions)
					}
				}
			})

			// Run Init and Apply
			test_structure.RunTestStage(t, "apply", func() {
				test_structure.SaveTerraformOptions(t, tempExampleFolder, terratestOptions)
				/* This will run `terraform init` and `terraform apply` and fail the test if there are any errors */
				terraform.InitAndApply(t, terratestOptions)
			})

			t.Run("TF_PLAN_VALIDATION", func(t *testing.T) {
				// Run Plan diff
				test_structure.RunTestStage(t, "plan", func() {
					terraformOptions := test_structure.LoadTerraformOptions(t, tempExampleFolder)
					planResult := terraform.Plan(t, terraformOptions)

					// Make sure the plan shows zero changes
					assert.Contains(t, planResult, "No changes.")
				})
			})

			t.Run("EKS_ADDON_VALIDATION", func(t *testing.T) {
				/*EKS and Addon Validation*/
				test_structure.RunTestStage(t, "eks_addon_validation", func() {
					terraformOptions := test_structure.LoadTerraformOptions(t, tempExampleFolder)
					eksClusterName := terraform.Output(t, terraformOptions, "eks_cluster_id")
					awsRegion := terraform.Output(t, terraformOptions, "region")
					eksAddonValidation(t, eksClusterName, awsRegion)
				})
			})
		})
	}

}

func getTerraformOptions(t *testing.T, inputTFOptions *terraform.Options) *terraform.Options {
	return terraform.WithDefaultRetryableErrors(t, inputTFOptions)
}

func eksAddonValidation(t *testing.T, eksClusterName string, awsRegion string) {
	/****************************************************************************/
	/*EKS Cluster Result
	/****************************************************************************/
	result, err := internal.EksDescribeCluster(awsRegion, eksClusterName)
	if err != nil {
		t.Errorf("Error describing EKS Cluster: %v", err)
	}
	/****************************************************************************/
	/*K8s ClientSet
	/****************************************************************************/
	k8sclient, err := internal.GetKubernetesClient(result.Cluster)
	if err != nil {
		t.Errorf("Error creating Kubernees clientset: %v", err)
	}

	/****************************************************************************/
	/*TEST: Match Cluster Name
	/****************************************************************************/
	t.Run("MATCH_EKS_CLUSTER_NAME", func(t *testing.T) {
		assert.Equal(t, eksClusterName, aws.StringValue(result.Cluster.Name))
	})

	/****************************************************************************/
	/*Test: Validate Kubernetes Deployments
	/****************************************************************************/
	t.Run("EKS_DEPLOYMENTS_VALIDATION", func(t *testing.T) {
		for _, dep := range expectedDeployments {
			deployment, err := internal.GetDeployment(k8sclient, dep.Name, dep.Namespace)
			if err != nil {
				assert.Fail(t, "DEPLOYMENT: %s | NAMESPACE: %s | Error: %s", dep.Name, dep.Namespace, err)
			} else {
				t.Log("|-----------------------------------------------------------------------------------------------------------------------|")
				t.Logf("DEPLOYMENT: %s | NAMESPACE: %s | READY: %d | AVAILABLE: %d | REPLICAS: %d | UNAVAILABLE: %d",
					dep.Name, dep.Namespace,
					deployment.Status.ReadyReplicas,
					deployment.Status.AvailableReplicas,
					deployment.Status.Replicas,
					deployment.Status.UnavailableReplicas)
				t.Logf("|-----------------------------------------------------------------------------------------------------------------------|")
				t.Run("MATCH_REPLICAS_VS_READY-REPLICAS/"+dep.Name, func(t *testing.T) {
					assert.Equal(t, aws.Int32Value(deployment.Spec.Replicas), deployment.Status.ReadyReplicas)
				})
				t.Run("UNAVAILABLE_REPLICAS/"+dep.Name, func(t *testing.T) {
					assert.Equal(t, int32(0), deployment.Status.UnavailableReplicas)
				})
			}
		}
	})

	/****************************************************************************/
	/*Test: Validate Kubernetes Services
	/****************************************************************************/
	t.Run("EKS_SERVICES_VALIDATION", func(t *testing.T) {
		for _, service := range expectedServices {
			services, err := internal.GetServices(k8sclient, service.Name, service.Namespace)
			if err != nil {
				assert.Fail(t, "SERVICE NAME: %s | NAMESPACE: %s| Error: %s", service.Name, service.Namespace, err)
			} else {
				t.Log("|-----------------------------------------------------------------------------------------------------------------------|")
				t.Logf("SERVICE NAME: %s | NAMESPACE: %s | STATUS: %s",
					service.Name,
					service.Namespace,
					services.Spec.Type)
				t.Logf("|-----------------------------------------------------------------------------------------------------------------------|")
				t.Run("SERVICE_STATUS/"+service.Name, func(t *testing.T) {
					assert.Equal(t, services.Spec.Type, service.Type)
				})
			}
		}
	})

}
