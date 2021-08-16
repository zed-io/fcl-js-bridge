//
//  FlowConfig.swift
//  FCLDemo
//
//  Created by lmcmz on 16/8/21.
//

import Foundation

extension Flow {
    struct Config: Codable {
        var accessNode: String
        var icon: String
        var title: String
        var handshake: String
        var scope: String
        var wallet: String
        var env: String
        var openIDScope: String

        enum CodingKeys: String, CodingKey {
            case accessNode = "accessNode.api"
            case icon = "app.detail.icon"
            case title = "app.detail.title"
            case handshake = "challenge.handshake"
            case scope = "challenge.scope"
            case wallet = "discovery.wallet"
            case env
            case openIDScope = "service.OpenID.scopes"
        }
    }
}
