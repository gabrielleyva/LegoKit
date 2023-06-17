//
//  Lego.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation
import SwiftUI
import Combine

/// The representation of a `Lego` that performs builds base on a `Change`, emits the updated `Design` and is responsible for connecting an `Adaptor` published change(s) to the `Blueprint`.
public final class Lego<B: Blueprint>: ObservableObject {
    // MARK: - Properties
    
    /// The current `Design`.
    @Published public private(set) var design: B.Design
    
    /// The `Blueprint`  that will  update the design.
    private let blueprint: B
    
    /// The adaptors that will publish change(s) in order to connect  asynchronous task(s) from a `@Contractor` to a `Blueprint`
    private let adaptors: [Adaptor<B>]
    
    /// The adaptors' cancellables.
    private var adaptorsCancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    /// The Lego's cancellables.
    private var legoCancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    /// A setting that determines wether or not to pretty print design changes.
    private let isLoggingEnabled: Bool
    
    // MARK: - Init
    
    /// Initializes the lego using a design, blueprint and adaptors.
    ///
    /// - Parameters:
    ///    - design: The initial `Design` for a view and blueprint.
    ///    - blueprint: The `Blueprint` that handles how the `Design` updates.
    ///    - adaptors: An `Adaptor` type  list  that will connect a `@Contractor` asynchronous work with the `Blueprint` to asynchronously update the `Design`.
    ///    - enableLogs: An optional setting that turns on or off logs for design changes.
    public init(_ design: B.Design,
                blueprint: B,
                adaptors: [Adaptor<B>] = [],
                enableLogs: Bool = false) {
        self.design = design
        self.blueprint = blueprint
        self.adaptors = adaptors
        self.isLoggingEnabled = enableLogs
    }
    
    // MARK: - Build
    
    /// Builds a new `Design` by updating the current `Design` with the desired `Change`.
    ///
    /// - Parameters:
    ///    - change: The `Change` used to update the `Design`.
    public func build(_ change: B.Change) {
        DispatchQueue.main.async {
            if self.isLoggingEnabled {
                let old = self.design
                self.blueprint.change(&self.design, on: change)
                self.log(old, self.design, for: change)
            } else {
                self.blueprint.change(&self.design, on: change)
            }
            
            for middleware in self.adaptors {
                middleware.connect(self.design, on: change)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: self.build)
                    .store(in: &self.adaptorsCancellables)
            }
        }
    }
    
    // MARK: - Glue
    
    /// Glues a property of the`Design` with a `Binding` data type on a `View`
    /// by deriving a two-way binding that updates the `Design` by performing a build based on a desired `Change`.
    ///
    /// Because the `Design` is  read-only, this binding function makes it possible to build bindable changes in a `Design`.
    ///
    /// Example:
    /// ```swift
    /// struct Design: Equatable {
    ///   var query: String = ""
    /// }
    ///
    /// enum Change: Equatable {
    ///   case search(String)
    /// }
    ///
    /// TextField("Search...",
    ///           text: lego.glue(\.query, build: { Change.search($0) }))
    /// ```
    ///
    /// - Parameters:
    ///  - keyPath: The `KeyPath` used for a binding property in the `Design`.
    ///  - transform: An `@escaping` closure that transforms the binding value into a `Change`.
    /// - Returns: A `Binding` of the key path data type value.
    public func glue<Value>(_ keyPath: KeyPath<B.Design, Value>,
                            build transform: @escaping (Value) -> B.Change) -> Binding<Value> {
        Binding<Value>(
            get: { self.design[keyPath: keyPath] },
            set: { self.build(transform($0)) }
        )
    }
    
    /// Glues a property of the`Design` with a `Binding` data type on a `View`
    /// by deriving a two-way binding that updates the `Design` by performing a build based on a desired `Change`.
    ///
    /// Because the `Design` is  read-only, this binding function makes it possible to build bindable changes in a `Design`.
    ///
    /// Example:
    /// ```swift
    /// struct Design: Equatable {
    ///   var displaySheet: Bool = false
    /// }
    ///
    /// enum Change: Equatable {
    ///   case dismiss
    /// }
    ///
    /// .sheet(isPresented: lego.glue(\.displaySheet, build: Change.dismiss)) {
    ///    Sheet()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///  - keyPath: The `KeyPath` used for a binding property in the `Design`.
    ///  - change: The `Change` used to update the `Design`.
    /// - Returns: A `Binding` of the key path data type value.
    public func glue<Value>(_ keyPath: KeyPath<B.Design, Value>,
                            build change: B.Change) -> Binding<Value> {
        glue(keyPath, build: { _ in change })
    }
    
    // MARK: - Design Change Subscribe Management
    
    /// Listens and detects any change made to the `Design`.
    ///
    /// A simple way to subscribe to a `Design` change outisde of a `View`.
    ///
    /// Example:
    /// ``` swift
    /// lego.onDesignChange { newDesign in
    ///  // Account for thread saftey depending on the use of the emitted design.
    /// }
    ///```
    ///
    /// - Returns: The updated `Design`.
    public func onDesignChange(completion: @escaping (B.Design) -> Void) {
        self.$design.sink { design in
            completion(design)
        }
        .store(in: &legoCancellables)
    }
    
    /// Disposes a `Lego` cancellable stored in the published changes of a `Design`.
    ///
    /// A simple way to unsubscribe from a `Design` change outisde of a `View`.
    ///
    /// Only needs to be called to manage cancellables if `onDesignChange` is being used.
    public func dispose() {
        guard !legoCancellables.isEmpty else { return }
        legoCancellables.removeFirst()
    }
    
    // MARK: - Logging
    
    private func log(_ oldDesign: B.Design, _ newDesign: B.Design, for change: B.Change) {
        let old = Mirror(reflecting: oldDesign)
        let new = Mirror(reflecting: newDesign)
        let change = Mirror(reflecting: change)
        var output = ""
        output.write("\nnununununununununununununununununununununununununununununununnunununununununununun\n")
        output.write("🚀 ACTION:")
        output.write("\n---------------------\n")
        output.write("\(old.prettyString())\n")
        output.write("⌛ OLD STATE")
        output.write("\n---------------------\n")
        output.write("\(new.prettyString())\n")
        output.write("👑 NEW STATE:")
        output.write("\n---------------------\n")
        output.write("\(change.prettyString())")
        output.write("nununununununununununununununununununununununununununununununnunununununununununun\n")
        print(output)
    }
}
