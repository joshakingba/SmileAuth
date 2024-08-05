//
//  savePasswordAnimation.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

// Define a SwiftUI view for displaying a popup animation
struct PopupAnimation: View {
    
    // ObservedObject to track and respond to changes in the SettingsViewModel
    @ObservedObject var settings: SettingsViewModel
    // Message to be displayed in the popup
    let message: LocalizedStringKey
    
    var body: some View {
        
        // ZStack to layer content on top of each other
        ZStack {
            // First VStack for the background rectangle
            VStack {
                // Rounded rectangle with specified dimensions and opacity
                RoundedRectangle(cornerRadius: 20)
                    .opacity(0.75)
                    .frame(minWidth: 150, maxWidth: 200, minHeight: 150, maxHeight: 200)
            }
            // Set the color of the rectangle to black
            .foregroundColor(.black)
            
            // Second VStack for the content inside the popup
            VStack {
                // Display a checkmark icon
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 70))
                    .foregroundColor(.white)
                // Spacer to add space between the icon and the text
                Spacer()
                    .frame(maxHeight: 20)
                // Display the message text
                Text(message)
                    .bold()
                    .foregroundColor(.white)
            }
        }
    }
}

// Preview provider for the PopupAnimation
struct savePasswordAnimation_Previews: PreviewProvider {
    static var previews: some View {
        // Display a preview of PopupAnimation with a sample message
        PopupAnimation(settings: SettingsViewModel(), message: "")
    }
}
