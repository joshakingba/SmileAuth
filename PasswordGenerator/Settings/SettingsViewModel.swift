//
//  SettingsViewModel.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import Foundation
import SwiftUI
import LocalAuthentication
import CoreHaptics

// ViewModel managing app settings, including biometric authentication, privacy mode, and clipboard functionality
final class SettingsViewModel: ObservableObject {
    
    // Initializer to load settings from UserDefaults and hardware capabilities
    init() {
        // Load biometric authentication settings
        self.unlockMethodIsActive = UserDefaults.standard.object(forKey: "biometricAuthentication") as? Bool ?? false
        // Load Face ID toggle setting
        self.faceIdToggle = UserDefaults.standard.object(forKey: "faceIdToggle") as? Bool ?? false
        // Load accent color index for the app
        self.accentColorIndex = UserDefaults.standard.object(forKey: "accentColorIndex") as? Int ?? 1
        // Check if haptic feedback is supported on the device
        supportsHaptics = hapticCapability.supportsHaptics
        // Load first launch status
        self.isFirstLaunch = UserDefaults.standard.object(forKey: "isFirstLaunch") as? Bool ?? true
        // Load auto-lock timer setting
        self.autoLock = UserDefaults.standard.object(forKey: "autoLock") as? Int ?? 1
        // Load privacy mode setting
        self.privacyMode = UserDefaults.standard.object(forKey: "privacyMode") as? Bool ?? true
        // Load ephemeral clipboard setting
        self.ephemeralClipboard = UserDefaults.standard.object(forKey: "ephemeralClipboard") as? Bool ?? true
    }
    
    // Hardware and settings properties
    var supportsHaptics: Bool = false
    let hapticCapability = CHHapticEngine.capabilitiesForHardware() // Check for haptic capabilities
    var colors = [Color.green, Color.blue] // Available accent colors
    
    // Published properties to track and update settings
    @Published var isUnlocked = false // Tracks whether the app is unlocked
    @Published var onBoardingSheetIsPresented = false // Controls the presentation of the onboarding sheet
    @Published var isHiddenInAppSwitcher = false // Determines if the app is hidden in the app switcher
    @Published var lockAppTimerIsRunning = false // Indicates if the app lock timer is running
    @AppStorage("isDarkMode") var appAppearance: String = "Auto" // Dark mode setting
    @AppStorage("appAppearanceToggle") var appAppearanceToggle: Bool = false // Dark mode toggle
    
    // Settings stored in UserDefaults with didSet observers to update UserDefaults
    @Published var autoLock: Int {
        didSet {
            UserDefaults.standard.set(autoLock, forKey: "autoLock") // Update auto-lock setting in UserDefaults
        }
    }
    
    @Published var ephemeralClipboard: Bool {
        didSet {
            UserDefaults.standard.set(ephemeralClipboard, forKey: "ephemeralClipboard") // Update clipboard setting in UserDefaults
        }
    }
    
    @Published var privacyMode: Bool {
        didSet {
            UserDefaults.standard.set(privacyMode, forKey: "privacyMode") // Update privacy mode setting in UserDefaults
        }
    }
    
    @Published var isFirstLaunch: Bool {
        didSet {
            UserDefaults.standard.set(isFirstLaunch, forKey: "isFirstLaunch") // Update first launch status in UserDefaults
        }
    }
    
    @Published var accentColorIndex: Int {
        didSet {
            UserDefaults.standard.set(accentColorIndex, forKey: "accentColorIndex") // Update accent color index in UserDefaults
        }
    }
    
    @Published var faceIdToggle: Bool {
        didSet {
            UserDefaults.standard.set(faceIdToggle, forKey: "faceIdToggle") // Update Face ID toggle setting in UserDefaults
        }
    }
    
    @Published var unlockMethodIsActive: Bool {
        didSet {
            UserDefaults.standard.set(unlockMethodIsActive, forKey: "biometricAuthentication") // Update biometric authentication setting in UserDefaults
        }
    }
    
    // Opens the App Store review page
    @IBAction func requestAppStoreReview() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1571284259?action=write-review") else {
            fatalError("Expected a valid URL") // Ensure the URL is valid
        }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil) // Open the App Store review URL
    }
    
    // Copies the given password to the clipboard with optional expiration
    func copyToClipboard(password: String) {
        let copiedPassword = password
        
        if ephemeralClipboard {
            // Set password with expiration if ephemeralClipboard is enabled
            let expireDate = Date().addingTimeInterval(TimeInterval(60)) // Expire after 60 seconds
            UIPasteboard.general.setItems([[UIPasteboard.typeAutomatic: copiedPassword]],
                                          options: [UIPasteboard.OptionsKey.expirationDate: expireDate])
        } else {
            // Set password without expiration
            UIPasteboard.general.string = copiedPassword
        }
    }
    
    // Determines the type of biometric authentication available
    func biometricType() -> BiometricType {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) // Check if policy can be evaluated
            switch(authContext.biometryType) {
            case .none:
                return .none // No biometric authentication available
            case .touchID:
                return .touch // Touch ID is available
            case .faceID:
                return .face // Face ID is available
            @unknown default:
                return .unknown // Unknown biometric type
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) ? .touch : .none // Fallback to Touch ID for iOS versions prior to 11
        }
    }
    
    // Enum for different biometric types
    enum BiometricType {
        case none
        case touch
        case face
        case unknown
    }
    
    // Attempts to authenticate using biometrics and sets isUnlocked based on success
    func biometricAuthentication() -> Bool {
        var getKeychainItems = false
        let context = LAContext()
        context.localizedFallbackTitle = "Déverouiller vos mots de passes." // Fallback title for authentication
        var error: NSError?
        let reason = "Déverouiller vos mots de passes." // Reason for authentication
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        print("success") // Authentication successful
                        self.isUnlocked = true
                        getKeychainItems = true
                    } else {
                        self.isUnlocked = false
                        print("Failed to authenticate") // Authentication failed
                    }
                }
            }
        } else {
            print("No biometrics") // No biometric authentication available
        }
        return getKeychainItems
    }
    
    // Attempts to add biometric authentication and updates settings accordingly
    func addBiometricAuthentication() {
        let context = LAContext()
        var error: NSError?
        let reason = "Déverouiller vos mots de passes." // Reason for authentication
        context.localizedFallbackTitle = "Déverouiller vos mots de passes." // Fallback title for authentication
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        print("Success") // Authentication successful
                        self.unlockMethodIsActive = true
                    } else {
                        self.faceIdToggle = false
                        self.unlockMethodIsActive = false
                        print("Failed to authenticate") // Authentication failed
                    }
                }
            }
        } else {
            print("No biometrics") // No biometric authentication available
            self.unlockMethodIsActive = false
        }
    }
    
    // Disables biometric authentication
    func turnOffBiometricAuthentication() {
        self.unlockMethodIsActive = false
    }
    
    // Locks the app after a specified time period if the app is in the background
    func lockAppInBackground() {
        lockAppTimerIsRunning = true
        let seconds: Int = 1 + autoLock * 60 // Calculate lock time based on autoLock setting
        let dispatchAfter = DispatchTimeInterval.seconds(seconds)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + dispatchAfter) {
            if self.lockAppTimerIsRunning {
                self.isUnlocked = false
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil) // Lock the app by dismissing the root view controller
            }
        }
    }
}
