//
//  WebView.swift
//  FCLDemo
//
//  Created by lmcmz on 28/7/21.
//

import SafariServices
import SwiftUI
import WebKit

struct Webview: UIViewRepresentable {
    func makeUIView(context _: UIViewRepresentableContext<Webview>) -> WKWebView {
        return JSCoreManager.shared.webview
    }

    func updateUIView(_ webview: WKWebView, context _: UIViewRepresentableContext<Webview>) {}
}
