import XCTest
@testable import RecommendationApp
import Foundation

// custom URLProtocol to intercept and mock network responses.
class MockURLProtocol: URLProtocol {
    //  static property allows setting a handler that mocks  network responses.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    // Determines if this protocol can handle the given request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    // Returns the request as its canonical form.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // Starts the loading process for the request the mock handling takes place.
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            //  handler  called  to get the mocked response and data.
            let (response, data) = try handler(request)
            // Notifies the client of the received response.
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                // Loads the data into the client.
                client?.urlProtocol(self, didLoad: data)
            }
            // Notifies the client that the loading has finished successfully.
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // Notifies the client that the loading has failed.
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    // Required by the protocol, but no implementation needed for mock.
    override func stopLoading() { }
}

class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    var urlSession: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]  // Mock protocol to intercept the network requests
        urlSession = URLSession(configuration: config)

        viewModel = DashboardViewModel(userId: "IK0lFTH91vdolMotPh3LQILuoBm1", seasion: urlSession)
    }

    override func tearDown() {
        viewModel = nil
        urlSession = nil
        super.tearDown()
    }

    func testGetRecommendationsSuccess() {
        // Mock successful network interaction
        let response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:5000/recommend")!,
                                       statusCode: 200,  // Status code 200 indicates success
                                       httpVersion: nil,
                                       headerFields: nil)!
        let data = Data()  // Assume empty data

        MockURLProtocol.requestHandler = { request in
            return (response, data)
        }
        
        let expectation = XCTestExpectation(description: "The network request should complete successfully.")

        // Start the request
        viewModel.getRecommendations()
        
        // test if the request completes without entering an error state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Wait for some time for the async request to be handled
            XCTAssertFalse(self.viewModel.isLoading, "The isLoading should be false after the request.")
            XCTAssertTrue(self.viewModel.movies.isEmpty, "The movies should be empty if we are not parsing any data.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetRecommendationsFailure() {
        // Mock a failure in network interaction
        MockURLProtocol.requestHandler = { request in
            throw URLError(.notConnectedToInternet)
        }

        let expectation = XCTestExpectation(description: "The network request should handle errors correctly.")

        viewModel.getRecommendations()
        
        // Check if the error state is handled correctly
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Allow time for the request to fail and be processed
            XCTAssertFalse(self.viewModel.isLoading, "The isLoading should be reset to false after a failure.")
            XCTAssertTrue(self.viewModel.movies.isEmpty, "The movies should remain empty after a failure.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
