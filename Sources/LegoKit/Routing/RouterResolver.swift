//
//  File.swift
//  
//
//  Created by Gabriel Leyva Merino on 6/16/23.
//

import Foundation

final internal class RouterResolver {
    
    // MARK: - Properties
    
    /// The current `Router`.
    private var router: AnyObject?
    
    /// Singleton that holds a unique `Router` instance.
    static public let shared = RouterResolver()
    
    // MARK: - Init
    
    private init() {}
    
    /// Stores a single unique `Router` instance.
    ///
    /// *Note: * Causes a `fatalError` if a `Router` instance already exists.
    ///
    /// - Parameter router: The `Router` to be stored and referenced.
    public func store<R: Routing>(_ router: Router<R>) {
        guard self.router == nil else {
            fatalError("The Router instance already exists.")
        }
        self.router = router
    }
    
    /// Updates the unique `Router` instance with a new one.
    ///
    /// - Parameter router: The new `Router` used to update the existing `Router`instance.
    public func update<R: Routing>(_ router: Router<R>) -> Router<R> {
        self.router = router
        guard let newRouter = self.router as? Router<R> else {
            fatalError("En error occured while attempting to update the Router instance.")
        }
        return newRouter
    }

    /// Resolves the existing `Router` instance to be used.
    ///
    /// *Note: * Causes a `fatalError` if a `Router` instance does not exists.
    ///
    /// - Returns: A unique `Router` instance.
    public func resolve<R: Routing>() -> Router<R> {
        guard let router = self.router as? Router<R> else {
            fatalError("The Router instance has not been added.")
        }
        return router
    }
}
