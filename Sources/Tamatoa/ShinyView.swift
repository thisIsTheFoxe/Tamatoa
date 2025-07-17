//
//  ShinyView.swift
//
//
//  Created by Henrik Storch on 17/07/2025
//

import SwiftUI
import CoreMotion

public typealias AttitudeDampening = (pitch: CGFloat, yaw: CGFloat, roll: CGFloat)

public extension View {
    
    /// Applies a shiny, interactive card effect to the view using device motion and a customizable highlight surface.
    ///
    /// This modifier adds a reflective highlight and optional 3D tilt effect, making the view appear as a glossy, interactive card.
    /// Device motion (pitch, yaw, and roll) is used to animate the highlight and 3D rotation, which can be dampened for a subtler effect.
    ///
    /// - Parameters:
    ///   - surface: The `Gradient` used as the shiny highlight surface. Defaults to `.highlight`.
    ///   - has3DEffect: Boolean determining whether a 3D tilt effect is applied. Defaults to `true`.
    ///   - contentMode: The `ContentMode` used to fit or fill the highlight surface. Defaults to `.fit`.
    ///   - dampening: A tuple specifying how much to reduce the effect of each attitude axis `(pitch, yaw, roll)`. Values between 0 and 1.
    ///                Lower values produce a more pronounced response, while higher values dampen the effect.
    ///                Defaults to `(0.9, 1.0, 0.0)`.
    ///
    /// - Note: The `MotionManager` must be actively updating motion data for this effect to work. Ensure that `startDeviceMotionUpdates()` is called appropriately in your app.
    ///
    /// - Returns: A view with a shiny, interactive, card-like appearance that responds to device motion.
    @ViewBuilder
    func shinyCard(_ surface: Gradient = .highlight,
                   has3DEffect: Bool = true,
                   contentMode: ContentMode = .fit,
                   dampening: AttitudeDampening = (0.9, 1.0, 0.0)) -> some View {
        modifier(ShinyCardModifier(surface: surface,
                                   has3DEffect: has3DEffect,
                                   contentMode: contentMode,
                                   attitudeScaling: (1 - dampening.pitch,
                                                     1 - dampening.yaw,
                                                     1 - dampening.roll)))
        .environmentObject(MotionManager.main)
    }
}

struct ShinyCardModifier: ViewModifier {
    @EnvironmentObject var model: MotionManager
    
    let surface: Gradient
    let has3DEffect: Bool
    let contentMode: ContentMode
    let attitudeScaling: AttitudeDampening
    
    func position(in rect: CGRect) -> CGSize {
        let x = 0 - (CGFloat(model.roll) / .pi * 4) * rect.height
        let y = 0 - (CGFloat(model.userDevicePitch) / .pi * 4) * rect.height
        return CGSize(width: x, height: y)
    }
    
    func scale(_ proxy: GeometryProxy) -> CGSize {
        if proxy.size.width > proxy.size.height {
            CGSize(width: proxy.size.width / proxy.size.height,
                   height: 1)
        } else {
            CGSize(width: 1,
                   height: proxy.size.height / proxy.size.width)
        }
    }
    
    func radius(_ rect: CGRect) -> CGFloat {
        contentMode == .fill ? max(rect.width / 2, rect.height / 2) : min(rect.width / 2, rect.height / 2)
    }
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let localFrame = proxy.frame(in: .local)
            let (axis, angle) = eulerToAxisAngle(pitch: model.userDevicePitch,
                                                 yaw: model.yaw,
                                                 roll: model.roll,
                                                 scaling: attitudeScaling)
            content
                .position(x: localFrame.midX, y: localFrame.midY)
                .overlay {
                    RadialGradient(
                        gradient: surface,
                        center: .center,
                        startRadius: 1,
                        endRadius: radius(localFrame))
                    .scaleEffect(scale(proxy))
                    .rotationEffect(.radians(localFrame.diagonalAngle()))
                    .offset(position(in: localFrame))
                    .mask(content)
                }
                .rotation3DEffect(.radians(Double(angle * 0.4)),
                                  axis: (x: axis.x, y: axis.y, z: axis.z))
                .animation(.linear(duration: 0.1), value: model.totalRotation)
        }
    }
}

