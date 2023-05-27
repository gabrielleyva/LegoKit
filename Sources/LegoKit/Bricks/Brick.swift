//
//  Brick.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation

@propertyWrapper
public struct Brick<T> {
    private let keyPath: WritableKeyPath<Bricks, T>
    public var wrappedValue: T {
        get { Bricks[keyPath] }
        set { Bricks[keyPath] = newValue }
    }
    
    public init(_ keyPath: WritableKeyPath<Bricks, T>) {
        self.keyPath = keyPath
    }
}
