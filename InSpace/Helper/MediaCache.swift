//
//  MediaCache.swift
//  InSpace
//
//  Created by Andy Copsey on 02/01/2025.
//

import Foundation
import UIKit

/// Provides high level caching and download capabilities for online media retrieval
class MediaCache {
    
    /// Singleton accessor
    static let shared = MediaCache()
    
    /// An in-memory cache to save having to retrieve images from disk
    private let memCache = NSCache<NSString, UIImage>()
    
    /// Will return an image from either the in-memory cache, a copy stored on disk (disk cache)
    /// or finally from the online resource where it originally resides
    func getImage(url: URL) async throws -> UIImage? {
        
        // Check if a copy of this image exists in the in-memory cache
        // Note: This yields the absolute fastest response time for highest performance
        let key = url.absoluteString as NSString
        if let obj = memCache.object(forKey: key) {
            return obj
        }
        
        // Check if a copy of this image exists on disk
        // Note: This is less optimal, but provides offline access in most instances
        // and faster performance over a potentially wasteful re-downloading of the resource
        if let image = loadFile(filename: url.absoluteString) {
            // to improve performance of this image, we'll transfer it into the in-memory cache in case
            // we need faster retrieval again soon
            memCache.setObject(image, forKey: key)
            return image
        }
        
        // Download this image, since we neither have it in the in-memory cache or on disk
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // attempt to parse the returned data as an image, otherwise something went wrong
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "MediaCache", code: 0, userInfo: [NSLocalizedDescriptionKey: "The image could not be downloaded"])
        }
        
        // download was successful, so write this image into the disk cache
        saveFile(filename: getSanitisedURL(url.absoluteString), data: data)
        
        // also copy this image into the in-memory cache for faster performance in future requests
        memCache.setObject(image, forKey: key)
        
        // return this image
        return image
    }
    
    /// Attempts to return an image object from an existing file on disk
    private func loadFile(filename: String) -> UIImage? {
        let file = getFilePath(for: filename)
        
        // check if this file exists in the cache directory
        guard FileManager.default.fileExists(atPath: file.path) else { return nil }
        
        // make sure this file loads, and conforms to an expected UIImage object
        guard let data = try? Data(contentsOf: file), let image = UIImage(data: data) else {
            return nil
        }
        
        // success!
        return image
    }
    
    /// Saves a data object to disk
    private func saveFile(filename: String, data: Data) {
        let file = getFilePath(for: filename)
        do {
            // write this file
            try data.write(to: file, options: .atomic)
        }
        catch {
            print("Error saving file '\(filename)' to disk")
        }
    }
    
    /// Returns a file path for a given file in our chosen user domain (for our media cache we're using the
    /// system-managed caches directory)
    private func getFilePath(for url: String) -> URL {
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        // Since our paths will be URLs, we'll want to sanitize any forbidden characters from this string.
        // We could hash the string using CommonCrypto and something like MD5 / SHA, but for less
        // complexity we'll just do some string substitution here
        let file = getSanitisedURL(url)
        
        // return this path
        return path.appendingPathComponent(file)
    }
    
    /// Returns a sanitised, filename-safe version of a URL
    private func getSanitisedURL(_ url: String) -> String {
        return url.replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "&", with: "")
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\\", with: "")
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "|", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "~", with: "-")
    }
}
