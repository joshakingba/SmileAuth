//
//  PasswordView.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI
import MobileCoreServices

/// A view for displaying and managing a single password entry.
struct PasswordView: View {
    
    // Environment value for managing view presentation
    @Environment(\.presentationMode) var presentation
    
    // State variables for managing view state and user inputs
    @State var key: String
    @ObservedObject var passwordListViewModel: PasswordListViewModel
    @ObservedObject var passwordGeneratorViewModel: PasswordGeneratorViewModel
    @ObservedObject var settings: SettingsViewModel
    
    @State private var showAlert = false
    @State var title: String
    @State var username: String
    @State private var clipboardSaveAnimation = false
    @State private var showUsernameSection = true
    @State private var revealPassword = false
    @State private var password = ""
    @State private var editingUsername = false
    @State private var editedUsername = ""
    @State private var editingPassword = false
    @State private var editedPassword = ""
    @State private var isLocked = true
    @State private var savedChangesAnimation = false
    
    var body: some View {
        
        // Check if the app switcher should be hidden
        if !settings.isHiddenInAppSwitcher {
            ZStack {
                
                Form {
                    
                    // Password section with options to view or edit password
                    Section(header: Text("Mot de passe")) {
                        PasswordSection(
                            password: $password,
                            revealPassword: $revealPassword,
                            key: key,
                            clipboardSaveAnimation: $clipboardSaveAnimation,
                            passwordListViewModel: passwordListViewModel,
                            passwordGeneratorViewModel: passwordGeneratorViewModel,
                            settings: settings,
                            isEditingPassword: $editingPassword,
                            savedChangesAnimation: $savedChangesAnimation,
                            editedPassword: $editedPassword
                        )
                    }
                    
                    // Username section with options to view or edit username
                    Section(header: Text("Nom de compte")) {
                        UsernameSection(
                            showUsernameSection: $showUsernameSection,
                            editingUsername: $editingUsername,
                            editedPassword: $editedPassword,
                            editedUsername: $editedUsername,
                            username: $username,
                            key: $key,
                            password: $password,
                            title: $title,
                            clipboardSaveAnimation: $clipboardSaveAnimation,
                            savedChangesAnimation: $savedChangesAnimation,
                            passwordListViewModel: passwordListViewModel,
                            passwordGeneratorViewModel: passwordGeneratorViewModel,
                            settings: settings
                        )
                    }
                    
                    // Delete button to remove the password entry
                    Section {
                        HStack {
                            Spacer()
                            Button(action: { showAlert.toggle() }, label:
                                Text("Supprimer le mot de passe")
                                .foregroundColor(.red)
                            )
                            Spacer()
                        }
                    }
                }
                
                // Popup for clipboard save animation
                .popup(isPresented: $clipboardSaveAnimation, type: .toast, position: .top, autohideIn: 2) {
                    VStack(alignment: .center) {
                        Spacer()
                            .frame(height: UIScreen.main.bounds.height / 22)
                        Label(settings.ephemeralClipboard ? "Copié (60sec)" : "Copié", systemImage: settings.ephemeralClipboard ? "timer" : "checkmark.circle.fill")
                            .padding(14)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(30)
                    }
                }
                
                // Popup for saved changes animation
                .popup(isPresented: $savedChangesAnimation, type: .toast, position: .top, autohideIn: 2) {
                    VStack(alignment: .center) {
                        Spacer()
                            .frame(height: UIScreen.main.bounds.height / 22)
                        Label("Enregistré", systemImage: "checkmark.circle.fill")
                            .opacity(1)
                            .padding(14)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(30)
                    }
                }
                
                // Action sheet for confirming password deletion
                .actionSheet(isPresented: $showAlert, content: {
                    ActionSheet(
                        title: Text("Supprimer le mot de passe"),
                        message: Text("Êtes vous certain de vouloir supprimer votre mot de passe? Cette action est irreversible."),
                        buttons: [
                            .cancel(),
                            .destructive(Text("Supprimer definitivement"), action: {
                                // Perform password deletion and update keychain
                                passwordListViewModel.keychain.delete(key)
                                passwordListViewModel.getAllKeys()
                                passwordListViewModel.deletedPasswordHaptic()
                            })
                        ]
                    )
                })
                
                // Navigation bar title and reveal password button
                .navigationBarTitle(title)
                .navigationBarItems(trailing:
                    Button(action: {
                        getPassword()
                    }, label: {
                        revealPassword ?
                            Image(systemName: "eye.slash") :
                            Image(systemName: "eye")
                    })
                    .padding(5)
                    .foregroundColor(settings.colors[settings.accentColorIndex])
                )
            }
         
            // Hide username section if username is empty
            .onAppear(perform: {
                if username.isEmpty { showUsernameSection = false }
            })
        }
    }
}

extension PasswordView {
    
    /// Retrieves the password from the keychain and toggles password visibility.
    func getPassword() {
        // Fetch the password from the keychain using the provided key
        password = passwordListViewModel.keychain.get(key) ?? ""
        // Toggle password visibility
        revealPassword.toggle()
        // Update keychain keys and provide haptic feedback
        passwordListViewModel.getAllKeys()
        passwordListViewModel.getPasswordHaptic()
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(
            key: "",
            passwordListViewModel: PasswordListViewModel(),
            passwordGeneratorViewModel: PasswordGeneratorViewModel(),
            settings: SettingsViewModel(),
            title: "",
            username: ""
        )
    }
}
