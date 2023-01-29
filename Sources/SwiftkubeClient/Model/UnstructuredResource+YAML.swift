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

import Foundation
import SwiftkubeModel
import Yams

public extension KubernetesAPIResource {

	static func load(contentsOf url: URL) throws -> Self {
		let data = try Data(contentsOf: url)
		let decoder = YAMLDecoder()
		return try decoder.decode(Self.self, from: data)
	}
}

public extension UnstructuredResource {

	static func load(yaml: String) throws -> [UnstructuredResource] {
		let decoder = YAMLDecoder()

		// YAMS's `load_all` return a sequence of `Any` and `compose_all` returns a sequence of `Node`
		// hence the compose -> serialize -> decode workaround
		// in order to get a list of type-erased `AnyKubernetesAPIResources`
		return try Yams.compose_all(yaml: yaml)
			.map { node -> UnstructuredResource in
				let resourceYAML = try Yams.serialize(node: node)
				return try decoder.decode(UnstructuredResource.self, from: resourceYAML)
			}
	}

	static func load(contentsOf url: URL) throws -> [UnstructuredResource] {
		let yaml = try String(contentsOf: url)
		return try load(yaml: yaml)
	}
}
