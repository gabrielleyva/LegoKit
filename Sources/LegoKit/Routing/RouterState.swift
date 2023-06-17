//
//  Route.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/28/23.
//

import Foundation

/// A protocol defining the state in a`Router`.
public protocol RouterState {
    /// Defines all the renderable views.
    associatedtype Views
    
    /// The current rendered view.
    var view: Views { get set }
}
