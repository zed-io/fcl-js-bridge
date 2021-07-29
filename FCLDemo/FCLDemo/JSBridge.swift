//
//  JSBridge.swift
//  FCLDemo
//
//  Created by lmcmz on 29/7/21.
//

import Foundation
import WebKit

class JSBridge: NSObject, WKScriptMessageHandler {
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message)
    }

    override init() {
        super.init()
    }
}
