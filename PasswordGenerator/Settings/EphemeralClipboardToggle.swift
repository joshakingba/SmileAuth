//
//  EphemeralClipboardToggle.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

struct EphemeralClipboardToggle: View {
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        
        Toggle(isOn: $settingsViewModel.ephemeralClipboard, label: {
            Label(
                title: { Text("Presse papier éphémère") },
                icon: { Image(systemName: "timer") })
        })
        .toggleStyle(SwitchToggleStyle(tint: settingsViewModel.colors[settingsViewModel.accentColorIndex]))
        
    }
}

struct EphemeralClipboardToggle_Previews: PreviewProvider {
    static var previews: some View {
        EphemeralClipboardToggle(settingsViewModel: SettingsViewModel())
    }
}
