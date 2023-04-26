//
//  CommonRetryView.swift
//  OrganizeWebView
//
//  Created by 도학태 on 2023/04/26.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class CommonRetryView : UIView {
    static let EXIST = 1
    
    let disposeBag = DisposeBag()
    
    let titleLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    let retryButton = UILabel().then {
        $0.textColor = .systemRed
        $0.numberOfLines = 0
    }
    
    override var intrinsicContentSize: CGSize {
        let titleSize = titleLabel.intrinsicContentSize
        let buttonSize = retryButton.intrinsicContentSize
        let width = min(titleSize.width, buttonSize.width)
        let height = titleSize.height + 16 + buttonSize.height
        return CGSize(width: width, height: height)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        let topMostViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.topMostViewController
        let alreadyAdded = topMostViewController?.view.subviews.contains(where: { $0.tag == CommonRetryView.EXIST }) ?? false
        guard !alreadyAdded else { return }
        
        topMostViewController?.view.addSubview(self)
        self.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func bind() {
        retryButton.rx.tapGesture()
            .when(.recognized)
            .bind(onNext : { [weak self] _ in
                let topMostViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.depthViewController
                let baseViewController = topMostViewController as? BaseViewController
                
                /*
                 BaseViewController에서 Override한 retry함수 호출
                 */
                baseViewController?.retry()
                
                self?.removeFromSuperview()
            })
            .disposed(by: disposeBag)
    }
    
    private func configure(
        _ title : String,
        _ buttonText : String
    ) {
        titleLabel.text = title
        retryButton.text = buttonText
        
        
        /*
         tag 설정
         */
        self.tag = CommonRetryView.EXIST
        
        /*
         frame 설정
         */
        self.frame = CGRect(origin: .zero, size: intrinsicContentSize)
    }
    
    
    func layout() {
        [
            titleLabel,
            retryButton
        ].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        retryButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.centerX.equalTo(titleLabel)
        }
        
    }
    
    
    class Builder {
        private var title : String    = ""
        private var retryStr : String = ""
        
        func setTitle(_ title : String) -> Self {
            self.title = title
            return self
        }
        
        func setRetryStr(_ retryStr : String) -> Self {
            self.retryStr = retryStr
            return self
        }
        
        func build() -> CommonRetryView {
            CommonRetryView().then {
                $0.configure(
                    title,
                    retryStr
                )
            }
        }
    }
    
    
    
    
}


