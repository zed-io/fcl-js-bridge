//
//  ViewModel.swift
//  FCLDemo
//
//  Created by lmcmz on 8/8/21.
//

import Foundation

class ViewModel: ObservableObject, JSBridgeDelegate {
    @Published var shouldShowWebView = false

    @Published var walletNode: Flow.WalletNode = JSCoreManager.shared.defaultWallet

    @Published var chainId: Flow.ChainId = JSCoreManager.shared.defaultChainId

    @Published var address = ""

    @Published var env = ""

    @Published var searchAddress = "0x5d2cd5bf303468fa"
    @Published var searchAddressBalance = "0"

    func showAddress(address: String) {
        self.address = address
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

    func changeWallet() {
        JSCoreManager.shared.changeWallet(wallet: walletNode)
    }

    func changeChain() {
        JSCoreManager.shared.changeNode(chainID: chainId)
        JSCoreManager.shared.changeWallet(wallet: walletNode)
    }

    init() {}
}
