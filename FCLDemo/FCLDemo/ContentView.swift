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

                Picker("iFrame", selection: $viewModel.selectedIndex, content: {
                    Text("Flow").tag(0)
                    Text("Blocoto").tag(1)
                })
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                Picker("Node", selection: $viewModel.selectedNodeIndex, content: {
                    Text("Testnet").tag(0)
                    Text("Mainnet").tag(1)
                })
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
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
