//
//  TestError.swift
//  Cat-Demo
//
//  Created by Sreenath Reddy on 2/22/26.
//

import Foundation

enum TestError: Error, Equatable {
    case missingStub
    case typeMismatch
    case sample
}
