//
//  WebView.swift
//  FCLDemo
//
//  Created by lmcmz on 28/7/21.
//

import SwiftUI
import WebKit

struct Webview: UIViewRepresentable {
    let url: URL
    func makeUIView(context _: UIViewRepresentableContext<Webview>) -> WKWebView {
        let webview = WKWebView(frame: .zero, configuration: webviewConfig())
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        return webview
    }

    func updateUIView(_ webview: WKWebView, context _: UIViewRepresentableContext<Webview>) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }

    private func webviewConfig() -> WKWebViewConfiguration {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let source =
            """
            (function() {
                window.fclProvider = new fclProvider.Provider();
                window.fcl.config()
                .put("app.detail.title", "1111111")
                .put("challenge.scope", "email")
                .put("accessNode.api", "https://access-testnet.onflow.org")
                .put("challenge.handshake", "https://flow-wallet-testnet.blocto.app/authn");

                window.fclProvider.postMessage = (jsonString) => {
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
        let handler = JSBridge()
        controller.addUserScript(script)
        controller.addUserScript(providerScript)
        controller.add(handler, name: "_fcl_")
        config.userContentController = controller
        return config
    }
}
