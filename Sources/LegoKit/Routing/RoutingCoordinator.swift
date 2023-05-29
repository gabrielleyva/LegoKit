//
//  RoutingCoordinator.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/28/23.
//

import Foundation
import SwiftUI

final class RoutingCoordinator<R: Routes>: ObservableObject {
    
    // MARK: - Properties
    
    /// Route
    @Published public private(set) var route: R.Route
    
    // MARK: - Init
    
    public init(_ route: R.Route) {
        self.route = route
    }
    
    // MARK: Routiong
    
    public func route(to route: R.Route) {
        self.route = route
    }
}
