//
//  PasswordViewModel.swift
//  PasswordGenerator
//
//  Created by Josh Kenzo
//

import Foundation
import CoreHaptics
import SwiftUI

final class PasswordGeneratorViewModel: ObservableObject {
    
    // Published properties to notify views of changes
    @Published var generatedPassword = [String]()
    @Published var possibleCombinaisons: Double
    
    // Initialization with default value for possible combinations
    init() {
        // Initialize possibleCombinaisons with a large number for a password length of 20
        self.possibleCombinaisons = Double(truncating: NSDecimalNumber(decimal: pow(78, 20)))
    }
    
    // Constants defining the range of password length and character sets
    let passwordLenghtRange = 1...30.0
    let alphabet: [String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    let specialCharactersArray: [String] = ["(", ")", "{", "}", "[", "]", "/", "+", "*", "$", ">", ".", "|", "^", "?", "&"]
    let numbersArray: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    // Method to provide haptic feedback when the generate button is pressed
    func generateButtonHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred(intensity: 1)
    }
    
    // Method to provide adaptive haptic feedback based on the entropy value
    func adaptativeSliderHaptic(entropy: Double) {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        
        switch entropy {
        case 128.0...200:
            print("haptic feedback intensity : 1")
            generator.impactOccurred(intensity: 1)
        case 60.0...128:
            print("haptic feedback intensity : 0.8")
            generator.impactOccurred(intensity: 0.8)
        case 36.0...60:
            print("haptic feedback intensity : 0.6")
            generator.impactOccurred(intensity: 0.6)
        case 28.0...36:
            print("haptic feedback intensity : 0.4")
            generator.impactOccurred(intensity: 0.4)
        default:
            print("haptic feedback intensity : 0.2")
            generator.impactOccurred(intensity: 0.2)
        }
    }
    
    // Method to calculate the entropy of a given password
    func calculatePasswordEntropy(password: String) -> Double {
        var pool = 0
        let length = password.count
        let lettersArray = Array(password)
        
        // Create a list of uppercase letters
        let uppercasedAlphabet = alphabet.map { $0.uppercased() }
        
        // Determine the character set used in the password
        if lettersArray.contains(where: alphabet.contains) {
            pool += alphabet.count
        }
        if lettersArray.contains(where: uppercasedAlphabet.contains) {
            pool += uppercasedAlphabet.count
        }
        if lettersArray.contains(where: numbersArray.contains) {
            pool += numbersArray.count
        }
        if lettersArray.contains(where: specialCharactersArray.contains) {
            pool += specialCharactersArray.count
        }
        
        // Calculate the total number of possible combinations
        let numberPower = pow(Double(pool), Double(length))
        possibleCombinaisons = numberPower
        
        // Calculate and return the entropy in bits
        let entropy = log2(numberPower)
        return entropy
    }
    
    // Method to provide haptic feedback when the password is copied
    func copyPasswordHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Method to generate a password based on specified criteria
    func generatePassword(length: Int, specialCharacters: Bool, uppercase: Bool, numbers: Bool) -> [String] {
        if uppercase && specialCharacters && numbers {
            return threeParameterPassword(length: length)
        } else if (uppercase && specialCharacters) || (uppercase && numbers) || (numbers && specialCharacters) {
            return twoParameterPassword(length: length, specialCharacters: specialCharacters, uppercase: uppercase, numbers: numbers)
        } else if uppercase || specialCharacters || numbers {
            return oneParameterPassword(length: length, specialCharacters: specialCharacters, uppercase: uppercase, numbers: numbers)
        } else {
            return lowercasePassword(length: length)
        }
    }
    
    // Method to generate a password containing only lowercase letters
    func lowercasePassword(length: Int) -> [String] {
        var password: [String] = []
        
        // Append random lowercase letters to the password
        for _ in 0..<length {
            password.append(alphabet.randomElement()!)
        }
        
        return password
    }
    
    // Method to generate a password with one of the specified criteria
    func oneParameterPassword(length: Int, specialCharacters: Bool, uppercase: Bool, numbers: Bool) -> [String] {
        var password: [String] = []
        let uppercasedAlphabet = alphabet.map { $0.uppercased() }
        
        if specialCharacters {
            // Add a mix of letters and special characters
            for _ in 0..<length / 2 {
                password.append(alphabet.randomElement()!)
                password.append(specialCharactersArray.randomElement()!)
            }
        } else if uppercase {
            // Add a mix of lowercase and uppercase letters
            for _ in 0..<length / 2 {
                password.append(alphabet.randomElement()!)
                password.append(uppercasedAlphabet.randomElement()!)
            }
        } else if numbers {
            // Add a mix of letters and numbers
            for _ in 0..<length / 2 {
                password.append(alphabet.randomElement()!)
                password.append(numbersArray.randomElement()!)
            }
        }
        
        // Ensure the password is the correct length
        password.shuffle()
        return Array(password.prefix(length))
    }
    
    // Method to generate a password with two of the specified criteria
    func twoParameterPassword(length: Int, specialCharacters: Bool, uppercase: Bool, numbers: Bool) -> [String] {
        var password: [String] = []
        let uppercasedAlphabet = alphabet.map { $0.uppercased() }
        
        if uppercase && specialCharacters {
            // Add a mix of uppercase letters, special characters, and lowercase letters
            for _ in 0..<length / 3 {
                password.append(uppercasedAlphabet.randomElement()!)
                password.append(specialCharactersArray.randomElement()!)
                password.append(alphabet.randomElement()!)
            }
        } else if uppercase && numbers {
            // Add a mix of uppercase letters, numbers, and lowercase letters
            for _ in 0..<length / 3 {
                password.append(uppercasedAlphabet.randomElement()!)
                password.append(numbersArray.randomElement()!)
                password.append(alphabet.randomElement()!)
            }
        } else if numbers && specialCharacters {
            // Add a mix of numbers, special characters, and lowercase letters
            for _ in 0..<length / 3 {
                password.append(numbersArray.randomElement()!)
                password.append(specialCharactersArray.randomElement()!)
                password.append(alphabet.randomElement()!)
            }
        }
        
        // Ensure the password is the correct length
        password.shuffle()
        return Array(password.prefix(length))
    }
    
    // Method to generate a password with all specified criteria
    func threeParameterPassword(length: Int) -> [String] {
        var password: [String] = []
        let uppercasedAlphabet = alphabet.map { $0.uppercased() }
        
        // Add an equal mix of uppercase letters, special characters, lowercase letters, and numbers
        for _ in 0..<length / 4 {
            password.append(uppercasedAlphabet.randomElement()!)
            password.append(specialCharactersArray.randomElement()!)
            password.append(alphabet.randomElement()!)
            password.append(numbersArray.randomElement()!)
        }
        
        // Ensure the password is the correct length
        password.shuffle()
        return Array(password.prefix(length))
    }
}
