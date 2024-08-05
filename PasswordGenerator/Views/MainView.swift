//
//  MainView.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI
import LocalAuthentication

// Main view of the application
struct MainView: View {
    
    // Observed objects for view models, updating the view when they change
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var passwordViewModel: PasswordListViewModel
    @ObservedObject var passwordGeneratorViewModel: PasswordGeneratorViewModel
    
    var body: some View {
        
        // Main content of the view
        TabViews(
            settingsViewModel: settingsViewModel,
            passwordListViewModel: passwordViewModel,
            passwordGeneratorViewModel: passwordGeneratorViewModel
        )
        // Overlay AuthenticationView if the app is locked
        .overlay(!settingsViewModel.isUnlocked ?
                 AuthenticationView(
                    viewModel: settingsViewModel,
                    biometricType: settingsViewModel.biometricType(),
                    passwordViewModel: passwordViewModel,
                    settingsViewModel: settingsViewModel
                 ) : nil)
        // Overlay PrivacyView if the app should hide content in the app switcher
        .overlay(settingsViewModel.isHiddenInAppSwitcher ? PrivacyView() : nil)
    }
}

// Preview provider for MainView, used in SwiftUI previews
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(
            settingsViewModel: SettingsViewModel(),
            passwordViewModel: PasswordListViewModel(),
            passwordGeneratorViewModel: PasswordGeneratorViewModel()
        )
    }
}
