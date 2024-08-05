//
//  LoggingView.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

// Define a SwiftUI view for user authentication
struct AuthenticationView: View {
    
    // State variable to manage scaling effect for animation
    @State private var scale: CGFloat = 1
    // ObservedObject to track and respond to changes in the SettingsViewModel
    @ObservedObject var viewModel: SettingsViewModel
    // State variable to store the type of biometric authentication
    @State var biometricType: SettingsViewModel.BiometricType
    // ObservedObject to track and respond to changes in the PasswordListViewModel
    @ObservedObject var passwordViewModel: PasswordListViewModel
    // ObservedObject to track and respond to changes in the SettingsViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    // State variable to manage animation state
    @State private var animate = false
    
    var body: some View {
        
        // ZStack to layer content on top of each other
        ZStack {
            
            // Set background color to gray and extend it to cover the entire screen area
            Color.gray.edgesIgnoringSafeArea(.all)
            
            // VStack to arrange elements vertically
            VStack {
                
                // Nested VStack for app icon and spacer
                VStack {
                    Spacer()
                        .frame(maxHeight: 50)
                    
                    // Display app icon with resizable and scaling effect
                    Image("appIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 10, idealWidth: 50, maxWidth: 100, minHeight: 0, idealHeight: 50, maxHeight: 100, alignment: .center)
                        .foregroundColor(.white)
                        .font(.system(size: 80))
                        .scaleEffect(scale)
                        // Apply continuous animation to the scale effect
                        .animateForever(using: .easeInOut(duration: 1), autoreverses: true, { scale = 0.95 })
                }
                .padding()
                
                Spacer()
                
                // Button for biometric or password authentication
                Button(action: {
                        if viewModel.biometricAuthentication() {
                            passwordViewModel.getAllKeys()
                        }
                    },
                    label: {
                        Label(
                            title: { biometricType == .face ? Text("Déverouiller avec Face ID") : biometricType == .touch ? Text("Déverouiller avec Touch ID") : Text("Entrer le mot de passe") },
                            icon: { Image(systemName: adaptativeImage(biometricType: biometricType)) }
                        )
                    })
                    .foregroundColor(.white)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white, lineWidth: 1))
                
                Spacer()
                    .frame(maxHeight: 30)
            }
            
            // onAppear modifier to perform actions when the view appears
            .onAppear(perform: {
                // Set the biometric type from the view model
                biometricType = viewModel.biometricType()
                
                // Check if the unlock method is active
                if settingsViewModel.unlockMethodIsActive == false {
                    // If not active, set isUnlocked to true and retrieve all keys
                    settingsViewModel.isUnlocked = true
                    passwordViewModel.getAllKeys()
                    print("No biometric authentication")
                }
                
                if settingsViewModel.unlockMethodIsActive == true {
                    // If active, perform biometric authentication and retrieve all keys
                    if settingsViewModel.biometricAuthentication() {
                        passwordViewModel.getAllKeys()
                    }
                    print("Biometric authentication")
                }
            })
        }
        // Hide the status bar for this view
        .statusBar(hidden: true)
        // Apply identity transition to the view
        .transition(.identity)
    }
}

// Preview provider for the AuthenticationView
struct LoggingView_Previews: PreviewProvider {
    static var previews: some View {
        // Display a preview of AuthenticationView with sample view models and biometric type
        AuthenticationView(viewModel: SettingsViewModel(), biometricType: SettingsViewModel.BiometricType.touch, passwordViewModel: PasswordListViewModel(), settingsViewModel: SettingsViewModel())
    }
}
