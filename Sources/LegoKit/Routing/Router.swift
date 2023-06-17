//
//  File.swift
//  
//
//  Created by Gabriel Leyva Merino on 6/16/23.
//

import Foundation
import SwiftUI

/// The representation of  the `Router` that performs the `Routing` processes in order to render different views.
public final class Router<R: Routing>: ObservableObject {
    // MARK: - Properties
    
    /// The current `RouterState`.
    @Published public private(set) var state: R.State
    
    /// The `Routing` provider that processes routing requests on the `RouterState`.
    private let routing: R
    
    // MARK: - Init
    
    /// Initializes the `Router` with  a `RouterState` and a `Routing` based processor.
    ///
    /// - Parameters:
    ///  - state: The initial `RouterState`.
    ///  - routing: The `Routing` processor that handles how the `RouterState` updates.
    public init(_ state: R.State, routing: R) {
        self.state = state
        self.routing = routing
    }
    
    // MARK: - Routing
    
    /// Routes to a new `View` by updating the `RouterState` using a `Route`.
    ///
    /// - Parameter route: The `Route` used to update the `RouterState`.
    public func route(to route: R.Route) {
        DispatchQueue.main.async {
            self.routing.route(to: route, on: &self.state)
        }
    }
    
    // MARK: - Bindable Routing
    
    /// Creates a bindable routing process in which a property of `RouterState` can work with a `Binding` data type on a `View`
    /// by deriving a two-way binding that updates the `RouterState`.
    ///
    /// Because the `RouterState` is read-only, this binding function makes it possible to perform bindable routing updates on the `RouterState`.
    ///
    /// Example:
    /// ```swift
    /// struct State: RouterState {
    ///   enum Views {
    ///     case home
    ///   }
    ///   var view: Views = .home
    ///   var displaySheet: Bool = false
    /// }
    ///
    /// enum Route {
    ///   case home
    ///   case sheet(Bool)
    /// }
    ///
    /// .sheet(isPresented: router.routable(\.displaySheet, route: { Route.sheet($0)) }) {
    ///    Sheet()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///  - keyPath: The `KeyPath` used for a binding property in the `RouterState`.
    ///  - transform: An `@escaping` closure that transforms the binding value into a `Route`.
    /// - Returns: A `Binding` of the key path data type value.
    public func routable<Value>(_ keyPath: KeyPath<R.State, Value>,
                                route transform: @escaping (Value) -> R.Route) -> Binding<Value> {
        Binding<Value>(
            get: { self.state[keyPath: keyPath] },
            set: { self.route(to: transform($0)) }
        )
    }
    
    /// Creates a bindable routing process in which a property of `RouterState` can work with a `Binding` data type on a `View`
    /// by deriving a two-way binding that updates the `RouterState`.
    ///
    /// Because the `RouterState` is read-only, this binding function makes it possible to perform bindable routing updates on the `RouterState`.
    ///
    /// Example:
    /// ```swift
    /// struct State: RouteState {
    ///   enum Views {
    ///     case home
    ///   }
    ///   var view: Views = .home
    ///   var displaySheet: Bool = false
    /// }
    ///
    /// enum Routes {
    ///   case home
    ///   case dismissSheet
    /// }
    ///
    /// .sheet(isPresented: router.routable(\.displaySheet, route: Routes.dismissSheet)) {
    ///    Sheet()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///  - keyPath: The `KeyPath` used for a binding property in the `RouterState`.
    ///  - route: The `Route` used to update the `RouterState`.
    /// - Returns: A `Binding` of the key path data type value.
    public func routable<Value>(_ keyPath: KeyPath<R.State, Value>,
                                route: R.Route) -> Binding<Value> {
        routable(keyPath, route: { _ in route })
    }
    
    // MARK: - Deep Linking
    
    /// Routes to a new `View` by updating the `RouterState` using a `URL`.
    ///
    /// - Parameter url: The `URL` used to update the `RouterState`.
    public func onOpenURL(on url: URL) {
        DispatchQueue.main.async {
            self.routing.route(with: url, on: &self.state)
        }
    }
}
