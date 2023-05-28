//
//  Contractor.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation

@propertyWrapper
public struct Contractor<T> {
    private let keyPath: WritableKeyPath<Contractors, T>
    public var wrappedValue: T {
        get { Contractors[keyPath] }
        set { Contractors[keyPath] = newValue }
    }
    
    public init(_ keyPath: WritableKeyPath<Contractors, T>) {
        self.keyPath = keyPath
    }
}
