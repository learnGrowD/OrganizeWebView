//
//  CommonWebViewController.swift
//  OrganizeWebView
//
//  Created by 도학태 on 2023/04/26.
//

import Foundation
import UIKit
import WebKit
import SnapKit



/*
 1. LoadingView 대응
 2. Network Error View 대응
 */


class CommonWebViewController : UIViewController {
    
    let webView = CommonWebView(bridgeName: "will_d")
    
    
    convenience init(urlProtocol : CommonUrlProtocol) {
        self.init(nibName: nil, bundle: nil)
        /*
         WebViewLoad
         */
        self.webView.load(with : urlProtocol.getUrl())
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        attribute()
        registerBridge()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func registerBridge() {
        
        /*
         필자는 Bridge를 통한 Web과의 통신을 3가지로 나웠다.
         1. Native UI 제공
         2. 앱의 생명주기 전반에 걸쳐 존재하는 Data 공급
            - 더욱 고도화를 시킨다면 App에서 Server에 데이터를 요청하고 Web에 넘겨주는 것도 가능하다!
         3. 그 외 일반적인 동작
         */
        
        /*
         Native UI 제공
         */
        self.webView.addBridgeDelegate("provide_ui") { _ in
            
            /*
             1. Modal
             2. BottomModal
             3. Loading
             4. Toast
             etc....
             */
        }
        
        /*
         Native Data 제공
         */
        self.webView.addBridgeDelegate("provide_data") { _ in
            
        }
        
        /*
         그 외 일반적인 동작
         */
        self.webView.addBridgeDelegate("common") { _ in
            
        }
    }
    
    func attribute() {
        webView.navigationDelegate = self
    }
    
    func layout() {
        [
            webView
        ].forEach {
            view.addSubview($0)
        }
        
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension CommonWebViewController : WKNavigationDelegate {
    
    /*
     web 페이지의 로딩이 시작될때 호출되는 함수
     */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    /*
     web에서의 로딩이 완료되었을때 호출되는 함수
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    /*
     Network가 연결이 안되있을때 호출 되는 함수
     */
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    }
}
