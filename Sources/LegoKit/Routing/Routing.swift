//
//  File.swift
//  
//
//  Created by Gabriel Leyva Merino on 6/16/23.
//

import Foundation

/// A protocol defining how the routing process upates a`RouterState` using a `Route`.
public protocol Routing {
    /// Defines all the available routes.
    associatedtype Route
    
    /// The `RouterState`.
    associatedtype State: RouterState
    
    /// Routes to a new view using a `Route` that updates the `RouterState`.
    /// - Parameters:
    ///    - route: The `Route` used to update the `RouterState` in order to render a new view.
    ///    - state: The current `RouterState`.
    func route(to route: Route, on state: inout State)
    
    /// Routes to a new view using a `URL` that updates  the `RouterState`.
    /// - Parameters:
    ///    - url: The `URL` used to updated the `RouterState` in order to render a new view.
    ///    - state: The current `RouterState`.
    func route(with url: URL, on state: inout State)
}
