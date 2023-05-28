//
//  Blueprint.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation

public protocol Blueprint {
    associatedtype Design: Equatable
    associatedtype Change: Equatable
    associatedtype Value
    
    static var brick: Self.Value { get set }
    
    func change(_ design: inout Design, on change: Change)
}

public extension Blueprint where Value == Never {
    static var brick: Value {
        set (value) {}
        get { fatalError("") }
    }
}
