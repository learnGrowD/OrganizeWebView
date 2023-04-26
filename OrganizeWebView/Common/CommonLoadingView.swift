//
//  CommonLoadingView.swift
//  OrganizeWebView
//
//  Created by 도학태 on 2023/04/26.
//

import Foundation
import Lottie
import UIKit


/*
 Lottie를 통한 LoadingView
 */

class CommonLoadingView {
    
    
    var loadingView : LottieAnimationView? = LottieAnimationView(name: "lottie").then {
    
        $0.isHidden = true
        $0.loopMode = .loop
        $0.play()
    }
    
    
    var timer : Timer? = nil
    var timeRemaining = 0.0
    
    
    
    convenience init(timeRemaining : Double = 0.8) {
        let superView = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.topMostViewController?.view
        self.init(superView: superView)
        self.timeRemaining = timeRemaining
    }
    
    
    init(superView : UIView?) {
        superView?.addSubview(loadingView!)
        loadingView?.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    
    func show() {
        /*
         touch 비활성
         */
        let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
        window?.isUserInteractionEnabled = false
        
        /*
         타이머가 동작하기 전에는 보여줘서는 안되기 때문에
         loadingView를 숨긴다.
         */
        loadingView?.isHidden = true
        
        startTimer()
    }
    
    
    func dismiss() {
        hide()
        stopTimer()
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
    
    private func hide() {
        /*
         touch 활성
         */
        let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
        window?.isUserInteractionEnabled = true
        
        self.loadingView?.isHidden = true
    }
    
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timeRemaining, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.timeRemaining -= self.timeRemaining

            /*
             0.8초가 지나면 호출
             */
            if self.timeRemaining == 0 {
                /*
                 loadingView zIndex 최고 레벨 부여
                 */
                self.loadingView?.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
                self.loadingView?.isHidden = false
            }

        }
    }
    
    
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}


