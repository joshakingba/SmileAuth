//
//  OnboardingView.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

// The OnboardingView struct is a view that shows an onboarding screen for the app
struct OnboardingView: View {
    
    // Observed object for the settings view model
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    // Binding to control the presentation of the onboarding view
    @Binding var isPresented: Bool
    
    // State to hold the biometric type for authentication
    @State var biometricType: SettingsViewModel.BiometricType
    
    // Environment variable to get the color scheme (light or dark mode)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        // Main vertical stack containing the onboarding content
        VStack {
            Spacer() // Spacer to push content to the center

            // Welcome title
            Text("Bienvenue sur lockd")
                .font(.title) // Font size for title
                .bold() // Bold font
            
            Spacer() // Spacer to push content down

            // VStack containing onboarding cells
            VStack(alignment: .leading) {
                
                // First onboarding cell with an image, text, and title
                OnboardingCell(image: "key.fill",
                               text: "Génerez vos mots de passe sécurisés sur-mesure",
                               title: "Mots de passe")
                    .padding() // Padding around the cell
                
                // Second onboarding cell
                OnboardingCell(image: "lock.square",
                               text: "Stockez vos mots de passe dans votre coffre et retrouvez les rapidement",
                               title: "Coffre fort")
                    .padding() // Padding around the cell
                
                // Third onboarding cell with adaptive image and message based on biometric type
                OnboardingCell(image: adaptativeImage(biometricType: biometricType),
                               text: adaptativeMessage(biometricType: biometricType),
                               title: "Sécurisé")
                    .padding() // Padding around the cell
                
            }
            .padding() // Padding around the VStack
            
            Spacer() // Spacer to push content up

            // Button to continue and dismiss the onboarding view
            Button(action: { isPresented = false }, // Action to set isPresented to false
                   label: {
                    
                    HStack {
                        Spacer().frame(maxWidth: 100) // Spacer to center the button text
                        Text("Continuer").foregroundColor(.white) // Button text
                        Spacer().frame(maxWidth: 100) // Spacer to center the button text
                    }})
                .padding() // Padding around the button
                .background(settingsViewModel.colors[settingsViewModel.accentColorIndex]) // Background color from settings
                .cornerRadius(10) // Rounded corners for the button
            
            Spacer() // Spacer to push content down
            
        }
        .environment(\.colorScheme, colorScheme) // Apply the color scheme from the environment
        .font(.body) // Set the font for the view
        .onAppear(perform: {
            // Update the biometricType state when the view appears
            biometricType = settingsViewModel.biometricType()
        })
    }
}

// Preview provider for OnboardingView to be used in SwiftUI previews
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(settingsViewModel: SettingsViewModel(), isPresented: .constant(true), biometricType: .touch)
    }
}
