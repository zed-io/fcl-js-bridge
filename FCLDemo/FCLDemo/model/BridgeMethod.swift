//
//  JSMethod.swift
//  FCLDemo
//
//  Created by lmcmz on 16/8/21.
//

import Foundation

extension Flow {
    struct ResponseMethod: Codable {
        var name: String
        var id: Int
    }

    struct ResponseModel<T>: Codable where T: Codable {
        var name: String
        var id: Int
        var object: T
    }

    enum BridgeMethod: String {
        case reauth
        case getConfig
        case account
    }
}
