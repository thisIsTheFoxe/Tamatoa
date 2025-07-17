//
//  Gradient.swift
//
//
//  Created by Henrik Storch on 17/07/2025
//

import SwiftUI

public extension Gradient {
    static let highlight = Gradient(colors: [
        .white.opacity(0.4),
        .white.opacity(0.2),
        .white.opacity(0.1),
        .white.opacity(0.08),
        .white.opacity(0)
    ])
    
    static let basicHighlight = Gradient(colors: [
        .white.opacity(0.4),
        .white.opacity(0.00)
    ])
}
