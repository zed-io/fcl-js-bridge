//
//  ContentView.swift
//  FCLDemo
//
//  Created by lmcmz on 28/7/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
//        "https://port.onflow.org"
//        "https://fcl-demo.netlify.app"
        // "about:blank"

        ZStack {
            Button("Auth") {}
            Webview(url: URL(string:
                "about:blank"
//                "https://fcl-demo.netlify.app"
            )!)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
