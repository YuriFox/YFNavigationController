//
//  YFNavigationController.swift
//  TestDich
//
//  Created by Yuri Fox on 21.02.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import UIKit

public protocol YFNavigationControllerSource: class {
    var navigationBarColor: UIColor { get }
}

extension YFNavigationControllerSource where Self: UIViewController {
    
    func updateNavigationBarAppearance() {
        let controller = self.navigationController as? YFNavigationController
        controller?.navigationBarColor = self.navigationBarColor
    }
    
}

public class YFNavigationController: UINavigationController {
    
    private weak var navigationBarView: UIView?
    
    public var navigationBarHeightOffset: CGFloat {
        set {
            guard let navigationBarView = self.navigationBarView else { return }
            let defaultHeight = UIApplication.shared.statusBarFrame.height + self.navigationBar.bounds.height
            navigationBarView.frame.size.height = defaultHeight + newValue
        }
        get {
            guard let navigationBarView = self.navigationBarView else { return 0 }
            let defaultHeight = UIApplication.shared.statusBarFrame.height + self.navigationBar.bounds.height
            return navigationBarView.frame.height - defaultHeight
        }
    }
    
    public var navigationBarColor: UIColor? {
        set(newColor) {
            
            if let navigationBarView = self.navigationBarView {
                self.navigationBar.sendSubview(toBack: navigationBarView)
                navigationBarView.backgroundColor = newColor
                return
            }
            
            self.clearAppearance()
            
            let statusBarFrame = UIApplication.shared.statusBarFrame
            let rect = CGRect(x: 0, y: -statusBarFrame.height, width: self.navigationBar.bounds.width, height: statusBarFrame.height + self.navigationBar.bounds.height)
            
            let view = UIView(frame: rect)
            view.backgroundColor = newColor
            view.isUserInteractionEnabled = false
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.navigationBar.insertSubview(view, at: 0)
            self.navigationBarView = view
            
        }
        get {
            return self.navigationBarView?.backgroundColor
        }
    }
    
    private var pushAnimator = YFNavigationControllerPushAnimator()
    private var popAnimator = YFNavigationControllerPopAnimator()
    private lazy var interactiveTransition: YFNavigationControllerInteractiveTransition = {
        let transaction = YFNavigationControllerInteractiveTransition()
        transaction.popAnimator = self.popAnimator
        return transaction
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialize()
        
    }
    
    private func initialize() {
        self.interactiveTransition.navigationController = self
        self.delegate = self
    }
    
    public func setDefaultAppearance() {
        self.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationBar.shadowImage = nil
        
        self.navigationBarView?.removeFromSuperview()
        self.navigationBarView = nil
        
    }
    
    private func clearAppearance() {
        let clearImage = UIImage()
        self.navigationBar.setBackgroundImage(clearImage, for: .default)
        self.navigationBar.shadowImage = clearImage
    }
    
}

extension YFNavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return operation == .pop ? self.popAnimator : self.pushAnimator
        
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return self.interactiveTransition.transitionInProgress ? self.interactiveTransition : nil
        
    }
    
}
