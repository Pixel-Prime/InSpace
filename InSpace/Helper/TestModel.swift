//
//  TestModel.swift
//  InSpace
//
//  Created by Andy Copsey on 05/01/2025.
//

import Foundation

/// A mocked URLSession data protocol to allow providing custom responses for tests
protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

/// Extension to URLSession to allow conformance to our new protocol
extension URLSession: URLSessionProtocol {}

/// Defines a mocked-up URL session we can use to test dummy response data
class TestURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        return (data ?? Data(), response ?? URLResponse())
    }
}
