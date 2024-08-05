//
//  PasswordView.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI
import MobileCoreServices
import LocalAuthentication

// Main view for the password generator feature
struct PasswordGeneratorView: View {
    
    // Observed object for the password generation logic
    @ObservedObject var viewModel = PasswordGeneratorViewModel()
    
    // Environment property for color scheme (light or dark mode)
    @Environment(\.colorScheme) var colorScheme
    
    // State properties for controlling the view
    @State private var isUnlocked = false
    @State private var uppercased = true
    @State private var specialCharacters = true
    @State private var characterCount = 20.0
    @State private var withNumbers = true
    @State private var generatedPassword = ""
    @State private var savePasswordSheetIsPresented = false
    @ObservedObject var settings: SettingsViewModel
    @ObservedObject var passwordViewModel: PasswordListViewModel
    @State private var showAnimation = false
    @State private var characters = [String]()
    @State private var clipboardSaveAnimation = false
    @State private var currentPasswordEntropy = 0.0
    @State private var entropySheetIsPresented = false
    @State private var strenghtMeterIsShowing = false
    @State private var copiedPassword = ""
    
    var body: some View {
        
        NavigationView {
            ZStack {
                
                Form {
                    
                    // Section for displaying the generated password
                    Section(header: Text("Mot de passe généré aléatoirement")) {
                        
                        HStack {
                            
                            Spacer()
                            
                            // Display the generated password with color coding for different types of characters
                            HStack(spacing: 0.5) {
                                ForEach(characters, id: \.self) { character in
                                    Text(character)
                                        .foregroundColor(viewModel.specialCharactersArray.contains(character) ? Color.init(hexadecimal: "#f16581") : viewModel.numbersArray.contains(character) ? Color.init(hexadecimal: "#4EB3BC") : viewModel.alphabet.contains(character) ? .gray : Color.init(hexadecimal: "#ffbc42"))
                                }
                            }
                            .font(characterCount > 25 ? .system(size: 15) : .body)
                            .animation(.easeOut(duration: 0.1))
                        
                            Spacer()
                            
                            // Button to copy the generated password to clipboard
                            Button(action: {
                                clipboardSaveAnimation = true
                                settings.copyToClipboard(password: generatedPassword)
                                viewModel.copyPasswordHaptic()
                            }, label: {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(settings.colors[settings.accentColorIndex])
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        HStack {
                            Spacer()
                            // Button to present the save password sheet
                            Button(action: { savePasswordSheetIsPresented.toggle() }, label: {
                                Text("Ajouter au coffre fort")
                                    .foregroundColor(settings.colors[settings.accentColorIndex])
                            })
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                        }
                        
                    }
                    
                    // Section for adjusting the password length and viewing its strength
                    Section(header: HStack {
                        if !strenghtMeterIsShowing {
                            Text("Nombre de caractères:")
                            Text("\(Int(characterCount))")
                        } else {
                            Text("Force du mot de passe:")
                            Text(entropyText(entropy: currentPasswordEntropy))
                                .foregroundColor(entropyColor(entropy: currentPasswordEntropy))
                        }
                        Spacer()
                        Button(action: {
                        }, label: !strenghtMeterIsShowing ? Image("") : Image("")
                        )
                        .font(.body)
                    }) {
                        
                        HStack {
                            
                            if !strenghtMeterIsShowing {
                                // Slider to adjust the length of the password
                                Slider(value: $characterCount, in: viewModel.passwordLenghtRange, step: 1)
                                    .transition(.opacity)
                                    .transition(.move(edge: .top))
                                    .animation(.easeOut(duration: 0.8))
                            }
                        }
    
                        VStack(alignment: .leading) {
                            if !strenghtMeterIsShowing {
                                // Button to generate a new password
                                Button(action: {
                                    viewModel.generateButtonHaptic()
                                    characters = viewModel.generatePassword(length: Int(characterCount), specialCharacters: specialCharacters, uppercase: uppercased, numbers: withNumbers)
                                    generatedPassword = characters.joined()
                                    currentPasswordEntropy = viewModel.calculatePasswordEntropy(password: characters.joined())
                                    viewModel.adaptativeSliderHaptic(entropy: currentPasswordEntropy)
                                }, label: {
                                    HStack {
                                        Spacer()
                                        Text("Générer")
                                        Spacer()
                                    }
                                })
                                .foregroundColor(settings.colors[settings.accentColorIndex])
                                .buttonStyle(PlainButtonStyle())
                                .transition(.opacity)
                            } else {
                                // Slider to adjust the length of the password during strength meter view
                                Slider(value: $characterCount, in: viewModel.passwordLenghtRange, step: 1)
                                    .animation(.easeInOut(duration: 0.7))
                            }
                        }
                    }
                    
                    // Section for including different types of characters in the password
                    Section(header: Text("Inclure"), footer: Text("").padding()) {
                        
                        Toggle(isOn: $specialCharacters, label: {
                            HStack {
                                Text("Caractères spéciaux")
                                Text("&-$").foregroundColor(Color.init(hexadecimal: "#f16581"))
                            }
                        })
                        .toggleStyle(SwitchToggleStyle(tint: settings.colors[settings.accentColorIndex]))
                        
                        Toggle(isOn: $uppercased, label: {
                            HStack {
                                Text("Majuscules")
                                Text("A-Z").foregroundColor(Color.init(hexadecimal: "#ffbc42"))
                            }
                        })
                        .toggleStyle(SwitchToggleStyle(tint: settings.colors[settings.accentColorIndex]))
                        
                        Toggle(isOn: $withNumbers, label: {
                            HStack {
                                Text("Chiffres")
                                Text("0-9").foregroundColor(Color.init(hexadecimal: "#4EB3BC"))
                            }
                        })
                        .toggleStyle(SwitchToggleStyle(tint: settings.colors[settings.accentColorIndex]))
                    }
                    
                }
                .navigationBarTitle("Générateur")
            
            }
            // Popup notifications for save actions and clipboard actions
            .popup(isPresented: $passwordViewModel.showAnimation, type: .toast, position: .top, autohideIn: 2) {
                VStack(alignment: .center) {
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height / 22)
                    Label("Ajouté au coffre", systemImage: "checkmark.circle.fill")
                        .padding(14)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(30)
                }
            }
            
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
        }
        
        // Sheet for saving the generated password
        .sheet(isPresented: $savePasswordSheetIsPresented, content: {
            SavePasswordView(password: $generatedPassword, sheetIsPresented: $savePasswordSheetIsPresented, generatedPasswordIsPresented: true, viewModel: passwordViewModel, settings: settings)
                .environment(\.colorScheme, colorScheme)
                .foregroundColor(settings.colors[settings.accentColorIndex])
        })
        // Update the password when the character count or options change
        .onChange(of: characterCount, perform: { _ in
            updatePassword()
        })
        .onChange(of: uppercased, perform: { _ in
            updatePassword()
        })
        .onChange(of: specialCharacters, perform: { _ in
            updatePassword()
        })
        .onChange(of: withNumbers, perform: { _ in
            updatePassword()
        })
        .onAppear(perform: {
            updatePassword()
        })
    }
    
    // Helper method to update the password and its entropy
    private func updatePassword() {
        characters = viewModel.generatePassword(length: Int(characterCount), specialCharacters: specialCharacters, uppercase: uppercased, numbers: withNumbers)
        generatedPassword = characters.joined()
        currentPasswordEntropy = viewModel.calculatePasswordEntropy(password: generatedPassword)
        viewModel.adaptativeSliderHaptic(entropy: currentPasswordEntropy)
    }
}

struct PasswordGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordGeneratorView(settings: SettingsViewModel(), passwordViewModel: PasswordListViewModel())
    }
}


