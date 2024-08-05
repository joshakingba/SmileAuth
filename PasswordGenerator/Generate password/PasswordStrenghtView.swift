//
//  PasswordStrenghtView.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

// Define a SwiftUI view to display password strength
struct PasswordStrenghtView: View {
    
    // Properties to hold entropy value and character count of the password
    let entropy: Double
    let characterCount: Double
    // State variable to manage animation state
    @State private var animate = false
    
    var body: some View {
        
        // Main container for the view
        VStack {
            // Horizontal stack to hold the shield icon and entropy text
            HStack {
                
                // Display shield icon with color based on entropy value
                Image(systemName: "shield.fill")
                    .foregroundColor(entropyColor(entropy: entropy))
                    .font(.largeTitle)
                    // Overlay text showing entropy value on top of the shield icon
                    .overlay(
                        Text("\(Int(entropy))")
                            .foregroundColor(.white)
                            .font(.footnote)
                            .bold()
                    )
            }
        }
    }
}

// Extension to add helper functions for the view
extension View {
    
    // Function to return localized string key based on entropy value
    func entropyText(entropy: Double) -> LocalizedStringKey {
        
        switch entropy {
        case 128.0...200:
            return "Très robuste" // Very strong
        case 60.0...128:
            return "Robuste" // Strong
        case 36.0...60:
            return "Moyen" // Medium
        case 28.0...36:
            return "Faible" // Weak
        default:
            return "Très faible" // Very weak
        }
    }
    
    // Function to return color based on entropy value
    func entropyColor(entropy: Double) -> Color {
        
        switch entropy {
        case 128.0...200:
            return .blue // Very strong passwords are blue
        case 60.0...128:
            return .green // Strong passwords are green
        case 36.0...60:
            return .yellow // Medium strength passwords are yellow
        case 28.0...36:
            return .orange // Weak passwords are orange
        default:
            return .red // Very weak passwords are red
        }
    }
}

// Preview provider for the PasswordStrenghtView
struct PasswordStrenghtView_Previews: PreviewProvider {
    static var previews: some View {
        // Display a preview of PasswordStrenghtView with sample entropy and character count
        PasswordStrenghtView(entropy: 200, characterCount: 20)
    }
}
