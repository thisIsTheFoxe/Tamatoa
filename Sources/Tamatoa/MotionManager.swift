//
//  MotionManager.swift
//
//
//  Created by Henrik Storch on 17/07/2025
//

import SwiftUI
import CoreMotion

public class MotionManager: ObservableObject {
    @Published public private(set) var yaw: CGFloat = 0
    @Published public private(set) var pitch: CGFloat = 0
    @Published public private(set) var roll: CGFloat = 0
    
    var totalRotation: CGFloat {
        roll + yaw + pitch
    }
    
    public var userDevicePitch: CGFloat {
        pitch + defaultUserDeviceAngle.radians
    }
    
    public var isTrackingMotion: Bool {
        motionInput.isDeviceMotionActive
    }
    
    /// The default angle for the user's device orientation, used to calibrate or offset the device's pitch measurement.
    ///
    /// This value is typically set to match the most common resting or ergonomic usage angle, allowing for more accurate
    /// interpretation of the user's device pitch. For example, a negative value assumes the device is tilted slightly toward
    /// the user by default, such as when holding a slightly phone upright.
    ///
    /// Adjust this value if your application assumes a different neutral device orientation.
    public var defaultUserDeviceAngle: Angle = Angle.degrees(-25)
    
    var motionInput = CMMotionManager()
    
    @MainActor static public let main = MotionManager()

    /// Sets the interval at which device motion updates are delivered to the motion manager.
    ///
    /// - Parameter interval: The time interval between each device motion update. A lower value results in more frequent motion data readings
    ///  but potentially higher power consumption.
    ///
    /// The default interval is set to 0.1 seconds.
    ///
    /// - Note: The actual delivery rate may be affected by system conditions, such as device performance limitations or power-saving modes.
    public func setMotionUpdateInterval(_ interval: TimeInterval) {
        motionInput.deviceMotionUpdateInterval = interval
    }
    
    public func startDeviceMotionUpdates() throws {
        guard !isTrackingMotion else {
            return
        }
        
        guard motionInput.isDeviceMotionAvailable else {
            throw NSError(domain: "MotionManagerError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Device motion is not available."])
        }
        
        guard let queue = OperationQueue.current else {
            throw NSError(domain: "MotionManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No current operation queue available."])
        }
        
        motionInput.startDeviceMotionUpdates(to: queue) { [weak self] _, _ in
            guard let self = self else { return }
            if let yaw = self.motionInput.yaw,
               let pitch = self.motionInput.pitch,
               let roll = self.motionInput.roll {
                self.yaw = CGFloat(yaw)
                self.pitch = CGFloat(pitch)
                self.roll = CGFloat(roll)
            }
        }
    }
    
    public func stopDeviceMotionUpdates() {
        if isTrackingMotion {
            motionInput.stopDeviceMotionUpdates()
            yaw = 0
            pitch = 0
            roll = 0
        }
    }
    
    private init() {
        motionInput.deviceMotionUpdateInterval = 0.1;
    }
}

internal extension CMMotionManager {
    var yaw: Double? {
        get { deviceMotion?.attitude.yaw }
    }
    
    var pitch: Double? {
        get { deviceMotion?.attitude.pitch }
    }
    
    var roll: Double? {
        get { deviceMotion?.attitude.roll }
    }
}
