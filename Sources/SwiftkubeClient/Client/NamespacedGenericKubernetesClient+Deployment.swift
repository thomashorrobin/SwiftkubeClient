//
//  File.swift
//  
//
//  Created by Thomas Horrobin on 19/08/2022.
//

import AsyncHTTPClient
import NIO
import SwiftkubeModel

public extension NamespacedGenericKubernetesClient where Resource == apps.v1.Deployment {
	
	func restartDeployment(
		in namespace: NamespaceSelector,
		name: String) async throws -> Resource {
			return try await super.restartDeployment(in: namespace, name: name)
	}
}
