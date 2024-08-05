//
//  PasswordGeneratorApp.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

// Define the main entry point for the app
@main
struct PasswordGeneratorApp: App {
    
    // ObservedObject instances to manage various view models
    @ObservedObject var settingsViewModel = SettingsViewModel()
    @ObservedObject var passwordViewModel = PasswordListViewModel()
    @ObservedObject var passwordGeneratorViewModel = PasswordGeneratorViewModel()
    
    // Environment variable to track the current scene phase (active, inactive, background)
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        
        // Define the main window group for the app
        WindowGroup {
            
            // Set the initial view to MainView with required view models
            MainView(settingsViewModel: settingsViewModel, passwordViewModel: passwordViewModel, passwordGeneratorViewModel: passwordGeneratorViewModel)
                // Set the accent color based on settings
                .accentColor(settingsViewModel.colors[settingsViewModel.accentColorIndex])
                
                // Display onboarding sheet on first launch
                .onAppear(perform: {
                    if settingsViewModel.isFirstLaunch {
                        settingsViewModel.onBoardingSheetIsPresented = true
                    }
                })
                
                // Define the content of the onboarding sheet
                .sheet(isPresented: $settingsViewModel.onBoardingSheetIsPresented, onDismiss: { settingsViewModel.isFirstLaunch = false } , content: {
                    OnboardingView(settingsViewModel: settingsViewModel, isPresented: $settingsViewModel.onBoardingSheetIsPresented, biometricType: settingsViewModel.biometricType())
                })
        }
        
        // Respond to changes in the scene phase
        .onChange(of: scenePhase) { newPhase in
            
            if newPhase == .inactive {
                // When the app becomes inactive, hide content if privacy mode is enabled and the app is unlocked
                if settingsViewModel.privacyMode && settingsViewModel.isUnlocked {
                    settingsViewModel.isHiddenInAppSwitcher = true
                }
            }
            
            else if newPhase == .active {
                // When the app becomes active, show content if privacy mode is enabled
                if settingsViewModel.privacyMode {
                    settingsViewModel.isHiddenInAppSwitcher = false
                }
                // Stop the lock app timer
                settingsViewModel.lockAppTimerIsRunning = false
            }
            
            else if newPhase == .background {
                // When the app goes to the background, hide content if privacy mode is enabled
                if settingsViewModel.privacyMode {
                    settingsViewModel.isHiddenInAppSwitcher = false
                }
                // Lock the app if the unlock method is active
                if settingsViewModel.unlockMethodIsActive {
                    settingsViewModel.lockAppInBackground()
                }
            }
        }
    }
}
