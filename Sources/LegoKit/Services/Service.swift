//
//  Service.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation

public protocol Service {
    associatedtype Value
    static var contractor: Self.Value { get set }
}



