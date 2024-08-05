//
//  TabView.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

// This struct defines a view containing a tab bar with three tabs
struct TabViews: View {
    
    // Observed objects for view models, updating the view when they change
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var passwordListViewModel: PasswordListViewModel
    @ObservedObject var passwordGeneratorViewModel: PasswordGeneratorViewModel
    
    var body: some View {
        
        // A vertical stack to contain the TabView
        VStack {
            // TabView to switch between different views
            TabView {
                
                // First tab: Password Generator
                PasswordGeneratorView(settings: settingsViewModel,
                                      passwordViewModel: passwordListViewModel)
                    .tabItem {
                        Label("Générateur", systemImage: "die.face.5.fill")
                    }
                    .tag(0)
                
                // Second tab: Password List
                PasswordListView(passwordViewModel: passwordListViewModel,
                                 settings: settingsViewModel,
                                 passwordGeneratorViewModel: passwordGeneratorViewModel,
                                 settingsViewModel: settingsViewModel)
                    .tabItem {
                        Label("Coffre fort", systemImage: "lock.square")
                    }
                    .tag(1)
                
                // Third tab: Settings
                SettingsView(settingsViewModel: settingsViewModel,
                             biometricType: settingsViewModel.biometricType(),
                             passwordViewModel: passwordListViewModel)
                    .tabItem {
                        Label("Préférences", systemImage: "gear")
                            .animation(.easeIn)
                    }
                    .tag(2)
            }
        }
    }
}

// Preview provider for TabViews, used in SwiftUI previews
struct TabViews_Previews: PreviewProvider {
    static var previews: some View {
        TabViews(settingsViewModel: SettingsViewModel(),
                 passwordListViewModel: PasswordListViewModel(),
                 passwordGeneratorViewModel: PasswordGeneratorViewModel())
    }
}
