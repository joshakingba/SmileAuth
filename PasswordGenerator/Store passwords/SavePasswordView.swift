//
//  SavePasswordView.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI
import SwiftUIX
import KeychainSwift

// View for saving or editing a password entry
struct SavePasswordView: View {
    
    // Binding to the password being edited or saved
    @Binding var password: String
    // Binding to control the presentation of the sheet
    @Binding var sheetIsPresented: Bool
    
    // Observed object for managing text binding with character limit
    @ObservedObject var editedPassword = TextBindingManager(limit: 30)
    
    // State variables to manage local view state
    @State private var username = ""  // Username input
    @State private var title = ""  // Title input
    @State private var isEditingPassword = false  // Flag to toggle password editing
    @State private var showKeyboard = false  // Flag to show/hide keyboard
    @State private var passwordLength = ""  // Display length of the password
    @State private var showMissingTitleAlert = false  // Flag for missing title alert
    @State private var showMissingPasswordAlert = false  // Flag for missing password alert
    @State private var showMissingPasswordAndTitleAlert = false  // Flag for missing both password and title alert
    @State private var showMissingUsernameFooter = false  // Flag for missing username footer
    @State private var showMissingTitleFooter = false  // Flag for missing title footer
    @State var generatedPasswordIsPresented: Bool  // Flag indicating if a generated password is presented
    
    // Observed object for the view model managing password list
    @ObservedObject var viewModel: PasswordListViewModel
    // Observed object for application settings
    @ObservedObject var settings: SettingsViewModel
    
    // Instance for managing keyboard interactions
    let keyboard = Keyboard()
    // Instance for interacting with the keychain
    let keychain = KeychainSwift()
    
    var body: some View {
        NavigationView {
            
            VStack {
                
                Form {
                    // Section for editing or displaying the password
                    Section(header: Text("Mot de passe").foregroundColor(.gray),
                            footer: passwordLength.isEmpty ? Text("Champ obligatoire")
                                .foregroundColor(.red) : Text("")) {
                        HStack {
                            Spacer()
                            
                            // Display password or show text field based on editing state
                            if !isEditingPassword {
                                Text(editedPassword.text)
                                    .foregroundColor(.gray).font(editedPassword.characterLimit > 25 ? .system(size: 15) : .body)
                            } else {
                                TextField(password, text: $editedPassword.text)
                                    .keyboardType(.asciiCapable)
                                    .disableAutocorrection(true)
                            }
                            Spacer()
                            
                            // Button to toggle editing mode or save the password
                            if !isEditingPassword {
                                Button(action: {
                                    withAnimation {
                                        isEditingPassword.toggle()
                                        showKeyboard = keyboard.isShowing
                                    }
                                }, label: {
                                    Text("Modifier")
                                })
                                .buttonStyle(PlainButtonStyle())
                                .foregroundColor(settings.colors[settings.accentColorIndex])
                                
                            } else {
                                Button(action: {
                                    withAnimation(.default) {
                                        isEditingPassword.toggle()
                                        showKeyboard = keyboard.isShowing
                                        viewModel.addedPasswordHaptic()
                                    }
                                }, label: {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(!editedPassword.text.isEmpty ? .green : .blue)
                                })
                                .animation(.easeIn)
                                .disabled(editedPassword.text.isEmpty)
                                .buttonStyle(PlainButtonStyle())
                                .foregroundColor(settings.colors[settings.accentColorIndex])
                            }
                        }
                        .alert(isPresented: $showMissingPasswordAlert, content: {
                            Alert(title: Text("Mot de passe invalide"), message: Text("Le champ mot de passe ne peut pas être vide."), dismissButton: .cancel(Text("OK!")))
                        })
                    }
                    
                    // Section for entering the username
                    Section(header: Text("Nom de compte").foregroundColor(.gray)) {
                        TextField("ex: example@icloud.com", text: $username)
                    }
                    
                    // Section for entering the title with footer validation
                    Section(header: Text("Titre").foregroundColor(.gray), footer: title.isEmpty ? Text("Champ obligatoire").foregroundColor(.red) : Text("")) {
                        TextField("ex: Twitter", text: $title)
                    }
                    .alert(isPresented: $showMissingTitleAlert, content: {
                        Alert(title: Text("Champ manquant"), message: Text("Vous devez au moins donner un nom de compte a votre mot de passe."), dismissButton: .cancel(Text("OK!")))
                    })
                    
                }
                .alert(isPresented: $showMissingPasswordAndTitleAlert, content: {
                    Alert(title: Text("Champs manquants"), message: Text("Champ(s) manquant(s)."), dismissButton: .cancel(Text("OK!")))
                })
                .navigationBarTitle("Nouveau mot de passe")  // Title for the navigation bar
                .navigationBarItems(leading: Button(action: {
                    // Cancel action to dismiss the sheet
                    sheetIsPresented.toggle()
                }, label: {
                    Text("Annuler")
                })
                                    
                                    , trailing: Button(action: {
                    // Save action to validate and save the password
                    withAnimation {
                        if !isEditingPassword {
                            if title.isEmpty || editedPassword.text.isEmpty {
                                showMissingPasswordAndTitleAlert.toggle()
                                print("Missing fields")
                            } else if !title.isEmpty && !editedPassword.text.isEmpty {
                                sheetIsPresented.toggle()
                                viewModel.saveToKeychain(password: editedPassword.text, username: username, title: title)
                                viewModel.getAllKeys()
                            }
                        }
                    }
                }, label: {
                    Text("Enregistrer")
                })
                .disabled(isEditingPassword ? true : false))
            }
            .onChange(of: editedPassword.text.count, perform: { _ in
                passwordLength = editedPassword.text  // Update password length when text changes
            })
        }
        .overlay(settings.isHiddenInAppSwitcher ? PrivacyView() : nil)  // Show privacy view if settings dictate
        .onAppear(perform: {
            // Set initial state when the view appears
            if !generatedPasswordIsPresented {
                isEditingPassword = true
            }
            editedPassword.text = password
            passwordLength = password
        })
    }
}

struct SavePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for the SavePasswordView with mock data
        SavePasswordView(password: .constant("MotDePasseExtremementCompliqué"), sheetIsPresented: .constant(true), generatedPasswordIsPresented: true, viewModel: PasswordListViewModel(), settings: SettingsViewModel())
    }
}
