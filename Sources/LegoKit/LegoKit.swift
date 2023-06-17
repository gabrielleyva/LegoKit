public struct LegoKit {
    
    /// Empty `LegoKit` intializer.
    public init() {}
    
    /// Sets and stores the single unique `Router` instance.
    ///
    /// *Note: * Causes a `fatalError` if a `Router` instance already exists.
    ///
    /// - Parameter router: The `Router` to be stored and referenced.
    public static func router<R: Routing>(_ router: Router<R>) {
        RouterResolver.shared.store(router)
    }
}
