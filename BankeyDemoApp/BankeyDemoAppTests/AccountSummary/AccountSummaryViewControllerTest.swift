//
//  AccountSummaryViewControllerTest.swift
//  BankeyDemoAppTests
//
//  Created by scmc-mac3 on 19/02/22.
//

import XCTest

@testable import BankeyDemoApp

class AccountSummaryViewControllerTest: XCTestCase {
    
    var sut: AccountSummaryViewController!
    var mockManager: MockProfileManager! //
    
    class MockProfileManager: ProfileManageable {
        var profile: Profile?
        var error: NetworkError?
        var accounts = [Account]()
        
        func fetchProfile(forUserId userId: String, completion: @escaping (Result<Profile, NetworkError>) -> Void) {
            if error != nil {
                completion(.failure(error!))
                return
            }
            profile = Profile(id: "1", firstName: "FirstName", lastName: "LastName")
            completion(.success(profile!))
        }
       
    }
    
    override func setUp() {
        super.setUp()
        sut = AccountSummaryViewController()
        mockManager = MockProfileManager()
        sut.profileManager = mockManager
    }
    
    func testTitleAndMessage_ForServerError() {
        let titleAndMessage = sut.titleAndMessageForTesting(for: .serverError)
        XCTAssertEqual(Constant.server_title_error.rawValue, titleAndMessage.0)
        XCTAssertEqual(Constant.server_message_error.rawValue, titleAndMessage.1)
    }
    
    func testTitleAndMessage_ForDecodingError() {
        let titleAndMessage = sut.titleAndMessageForTesting(for: .decodingError)
        XCTAssertEqual(Constant.decoding_title_error.rawValue, titleAndMessage.0)
        XCTAssertEqual(Constant.decoding_message_error.rawValue, titleAndMessage.1)
    }
    func testAlertForServerError() throws {
        mockManager.error = NetworkError.serverError
        sut.forceFetchProfile()
        
        XCTAssertEqual(Constant.server_title_error.rawValue, sut.errorAlert.title)
        XCTAssertEqual(Constant.server_message_error.rawValue, sut.errorAlert.message)
    }
    func testAlertForDecodingError() throws {
        mockManager.error = NetworkError.decodingError
        sut.forceFetchProfile()
        
        XCTAssertEqual(Constant.decoding_title_error.rawValue, sut.errorAlert.title)
        XCTAssertEqual(Constant.decoding_message_error.rawValue, sut.errorAlert.message)
    }
}

