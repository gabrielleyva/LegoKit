//
//  File.swift
//  
//
//  Created by Gabriel Leyva Merino on 6/16/23.
//

import Foundation

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
