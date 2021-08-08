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
    func showMessage()
    func hideWebView()
}

class JSCoreManager: NSObject {
    private var viewModel: ViewModel?

    static let shared = JSCoreManager()

    var delegate: JSBridgeDelegate?

    var server: HttpServer!

    lazy var webview: WKWebView = {
        let webview = WKWebView(frame: .zero, configuration: webviewConfig)
        let url = URL(string: "http://127.0.0.1:8080")!
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        webview.navigationDelegate = self
        return webview
    }()

    lazy var webviewConfig: WKWebViewConfiguration = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
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
                .put("discovery.wallet", "https://fcl-discovery.onflow.org/testnet/authn");
            
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

    override init() {
        let url = Bundle.main.path(forResource: "index", ofType: "html")!
        let source = try! String(contentsOfFile: url)
        server = HttpServer()
        server["/"] = { _ in
            HttpResponse.ok(.text(source))
        }
        try! server.start()
    }

    func setViewModel(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func auth() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.webview.evaluateJavaScript("fclbridge.reauth()")
        }
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
        viewModel?.hideWebView()

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
            viewModel?.showAddress(address: addr)
        case "getConfig":
            guard let object = json["object"] as? AnyObject,
                let env = object["env"] as? String else {
                return
            }

            viewModel?.showEnv(env: env)
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
