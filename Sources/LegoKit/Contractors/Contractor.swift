//
//  Contractor.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation

/// A `@propertyWrapper` used to access a `Service` via a `KeyPath`.
@propertyWrapper
public struct Contractor<T> {
    /// The desired key path to access the `Service`
    private let keyPath: WritableKeyPath<Contractors, T>
    
    /// The underlying `Service` of the property wrapper.
    public var wrappedValue: T {
        get { Contractors[keyPath] }
        set { Contractors[keyPath] = newValue }
    }
    
    /// Initialized the property wrapper with a key path on `Contractors`.
    /// - Parameter keyPath: The desired key path.
    public init(_ keyPath: WritableKeyPath<Contractors, T>) {
        self.keyPath = keyPath
    }
}
