//
//  CommonWebView.swift
//  OrganizeWebView
//
//  Created by 도학태 on 2023/04/25.
//

import Foundation
import WebKit


/*
 1. Bridge Name
 2. NetWork Error 대응 -> 재시도를 통해서 해결
 3. LoadingView
 */

/*
 1. FunctionName
 2. JsonData
 */
typealias BridgeDelegate = (String, Data) -> Void
class CommonWebView : WKWebView {
    /*
     BrideDelegate Name
     */
    static let PROVIDE_UI   = "provide_ui"
    static let PROVIDE_DATA = "provide_data"
    static let COMMON       = "common"
    
    private var bridgeName : String = ""
    private var bridgeDelegates : [String : BridgeDelegate] = [:]
    
    convenience init(bridgeName : String) {
        self.init(frame: .zero)
        self.bridgeName = bridgeName
        self.attribute()
    }
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(with str : String) {
        let url = URL(string: str)
        let urlReq = URLRequest(url: url!)
        self.load(urlReq)
    }
    
    func load(with url : URL?) {
        let urlReq = URLRequest(url: url!)
        self.load(urlReq)
    }
    
    func injection(_ script : String) {
        let userJavascript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(userJavascript)
    }
    
    func addBridgeDelegate(_ name : String, delegate : @escaping BridgeDelegate) {
        bridgeDelegates[name] = delegate
    }
    
    func attribute() {
        /*
         window.open()을 허용
         그러나 IOS 9 이후 부터는 무시 된다.
         */
        self.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        /*
         WebPage에서 javascript 코드를 실행 할 수 있다.
         */
        if #available(iOS 14.0, *) {
            self.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            self.configuration.preferences.javaScriptEnabled = true
        }

        /*
         WebView에서 링크 미리보기 제한
         기본값이 true
         */
        self.allowsLinkPreview = false
        
        /*
         webView bridge 연결
         *** bridgeName을 통해서 생성한 CommonWebView라면 WebView와 통신을 한다.
         그렇지 않은 CommonWebView라면 소통을 할 수 없다.
         bridgeName을 하나만 연결하고 이벤트 및 데이터 전달은 약속한 JSON 규격을 통해서 통신한다. 그럼으로 하나만 설정한다.
         */
        if !bridgeName.isEmpty {
            self.configuration.userContentController.add(self, name: bridgeName)
        }        
        
        /*
         WKWebView 캐시 날리기
         만약 캐시를 안날린다면 더 나은 사용자 경험을 유도 할 수 있다.
         - 캐시된 데이터는 웹 페이지를 더 빠르게 로딩하는 데 도움이 되며, 네트워크 사용량을 줄이는 데도 효과적
         */
        let chcheDataTypes : Set<String> = [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: chcheDataTypes, modifiedSince: date, completionHandler: {})
    }
}

extension CommonWebView : WKScriptMessageHandler {
    /*
     Bridge 대응
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let jsonStr = message.body as? String ?? "Bridge Message Type is not String"
        print("NATIVE_BRIDGE_RESULT_JSON : \(jsonStr)")
        /*
         웹에서 넘어오는 데이터 JSON String -> Data로 치환
         */
        let jsonData = jsonStr.data(using: .utf8) ?? Data()
        let functionName = (try? JSONDecoder().decode(CommonBridgeResultDto.self, from: jsonData).functionName) ?? ""
        /*
         설정된 Delegate들에게 일괄적으로 JsonData 전달
         */
        bridgeDelegates.forEach {
            $0.value(functionName, jsonData)
        }
        
    }
}
