//
//  RegisterTest.swift
//  RecommendationAppTests


import XCTest
@testable import RecommendationApp

class RegisterViewModelTests: XCTestCase {
    var viewModel: RegisterViewModel!

    override func setUp() {
        super.setUp()
        viewModel = RegisterViewModel()
    }
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    //valid registration data
    func testValidRegistrationData() {
        viewModel.name = "John Doe"
        viewModel.email = "john.doe@example.com"
        viewModel.password = "Password123!"
        XCTAssertTrue(viewModel.validate(), "The validation should pass with valid input data.")
    }
    //validate incorrect email format
    func testInvalidEmail() {
        viewModel.name = "John Doe"
        viewModel.email = "john.doe"
        viewModel.password = "Password123!"
        XCTAssertFalse(viewModel.validate(), "The validation should fail due to invalid email format.")
    }
    //validating password that does not meet the criteria
    func testInvalidPassword() {
        viewModel.name = "John Doe"
        viewModel.email = "john.doe@example.com"
        viewModel.password = "pass"
        XCTAssertFalse(viewModel.validate(), "The validation should fail due to invalid password format.")
    }
    //checkkng if inputs are empty
    func testEmptyFields() {
        viewModel.name = ""
        viewModel.email = ""
        viewModel.password = ""
        XCTAssertFalse(viewModel.validate(), "The validation should fail when fields are empty.")
    }
}
