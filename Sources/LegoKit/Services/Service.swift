//
//  Service.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation

/// A protocol used to define a `Service` that can be accessed through a `@Contractor` property wrapper via dependency injection.
public protocol Service {
    associatedtype Value
    
    /// The reference used to acces the `Service` via a `@Contractor` property wrapper.
    static var contractor: Self.Value { get set }
}



