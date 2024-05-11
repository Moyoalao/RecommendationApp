//
//  RecommendationAppTests.swift
//  RecommendationAppTests
//


import XCTest
@testable import RecommendationApp

class LoginViewModelTests: XCTestCase {
    
    var viewModel: LoginViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = LoginViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    //validating correct email and password
    func testValidEmailAndPassword() {
           viewModel.email = "valid@example.com"
           viewModel.password = "Valid123!"
           XCTAssertTrue(viewModel.validate(), "Validate should return true for correct email and password")
       }
       //validating incorrect email format
       func testInvalidEmail() {
           viewModel.email = "invalidemail"
           viewModel.password = "Valid123!"
           XCTAssertFalse(viewModel.validate(), "Validate should return false for incorrect email format")
       }
       //validating password that does not meet the criteria
       func testInvalidPassword() {
           viewModel.email = "valid@example.com"
           viewModel.password = "short"
           XCTAssertFalse(viewModel.validate(), "Validate should return false for incorrect password format")
       }
       //checking empty credentials
       func testEmptyCredentials() {
           viewModel.email = ""
           viewModel.password = ""
           XCTAssertFalse(viewModel.validate(), "Validate should return false when credentials are empty")
       }
}
