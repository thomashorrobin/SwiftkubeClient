//
// Copyright 2020 Swiftkube Project
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftkubeClient
import SwiftkubeModel
import XCTest

final class K3dNamespaceTests: K3dTestCase {

	override class func setUp() {
		super.setUp()

		// ensure clean state
		deleteNamespace("ns1")
		deleteNamespace("ns2")
		deleteNamespace("ns3")

		// create namespaces for tests
		createNamespace("ns1", labels: ["app": "nginx", "env": "dev"])
		createNamespace("ns2", labels: ["app": "nginx", "env": "qa"])
		createNamespace("ns3", labels: ["app": "swiftkube", "env": "prod"])
	}

	func testListByLabels_eq() async {
		let namespaces = try? await K3dTestCase.client.namespaces.list(options: [
			.labelSelector(.eq(["app": "nginx"]))
		])
		.map { $0.name }

		assertEqual(namespaces, ["ns1", "ns2"])
	}

	func testListByLabels_neq() async {
		let namespaces = try? await K3dTestCase.client.namespaces.list(options: [
			.labelSelector(.exists(["app"])),
			.labelSelector(.neq(["app": "nginx"]))
		])
		.map { $0.name }

		assertEqual(namespaces, ["ns3"])
	}

	func testListByLabels_exists() async {
		let namespaces = try? await K3dTestCase.client.namespaces.list(options: [
			.labelSelector(.exists(["app"]))
		])
		.map { $0.name }

		assertEqual(namespaces, ["ns1", "ns2", "ns3"])

		let empty = try? await K3dTestCase.client.namespaces.list(options: [
			.labelSelector(.exists(["foo"]))
		])
		.map { $0.name }

		assertEqual(empty, [])
	}

	func testListByLabels_in() async {
		let all = try? await K3dTestCase.client.namespaces.list(options: [
			.labelSelector(.in(["app": ["nginx", "swiftkube"]]))
		])
		.map { $0.name }

		assertEqual(all, ["ns1", "ns2", "ns3"])

		let sub = try? await K3dTestCase.client.namespaces.list(options: [
			.labelSelector(.in(["app": ["nginx"]]))
		])
		.map { $0.name }

		assertEqual(sub, ["ns1", "ns2"])
	}

	func testListByLabels_notIn() async {
		let namespaces = try? await K3dTestCase.client.namespaces.list(options: [
			.labelSelector(.exists(["app"])),
			.labelSelector(.notIn(["app": ["swiftkube"]]))
		])
		.map { $0.name }

		assertEqual(namespaces, ["ns1", "ns2"])
	}

	func testGetByName() async {
		let namespace = try? await K3dTestCase.client.namespaces.get(name: "ns2").name
		XCTAssertEqual(namespace, "ns2")
	}
}
