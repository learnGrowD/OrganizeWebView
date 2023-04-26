//
//  MainViewController.swift
//  OrganizeWebView
//
//  Created by 도학태 on 2023/04/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class MainViewController : BaseViewController {
    let disposeBag = DisposeBag()
    
    let button = UILabel().then {
        $0.textColor = .black
        $0.text = "Start WebView"
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        
        button.rx.tapGesture()
            .when(.recognized)
            .bind(onNext : { [weak self] _ in
                guard let self = self else { return }
                let url = CommonUrl("https://www.naver.com")
                let vc = CommonWebViewController(urlProtocol: url, isNavHide: false, navTitle: "NAVER")

                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func layout() {
        [
            button
        ].forEach {
            view.addSubview($0)
        }
        
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
    }
}
