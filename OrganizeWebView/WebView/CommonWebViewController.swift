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
import UIColor_Hex_Swift
import RxSwift
import RxCocoa

/*
 1. LoadingView 대응 -> 0
 2. Network Error View 대응 -> 0
 
 3. NavigationBar
 4. popUp에 대해서 대응
 */

class CommonWebViewController : BaseViewController {
    let disposeBag = DisposeBag()
    let webView = CommonWebView(bridgeName: "will_d")
    var urlProtocol : CommonUrlProtocol? = nil
    var isNavHide = false
    var navTitle = ""
    var isPresentShow = false
    var loadingView : CommonLoadingView? = nil
    
    
    /*
     popUp WebView
     */
    var popUpView : CommonWebView? = nil
    
    /*
     Navigation Show
     */
    convenience init(
        urlProtocol : CommonUrlProtocol,
        isNavHide : Bool = true,
        navTitle : String = "",
        isPresentShow : Bool = false
    ) {
        self.init(nibName: nil, bundle: nil)
        /*
         WebViewLoad
         */
        self.urlProtocol = urlProtocol
        self.isNavHide = isNavHide
        self.navTitle = navTitle
        self.isPresentShow = isPresentShow
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(isNavHide, animated: animated)
        self.title = navTitle
        if isPresentShow {
            let customView = UIImageView(image: UIImage(named: "exit")).then {
                $0.snp.makeConstraints {
                    $0.width.height.equalTo(44)
                }
            }
            customView.rx.tapGesture()
                .when(.recognized)
                .bind(onNext : { [weak self] _ in
                    guard let self = self else { return }
                    self.dismiss(animated: true)
                })
                .disposed(by: disposeBag)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customView)
            self.isPresentShow = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func retry() {
        self.webView.load(with: urlProtocol?.getUrl())
    }
    
    
    func controlShowHideNav(isHide : Bool) {
        self.navigationController?.setNavigationBarHidden(isHide, animated: false)
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
        self.webView.addBridgeDelegate(CommonWebView.PROVIDE_UI) {
            /*
             1. Modal
             2. BottomModal
             3. Loading
             4. Toast
             etc....
             */
            switch $0 {
            case "NATIVE_SHOW_BOTTOM_MODAL":
                let data = try? JSONDecoder().decode(ShowBottomModalResultDto.self, from: $1)
                guard let bridgeData = data else { return }
                let cancel = bridgeData.actions[bridgeData.actions.count - 1]

                var actions = bridgeData.actions.map { action in
                    CommonBottomModalAction(title: action.title ?? "", titleColor: UIColor(action.color ?? "")) { _ in
                        self.webView.evaluateJavaScript("doAction('\(action.actionId ?? "")')")
                    }
                }
                actions.remove(at: actions.count - 1)
                CommonBottomModal.Builder()
                    .setActions(actions)
                    .setCancelMessage(cancel.title ?? "")
                    .build()
                    .show()
            default:
                break
            }
        }
        
        /*
         Native Data 제공
         */
        self.webView.addBridgeDelegate(CommonWebView.PROVIDE_DATA) { name, _ in
            switch name {
            case "NATIVE_PROVIDE_IS_PRODUCT_RELEASE":
                self.webView.evaluateJavaScript("receiveData('\(AppConfigure.IS_PRODUCT_RELEASE)')")
            default:
                break
            }
        }
        
        /*
         그 외 일반적인 동작
         */
        self.webView.addBridgeDelegate(CommonWebView.COMMON) { [weak self] name, _ in
            guard let self = self else { return }
            switch name {
            case "back":
                self.navigationController?.popViewController(animated: true)
            case "SAVE_SOME_DATA":
                let userDefault = UserDefaults.standard
                userDefault.setValue(true, forKey: "some_value")
            default:
                break
            }
            
        }
    }
    
    func attribute() {
        /*
         delegate 설정
         */
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        let token = ""
        let script = """
        window.token="\(token)";
        """
        webView.injection(script)
    }
    
    func layout() {
        [
            webView,
        ].forEach {
            view.addSubview($0)
        }
        
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension CommonWebViewController : WKNavigationDelegate {
    
    func showLoading(timeRemaining : Double) {
        loadingView = CommonLoadingView(timeRemaining: timeRemaining)
        loadingView?.show()
        
    }
    
    func hideLoading() {
        loadingView?.dismiss()
        loadingView = nil
    }
    
    /*
     web 페이지의 로딩이 시작될때 호출되는 함수
     */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoading(timeRemaining: 0.0)
    }
    
    /*
     web에서의 로딩이 완료되었을때 호출되는 함수
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoading()
    }
    
    /*
     Network가 연결이 안되있을때 호출 되는 함수
     */
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideLoading()
        CommonRetryView.Builder()
            .setTitle("오류")
            .setRetryStr("재시도")
            .build()
            .show()
    }
}


/*
 POP_UP
 */

extension CommonWebViewController : WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        /*
         새로운 웹뷰 생성 그리고 화면위에 붙여준다.
         */
        popUpView = CommonWebView(frame: view.bounds, configuration: configuration)
        popUpView?.navigationDelegate = self
        popUpView?.uiDelegate = self
        view.addSubview(popUpView ?? UIView())
        popUpView?.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        return popUpView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        /*
         삭제
         */
        if webView == popUpView {
            self.popUpView?.removeFromSuperview()
            self.popUpView = nil
        }
        
        
    }
}



