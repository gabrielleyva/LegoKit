//
//  Bricks.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation

/// Provides access to injected `Bricks`.
public struct Bricks {
    /// This used as an accessor to the computed properties within extensions of `Bricks`.
    private static var current = Bricks()

    /// A static subscript for updating the value of `Blueprint` instances.
    static subscript<K>(key: K.Type) -> K.Value where K : Blueprint {
        get { key.brick }
        set { key.brick = newValue }
    }

    /// A static subscript accessor for updating and referencing `Bricks` directly.
    static subscript<T>(_ keyPath: WritableKeyPath<Bricks, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}
