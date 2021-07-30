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
        Webview(url: URL(string: "http://127.0.0.1:3000")!)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
