//
//  Lego.swift
//  
//
//  Created by Gabriel Leyva Merino on 5/27/23.
//

import Foundation
import SwiftUI
import Combine

public final class Lego<B: Blueprint>: ObservableObject {
    
    // MARK: - Properties
    
    /// Design
    @Published private(set) var design: B.Design
    
    /// Blueprint
    private let blueprint: B
    
    /// Adaptors
    private let adaptors: [Adaptor<B>]
    
    /// Adaptor Cancellables
    private var adaptorsCancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    /// Lego Cancellables
    private var legoCancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    /// Logs
    private let isLoggingEnabled: Bool
    
    // MARK: - Init
    
    init(_ design: B.Design, blueprint: B,
         adaptors: [Adaptor<B>] = [],
         enableLogs: Bool = false) {
        self.design = design
        self.blueprint = blueprint
        self.adaptors = adaptors
        self.isLoggingEnabled = enableLogs
    }
    
    // MARK: - Build
    
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
    
    public func glue<Value>(_ keyPath: KeyPath<B.Design, Value>, change: @escaping (Value) -> B.Change) -> Binding<Value> {
        Binding<Value>(
            get: { self.design[keyPath: keyPath] },
            set: { self.build(change($0)) }
        )
    }
    
    // MARK: - Design Change Subscribe Management
    
    public func onDesignChange(completion: @escaping (B.Design) -> Void) {
        self.$design.sink { design in
            completion(design)
        }
        .store(in: &legoCancellables)
    }
    
    public func dispose() {
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

// MARK: - Mirror Extension

internal extension Mirror {
    func prettyString(_ space: String = "") -> String {
        var string = ""
        for child in children {
            let mirror = Mirror(reflecting: child.value)
            if mirror.children.count > 0 {
                string.write("\(space)▼ \(child.label ?? ""):\n")
                string.write("\(mirror.prettyString(space + "   "))")
            } else {
                string.write("\(space)○ \(child.label ?? ""): \(child.value)\n")
            }
        }
        return string
    }
}
