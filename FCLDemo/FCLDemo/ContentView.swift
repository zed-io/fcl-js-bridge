//
//  ContentView.swift
//  FCLDemo
//
//  Created by lmcmz on 28/7/21.
//

import SwiftUI

struct ContentView: View {
    @State var isShown = false

    var body: some View {
//        "https://port.onflow.org"
//        "https://fcl-demo.netlify.app"
        // "about:blank"

        ZStack {
            Button("Auth") {
                JSCoreManager.shared.auth()
                isShown.toggle()
            }
            if isShown {
                Webview()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
