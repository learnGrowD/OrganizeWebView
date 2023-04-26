//
//  BaseViewController.swift
//  OrganizeWebView
//
//  Created by 도학태 on 2023/04/26.
//

import Foundation
import UIKit



extension UIViewController {
    var rootViewController : UIViewController? {
        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController
    }
    
    var topMostViewController: UIViewController? {
        guard let rootViewController = self.rootViewController else { return nil }

        var topMostViewController = rootViewController

        while let presentedViewController = topMostViewController.presentedViewController {
            topMostViewController = presentedViewController
        }

        while let parentViewController = topMostViewController.parent {
            if parentViewController is UINavigationController {
                topMostViewController = parentViewController
            } else if let presentedViewController = parentViewController.presentedViewController, presentedViewController != topMostViewController {
                topMostViewController = presentedViewController
            } else {
                break
            }
        }
        
        
        if topMostViewController.isViewLoaded && topMostViewController.view.window != nil {
            return topMostViewController
        } else {
            return nil
        }
    }
    
    var depthViewController : UIViewController? {
        get {
            var depthViewController = self.topMostViewController
            
            /*
             TabBar
             */
            if let tabBarController = depthViewController as? UITabBarController {
                depthViewController = tabBarController.selectedViewController
            }
            
            /*
             Navigation
             */
            if let navigationController = depthViewController as? UINavigationController {
                depthViewController = navigationController.visibleViewController
            }
            
            if depthViewController?.isViewLoaded == true && depthViewController?.view.window != nil {
                return depthViewController
            } else {
                return nil
            }
        }
    }
}

class BaseViewController : UIViewController {
    
    /*
     재시도 했을때 호출되는 함수
     */
    func retry() {}
}
