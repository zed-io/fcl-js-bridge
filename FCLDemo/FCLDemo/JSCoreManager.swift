//
//  JSCoreManager.swift
//  JSCoreManager
//
//  Created by lmcmz on 4/8/21.
//

import Foundation
import JavaScriptCore

class JSCoreManager {
    let context = JSContext()

    init() {
        context?.exceptionHandler = { _, exception in
            print(exception!.toString()!)
        }

        let providerJsString = Bundle.main.path(forResource: "fcl-min", ofType: "js")!
        let providerScript = try! String(contentsOfFile: providerJsString)
        context?.evaluateScript(providerScript)

        print(context?.evaluateScript("fcl.VERSION").toString())

        let test = context?.objectForKeyedSubscript("window.fcl.VERSION")
        let result = test?.call(withArguments: [])
        print(result)
    }
}
