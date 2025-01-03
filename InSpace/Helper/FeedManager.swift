//
//  FeedManager.swift
//  InSpace
//
//  Created by Andy Copsey on 27/12/2024.
//

import Foundation

/// Wraps common feed-related download and management functionality for easy app digest
class FeedManager {
    
    /// Primary base URI for all feed requests
    private static let kFeedBaseURL = "https://images-api.nasa.gov/"
    
    /// Locator to allow searching for assets
    private static var kFeedSearchURI: String { return "\(FeedManager.kFeedBaseURL)/search?q=" }
    
    /// Locator for a given media asset
    private static var kFeedAssetURI: String { return "\(FeedManager.kFeedBaseURL)/asset/{id}" }
    
    /// Locator for a given item's metadata
    private static var kFeedMetadataURI: String { return "\(FeedManager.kFeedBaseURL)/metadata/{id}" }
    
    /// Locator for a given asset's captions
    private static var kFeedCaptionsURI: String { return "\(FeedManager.kFeedBaseURL)/captions/{id}" }
    
    /// Locator for an asset's album association
    private static var kFeedAlbumsURI: String { return "\(FeedManager.kFeedBaseURL)/album/{id}" }
    
    /// Requests a media item's collection list
    static func requestCollectionData(_ urlString: String) async throws -> [String] {
        
        // capture common errors
        guard !urlString.isEmpty else {
            throw FeedError.empty
        }
        
        // build the URL
        guard let url = URL(string: urlString) else {
            throw FeedError.malformed
        }
        
        // run the request
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // check the response
            guard let response = response as? HTTPURLResponse else {
                throw FeedError.responseError
            }
            
            // check the response code is valid (between 200-299)
            guard (200...299).contains(response.statusCode) else {
                throw FeedError.responseCode(response.statusCode)
            }
            
            // convert the response into the expected NASAFeedContainer format
            do {
                let obj = try JSONDecoder().decode([String].self, from: data)
                return obj
            }
            catch {
                // Unable to understand the JSON response
                throw FeedError.noData
            }
        }
        catch {
            // Catch unexpected / other errors
            throw FeedError.connectivity
        }
    }
    
    /// Requests a fresh copy of the feed data
    static func requestSearch(_ searchKeywords: String) async throws -> NASAFeedContainer? {
        
        // capture common errors
        guard !searchKeywords.isEmpty else {
            throw FeedError.empty
        }
        
        // build the URL
        guard let url = URL(string: "\(kFeedSearchURI)\(searchKeywords)") else {
            throw FeedError.malformed
        }
        
        // run the request
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // check the response
            guard let response = response as? HTTPURLResponse else {
                throw FeedError.responseError
            }
            
            // check the response code is valid (between 200-299)
            guard (200...299).contains(response.statusCode) else {
                throw FeedError.responseCode(response.statusCode)
            }
            
            // convert the response into the expected NASAFeedContainer format
            do {
                let obj = try JSONDecoder().decode(NASAFeedContainer.self, from: data)
                return obj
            }
            catch {
                // Unable to understand the JSON response
                throw FeedError.noData
            }
        }
        catch {
            // Catch unexpected / other errors
            throw FeedError.connectivity
        }
    }
    
    /// Provides definitions of feed manager error cases
    public enum FeedError: Error, CustomStringConvertible {
        
        // error cases
        case malformed
        case empty
        case noData
        case responseError
        case connectivity
        case responseCode(Int)
        case error(Error)
        
        // returns a human-readable version of this error
        var description: String {
            switch self {
            case .noData:
                return "The server returned no data"
            case .responseCode(let value):
                return "Error, the server responded with \(value)"
            case .responseError:
                return "There was an unknown error responding to the server"
            case .error(let error):
                return "\(error.localizedDescription)"
            case .empty:
                return "No search keywords were provided"
            case .malformed:
                return "The provided URI was incorrectly formed"
            case .connectivity:
                return "There was a problem communicating with the server"
            }
        }
    }
}
