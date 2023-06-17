//
//  Blueprint.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation

/// A protocol defining how a `Design` updates based on a `Change`.
public protocol Blueprint {
    associatedtype Design: Equatable
    associatedtype Change: Equatable
    associatedtype Value
    
    /// The reference used to acces the `Blueprint` via a `@Brick` property wrapper.
    static var brick: Self.Value { get set }
    
    /// Updates the `Design` based on a `Change`
    ///
    /// - Parameters:
    ///  - design: The current `Design`.
    ///  - change: The desired `Change`.
    func change(_ design: inout Design, on change: Change)
}

/// Allows the brick property to be optional when conforming to the `Blueprint` protocol.
public extension Blueprint where Value == Never {
    static var brick: Value {
        set (value) {}
        get { fatalError("") }
    }
}
