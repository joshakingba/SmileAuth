//
//  PasswordSection.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI
import SwiftUIX

// PasswordSection handles the display and editing of a password within PasswordView
struct PasswordSection: View {
    
    // Bindings for managing state and interactions with the password
    @Binding var password: String
    @Binding var revealPassword: Bool
    var key: String
    @Binding var clipboardSaveAnimation: Bool
    @ObservedObject var passwordListViewModel: PasswordListViewModel
    @ObservedObject var passwordGeneratorViewModel: PasswordGeneratorViewModel
    @ObservedObject var settings: SettingsViewModel
    @Binding var isEditingPassword: Bool
    @Binding var savedChangesAnimation: Bool
    @Binding var editedPassword: String
    
    var body: some View {
        
        // Display the password section based on the editing state
        
        // View when not editing the password
        if !isEditingPassword {
            NotEditingPasswordView(
                revealPassword: $revealPassword,
                password: $password,
                isEditingPassword: $isEditingPassword,
                editedPassword: $editedPassword,
                settings: settings
            )
        }
        
        // View when editing the password
        else if isEditingPassword {
            EditingPasswordView(
                editedPassword: $editedPassword,
                isEditingPassword: $isEditingPassword,
                password: $password,
                savedChangesAnimation: $savedChangesAnimation,
                key: key,
                passwordListViewModel: passwordListViewModel,
                settings: settings
            )
        }
        
        // Button to copy the password to the clipboard
        Button(action: {
            // Copy the password to clipboard and show animation
            settings.copyToClipboard(password: password)
            passwordGeneratorViewModel.copyPasswordHaptic()
            clipboardSaveAnimation = true
        }, label: {
            HStack {
                Spacer()
                Text("Copier")
                Spacer()
            }
        })
        .disabled(!revealPassword || isEditingPassword) // Disable button if password is not revealed or in editing mode
        
    }
}

extension PasswordSection {
    
    // View displayed when not editing the password
    struct NotEditingPasswordView: View {
        
        @Binding var revealPassword: Bool
        @Binding var password: String
        @Binding var isEditingPassword: Bool
        @Binding var editedPassword: String
        @ObservedObject var settings: SettingsViewModel
        
        var body: some View {
            HStack {
                
                // Display password with masking based on reveal state
                HStack {
                    Spacer()
                    if #available(iOS 15, *) {
                        Text(revealPassword ? password : "****************************")
                            .privacySensitive(settings.privacyMode && revealPassword ? true : false)
                    } else {
                        Text(revealPassword ? password : "****************************")
                    }
                    Spacer()
                }
                
                Spacer()
                
                // Button to switch to editing mode
                Button(action: {
                    isEditingPassword.toggle()
                    editedPassword = password
                }, label: {
                    Image(systemName: "pencil")
                })
                .foregroundColor(!revealPassword ? .gray : settings.colors[settings.accentColorIndex])
                .buttonStyle(PlainButtonStyle())
                .disabled(!revealPassword) // Disable button if password is not revealed
            }
        }
    }
    
    // View displayed when editing the password
    struct EditingPasswordView: View {
        
        @Binding var editedPassword: String
        @Binding var isEditingPassword: Bool
        @Binding var password: String
        @Binding var savedChangesAnimation: Bool
        var key: String
        @ObservedObject var passwordListViewModel: PasswordListViewModel
        @ObservedObject var settings: SettingsViewModel
        
        var body: some View {
            HStack {
                
                // Text field for editing the password
                CocoaTextField("password", text: $editedPassword)
                    .keyboardType(.asciiCapable)
                    .isFirstResponder(true)
                    .disableAutocorrection(true)
                
                // Button to save the edited password
                Button(action: {
                    savedChangesAnimation = true
                    isEditingPassword.toggle()
                    password = editedPassword
                    passwordListViewModel.updatePassword(key: key, newPassword: password)
                    passwordListViewModel.addedPasswordHaptic()
                }, label: {
                    Image(systemName: "checkmark")
                        .foregroundColor(!editedPassword.isEmpty ? .green : .blue)
                })
                .disabled(editedPassword.isEmpty) // Disable button if password field is empty
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(settings.colors[settings.accentColorIndex])
            }
        }
    }
    
    // Preview for the PasswordSection view
    struct PasswordSection_Previews: PreviewProvider {
        static var previews: some View {
            PasswordSection(
                password: .constant(""),
                revealPassword: .constant(true),
                key: "",
                clipboardSaveAnimation: .constant(true),
                passwordListViewModel: PasswordListViewModel(),
                passwordGeneratorViewModel: PasswordGeneratorViewModel(),
                settings: SettingsViewModel(),
                isEditingPassword: .constant(true),
                savedChangesAnimation: .constant(false),
                editedPassword: .constant("")
            )
        }
    }
}

extension PasswordSection {
    
    // Update the password value
    mutating func updatePassword() {
        password = editedPassword
    }
}
