//
//  ViewModel.swift
//  FCLDemo
//
//  Created by lmcmz on 8/8/21.
//

import Foundation

class ViewModel: ObservableObject {
    @Published var shouldShowWebView = false

    @Published var address = ""

    @Published var env = ""

    func showAddress(address: String) {
        self.address = address
    }

    func showEnv(env: String) {
        self.env = env
    }

    func hideWebView() {
        shouldShowWebView = false
    }

    init() {}
}
