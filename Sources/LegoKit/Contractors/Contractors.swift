//
//  Contractors.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation

/// Provides access to injected `Contractors`.
public struct Contractors {
    /// This used as an accessor to the computed properties within extensions of `Contractors`.
    private static var current = Contractors()

    /// A static subscript for updating the value of `Blueprint` instances.
    static subscript<K>(key: K.Type) -> K.Value where K : Service {
        get { key.contractor }
        set { key.contractor = newValue }
    }

    /// A static subscript accessor for updating and referencing `Contractors` directly.
    static subscript<T>(_ keyPath: WritableKeyPath<Contractors, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}
