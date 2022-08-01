package tests

import (
	"fmt"
	"io/ioutil"
	"path/filepath"
	"strings"
	"testing"

	"github.com/ghodss/yaml"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"sigs.k8s.io/kustomize/v3/k8sdeps/kunstruct"
	"sigs.k8s.io/kustomize/v3/k8sdeps/transformer"
	"sigs.k8s.io/kustomize/v3/pkg/fs"
	"sigs.k8s.io/kustomize/v3/pkg/loader"
	"sigs.k8s.io/kustomize/v3/pkg/plugins"
	"sigs.k8s.io/kustomize/v3/pkg/resmap"
	"sigs.k8s.io/kustomize/v3/pkg/resource"
	"sigs.k8s.io/kustomize/v3/pkg/target"
	"sigs.k8s.io/kustomize/v3/pkg/validators"
)

type KustomizeTestCase struct {
	// Package is the path to the kustomize directory to run kustomize in
	Package string
	// Expected is a path to a directory containing the expected resources
	Expected string
}

// RunTestCase runs the specified test case
func RunTestCase(t *testing.T, testCase *KustomizeTestCase) {
	expected := map[string]*expectedResource{}

	// Read all the YAML files containing expected resources and parse them.
	files, err := ioutil.ReadDir(testCase.Expected)
	if err != nil {
		t.Fatal(err)
	}

	for _, f := range files {
		contents, err := ioutil.ReadFile(filepath.Join(testCase.Expected, f.Name()))
		if err != nil {
			t.Fatalf("Err: %v", err)
		}

		u := &unstructured.Unstructured{}
		if err := yaml.Unmarshal([]byte(contents), u); err != nil {
			t.Fatalf("Error: %v", err)
		}

		r := &expectedResource{
			fileName: f.Name(),
			yaml:     string(contents),
			u:        u,
		}

		expected[r.Key()] = r
	}

	fsys := fs.MakeRealFS()
	// We don't want to enforce the security check.
	// This is equivalent to running:
	// kustomize build --load_restrictor none
	lrc := loader.RestrictionNone

	_loader, loaderErr := loader.NewLoader(lrc, validators.MakeFakeValidator(), testCase.Package, fsys)
	fmt.Println(testCase.Package)
	if loaderErr != nil {
		t.Fatalf("could not load kustomize loader: %v", loaderErr)
	}
	rf := resmap.NewFactory(resource.NewFactory(kunstruct.NewKunstructuredFactoryImpl()), transformer.NewFactoryImpl())
	pc := plugins.DefaultPluginConfig()
	kt, err := target.NewKustTarget(_loader, rf, transformer.NewFactoryImpl(), plugins.NewLoader(pc, rf))
	if err != nil {
		t.Fatalf("Unexpected construction error %v", err)
	}
	actual, err := kt.MakeCustomizedResMap()
	if err != nil {
		t.Fatalf("Err: %v", err)
	}

	actualNames := map[string]bool{}

	// Check that all the actual resources match the expected resources
	for _, r := range actual.Resources() {
		rKey := key(r.GetKind(), r.GetName())
		actualNames[rKey] = true

		e, ok := expected[rKey]

		if !ok {
			t.Errorf("Actual output included an unexpected resource; resource: %v", rKey)
			continue
		}

		actualYaml, err := r.AsYAML()

		if err != nil {
			t.Errorf("Could not generate YAML for resource: %v; error: %v", rKey, err)
			continue
		}
		// Ensure the actual YAML matches.
		if string(actualYaml) != e.yaml {
			ReportDiffAndFail(t, actualYaml, e.yaml)
		}
	}

	// Make sure we aren't missing any expected resources
	for name, _ := range expected {
		if _, ok := actualNames[name]; !ok {
			t.Errorf("Actual resources is missing expected resource: %v", name)
		}
	}

}

func convertToArray(x string) ([]string, int) {
	a := strings.Split(strings.TrimSuffix(x, "\n"), "\n")
	maxLen := 0
	for i, v := range a {
		z := tabToSpace(v)
		if len(z) > maxLen {
			maxLen = len(z)
		}
		a[i] = z
	}
	return a, maxLen
}

// expectedResource represents an expected Kubernetes resource to be generated
// from the kustomize package.
type expectedResource struct {
	fileName string
	yaml     string
	u        *unstructured.Unstructured
}

// key generates a name to index resources by. It is used to match expected and actual resources.
func key(kind string, name string) string {
	return kind + "." + name
}

// Key returns a unique identifier fo this resource that can be used to index it
func (r *expectedResource) Key() string {
	if r.u == nil {
		return ""
	}

	return key(r.u.GetKind(), r.u.GetName())
}

// Pretty printing of file differences.
func ReportDiffAndFail(t *testing.T, actual []byte, expected string) {
	sE, maxLen := convertToArray(expected)
	sA, _ := convertToArray(string(actual))
	fmt.Println("===== ACTUAL BEGIN ========================================")
	fmt.Print(string(actual))
	fmt.Println("===== ACTUAL END ==========================================")
	format := fmt.Sprintf("%%s  %%-%ds %%s\n", maxLen+4)
	limit := 0
	if len(sE) < len(sA) {
		limit = len(sE)
	} else {
		limit = len(sA)
	}
	fmt.Printf(format, " ", "EXPECTED", "ACTUAL")
	fmt.Printf(format, " ", "--------", "------")
	for i := 0; i < limit; i++ {
		fmt.Printf(format, hint(sE[i], sA[i]), sE[i], sA[i])
	}
	if len(sE) < len(sA) {
		for i := len(sE); i < len(sA); i++ {
			fmt.Printf(format, "X", "", sA[i])
		}
	} else {
		for i := len(sA); i < len(sE); i++ {
			fmt.Printf(format, "X", sE[i], "")
		}
	}
	t.Fatalf("Expected not equal to actual")
}

func tabToSpace(input string) string {
	var result []string
	for _, i := range input {
		if i == 9 {
			result = append(result, "  ")
		} else {
			result = append(result, string(i))
		}
	}
	return strings.Join(result, "")
}

func hint(a, b string) string {
	if a == b {
		return " "
	}
	return "X"
}
