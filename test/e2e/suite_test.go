/*
Copyright 2017 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package e2e

import (
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	. "sigs.k8s.io/cri-tools/test/framework"
)

const registry = "gcr.io/k8s-staging-cri-tools/"

// TestE2E runs the created specs.
func TestE2E(t *testing.T) {
	t.Parallel()
	RegisterFailHandler(Fail)
	RunSpecs(t, "e2e")
}

var t *TestFramework

var _ = BeforeSuite(func() {
	t = NewTestFramework()
	t.Setup()
})

var _ = AfterSuite(func() {
	t.Teardown()
})
