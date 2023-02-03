//go:build e2e
// +build e2e

package src

import (
	"context"
	internal "github.com/aws-ia/terraform-aws-eks-blueprints/aws"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	core "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"strings"
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
			"eks-cluster-with-new-vpc",
			"us-west-2",
			"aws-terra-test-eks",
			map[string]string{
				"rootFolder":        "../..",
				"exampleFolderPath": "examples/eks-cluster-with-new-vpc"},
		},
	}
	/* Commented for future use
	S3BackendConfig = map[string]string{
		"bucketName": "terraform-ssp-github-actions-state",
		"s3Prefix": "terratest/examples/",
		"awsRegion" : "us-west-2"}*/

	destroyModules = []string{
		"module.eks_blueprints_kubernetes_addons",
		"module.eks_blueprints",
		"module.vpc",
		"full_destroy",
	}

	/*Update the expected Output variables and values*/
	outputParameters = [...]Outputs{
		{"vpc_cidr", "10.0.0.0/16", "equal"},
		{"vpc_private_subnet_cidr", "[10.0.10.0/24 10.0.11.0/24 10.0.12.0/24]", "equal"},
		{"vpc_public_subnet_cidr", "[10.0.0.0/24 10.0.1.0/24 10.0.2.0/24]", "equal"},
		{"eks_cluster_id", "aws-terra-test-eks", "equal"},
		{"eks_managed_nodegroup_status", "[ACTIVE]", "equal"},
	}

	/*EKS API Validation*/
	expectedEKSWorkerNodes = 3

	/*Update the expected Deployments names and the namespace*/
	expectedDeployments = [...]Deployment{
		{"aws-load-balancer-controller", "kube-system"},
		{"cluster-autoscaler-aws-cluster-autoscaler", "kube-system"},
		{"coredns", "kube-system"},
		{"metrics-server", "kube-system"},
	}

	/*Update the expected DaemonSet names and the namespace*/
	expectedDaemonSets = [...]DaemonSet{
		{"aws-node", "kube-system"},
		{"kube-proxy", "kube-system"},
		{"aws-cloudwatch-metrics", "amazon-cloudwatch"},
	}

	/*Update the expected K8s Services names and the namespace*/
	expectedServices = [...]Services{
		{"cluster-autoscaler-aws-cluster-autoscaler", "kube-system", "ClusterIP"},
		{"kube-dns", "kube-system", "ClusterIP"},
		{"kubernetes", "default", "ClusterIP"},
		{"metrics-server", "kube-system", "ClusterIP"},
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
				// VarFiles:     []string{testCase.name + ".tfvars"}, // The var file paths to pass to Terraform commands using -var-file option.
				//BackendConfig: map[string]interface{}{
				//	"bucket": S3BackendConfig["bucketName"],
				//	"key":    S3BackendConfig["s3Prefix"]+testCase.name,
				//	"region": S3BackendConfig["awsRegion"],
				//},
				NoColor: true,
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
							// VarFiles:     []string{testCase.name + ".tfvars"}, // The var file paths to pass to Terraform commands using -var-file option.
							//BackendConfig: map[string]interface{}{
							//	"bucket": S3BackendConfig["bucketName"],
							//	"key":    S3BackendConfig["s3Prefix"]+testCase.name,
							//	"region": S3BackendConfig["awsRegion"],
							//},
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

			t.Run("TF_OUTPUTS_VALIDATION", func(t *testing.T) {
				/*Outputs Validation*/
				test_structure.RunTestStage(t, "outputs_validation", func() {
					terraformOptions := test_structure.LoadTerraformOptions(t, tempExampleFolder)
					for _, tc := range outputParameters {
						t.Run(tc.OutputVariable, func(t *testing.T) {
							ActualOutputValue := terraform.Output(t, terraformOptions, tc.OutputVariable)
							switch strings.ToLower(tc.AssertType) {
							case "equal":
								assert.Equal(t, tc.ExpectedOutputValue, ActualOutputValue)
							case "notempty":
								assert.NotEmpty(t, ActualOutputValue)
							case "contains":
								assert.Contains(t, ActualOutputValue, tc.ExpectedOutputValue)
							}
						})
					}
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
	/*TEST: Verify the total number of nodes running
	/****************************************************************************/
	nodes, err := k8sclient.CoreV1().Nodes().List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		t.Errorf("Error getting EKS nodes: %v", err)
	}
	t.Run("MATCH_TOTAL_EKS_WORKER_NODES", func(t *testing.T) {
		assert.Equal(t, expectedEKSWorkerNodes, len(nodes.Items))
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
	/*Test: Validate Kubernetes DaemonSets
	/****************************************************************************/
	t.Run("EKS_DAEMONSETS_VALIDATION", func(t *testing.T) {
		for _, daemon := range expectedDaemonSets {
			daemonset, err := internal.GetDaemonSet(k8sclient, daemon.Name, daemon.Namespace)
			if err != nil {
				assert.Fail(t, "DaemonSet: %s | NAMESPACE: %s| Error: %s", daemon.Name, daemon.Namespace, err)
			} else {
				t.Log("|-----------------------------------------------------------------------------------------------------------------------|")
				t.Logf("DaemonSet: %s | NAMESPACE: %s | DESIRED: %d | CURRENT: %d | READY: %d  AVAILABLE: %d | UNAVAILABLE: %d",
					daemon.Name,
					daemon.Namespace,
					daemonset.Status.DesiredNumberScheduled,
					daemonset.Status.CurrentNumberScheduled,
					daemonset.Status.NumberReady,
					daemonset.Status.NumberAvailable,
					daemonset.Status.NumberUnavailable)
				t.Logf("|-----------------------------------------------------------------------------------------------------------------------|")
				t.Run("MATCH_DESIRED_VS_CURRENT_PODS/"+daemon.Name, func(t *testing.T) {
					assert.Equal(t, daemonset.Status.DesiredNumberScheduled, daemonset.Status.CurrentNumberScheduled)
				})
				t.Run("UNAVAILABLE_REPLICAS/"+daemon.Name, func(t *testing.T) {
					assert.Equal(t, int32(0), daemonset.Status.NumberUnavailable)
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
