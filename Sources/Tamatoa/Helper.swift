//
//  Helper.swift
//
//
//  Created by Henrik Storch on 17/07/2025
//

import simd

/// Converts pitch, yaw, roll (in radians) to axis-angle rotation.
/// - Parameters:
///   - pitch: Rotation around X-axis (in radians)
///   - yaw: Rotation around Y-axis (in radians)
///   - roll: Rotation around Z-axis (in radians)
/// - Returns: A tuple containing the rotation axis (normalized) and angle (in radians)
func eulerToAxisAngle(pitch: Double, yaw: Double, roll: Double, scaling: AttitudeDampening) -> (axis: simd_double3, angle: Double) {
    // Create individual axis quaternions
    
    // Reference: https://developer.apple.com/documentation/coremotion/getting-processed-device-motion-data
    let qx = simd_quatd(angle: pitch * scaling.pitch, axis: simd_double3(1, 0, 0)) // pitch (x)
    let qy = simd_quatd(angle: roll * scaling.roll, axis: simd_double3(0, 1, 0)) // roll (y)
    let qz = simd_quatd(angle: yaw * scaling.yaw, axis: simd_double3(0, 0, 1)) // yaw (z)
    
    // Apply in Z → X → Y order: roll, then pitch, then yaw
    let q = qy * qx * qz

    // Convert quaternion to axis-angle
    let angle = 2 * acos(q.real)
    
    // Handle numerical precision issues when angle ~ 0
    let s = sqrt(1 - q.real * q.real)
    let axis: simd_double3
    if s < 0.001 {
        axis = simd_double3(1, 0, 0) // arbitrary default axis
    } else {
        axis = simd_normalize(q.imag)
    }
    
    return (axis, angle)
}

import CoreGraphics

extension CGRect {
    /// Returns the diagonal angle of the rectangle in radians.
    func diagonalAngle() -> CGFloat {
        atan2(width, height)
    }
}
