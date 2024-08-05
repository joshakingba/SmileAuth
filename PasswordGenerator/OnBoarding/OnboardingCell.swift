//
//  OnboardingCell.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

// OnboardingCell is a custom view used in the onboarding process to display an icon, a title, and a description.
struct OnboardingCell: View {
    
    // Properties for the image, text, and title
    let image: String
    let text: LocalizedStringKey
    let title: LocalizedStringKey
    
    var body: some View {
        
        // Horizontal stack to layout the icon and text vertically
        HStack {
            // Image component with specified properties
            Image(systemName: image)
                .frame(minWidth: 50, maxWidth: 60, minHeight: 50, maxHeight: 60) // Fixed size for the icon
                .font(.largeTitle) // Large font size for the icon
                .foregroundColor(.white) // White color for the icon
                .background(.blue) // Blue background color for the icon
                .clipShape(Circle()) // Circular shape for the icon
            
            // Vertical stack for the text content
            VStack(alignment: .leading) {
                
                // Title text with bold font
                Text(title)
                    .bold()
                
                // Spacer to add space between title and description
                Spacer()
                    .frame(height: 5) // Fixed height for spacing
                
                // Description text with body font and gray color
                Text(text)
                    .font(.body) // Body font size for the description
                    .foregroundColor(.gray) // Gray color for the description
            }
            .padding() // Padding around the VStack
        }
    }
}

// Preview provider for OnboardingCell to be used in SwiftUI previews
struct OnboardingCell_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCell(image: "lock.fill",
                       text: "Ajsqdfoifjazkfafafniaf aberaiunrafarv avunrrah vahbva.",
                       title: "Sécurisé")
    }
}
