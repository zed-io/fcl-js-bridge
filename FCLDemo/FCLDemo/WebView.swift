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
    var viewModel: ViewModel
    func makeUIView(context _: UIViewRepresentableContext<Webview>) -> WKWebView {
        JSCoreManager.shared.setViewModel(viewModel: viewModel)
        return JSCoreManager.shared.webview
    }

    func updateUIView(_ webview: WKWebView, context _: UIViewRepresentableContext<Webview>) {}

    func makeCoordinator() -> JSCoreManager {
        return JSCoreManager.shared
    }
}
