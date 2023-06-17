//
//  Adaptor.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation
import Combine

/// A class that is represented by a `Blueprint` in order to handle asynchronous calls from any given`@Contractor`.
open class Adaptor<B: Blueprint> {
    // MARK: - Init
    
    /// Base initializer.
    public init () {}
    
    // MARK: - Connect
    
    /// Publishes a new `Change` based on the completion of asynchronous work that was triggered by a `Change` requiring a `Contractor`.
    ///
    /// Override the function in a custom subclass that inherits from `Adaptor` represented by a `Blueprint`.
    ///
    /// Exmaple:
    /// ```swift
    /// public class PermissionsAdaptor: Adaptor<AppBlueprint> {
    ///
    ///    @Contractor(\.permissions) private var permissionsService: PermissionsService
    ///
    ///    public override func connect(_ design: AppBlueprint.Design, on change: AppBlueprint.Change) -> AnyPublisher<AppBlueprint.Change, Never> {
    ///        return Future<AppBlueprint.Change, Never> { promise in
    ///           switch change {
    ///           case .requestCameraAccess:
    ///               Task {
    ///                  let cameraPermission = await self.permissionsService.requestCameraAccess()
    ///                  promise(.success(.cameraAccessRequestCompleted(cameraPermission)))
    ///               }
    ///           }
    ///       }
    ///       .eraseToAnyPublisher()
    ///    }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///  - design: The current `Design`.
    ///  - change: The desired `Change`.
    /// - Returns: A publisher with a new `Change`.
    open func connect(_ design: B.Design, on change: B.Change) -> AnyPublisher<B.Change, Never> {
        return Future<B.Change, Never> { _ in }
        .eraseToAnyPublisher()
    }
}
