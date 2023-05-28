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

public struct MainBlueprint: Blueprint {
        
    public struct Design: Equatable {
        var house: HouseBlueprint.Design
    }
    public enum Change: Equatable {
        case house(HouseBlueprint.Change)
    }
    public func change(_ design: inout Design, on change: Change) {}
}

public struct HouseBlueprint: Blueprint {
    @Brick (\.house) var house
    public static var brick: HouseBlueprint = HouseBlueprint()
    public struct Design: Equatable {}
    public enum Change: Equatable {}
    public func change(_ design: inout Design, on change: Change) {}
}

extension Bricks {
    var house: HouseBlueprint {
        get { Self[HouseBlueprint.Value.self] }
        set { Self[HouseBlueprint.Value.self] = newValue }
    }
}
