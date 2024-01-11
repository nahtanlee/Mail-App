//
//  DesignAssets.swift
//  Mail
//
//  Created by Nathan Lee on 11/1/2024.
//

import SwiftUI

// Error shake animation for buttons
struct ShakeButton: GeometryEffect {
    var amount: CGFloat = 7
    var shakesPerUnit = 4
    var animatableData: CGFloat
    

    func effectValue(size: CGSize) -> ProjectionTransform {

        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))

    }
}

// Error shake animation for textfields
struct ShakeFields: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 4
    var animatableData: CGFloat
    

    func effectValue(size: CGSize) -> ProjectionTransform {

        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))

    }
}

// Text fields
extension Shape {
    func textFieldModifier(motion: MotionManager) -> some View {
        self
            .fill(.shadow(.inner(radius: 1, x: motion.x * 5, y: motion.y * 5)))
            .stroke(LinearGradient(colors: [.black, .white], startPoint: .top, endPoint: .bottom).opacity(0.3), lineWidth: 1)
            .foregroundStyle(.black.opacity(0.2))
    }
    
    func buttonModifier() -> some View {
        self
        
    }
    
    func windowEffectModifier() -> some View {
        self
    }
}

// 3D effect for windows
extension View {
    func windowEffectModifier(minWidth: CGFloat, minHeight: CGFloat, cornerRadius: CGFloat, motion: MotionManager) -> some View {
        self
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(AngularGradient(stops: [
                        Gradient.Stop(color: .white.opacity(0), location: 0),
                        Gradient.Stop(color: .white.opacity(0), location: 0.45),
                        Gradient.Stop(color: .white, location: 0.5),
                        Gradient.Stop(color: .white.opacity(0), location: 0.55),
                        Gradient.Stop(color: .white.opacity(0), location: 1),
                    ], center: UnitPoint(x: 0.5, y: 0.5), angle: Angle(degrees: motion.gradientAngle)), lineWidth: 2).opacity(0.6)
                    .frame(minWidth: minWidth, minHeight: minHeight)
            }
    }
}






