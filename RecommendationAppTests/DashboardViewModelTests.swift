//
//  RecommendationTest.swift
//  RecommendationAppTests
//


import XCTest
@testable import RecommendationApp

import Foundation

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {

    }
}


class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    var urlSession: URLSession!

    override func setUp() {
        super.setUp()
        // Configure MockURLProtocol with a custom session
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self] // Use MockURLProtocol to handle requests
        urlSession = URLSession(configuration: config)

        // Initialize the view model with the mocked session
        viewModel = DashboardViewModel(userId: "IK0lFTH91vdolMotPh3LQILuoBm1", seasion: urlSession)
    }

    override func tearDown() {
        viewModel = nil
        urlSession = nil
        super.tearDown()
    }

    func testGetRecommendationsSuccess() {
        // Prepare the mock response and data
        let jsonString = "{\"results\": [\"Movie Title 1\", \"Movie Title 2\"]}"
        let responseData = jsonString.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:5000/recommend")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)!

        MockURLProtocol.requestHandler = { request in
            print("MockURLProtocol handling request: \(request.url!)")
            return (response, responseData)
        }

        let expectation = XCTestExpectation(description: "Fetching recommendations should succeed and parse data correctly.")

        // Observe the movies array for changes
        let cancellable = viewModel.$movies.sink { movies in
            print("Received movies: \(movies)")
            if !movies.isEmpty {
                XCTAssertEqual(movies.count, 2, "Should have parsed 2 movies.")
                expectation.fulfill()
            }
        }

        viewModel.getRecommendations()

        wait(for: [expectation], timeout: 75.0)
        cancellable.cancel()
    }

    func testGetRecommendationsFailure() {
        // Simulate a network error
        MockURLProtocol.requestHandler = { request in
            throw URLError(.timedOut)
        }

        let expectation = XCTestExpectation(description: "Fetching recommendations should handle errors properly.")

        // Observe the isLoading flag for changes
        let cancellable = viewModel.$isLoading.sink { isLoading in
            if !isLoading {
                // Ensure the view model stops loading and handles the error
                XCTAssert(self.viewModel.movies.isEmpty, "Movies array should be empty after a failed fetch.")
                expectation.fulfill()
            }
        }

        viewModel.getRecommendations()

        wait(for: [expectation], timeout: 5.0)
        cancellable.cancel()
    }
}
