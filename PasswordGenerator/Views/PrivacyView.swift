//
//  PrivacyView.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

// Define a SwiftUI view to display a privacy screen
struct PrivacyView: View {
    var body: some View {
        
        // ZStack to layer content on top of each other
        ZStack {
            // Set background color to gray and extend it to cover the entire screen area
            Color.gray.edgesIgnoringSafeArea(.all)
        }
    }
}

// Preview provider for the PrivacyView
struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        // Display a preview of PrivacyView
        PrivacyView()
    }
}
