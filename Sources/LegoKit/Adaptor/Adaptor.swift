//
//  Adaptor.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation
import Combine

open class Adaptor<B: Blueprint> {
    public init () {}
    open func connect(_ design: B.Design, on change: B.Change) -> AnyPublisher<B.Change, Never> {
        return Future<B.Change, Never> { _ in }
        .eraseToAnyPublisher()
    }
}
