//
//  AlertManager.swift
//  SSLPinning
//
//  Created by Sohanur Rahman on 31/5/25.
//


import UIKit

class AlertManager {
    
    static let shared = AlertManager()
    
    private init() {}
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            guard let topViewController = self.getTopViewController() else {
                print("⚠️ Unable to find top view controller to present alert.")
                return
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func getTopViewController(base: UIViewController? = UIApplication.shared.connectedScenes
                                        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                                        .first?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        }
        
        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        
        return base
    }
}
