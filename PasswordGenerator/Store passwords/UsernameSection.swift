//
//  UsernameSection.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI
import SwiftUIX

/// A view section for managing the username of a password entry.
struct UsernameSection: View {
    
    // Binding variables to manage view state and user inputs
    @Binding var showUsernameSection: Bool
    @Binding var editingUsername: Bool
    @Binding var editedPassword: String
    @Binding var editedUsername: String
    @Binding var username: String
    @Binding var key: String
    @Binding var password: String
    @Binding var title: String
    @Binding var clipboardSaveAnimation: Bool
    @Binding var savedChangesAnimation: Bool
    
    // Observed objects for interacting with data and settings
    @ObservedObject var passwordListViewModel: PasswordListViewModel
    @ObservedObject var passwordGeneratorViewModel: PasswordGeneratorViewModel
    @ObservedObject var settings: SettingsViewModel
    
    var body: some View {
        
        // Check if the username section should be shown
        if showUsernameSection {
            
            // Check if the username is currently being edited
            if !editingUsername {
                
                // Display the username and an edit button
                HStack {
                    Spacer()
                    Text(username)
                    Spacer()
                    
                    Button(action: {
                        // Start editing the username
                        editingUsername.toggle()
                        editedUsername = username
                    }, label: {
                        Image(systemName: "pencil")
                    })
                }
                
            } else {
                
                // Display a text field to edit the username
                HStack {
                    CocoaTextField("Username", text: $editedUsername)
                        .keyboardType(.asciiCapable)
                        .isFirstResponder(true)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        // Update the username and show saved changes animation
                        updateUsername()
                        savedChangesAnimation = true
                    }, label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(!editedPassword.isEmpty ? .green : .blue)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(settings.colors[settings.accentColorIndex])
                }
               
            }
            
            // Button to copy the username to the clipboard
            Button(action: {
                settings.copyToClipboard(password: username)
                passwordGeneratorViewModel.copyPasswordHaptic()
                clipboardSaveAnimation = true
            }) {
                HStack {
                    Spacer()
                    Text("Copier")
                    Spacer()
                }
            }
            .disabled(editingUsername) // Disable copy button while editing username
            
        } else {
            
            // Button to show the username section if it's not visible
            HStack {
                Spacer()
                Button(action: {
                    showUsernameSection = true
                }, label: Text("Ajouter un nom de compte"))
                Spacer()
            }
        }
        
    }
}

extension UsernameSection {
    
    /// Updates the username in the view model and keychain.
    func updateUsername() {
        // Toggle the editing state
        editingUsername.toggle()
        
        // Update the username and password
        username = editedUsername
        password = passwordListViewModel.keychain.get(key) ?? ""
        let newKey = passwordListViewModel.updateUsername(key: key, password: password, newUsername: username, title: title)
        key = newKey
        
        // Provide haptic feedback to indicate the password was updated
        passwordListViewModel.addedPasswordHaptic()
    }
}

struct UsernameSection_Previews: PreviewProvider {
    static var previews: some View {
        UsernameSection(
            showUsernameSection: .constant(true),
            editingUsername: .constant(true),
            editedPassword: .constant(""),
            editedUsername: .constant(""),
            username: .constant(""),
            key: .constant(""),
            password: .constant(""),
            title: .constant(""),
            clipboardSaveAnimation: .constant(true),
            savedChangesAnimation: .constant(false),
            passwordListViewModel: PasswordListViewModel(),
            passwordGeneratorViewModel: PasswordGeneratorViewModel(),
            settings: SettingsViewModel()
        )
    }
}
