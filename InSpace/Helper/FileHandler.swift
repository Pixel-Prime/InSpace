//
//  FileHandler.swift
//  InSpace
//
//  Created by Andy Copsey on 02/01/2025.
//

import Foundation

/// Provides high-level wrappers around common file management functions
extension FileManager {
    
    /// Writes a data object to the documents directory
    func writeDataToDocs(data: Data, filename: String) throws {
        
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = docs.appendingPathComponent(filename)
        try data.write(to: path)
        print("Saved \(data.count) bytes for file '\(filename)' OK!")
    }
    
    /// Attempts to read a decodable object (T) from the documents directory
    func readDataFromDocs<T: Codable>(filename: String) throws -> T? {
        
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = docs.appendingPathComponent(filename)
        let data = try Data(contentsOf: path)
        let obj = try JSONDecoder().decode(T.self, from: data)
        print("Loaded \(data.count) bytes from file '\(filename)'")
        return obj
    }
    
    /// Returns a converted filename for the given keywords (used in file saving / loading)
    func filenameForKeywords(_ keywords: String) -> String {
        return keywords.replacingOccurrences(of: " ", with: "_").appending(".dat")
    }
    
    /// Returns true if the specified filename exists in the documents directory
    func hasSavedFile(_ filename: String) -> Bool {
        
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = docs.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: path.path)
    }
    
}
