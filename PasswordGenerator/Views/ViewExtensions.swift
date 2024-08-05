//
//  ViewExtensions.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

// Extension to add custom functionality to all views
extension View {
    
    // Function to apply a continuous animation to a view
    func animateForever(using animation: Animation = Animation.easeInOut(duration: 1), autoreverses: Bool = false, _ action: @escaping () -> Void) -> some View {
        // Create an animation that repeats forever
        let repeated = animation.repeatForever(autoreverses: autoreverses)

        // Apply the animation when the view appears
        return onAppear {
            withAnimation(repeated) {
                action()
            }
        }
    }
    
    // Function to return an appropriate image name based on the biometric type
    func adaptativeImage(biometricType: SettingsViewModel.BiometricType) -> String {
        
        switch biometricType {
        case .none:
            return "key"  // Return "key" image for no biometric type
        case .touch:
            return "touchid"  // Return "touchid" image for Touch ID
        case .face:
            return "faceid"  // Return "faceid" image for Face ID
        case .unknown:
            return "key"  // Return "key" image for unknown biometric type
        }
    }
    
    // Function to return an appropriate message based on the biometric type
    func adaptativeMessage(biometricType: SettingsViewModel.BiometricType) -> LocalizedStringKey {
        
        switch biometricType {
        case .none:
            return "Protégez vos mots de passes avec votre code de verouillage d'iPhone"  // Message for no biometric type
        case .touch:
            return "Protégez vos mots de passes avec Touch ID"  // Message for Touch ID
        case .face:
            return "Protégez vos mots de passes avec Face ID"  // Message for Face ID
        case .unknown:
            return "Protégez vos mots de passes avec votre code de verouillage d'iPhone"  // Message for unknown biometric type
        }
    }
}
