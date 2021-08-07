//
//  JSCoreManager.swift
//  JSCoreManager
//
//  Created by lmcmz on 4/8/21.
//

import Foundation
import JavaScriptCore
import WebKit

class JSCoreManager {
//    let context = JSContext()
//
//    init() {
//        context?.exceptionHandler = { _, exception in
//            print(exception!.toString()!)
//        }
//
//        let providerJsString = Bundle.main.path(forResource: "fcl-min", ofType: "js")!
//        let providerScript = try! String(contentsOfFile: providerJsString)
//        context?.evaluateScript(providerScript)
//
//        print(context?.evaluateScript("fcl.VERSION").toString())
//
//        let test = context?.objectForKeyedSubscript("window.fcl.VERSION")
//        let result = test?.call(withArguments: [])
//        print(result)
//    }

    static let shared = JSCoreManager()

    lazy var webview: WKWebView = {
        let webview = WKWebView(frame: .zero, configuration: webviewConfig())
        let url = URL(string: "about:blank")!
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        return webview
    }()

    init() {}

    func auth() {
        let source =
            """
            fcl.reauthenticate()
            """

        webview.evaluateJavaScript(source) { result, error in
            print(result)
            print(error)
        }
    }

    private func webviewConfig() -> WKWebViewConfiguration {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
//        let chainId = ""
//        let rpcUrl = ""
        let source =
            """
            (function() {
                window.fcl.config()
                .put("env", "testnet")
                .put("service.OpenID.scopes", "email")
                .put("app.detail.icon", "https://placekitten.com/g/200/200")
                .put("app.detail.title", "1111111")
                .put("challenge.scope", "email") // request for Email
                .put("accessNode.api", "https://access-testnet.onflow.org") // Flow testnet
                .put("discovery.wallet", "https://fcl-discovery.onflow.org/testnet/authn")
            })();
            """

        var providerJsString: String {
            return Bundle.main.path(forResource: "fcl-min", ofType: "js")!
        }

        var providerScript: WKUserScript {
            let source = try! String(contentsOfFile: providerJsString)
            let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            return script
        }

        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let controller = WKUserContentController()
        let handler = JSBridge()
        controller.addUserScript(script)
        controller.addUserScript(providerScript)
        controller.add(handler, name: "_fcl_")
        config.userContentController = controller

        return config
    }
}
