//
//  DependencyContainerKey.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import SwiftUI

/// Environment key for dependency injection
private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: DependencyContainer? = nil
}

extension EnvironmentValues {
    var dependencyContainer: DependencyContainer? {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

extension View {
    func dependencyContainer(_ container: DependencyContainer) -> some View {
        environment(\.dependencyContainer, container)
    }
}
