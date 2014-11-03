//
//  CardsViewController.swift
//  Tinder
//
//  Created by Terra Oldham on 10/30/14.
//  Copyright (c) 2014 HearsaySocial. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    var cardInitialCenter: CGPoint!
    @IBOutlet weak var imageView: UIImageView!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var reverseRotation = false
    var isPresenting: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onCustomPan:")
        imageView.addGestureRecognizer(panGestureRecognizer)

        // Do any additional setup after loading the view.
    }

    func onCustomPan(pan: UIPanGestureRecognizer) {
        var point = pan.locationInView(view)
        var velocity = pan.velocityInView(view)
        var translation = pan.translationInView(view)
        
        if panGestureRecognizer.state == UIGestureRecognizerState.Began {
            println("Gesture began at: \(point)")
            cardInitialCenter = imageView.center
            
            if point.y > cardInitialCenter.y {
                reverseRotation = true
            } else {
                reverseRotation = false
            }

        } else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
            println("Gesture changed at: \(point)")
            
            imageView.center.x = cardInitialCenter.x + translation.x
            imageView.center.y = cardInitialCenter.y + translation.y
            
            var angle = CGFloat(10 * M_PI / 180)
            if translation.x < 0 {
                angle = -angle
            }
            if reverseRotation {
                angle = -angle
            }
            imageView.transform = CGAffineTransformMakeRotation(angle)
            
        } else if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
            println("Gesture ended at: \(point)")
            if translation.x > 50 {
                imageView.center.x = 520
            } else if translation.x < -50 {
                imageView.center.x = -200
            } else {
                imageView.center.x = cardInitialCenter.x
                imageView.center.y = cardInitialCenter.y
                imageView.transform = CGAffineTransformIdentity
            }
        }
        
        
    }

    @IBAction func onTap(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("segue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var toViewController = segue.destinationViewController as ProfileViewController
        toViewController.image = self.imageView.image
        toViewController.modalPresentationStyle = UIModalPresentationStyle.Custom
        toViewController.transitioningDelegate = self
    }
    
    func animationControllerForPresentedController(presented: UIViewController!, presentingController presenting: UIViewController!, sourceController source: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        isPresenting = false
        return self
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        // The value here should be the duration of the animations scheduled in the animationTransition method
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        println("animating transition")
        var containerView = transitionContext.containerView()
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        if (isPresenting) {
            containerView.addSubview(toViewController.view)
            
            var profileVC = toViewController as ProfileViewController
            imageView.hidden = true
            profileVC.imageView.hidden = true
            toViewController.view.alpha = 0
            
            
            var window = UIApplication.sharedApplication().keyWindow
            var newPhoto = UIImageView(frame: imageView.frame)
            newPhoto.image = imageView.image
            newPhoto.contentMode = imageView.contentMode
            window.addSubview(newPhoto)
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: nil, animations: { () -> Void in
                newPhoto.frame = profileVC.imageView.frame
                toViewController.view.alpha = 1
                }, completion: { (finished: Bool) -> Void in
                newPhoto.removeFromSuperview()
                profileVC.imageView.hidden = false
                transitionContext.completeTransition(true)
            })
            
        } else {
            var cardsVC = toViewController as CardsViewController
            var window = UIApplication.sharedApplication().keyWindow
            imageView.hidden = true
            cardsVC.imageView.hidden = true
            
            var smallPhoto = UIImageView(frame: imageView.frame)
            smallPhoto.image = imageView.image
            smallPhoto.contentMode = imageView.contentMode
            window.addSubview(smallPhoto)
            
            UIView.animateWithDuration(0.4, animations: { () -> Void in
    
                smallPhoto.frame = cardsVC.imageView.frame
                fromViewController.view.alpha = 0
                
                }) { (finished: Bool) -> Void in
                    smallPhoto.removeFromSuperview()
                    cardsVC.imageView.hidden = false
                    transitionContext.completeTransition(true)
                    fromViewController.view.removeFromSuperview()
            }
        }
    }

}
