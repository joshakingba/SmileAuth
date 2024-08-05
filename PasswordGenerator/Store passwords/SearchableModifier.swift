//
//  SearchableModifier.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import SwiftUI

/// A `ViewModifier` for adding a searchable text field to a view.
struct SearchableModifier: ViewModifier {
    // Binding to the search text
    @Binding var text: String
    
    func body(content: Content) -> some View {
        // Check if the iOS version is 15 or later
        if #available(iOS 15, *) {
            // Apply the searchable modifier to the content if iOS 15 or later
            content.searchable(text: $text, placement: .navigationBarDrawer(displayMode: .automatic))
        } else {
            // For iOS versions earlier than 15, no searchable functionality is applied
            // Placeholder for future or alternative implementation
            content
        }
    }
}

