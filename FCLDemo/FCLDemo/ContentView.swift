//
//  ContentView.swift
//  FCLDemo
//
//  Created by lmcmz on 28/7/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()

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
                    Button("Config") {
                        JSCoreManager.shared.config()
                    }

                    Text(verbatim: viewModel.env)
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
