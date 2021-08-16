//
//  ContentView.swift
//  FCLDemo
//
//  Created by lmcmz on 28/7/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()

    init() {
        JSCoreManager.shared.delegate = viewModel
        JSCoreManager.shared.setConifg()
    }

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {
                Section {
                    Button("Auth") {
                        viewModel.shouldShowWebView.toggle()
                        JSCoreManager.shared.auth()
                    }

                    Text(verbatim: viewModel.address)
                }

                Section {
                    TextField("Account", text: $viewModel.searchAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle()).padding()
                    Button("Get Account Balance") {
                        JSCoreManager.shared.getAccount(address: viewModel.searchAddress)
                    }
                    Text(verbatim: viewModel.searchAddressBalance)
                }

                Section {
                    Button("Config") {
                        JSCoreManager.shared.config()
                    }

                    Text(verbatim: viewModel.env)
                }

                HStack {
                    Picker("iFrame", selection: $viewModel.walletNode, content: {
                        Text("Flow").tag(Flow.WalletNode.flow)
                        Text("Blocoto").tag(Flow.WalletNode.blcoto)
                    }).onChange(of: viewModel.walletNode, perform: { _ in
                        viewModel.changeWallet()
                    })
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()

                    Picker("Node", selection: $viewModel.chainId, content: {
                        Text("Testnet").tag(Flow.ChainId.testnet)
                        Text("Mainnet").tag(Flow.ChainId.mainnet)
                    }).onChange(of: viewModel.chainId, perform: { _ in
                        viewModel.changeChain()
                    })
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                }
            }

            if viewModel.shouldShowWebView {
                Webview(viewModel: viewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
