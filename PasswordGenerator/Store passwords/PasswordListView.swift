//
//  PasswordListView.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI
import SwiftUIX
import Security
import KeychainSwift

// View for displaying and managing a list of passwords
struct PasswordListView: View {
    
    // Observed objects that provide data and functionality
    @ObservedObject var passwordViewModel: PasswordListViewModel
    @ObservedObject var settings: SettingsViewModel
    @ObservedObject var passwordGeneratorViewModel: PasswordGeneratorViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    // State variables to manage local view state
    @State private var password = ""  // Temporary state for new passwords
    @State private var showPasswordView = false  // Flag to show password detail view
    @State private var addSheetIsShowing = false  // Flag to control the display of the add password sheet
    @State private var showAnimation = false  // Flag to show animations
    @State private var searchText = ""  // Text used for searching passwords
    
    // Environment variables for UI appearance and lifecycle
    @Environment(\.colorScheme) var colorScheme  // Color scheme (light/dark mode)
    @Environment(\.scenePhase) var scenePhase  // Scene phase (active/background)
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                // Conditional SearchBar for iOS versions < 15
                if #available(iOS 15, *) {
                    // iOS 15+ uses built-in search features
                } else {
                    // Older iOS versions use a custom SearchBar
                    SearchBar(NSLocalizedString("Rechercher un mot de passe", comment: ""), text: $searchText)
                        .returnKeyType(.done)
                        .searchBarStyle(.minimal)
                        .showsCancelButton(true)
                        .onCancel {
                            searchText = ""  // Clear search text when canceled
                        }
                        .frame(maxWidth: 370)
                }
                
                Form {
                    // Section header with total count and sorting options
                    Section(header:
                        HStack {
                            if passwordViewModel.keys.isEmpty == false {
                                Text("Total : \(self.passwordViewModel.keys.filter { self.searchText.isEmpty ? true : $0.components(separatedBy: passwordViewModel.separator)[0].starts(with: self.searchText) }.count)")
                                Spacer()
                                Picker(selection: $passwordViewModel.sortSelection, label: passwordViewModel.sortSelection == 0 ? Text("A-Z") : Text("Z-A"), content: {
                                    Text("A-Z").tag(0)  // Sort ascending
                                    Text("Z-A").tag(1)  // Sort descending
                                })
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                    ) {
                        List {
                            // Display a list of passwords with navigation and deletion options
                            ForEach(enumerating: passwordViewModel.sortSelection == 0 ?
                                self.passwordViewModel.keys.sorted().filter {
                                    self.searchText.isEmpty ? true : $0.lowercased().components(separatedBy: passwordViewModel.separator)[0].starts(with: self.searchText.lowercased())
                                } :
                                self.passwordViewModel.keys.sorted().reversed().filter {
                                    self.searchText.isEmpty ? true : $0.lowercased().components(separatedBy: passwordViewModel.separator)[0].starts(with: self.searchText.lowercased())
                                }, id: \.self) { keys, key in
                                
                                // Split key into title and username
                                let keyArray = key.components(separatedBy: passwordViewModel.separator)
                                let title = keyArray[0]
                                let username = keyArray[1]
                                
                                // Row for each password entry with navigation link
                                HStack {
                                    NavigationLink(destination: PasswordView(key: key, passwordListViewModel: passwordViewModel, passwordGeneratorViewModel: passwordGeneratorViewModel, settings: settingsViewModel, title: title, username: username)) {
                                        Label(title, systemImage: "key")
                                    }
                                }
                            }
                            // Enable deletion of items from the list
                            .onDelete { offsets in
                                passwordViewModel.deleteFromList(offsets: offsets)
                            }
                        }
                    }
                }
                .sheet(isPresented: $addSheetIsShowing, content: {
                    // Present a sheet to add a new password
                    SavePasswordView(password: $password, sheetIsPresented: $addSheetIsShowing, generatedPasswordIsPresented: false, viewModel: passwordViewModel, settings: settings)
                        .environment(\.colorScheme, colorScheme)
                        .accentColor(settings.colors[settings.accentColorIndex])
                })
                .navigationBarItems(trailing: Button(action: { addSheetIsShowing.toggle() }, label: {
                    Image(systemName: "plus")  // Button to show the add password sheet
                }))
                .navigationBarTitle("Coffre fort")  // Title for the navigation bar
                .searchablePasswords(with: $searchText)  // Custom modifier for searchable functionality
                .onAppear(perform: {
                    // Load all keys when the view appears
                    passwordViewModel.getAllKeys()
                })
                
            }
        }
    }
}

extension View {
    @ViewBuilder
    func searchablePasswords(with text: Binding<String>) -> some View {
        // Apply searchable functionality conditionally based on iOS version
        if #available(iOS 15, *) {
            self.modifier(SearchableModifier(text: text))
                .disableAutocorrection(true)  // Disable autocorrection for search field
        }
        else {
            self.modifier(EmptyModifier())  // No-op for older iOS versions
        }
    }
}

struct PasswordListView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for the PasswordListView with mock view models
        PasswordListView(passwordViewModel: PasswordListViewModel(), settings: SettingsViewModel(), passwordGeneratorViewModel: PasswordGeneratorViewModel(), settingsViewModel: SettingsViewModel())
    }
}
