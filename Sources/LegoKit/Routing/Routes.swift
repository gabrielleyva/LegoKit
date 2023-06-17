//
//  File.swift
//  
//
//  Created by Gabriel Leyva Merino on 6/16/23.
//

import Foundation

/// A `@propertyWrapper` used to access and update the unique `Router` instance.
@propertyWrapper
public struct Routes<R: Routing> {
    private let value: Router<R>
    
    /// The underlying `Router` value of the property wrapper.
    public var wrappedValue: Router<R> {
        RouterResolver.shared.update(value)
    }

    /// Initializes the property wrapper by resolving the unique `Router` instance.
    public init() {
        value = RouterResolver.shared.resolve()
    }
}
