//
//  ViewController.swift
//  WebViewDemo
//
//  Created by myx on 2021/11/4.
//

import UIKit
import JavaScriptCore
import WebKit

class ViewController: UIViewController {
    
    lazy var webView: WKWebView = {
        let frame = UIScreen.main.bounds
        let userContent = WKUserContentController()
        userContent.add(self, name: "shareAction")
        let config = WKWebViewConfiguration()
        config.userContentController = userContent
        let webView = WKWebView(frame: frame, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(webView)
        view.insertSubview(webView, at: 0)
        
        if let path = Bundle.main.path(forResource: "h5", ofType: "html") {
            let url = URL(fileURLWithPath: path)
            let req = URLRequest(url: url)
            webView.load(req)
        }
        
        ocWrapper()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        swiftJsCall()
    }
    
    func ocWrapper() {
        let wrapper = Wrapper()
        wrapper.foo()
    }
    
    func swiftJsCall() {
        guard
            let path = Bundle.main.path(forResource: "test", ofType: "js"),
            let script = try? String(contentsOfFile: path, encoding: .utf8)
        else { return }
        guard let context = JSContext() else { return }
        context.evaluateScript(script)
        // 这里的 @convention 是用来修饰闭包的，后面需要跟个参数 (block)
        let object: @convention (block) (String) -> Void = { text in
            print("来自 Swift 的回调: \(text)")
        }
        context.setObject(object, forKeyedSubscript: "print" as NSString)
        let function = context.objectForKeyedSubscript("printHello")
        function?.call(withArguments: [])
    }

}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("message.name: \(message.name)")
        print("message.body: \(message.body)")
    }
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("m: \(message)")
    }
}

extension ViewController: WKNavigationDelegate {}
