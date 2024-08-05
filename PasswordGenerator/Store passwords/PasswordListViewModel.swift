//
//  PasswordListViewModel.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import Foundation
import KeychainSwift
import CoreHaptics
import SwiftUI

// ViewModel class for managing passwords and interactions with the Keychain
final class PasswordListViewModel: ObservableObject {
    
    // Published properties to update views when these values change
    @Published var keys = [String]()  // List of keys (password titles) stored in Keychain
    @Published var usernames = [String]()  // List of usernames (associated with passwords) stored in Keychain
    @Published var showAnimation = false  // Flag to control the display of animations
    @Published var sortSelection = 0  // Determines the sorting order of keys (0: ascending, 1: descending)
    let separator = ":separator:"  // Separator used to differentiate key components in Keychain
    
    // Instance of KeychainSwift to interact with the Keychain
    @Published var keychain = KeychainSwift()

    // Boolean indicating whether the Keychain is synced with iCloud
    @Published var keychainSyncWithIcloud: Bool {
        didSet {
            // Save the updated sync status to UserDefaults
            UserDefaults.standard.set(keychainSyncWithIcloud, forKey: "keychainSyncWithIcloud")
        }
    }
    
    // Initializer
    init() {
        // Load the sync status from UserDefaults, default to false if not set
        self.keychainSyncWithIcloud = UserDefaults.standard.object(forKey: "keychainSyncWithIcloud") as? Bool ?? false
        // Initialize keys from Keychain
        keys = keychain.allKeys
    }
    
    // Function to save a password to Keychain with associated username and title
    func saveToKeychain(password: String, username: String, title: String) {
        // Create a unique key combining title and username
        let key = title + separator + username
        
        // Attempt to save password to Keychain
        if keychain.set(password, forKey: key) {
            addedPasswordHaptic()  // Trigger haptic feedback on successful save
            showAnimation = true  // Show animation indicating success
            print("Successfully saved to Keychain")
        } else {
            print("Error saving to Keychain")
        }
    }
    
    // Function to update an existing password in Keychain
    func updatePassword(key: String, newPassword: String) {
        // Attempt to update the password for the given key
        if keychain.set(newPassword, forKey: key, withAccess: .accessibleWhenUnlocked) {
            print("Successfully updated password")
        } else {
            print("Error updating password")
        }
    }
    
    // Function to update the username associated with a password
    func updateUsername(key: String, password: String, newUsername: String, title: String) -> String {
        // Create a new key with updated username
        let newKey = title + separator + newUsername
        
        // Delete the old key and save the password with the new key
        if keychain.delete(key) {
            if keychain.set(password, forKey: newKey, withAccess: .accessibleWhenUnlocked) {
                print("Username successfully updated")
            } else {
                print("Error updating username")
            }
        } else {
            print("Failed to delete old key")
        }
        return newKey
    }
    
    // Function to trigger haptic feedback on adding a password
    func addedPasswordHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        print("Simple haptic for adding password")
    }
    
    // Function to trigger haptic feedback on deleting a password
    func deletedPasswordHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 1)
        print("Simple haptic for deleting password")
    }
    
    // Function to trigger haptic feedback when retrieving a password
    func getPasswordHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 1)
        print("Simple haptic for retrieving password")
    }
    
    // Function to trigger a simple haptic feedback
    func simpleHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: 1)
    }
    
    // Function to trigger heavy haptic feedback
    func heavyHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 1)
    }
    
    // Function to delete a password from Keychain
    func deletePassword(key: String) {
        if keychain.delete(key) {
            print("Successfully deleted")
        } else {
            print("Error deleting password")
        }
    }
    
    // Function to delete multiple passwords from Keychain based on IndexSet
    func deleteFromList(offsets: IndexSet) {
        for offset in offsets {
            let keyToDelete = keys[offset]
            deletePassword(key: keyToDelete)
            
            // Delay before refreshing keys to avoid animation glitches in the list
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.getAllKeys()
            }
        }
    }
    
    // Function to get all keys from Keychain and sort them based on the sortSelection
    func getAllKeys() {
        if sortSelection == 0 {
            keys = keychain.allKeys.sorted()  // Sort keys in ascending order
        } else {
            keys = keychain.allKeys.sorted().reversed()  // Sort keys in descending order
        }
    }
}
