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
    
    let button1 = UILabel().then {
        $0.textColor = .black
        $0.text = "Start WebView"
    }
    
    let button2 = UILabel().then {
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
        
        button1.rx.tapGesture()
            .when(.recognized)
            .bind(onNext : { [weak self] _ in
                guard let self = self else { return }
                let person = Person(id: 88, name: "D", age: 26, address: "서현동")
                let url = SwiftUrl(person: person)
                let vc = CommonWebViewController(urlProtocol: url)
                
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        button2.rx.tapGesture()
            .when(.recognized)
            .bind(onNext : { [weak self] _ in
                guard let self = self else { return }
                
                let url = CommonUrl("https://www.naver.com")
                let navInfo = NavigationBarInfo(navTitle: "Naver", type: 0)
                let vc = CommonWebViewController(urlProtocol: url, navInfo: navInfo)
                
//                self.present(vc, animated: true)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func layout() {
        [
            button1,
            button2
        ].forEach {
            view.addSubview($0)
        }
        
        button1.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        button2.snp.makeConstraints {
            $0.top.equalTo(button1.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
    }
}
