package tests

import (
	"bytes"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/ghodss/yaml"
	"sigs.k8s.io/kustomize/kyaml/kio"
	kyaml "sigs.k8s.io/kustomize/kyaml/yaml"
	"sigs.k8s.io/kustomize/v3/pkg/types"
)

const (
	VersionLabel      = "app.kubernetes.io/version"
	InstanceLabel     = "app.kubernetes.io/instance"
	ManagedByLabel    = "app.kubernetes.io/managed-by"
	PartOfLabel       = "app.kubernetes.io/part-of"
	KustomizationFile = "kustomization.yaml"
)

// readKustomization will read a kustomization.yaml and return the kustomize object
func readKustomization(kfDefFile string) (*types.Kustomization, error) {
	data, err := ioutil.ReadFile(kfDefFile)
	if err != nil {
		return nil, err
	}
	def := &types.Kustomization{}
	if err = yaml.Unmarshal(data, def); err != nil {
		return nil, err
	}
	return def, nil
}

// TestCommonLabelsImmutable is a test to try to ensure we don't have mutable labels which will
// cause problems on upgrades per https://github.com/kubeflow/manifests/issues/1131.
func TestCommonLabelsImmutable(t *testing.T) {
	rootDir := ".."

	// Directories to exclude. Thee paths should be relative to rootDir.
	// Subdirectories won't be searched
	excludes := map[string]bool{
		"tests":   true,
		".git":    true,
		".github": true,
	}

	// These labels are likely to be mutable and should not be part of commonLabels
	// TODO(jlewi): In 1.0 and prior versions the convention was to use mutable values that contained the
	// version number. That was the original reason we made these forbidden labels; it was to stop people
	// from attaching mutable versions that would break upgrades. Post 1.1 we might want to start relaxing that
	// and allow applications to start using these labels but in an immutable fashion.
	forbiddenLabels := []string{VersionLabel, ManagedByLabel, InstanceLabel, PartOfLabel}

	err := filepath.Walk("..", func(path string, info os.FileInfo, err error) error {
		relPath, err := filepath.Rel(rootDir, path)

		if err != nil {
			t.Fatalf("Could not compute relative path(%v, %v); error: %v", rootDir, path, err)
		}

		if _, ok := excludes[relPath]; ok {
			t.Logf("Skipping directory %v", path)
			return filepath.SkipDir
		}

		// skip directories
		if info.IsDir() {
			return nil
		}

		if info.Name() != KustomizationFile {
			return nil
		}

		k, err := readKustomization(path)

		if err != nil {
			t.Errorf("Error reading file: %v; error: %v", path, err)
			return nil
		}

		if k.CommonLabels == nil {
			return nil
		}

		for _, l := range forbiddenLabels {
			if _, ok := k.CommonLabels[l]; ok {
				t.Errorf("%v has forbidden commonLabel %v", path, l)
			}
		}
		return nil
	})

	if err != nil {
		t.Errorf("error walking the path %v; error: %v", rootDir, err)
	}
}

// deprecatedK8s represents a K8s resource that should be replaced by a new type.
type deprecatedK8s struct {
	oldVersion string
	oldKind    string
	newVersion string
	newKind    string
}

func versionAndKind(version string, kind string) string {
	return version + "/" + kind
}

