//
//  TextBindingManager.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import Foundation

// A class that manages text binding with a character limit
final class TextBindingManager: ObservableObject {
    
    // Published property that triggers view updates when changed
    @Published var text = "" {
        didSet {
            // If the new text exceeds the character limit and the old text was within the limit
            if text.count > characterLimit && oldValue.count <= characterLimit {
                // Revert to the old text if the new text exceeds the limit
                text = oldValue
            }
        }
    }
    
    // The maximum number of characters allowed
    let characterLimit: Int

    // Initializer with a default character limit of 30
    init(limit: Int = 30) {
        // Set the character limit
        characterLimit = limit
    }
}
