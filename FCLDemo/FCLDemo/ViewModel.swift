//
//  ViewModel.swift
//  FCLDemo
//
//  Created by lmcmz on 8/8/21.
//

import Foundation

class ViewModel: ObservableObject, JSBridgeDelegate {
    @Published var shouldShowWebView = false

    @Published var selectedIndex = 0

    @Published var selectedNodeIndex = 0

    @Published var address = ""

    @Published var env = ""

    @Published var searchAddress = "0x5d2cd5bf303468fa"
    @Published var searchAddressBalance = "0"

    func showAddress(address: String) {
        self.address = address
    }

    func getSelectedIndex() -> Int {
        return selectedIndex
    }

    func getSelectedNodeIndex() -> Int {
        return selectedNodeIndex
    }

    func showEnv(env: String) {
        self.env = env
    }

    func hideWebView() {
        shouldShowWebView = false
    }

    func showBalance(balance: String) {
        searchAddressBalance = balance
    }

    init() {}
}
