//
//  YFNavigationControllerAnimator.swift
//  TestDich
//
//  Created by Yuri Fox on 21.02.2018.
//  Copyright © 2018 Yuri Lysytsia. All rights reserved.
//

import UIKit

class YFNavigationControllerPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else { return }
        
        let color = (toVC as? YFNavigationControllerSource)?.navigationBarColor
        
        let shadowMask = UIView(frame: transitionContext.containerView.bounds)
        shadowMask.backgroundColor = UIColor.black
        shadowMask.alpha = 0
        transitionContext.containerView.addSubview(shadowMask)
        transitionContext.containerView.addSubview(toVC.view)
        
        let startFromViewFrame = fromVC.view.frame
        let finalToViewFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalToViewFrame.offsetBy(dx: finalToViewFrame.width, dy: 0)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            toVC.view.frame = finalToViewFrame
            
            let finalFromFrame = startFromViewFrame.offsetBy(dx: -startFromViewFrame.width / 2, dy: 0)
            fromVC.view.frame = finalFromFrame
            shadowMask.alpha = 0.3
            
            if let navigationController = fromVC.navigationController as? YFNavigationController, let color = color {
                
                navigationController.navigationBarColor = color
                
            }
            
        }) { _ in
            
            fromVC.view.frame = startFromViewFrame
            shadowMask.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        }
        
    }
    
}

class YFNavigationControllerPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var animating = false

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else { return }

        let color = (toVC as? YFNavigationControllerSource)?.navigationBarColor
        
        let shadowMask = UIView(frame: transitionContext.containerView.bounds)
        shadowMask.backgroundColor = UIColor.black
        shadowMask.alpha = 0.3

        let finalToFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalToFrame.offsetBy(dx: -finalToFrame.width/2, dy: 0)

        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        transitionContext.containerView.insertSubview(shadowMask, aboveSubview: toVC.view)

        let duration = self.transitionDuration(using: transitionContext)

        animating = true
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            fromVC.view.frame = fromVC.view.frame.offsetBy(dx: fromVC.view.frame.width, dy: 0)
            toVC.view.frame = finalToFrame
            shadowMask.alpha = 0
            
            if let navigationController = fromVC.navigationController as? YFNavigationController, let color = color {
                
                navigationController.navigationBarColor = color
                
            }
            
        }) { (finished) -> Void in
            self.animating = false
            shadowMask.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
}

class YFNavigationControllerInteractiveTransition: UIPercentDrivenInteractiveTransition {
 
    var transitionInProgress: Bool = false
    var shouldCompleteTransition = false
    
    weak var navigationController: UINavigationController! {
        didSet {
            let panGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            panGesture.edges = .left
            self.navigationController.view.addGestureRecognizer(panGesture)
        }
    }

    weak var popAnimator: YFNavigationControllerPopAnimator?
    
    override var completionSpeed: CGFloat {
        get {
            return max(CGFloat(0.5), 1 - self.percentComplete)
        } set {
            super.completionSpeed = newValue
        }
    }
    
    @objc func handlePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: sender.view)
        let velocity = sender.velocity(in: sender.view)
        let progress = translation.x / self.navigationController.view.frame.width
        
        switch sender.state {
        case .began:
            if let popAnimator = self.popAnimator, !popAnimator.animating {
                self.transitionInProgress = true
                if velocity.x > 0 && self.navigationController.viewControllers.count > 0 {
                    navigationController.popViewController(animated: true)
                }
            }
            
        case .changed:
            self.shouldCompleteTransition = progress > 0.5
            self.update(progress)
        case .cancelled:
            if self.transitionInProgress {
                self.cancel()
                self.transitionInProgress = false
            }
        case .ended:
            if self.transitionInProgress {
                self.shouldCompleteTransition ? self.finish() : self.cancel()
                self.transitionInProgress = false
            }
        default:
            return
        }

    }
    
}
