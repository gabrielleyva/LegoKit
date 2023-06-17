//
//  Brick.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation

/// A `@propertyWrapper` used to access a `Blueprint`  via a `KeyPath`.
@propertyWrapper
public struct Brick<T> {
    /// The desired key path to access the `Blueprint`
    private let keyPath: WritableKeyPath<Bricks, T>
    
    /// The underlying `Blueprint` of the property wrapper.
    public var wrappedValue: T {
        get { Bricks[keyPath] }
        set { Bricks[keyPath] = newValue }
    }
    
    /// Initialized the property wrapper with a key path on `Bricks`.
    /// - Parameter keyPath: The desired key path.
    public init(_ keyPath: WritableKeyPath<Bricks, T>) {
        self.keyPath = keyPath
    }
}
