//
//  CommonBottomModal.swift
//  OrganizeWebView
//
//  Created by 도학태 on 2023/04/26.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa
import RxGesture
import PanModal


struct CommonBottomModalAction {
    let title : String
    let titleColor : UIColor
    let action : (CommonBottomModal) -> Void
}

class CommonBottomModal : BaseViewController {
    
    let disposeBag = DisposeBag()
    
    let blurView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    var actions : [CommonBottomModalAction] = []
    
    let stackView = UIStackView().then {
        $0.spacing = 5
        $0.axis = .vertical
    }
    
    let cancleButton = UILabel().then {
        $0.heightAnchor.constraint(equalToConstant: 56).isActive = true
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.textAlignment = .center
    }
    
    func show() {
        
        /*
         최상단 ViewController가 자기 자신인지 판단
         */
        if topMostViewController !== self {
            topMostViewController?.presentPanModal(self)
        }
    }
    
    private func configure(
        _ actions : [CommonBottomModalAction],
        _ actionBackgroundColor : UIColor,
        _ cancelMessage : String,
        _ cancelBackgroundColor : UIColor
    ) {
        
        /*
         actionData Label로 변환
         실질 적인 UI/UX를 하는 실재로 변환하는 과정
         */
        let labels = actions
            .map { action in
                UILabel().then {
                    $0.text = action.title
                    $0.textColor = action.titleColor
                    
                    $0.heightAnchor.constraint(equalToConstant: 56).isActive = true
                    $0.backgroundColor = actionBackgroundColor
                    $0.clipsToBounds = true
                    $0.layer.cornerRadius = 16
                    $0.textAlignment = .center
                }
            }
        
        cancleButton.text = cancelMessage
        cancleButton.backgroundColor = cancelBackgroundColor
        
        /*
         stackView에 추가
         */
        labels.forEach {
            stackView.addArrangedSubview($0)
        }
        stackView.addArrangedSubview(cancleButton)
        
        
        [
            blurView,
            stackView
        ].forEach {
            view.addSubview($0)
        }
        
        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        /*
         actions의 아이템 개수에 따라 stackView의 크기를 동적으로 결정
         */
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(38)
            /*
             주요 코드
             */
            $0.top.equalTo(labels[0])
        }
        
        
        /*
         bind
         */
        blurView.rx.tapGesture()
            .when(.recognized)
            .bind(onNext : { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        cancleButton.rx.tapGesture()
            .when(.recognized)
            .bind(onNext : { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        /*
         commonActionDelegate에서 정의한 함수 호출
         */
        labels
            .enumerated()
            .forEach { index, label in
                label.rx.tapGesture()
                .when(.recognized)
                .bind(onNext : { [weak self] _ in
                    guard let self = self else { return }
                    self.dismiss(animated: true) {
                        actions[index].action(self)
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
        
    class Builder {
        /*
         필요한 Design에 맞게 속성 추가
         */
        private var actions : [CommonBottomModalAction] = []
        
        private var actionBackground : UIColor = .white
        
        private var cancelMessage : String = "취소"
        private var cancelBackgroundColor : UIColor = .gray
        
        
        func setActions(_ actions : [CommonBottomModalAction]) -> Self {
            self.actions = actions
            return self
        }
        
        func setActionBackgroundColor(_ color : UIColor) -> Self {
            self.actionBackground = color
            return self
        }
        
        func setCancelMessage(_ message : String) -> Self {
            self.cancelMessage = message
            return self
        }
        
        func cancelBackgroundColor(_ color : UIColor) -> Self {
            self.cancelBackgroundColor = color
            return self
        }
        
        
        /*
         설정을 모두 완료하고 이때 CommonBottomModal 생성
         */
        func build() -> CommonBottomModal {
            return CommonBottomModal().then {
                $0.configure(
                    actions,
                    actionBackground,
                    cancelMessage,
                    cancelBackgroundColor
                )
            }
        }
        
    }
}


extension CommonBottomModal : PanModalPresentable {
    
    var showDragIndicator: Bool {
        return false
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(0)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(0)
    }
    var anchorModalToLongForm: Bool {
        return false
    }
}
