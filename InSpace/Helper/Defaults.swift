//
//  Defaults.swift
//  InSpace
//
//  Created by Andy Copsey on 02/01/2025.
//

import Foundation

/// Common wrapper for quick UserDefaults operations
class Defaults {
    
    /// Writes a string to the UserDefaults
    public static func writeString(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    /// Reads a value from the UserDefaults
    public static func readString(key: String) -> String {
        if let value = UserDefaults.standard.string(forKey: key) {
            return value
        }
        return ""
    }
    
    /// Deletes an object from the UserDefaults
    public static func deleteKey(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
