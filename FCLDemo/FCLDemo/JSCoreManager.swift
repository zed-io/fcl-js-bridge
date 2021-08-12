//
//  JSCoreManager.swift
//  JSCoreManager
//
//  Created by lmcmz on 4/8/21.
//

import Foundation
import Swifter
import WebKit

protocol JSBridgeDelegate {
    func showAddress(address: String)
    func showEnv(env: String)
    func showBalance(balance: String)
    func getSelectedIndex() -> Int
    func getSelectedNodeIndex() -> Int
    func hideWebView()
}

class JSCoreManager: NSObject {
    static let shared = JSCoreManager()

    var delegate: JSBridgeDelegate?

    var server: HttpServer!

    lazy var webview: WKWebView = {
        let webview = WKWebView(frame: .zero, configuration: webviewConfig)
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webview.loadFileURL(url, allowingReadAccessTo: url)
        webview.navigationDelegate = self
        return webview
    }()

    lazy var webviewConfig: WKWebViewConfiguration = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        config.setValue(true, forKey: "_allowUniversalAccessFromFileURLs")

        let index = delegate?.getSelectedIndex()
        let array = ["https://fcl-discovery.onflow.org/testnet/authn", "https://flow-wallet-testnet.blocto.app/authn"]

        let nodeIndex = delegate?.getSelectedNodeIndex()
        let node = ["https://access-testnet.onflow.org", "https://flow-access-mainnet.portto.io"]
        let nodeEnv = ["testnet", "mainnet"]

        let source =
            """
            (function() {
                window.fcl.config()
                .put("env", "\(nodeEnv[nodeIndex!])")
                .put("service.OpenID.scopes", "email")
                .put("app.detail.icon", "https://placekitten.com/g/200/200")
                .put("app.detail.title", "1111111")
                .put("challenge.scope", "email") // request for Email
                .put("accessNode.api", "\(node[nodeIndex!])") // Flow testnet
                .put("discovery.wallet", "\(array[index!])");
            
                window.fclbridge = new fclnative.Bridge();
                fclnative.postMessage = (jsonString) => {
                    webkit.messageHandlers._fcl_.postMessage(jsonString)
                };
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
        controller.addUserScript(script)
        controller.addUserScript(providerScript)
        controller.add(self, name: "_fcl_")
        config.userContentController = controller
        return config
    }()

    override init() {}

    func auth() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.webview.evaluateJavaScript("fclbridge.reauth()")
        }
    }

    func getAccount(address: String) {
        webview.evaluateJavaScript("fclbridge.getAccount(\"\(address)\")")
    }

    func config() {
        webview.evaluateJavaScript("fclbridge.getConfig()")
    }
}

extension JSCoreManager: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        print("Finish")
    }
}

extension JSCoreManager: WKScriptMessageHandler {
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.json)
        delegate?.hideWebView()

        let json = message.json

        guard let name = json["name"] as? String else {
            return
        }

        switch name {
        case "reauth":
            guard let object = json["object"] as? AnyObject,
                let addr = object["addr"] as? String else {
                return
            }
            delegate?.showAddress(address: addr)
        case "getConfig":
            guard let object = json["object"] as? AnyObject,
                let env = object["accessNode.api"] as? String else {
                return
            }
            delegate?.showEnv(env: env)
        case "account":
            guard let object = json["object"] as? AnyObject,
                let balance = object["balance"] as? Int64 else {
                return
            }
            delegate?.showBalance(balance: String(balance))
        default:
            return
        }
    }
}

extension WKScriptMessage {
    var json: [String: Any] {
        if let string = body as? String,
            let data = string.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = object as? [String: Any] {
            return dict
        } else if let object = body as? [String: Any] {
            return object
        }
        return [:]
    }
}
