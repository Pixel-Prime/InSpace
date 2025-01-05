//
//  InSpaceTests.swift
//  InSpaceTests
//
//  Created by Andy Copsey on 27/12/2024.
//

import XCTest
@testable import InSpace

final class InSpaceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Tests whether the code can parse the basic feed model correctly
    func testFeedModelParsing() async throws {
        
        // build a new text URL session
        let session = TestURLSession()
        guard let data = NASAFeedContainer.emptyFeedAsJSON() else {
            XCTFail("Error retrieving valid empty feed model")
            return
        }
        
        // set session data and response
        session.data = data
        session.response = HTTPURLResponse(url: URL(string: FeedManager.kFeedSearchURI)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // run the request
        let result = try await FeedManager.requestSearch("Jupiter", session: session)
        
        // ensure the result isn't nil
        XCTAssertNotNil(result)
    }
    
    /// Tests whether the feed is providing data we can parse correctly
    func testFeedResponse() async throws {
        
        // run the request
        let result = try await FeedManager.requestSearch("Jupiter")
        
        // ensure that the appropriate paths in our data model aren't nil
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.collection)
        XCTAssertNotNil(result?.collection?.items)
        
        // check to ensure we're returning data for our known feed criteria ('Jupiter' search term)
        XCTAssertGreaterThan(result?.collection?.items?.count ?? 0, 0)
    }
    
    /// Performance measurement for the feed data
    func testFeedPerformance() async throws {
        measure {
            // set our expectation object
            let exp = expectation(description: "Feed request server performance")
            
            // run the asynchronous download task
            Task {
                do {
                    // request the response and ensure the result isn't nil
                    let result = try await FeedManager.requestSearch("Jupiter")
                    XCTAssertNotNil(result)
                }
                catch {
                    XCTFail("Error retrieving feed response: \(error)")
                }
                exp.fulfill()
            }
            
            // wait for completion of the server response, or our timeout
            wait(for: [exp], timeout: 6.0)
        }
    }
}