// TestValidK8sResources reads all the K8s resources and performs a bunch of validation checks.
//
// Currently the following checks are performed:
//  i) ensure we don't include status in resources
//     as this causes validation issues: https://github.com/kubeflow/manifests/issues/1174
//
//  ii) ensure that if annotations are present it is not empty.
//  Having empty annotations https://github.com/GoogleContainerTools/kpt/issues/541 causes problems for kpt and
//  ACM.  Offending YAML looks like
//      metadata:
// 		 name: kf-admin-iap
//       annotations:
//      rules:
//        ...
func TestValidK8sResources(t *testing.T) {
	rootDir := ".."

	// Directories to exclude. Thee paths should be relative to rootDir.
	// Subdirectories won't be searched
	excludes := map[string]bool{
		"tests":                  true,
		".git":                   true,
		".github":                true,
		"profiles/overlays/test": true,
		// Skip cnrm-install. We don't install this with ACM so we don't need to fix it.
		// It seems like if this is an issue it should eventually get fixed in upstream cnrm configs.
		// The CNRM directory has lots of CRDS with non empty status.
		"distributions/gcp/v2/management/cnrm-install": true,
	}

	deprecated := []deprecatedK8s{
		{
			oldVersion: "extensions/v1beta1",
			oldKind:    "Ingress",
			newVersion: "networking.k8s.io/v1beta1",
			newKind:    "Ingress",
		},
		{
			oldVersion: "extensions/v1beta1",
			oldKind:    "Deployment",
			newVersion: "apps/v1",
			newKind:    "Deployment",
		},
	}

	deprecatedMap := map[string]string{}

	for _, d := range deprecated {
		deprecatedMap[versionAndKind(d.oldVersion, d.oldKind)] = versionAndKind(d.newVersion, d.newKind)
	}

	err := filepath.Walk("..", func(path string, info os.FileInfo, err error) error {
		relPath, err := filepath.Rel(rootDir, path)

		if err != nil {
			t.Fatalf("Could not compute relative path(%v, %v); error: %v", rootDir, path, err)
		}

		if _, ok := excludes[relPath]; ok {
			return filepath.SkipDir
		}

		// skip directories
		if info.IsDir() {
			return nil
		}

		// Skip non YAML files
		ext := filepath.Ext(info.Name())

		if ext != ".yaml" && ext != ".yml" {
			return nil
		}
		data, err := ioutil.ReadFile(path)

		if err != nil {
			t.Errorf("Error reading %v; error: %v", path, err)
		}

		input := bytes.NewReader(data)
		reader := kio.ByteReader{
			Reader: input,
			// We need to disable adding reader annotations because
			// we want to run some checks about whether annotations are set and
			// adding those annotations interferes with that.
			OmitReaderAnnotations: true,
		}

		nodes, err := reader.Read()

		if err != nil {
			t.Errorf("Error unmarshaling %v; error: %v", path, err)
		}

		for _, n := range nodes {
			//root := n

			m, err := n.GetMeta()
			// Skip objects with no metadata
			if err != nil {
				continue
			}

			// Skip Kustomization
			if strings.ToLower(m.Kind) == "kustomization" {
				continue
			}
			if m.Name == "" || m.Kind == "" {
				continue
			}

			// Check if its a deprecated K8s resource
			vAndK := versionAndKind(m.APIVersion, m.Kind)
			if v, ok := deprecatedMap[vAndK]; ok {
				t.Errorf("Path %v; resource %v; has version and kind %v which should be changed to %v", path, m.Name, vAndK, v)
			}

			// Ensure status isn't set
			f := n.Field("status")

			if !kyaml.IsFieldEmpty(f) {
				t.Errorf("Path %v; resource %v; has status field", path, m.Name)
			}

			metadata := n.Field("metadata")

			checkEmptyAnnotations := func() {
				annotations := metadata.Value.Field("annotations")

				if annotations == nil {
					return
				}

				if kyaml.IsFieldEmpty(annotations) {
					t.Errorf("Path %v; resource %v; has empty annotations; if no annotations are present the field shouldn't be present", path, m.Name)
					return
				}
			}

			checkEmptyAnnotations()
		}
		return nil
	})

	if err != nil {
		t.Errorf("error walking the path %v; error: %v", rootDir, err)
	}
}

// TestCheckWebhookSelector is a test to try to ensure all the mutating webhooks
// have either namespaceSeletor or objectSelector to avoid issues per
// https://github.com/kubeflow/manifests/issues/1213.
func TestCheckWebhookSelector(t *testing.T) {
	rootDir := ".."

	// Directories to exclude. Thee paths should be relative to rootDir.
	// Subdirectories won't be searched
	excludes := map[string]bool{
		"tests":   true,
		".git":    true,
		".github": true,
	}

	err := filepath.Walk("..", func(path string, info os.FileInfo, err error) error {
		relPath, err := filepath.Rel(rootDir, path)

		if err != nil {
			t.Fatalf("Could not compute relative path(%v, %v); error: %v", rootDir, path, err)
		}

		if _, ok := excludes[relPath]; ok {
			return filepath.SkipDir
		}

		// skip directories
		if info.IsDir() {
			return nil
		}

		// Skip non YAML files
		ext := filepath.Ext(info.Name())

		if ext != ".yaml" && ext != ".yml" {
			return nil
		}
		data, err := ioutil.ReadFile(path)

		if err != nil {
			t.Errorf("Error reading %v; error: %v", path, err)
		}

		input := bytes.NewReader(data)
		reader := kio.ByteReader{
			Reader: input,
		}

		nodes, err := reader.Read()

		if err != nil {
			if strings.Contains(err.Error(), "wrong Node Kind for") {
				t.Logf("Skipping non SequenceNode yaml %v", path)
				return nil
			}
			t.Errorf("Error unmarshaling %v; error: %v", path, err)
		}

		for _, n := range nodes {
			//root := n

			m, err := n.GetMeta()
			// Skip objects with no metadata
			if err != nil {
				continue
			}

			// Skip objects with no name or kind
			if m.Name == "" || m.Kind == "" {
				continue
			}

			// Skip non-mutating webhook files
			if strings.ToLower(m.Kind) != "mutatingwebhookconfiguration" {
				continue
			}

			// Ensure objectSelector or namespaceSelector is set for pod resource
			if webhooks := n.Field("webhooks"); webhooks != nil {
				webhookElements, err := webhooks.Value.Elements()
				// Skip webhooks with no element
				if err != nil {
					continue
				}
				for _, w := range webhookElements {
					if kyaml.IsFieldEmpty(w.Field("namespaceSelector")) && kyaml.IsFieldEmpty(w.Field("objectSelector")) {
						// If there's no objectSelector or namespaceSelector, make sure the mutating webhook doesn't
						// have any rule for pods.
						if rules := w.Field("rules"); rules != nil {
							ruleElements, err := rules.Value.Elements()
							if err != nil {
								continue
							}
							for _, rule := range ruleElements {
								if resources := rule.Field("resources"); resources != nil {
									resourceElements, err := resources.Value.Elements()
									if err != nil {
										continue
									}
									for _, resource := range resourceElements {
										resourceString, err := resource.String()
										if err != nil {
											continue
										}
										if strings.TrimSpace(resourceString) == "pods" || strings.TrimSpace(resourceString) == "*" {
											t.Errorf("Path %v; resource %v; does not have objectSelector or namespaceSelector is for mutating webhook on pods", path, m.Name)
										}
									}
								}
							}
						}
					}
				}
			}
		}
		return nil
	})

	if err != nil {
		t.Errorf("error walking the path %v; error: %v", rootDir, err)
	}
}

