//
//  File 2.swift
//  
//
//  Created by Gabriel Leyva Merino on 6/16/23.
//

import Foundation
import SwiftUI

/// A `@propertyWrapper` used to access the unique `Router` instance as an `@ObservableObject`.
/// *Note: * It does not update the underlying `Router` instance. Only emits changes via an `@ObservedObject` .
@propertyWrapper
public struct ObservedRoutes<R: Routing>: DynamicProperty {
    /// The observed `Router`.
    @ObservedObject private var value: Router<R>
    
    /// The underlying `Router` value of the property wrapper.
    public var wrappedValue: Router<R> {
        value
    }

    /// Initializes the property wrapper by resolving the unique `Router` instance.
    public init() {
        value = RouterResolver.shared.resolve()
    }
}
