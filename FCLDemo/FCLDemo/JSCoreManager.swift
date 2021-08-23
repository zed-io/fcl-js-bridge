//
//  JSCoreManager.swift
//  JSCoreManager
//
//  Created by lmcmz on 4/8/21.
//

import Foundation
import WebKit

protocol JSBridgeDelegate {
    func showAddress(address: String)
    func showEnv(env: String)
    func showBalance(balance: String)
    func showWebView()
    func hideWebView()
    func showScriptOne(result: String)
}

class JSCoreManager: NSObject {
    static let shared = JSCoreManager()

    var delegate: JSBridgeDelegate?

    var isDebug = true

    var defaultWallet: Flow.WalletNode = Flow.WalletNode.blcoto

    var defaultChainId: Flow.ChainId = Flow.ChainId.mainnet

    let walletURL: [Flow.ChainId: [Flow.WalletNode: String]] = [
        .testnet: [
            .blcoto: "https://flow-wallet-testnet.blocto.app/authn",
            .flow: "https://fcl-discovery.onflow.org/testnet/authn",
        ],
        .mainnet: [
            .blcoto: "https://flow-wallet.blocto.app/authn",
            .flow: "https://fcl-discovery.onflow.org/authn",
        ],
    ]

    let nodeURL: [Flow.ChainId: String] = [
        .testnet: "https://access-testnet.onflow.org",
        .mainnet: "https://flow-access-mainnet.portto.io",
    ]

    lazy var webview: WKWebView = {
        let webview = WKWebView(frame: .zero, configuration: webviewConfig)
        let url = Bundle.main.url(forResource: isDebug ? "index-dev" : "index", withExtension: "html")!
        let source = try! String(contentsOf: url)
        webview.loadHTMLString(source, baseURL: URL(string: "http://fcl-bridge-demo")!)
        webview.navigationDelegate = self
        return webview
    }()

    lazy var webviewConfig: WKWebViewConfiguration = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs

        let controller = WKUserContentController()

        if isDebug {
            var providerJsString = Bundle.main.path(forResource: "fcl-min", ofType: "js")!
            let source = try! String(contentsOfFile: providerJsString)
            let providerScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            controller.addUserScript(providerScript)
        }

        controller.add(self, name: "_fcl_")
        config.userContentController = controller
        return config
    }()

    func auth() {
        webview.evaluateJavaScript("fclbridge.reauth()")
    }

    func getAccount(address: String) {
        webview.evaluateJavaScript("fclbridge.getAccount(\"\(address)\")")
    }

    func config() {
        webview.evaluateJavaScript("fclbridge.getConfig()")
    }

    func sendTransaction() {
        webview.evaluateJavaScript("fclbridge.sendTransaction();")
    }

    func scriptOne() {
        webview.evaluateJavaScript("fclbridge.scriptOne()")
    }

    func setConifg() {
        webview.allowsLinkPreview = true
    }

    func changeNode(chainID: Flow.ChainId) {
        defaultChainId = chainID
        let nodeURL = nodeURL[chainID]
        webview.evaluateJavaScript(
            """
            window.fcl.config()
                .put("env", \"\(defaultChainId.rawValue)\")
                .put("accessNode.api", \"\(nodeURL!)\");
            """
        )
    }

    func changeWallet(wallet: Flow.WalletNode) {
        defaultWallet = wallet
        let walletURL = walletURL[defaultChainId]![wallet]
        webview.evaluateJavaScript(
            """
            window.fcl.config()
                .put("discovery.wallet", \"\(walletURL!)\");
            """
        )
    }
}

extension JSCoreManager: WKNavigationDelegate {
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        let wallet = walletURL[defaultChainId]![defaultWallet]
        let node = nodeURL[defaultChainId]
        webview.evaluateJavaScript(
            """
            window.fcl.config()
                .put("env", \"\(defaultChainId.rawValue)\")
                .put("service.OpenID.scopes", "email")
                .put("app.detail.icon", "https://placekitten.com/g/200/200")
                .put("app.detail.title", "fcl js bridge demo")
                .put("challenge.scope", "email") // request for Email
                .put("accessNode.api", \"\(node!)\")
                .put("discovery.wallet", \"\(wallet!)\");
            """
        )
    }
}

extension JSCoreManager: WKScriptMessageHandler {
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.json)

        guard let response = extractMethod(message: message) else {
            return
        }

        let json = message.json

        switch response.name {
        case Flow.BridgeMethod.getConfig.rawValue:
            guard let model: Flow.ResponseModel<Flow.Config> = extractObject(message: message) else {
                return
            }
            let object = model.object
            delegate?.showEnv(env: object.accessNode)
        case Flow.BridgeMethod.show.rawValue:
            delegate?.showWebView()
        case Flow.BridgeMethod.hide.rawValue:
            delegate?.hideWebView()
        case Flow.BridgeMethod.reauth.rawValue:
            guard let object = json["object"] as? AnyObject,
                let addr = object["addr"] as? String else {
                return
            }
            delegate?.showAddress(address: addr)
        case Flow.BridgeMethod.account.rawValue:
            guard let object = json["object"] as? AnyObject,
                let balance = object["balance"] as? Int64 else {
                return
            }
            delegate?.showBalance(balance: String(balance))

        case Flow.BridgeMethod.scriptOne.rawValue:
            guard let result = json["object"] as? Int else {
                return
            }
            delegate?.showScriptOne(result: String(result))
        default:
            return
        }
    }

    private func extractMethod(message: WKScriptMessage) -> Flow.ResponseMethod? {
        let decoder = JSONDecoder()
        if let string = message.body as? String,
            let data = string.data(using: .utf8),
            let model = try? decoder.decode(Flow.ResponseMethod.self, from: data) {
            return model
        } else if let object = message.body as? [String: Any],
            let data = try? JSONSerialization.data(withJSONObject: object, options: []),
            let model = try? decoder.decode(Flow.ResponseMethod.self, from: data) {
            return model
        }
        return nil
    }

    private func extractObject<T>(message: WKScriptMessage) -> Flow.ResponseModel<T>? {
        let decoder = JSONDecoder()
        if let string = message.body as? String,
            let data = string.data(using: .utf8),
            let model = try? decoder.decode(Flow.ResponseModel<T>.self, from: data) {
            return model
        } else if let object = message.body as? [String: Any],
            let data = try? JSONSerialization.data(withJSONObject: object, options: []),
            let model = try? decoder.decode(Flow.ResponseModel<T>.self, from: data) {
            return model
        }
        return nil
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