// kustomizationHasDeprecatedEnv checks if the node has the depracted format of configmap generator
// see https://github.com/kubeflow/manifests/issues/538
func kustomizationHasDeprecatedEnv(t *testing.T, n *kyaml.RNode) bool {
	configMaps, err := n.Pipe(kyaml.Lookup("configMapGenerator"))
	if err != nil {
		s, _ := n.String()
		t.Errorf("%v: %s", err, s)
		return false
	}

	if configMaps == nil {
		// doesn't have any configmap generators, skip the Resource
		return false
	}

	// visit each container and apply the cpu and memory reservations

	hasDeprecated := false
	err = configMaps.VisitElements(func(cm *kyaml.RNode) error {
		// Ensure env field isn't set
		f := cm.Field("env")

		if !kyaml.IsFieldEmpty(f) {
			hasDeprecated = true
		}
		return nil
	})

	if err != nil {
		t.Errorf("Error chcecking if deprecated envs are set; error %v", err)
	}

	return hasDeprecated
}

// TestKustomizationHasDeprecatedEnv verifies that kustomizationHasDeprecatedEnv correctly
// detects obosolete kustomizations
func TestKustomizationHasDeprecatedEnv(t *testing.T) {
	type testCase struct {
		Raw      string
		Expected bool
	}

	testCases := []testCase{
		{
			Raw: `apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- cluster-role-binding.yaml
configMapGenerator:
- name: config-map
  env: somenev

`,
			Expected: true,
		},
		{
			Raw: `apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- cluster-role-binding.yaml
configMapGenerator:
- name: config-map
  envs:
   - params.env
`,
			Expected: false,
		},
	}

	for _, c := range testCases {
		n, err := kyaml.Parse(c.Raw)

		if err != nil {
			t.Errorf("Could not parse yaml:\n%v\nerror: %v", c.Raw, err)
			continue
		}

		actual := kustomizationHasDeprecatedEnv(t, n)

		if actual != c.Expected {
			t.Errorf("got %v; want %v; YAML\n:%v", actual, c.Expected, c.Raw)
		}
	}
}

// TestNoObsoleteKustomizations verifies that all kustomization files aren't using
// deprecated/obsolete features
func TestNoObsoleteKustomizations(t *testing.T) {
	rootDir := ".."

	// Directories to exclude. Thee paths should be relative to rootDir.
	// Subdirectories won't be searched
	excludes := map[string]bool{
		"tests":                  true,
		".git":                   true,
		".github":                true,
		"profiles/overlays/test": true,
		// Skip cnrm-install. We don't install this with ACM so we don't need to fix it.
		// It seems like if this is an issue it should eventually get fixed in upstream cnrm configs.
		// The CNRM directory has lots of CRDS with non empty status.
		"distributions/gcp/v2/management/cnrm-install": true,
	}

	err := filepath.Walk("..", func(path string, info os.FileInfo, err error) error {
		relPath, err := filepath.Rel(rootDir, path)

		if err != nil {
			t.Fatalf("Could not compute relative path(%v, %v); error: %v", rootDir, path, err)
		}

		if _, ok := excludes[relPath]; ok {
			return filepath.SkipDir
		}

		// skip directories
		if info.IsDir() {
			return nil
		}

		if strings.ToLower(info.Name()) != "kustomization.yaml" {
			return nil
		}

		data, err := ioutil.ReadFile(path)

		if err != nil {
			t.Errorf("Error reading %v; error: %v", path, err)
		}

		input := bytes.NewReader(data)
		reader := kio.ByteReader{
			Reader: input,
			// We need to disable adding reader annotations because
			// we want to run some checks about whether annotations are set and
			// adding those annotations interferes with that.
			OmitReaderAnnotations: true,
		}

		nodes, err := reader.Read()

		if err != nil {
			t.Errorf("Error unmarshaling %v; error: %v", path, err)
		}

		for _, n := range nodes {
			m, err := n.GetMeta()
			// Skip objects with no metadata
			if err != nil {
				continue
			}

			// Skip Kustomization
			if strings.ToLower(m.Kind) != "kustomization" {
				continue
			}

			hasDeprecated := kustomizationHasDeprecatedEnv(t, n)

			if hasDeprecated {
				t.Errorf("Kustomization %v is using obsolete syntax for configMapGenerate; you must use envs not env", path)
			}
		}
		return nil
	})

	if err != nil {
		t.Errorf("error walking the path %v; error: %v", rootDir, err)
	}
}
