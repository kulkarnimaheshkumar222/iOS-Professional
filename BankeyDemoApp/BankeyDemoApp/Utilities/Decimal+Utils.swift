//
//  Decimal+Utils.swift
//  BankeyDemoApp
//
//  Created by scmc-mac3 on 06/02/22.
//

import Foundation

extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}
