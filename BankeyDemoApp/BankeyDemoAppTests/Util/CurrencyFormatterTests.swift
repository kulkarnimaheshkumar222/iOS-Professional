//
//  CurrencyFormatterTests.swift
//  BankeyDemoAppTests
//
//  Created by scmc-mac3 on 11/02/22.
//

import Foundation
import XCTest

@testable import BankeyDemoApp

class Test: XCTestCase {
    
    var sut: CurrencyFormatter!

    override func setUp() {
        super.setUp()
        
        sut = CurrencyFormatter()
        
    }
    
    func testBreakDollarsIntoCents() {
        let result = sut.breakIntoDollarsAndCents(929466.23)
        XCTAssertEqual(result.0, "929,466")
        XCTAssertEqual(result.1, "23")
    }
    
    func testDollarFormatted() {
       // 929466 > $929,466.00
        let result = sut.dollarsFormatted(929466.20)
        XCTAssertEqual(result, "$929,466.20")
    }
    
    func testZeroDollarFormatted() {
        let result = sut.dollarsFormatted(0)
        XCTAssertEqual(result, "$0.00")
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}
