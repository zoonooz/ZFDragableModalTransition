//
//  ZFModalTransitionAnimator.m
//
//  Created by Amornchai Kanokpullwad on 5/10/14.
//  Copyright (c) 2014 zoonref. All rights reserved.
//

#import "ZFModalTransitionAnimator.h"

@interface ZFModalTransitionAnimator ()
@property (nonatomic, strong) UIViewController *modalController;
@property (nonatomic, strong) ZFDetectScrollViewEndGestureRecognizer *gesture;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property CGFloat panLocationStart;
@property BOOL isDismiss;
@property BOOL isInteractive;
@end

@implementation ZFModalTransitionAnimator

- (instancetype)initWithModalViewController:(UIViewController *)modalViewController
{
    self = [super init];
    if (self) {
        _modalController = modalViewController;
        _direction = ZFModalTransitonDirectionBottom;
        _dragable = NO;
        _scaleDownRatio = 0.9f;
    }
    return self;
}

- (void)setDragable:(BOOL)dragable
{
    _dragable = dragable;
    if (self.isDragable) {
        self.gesture = [[ZFDetectScrollViewEndGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.gesture.delegate = self;
        [self.modalController.view addGestureRecognizer:self.gesture];
    }
}

- (void)setContentScrollView:(UIScrollView *)scrollView
{
    self.gesture.scrollview = scrollView;
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    // Reset to our default state
    self.isInteractive = NO;
    self.transitionContext = nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.8;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isInteractive) {
        return;
    }
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
    if (!self.isDismiss) {
        
        CGRect startRect;
        [[transitionContext containerView] addSubview:toViewController.view];
        
        if (self.direction == ZFModalTransitonDirectionBottom) {
            startRect = CGRectMake(0,
                                   CGRectGetHeight(toViewController.view.frame),
                                   CGRectGetWidth(toViewController.view.frame),
                                   CGRectGetHeight(toViewController.view.frame));
        } else if (self.direction == ZFModalTransitonDirectionLeft) {
            startRect = CGRectMake(-CGRectGetWidth(toViewController.view.frame),
                                   0,
                                   CGRectGetWidth(toViewController.view.frame),
                                   CGRectGetHeight(toViewController.view.frame));
        } else if (self.direction == ZFModalTransitonDirectionRight) {
            startRect = CGRectMake(CGRectGetWidth(toViewController.view.frame),
                                   0,
                                   CGRectGetWidth(toViewController.view.frame),
                                   CGRectGetHeight(toViewController.view.frame));
        }
        
        toViewController.view.frame = startRect;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:5
              initialSpringVelocity:15
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             fromViewController.view.transform = CGAffineTransformMakeScale(self.scaleDownRatio, self.scaleDownRatio);
                             
                             toViewController.view.frame = CGRectMake(0,0,
                                                                      CGRectGetWidth(toViewController.view.frame),
                                                                      CGRectGetHeight(toViewController.view.frame));
                             
                             
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             
                         }];
    } else {
        
        [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
        toViewController.view.layer.transform = CATransform3DMakeScale(self.scaleDownRatio, self.scaleDownRatio, 1);
        
        CGRect endRect;
        
        if (self.direction == ZFModalTransitonDirectionBottom) {
            endRect = CGRectMake(0,
                                 CGRectGetHeight(fromViewController.view.frame),
                                 CGRectGetWidth(fromViewController.view.frame),
                                 CGRectGetHeight(fromViewController.view.frame));
        } else if (self.direction == ZFModalTransitonDirectionLeft) {
            endRect = CGRectMake(-CGRectGetWidth(fromViewController.view.frame),
                                 0,
                                 CGRectGetWidth(fromViewController.view.frame),
                                 CGRectGetHeight(fromViewController.view.frame));
        } else if (self.direction == ZFModalTransitonDirectionRight) {
            endRect = CGRectMake(CGRectGetWidth(fromViewController.view.frame),
                                 0,
                                 CGRectGetWidth(fromViewController.view.frame),
                                 CGRectGetHeight(fromViewController.view.frame));
        }
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:5
              initialSpringVelocity:5
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             toViewController.view.layer.transform = CATransform3DIdentity;
                             fromViewController.view.frame = endRect;
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             
                         }];
    }
}

# pragma mark - Gesture

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    // Location reference
    CGPoint location = [recognizer locationInView:[self.modalController.view window]];
    
    // Velocity reference
    CGPoint velocity = [recognizer velocityInView:[self.modalController.view window]];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.isInteractive = YES;
        if (self.direction == ZFModalTransitonDirectionBottom) {
            self.panLocationStart = location.y;
        } else {
            self.panLocationStart = location.x;
        }
        [self.modalController dismissViewControllerAnimated:YES completion:nil];
    }
    
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat animationRatio = 0;
        
        if (self.direction == ZFModalTransitonDirectionBottom) {
            animationRatio = (location.y - self.panLocationStart) / (CGRectGetHeight([self.modalController view].bounds));
        } else if (self.direction == ZFModalTransitonDirectionLeft) {
            animationRatio = (self.panLocationStart - location.x) / (CGRectGetWidth([self.modalController view].bounds));
        } else if (self.direction == ZFModalTransitonDirectionRight) {
            animationRatio = (location.x - self.panLocationStart) / (CGRectGetWidth([self.modalController view].bounds));
        }
        
        [self updateInteractiveTransition:animationRatio];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGFloat velocityForSelectedDirection;
        
        if (self.direction == ZFModalTransitonDirectionBottom) {
            velocityForSelectedDirection = velocity.y;
        } else {
            velocityForSelectedDirection = velocity.x;
        }
        
        if (velocityForSelectedDirection > 100
            && (self.direction == ZFModalTransitonDirectionRight
                || self.direction == ZFModalTransitonDirectionBottom)) {
                [self finishInteractiveTransition];
            } else if (velocityForSelectedDirection < -100 && self.direction == ZFModalTransitonDirectionLeft) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        
    }
}

#pragma mark -

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    toViewController.view.layer.transform = CATransform3DMakeScale(self.scaleDownRatio, self.scaleDownRatio, 1);
    [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
    
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.layer.transform = CATransform3DMakeScale(self.scaleDownRatio + ((1-self.scaleDownRatio) * percentComplete), self.scaleDownRatio + ((1-self.scaleDownRatio) * percentComplete), 1);
    
    if (self.direction == ZFModalTransitonDirectionBottom) {
        fromViewController.view.frame = CGRectMake(0,
                                                   (CGRectGetHeight(fromViewController.view.frame) * percentComplete),
                                                   CGRectGetWidth(fromViewController.view.frame),
                                                   CGRectGetHeight(fromViewController.view.frame));
    } else if (self.direction == ZFModalTransitonDirectionLeft) {
        fromViewController.view.frame = CGRectMake(-(CGRectGetWidth(fromViewController.view.frame) * percentComplete),
                                                   0,
                                                   CGRectGetWidth(fromViewController.view.frame),
                                                   CGRectGetHeight(fromViewController.view.frame));
    } else if (self.direction == ZFModalTransitonDirectionRight) {
        fromViewController.view.frame = CGRectMake(CGRectGetWidth(fromViewController.view.frame) * percentComplete,
                                                   0,
                                                   CGRectGetWidth(fromViewController.view.frame),
                                                   CGRectGetHeight(fromViewController.view.frame));
    }
    
}

- (void)finishInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endRect;
    
    if (self.direction == ZFModalTransitonDirectionBottom) {
        endRect = CGRectMake(0,
                             CGRectGetHeight(fromViewController.view.frame),
                             CGRectGetWidth(fromViewController.view.frame),
                             CGRectGetHeight(fromViewController.view.frame));
    } else if (self.direction == ZFModalTransitonDirectionLeft) {
        endRect = CGRectMake(-CGRectGetWidth(fromViewController.view.frame),
                             0,
                             CGRectGetWidth(fromViewController.view.frame),
                             CGRectGetHeight(fromViewController.view.frame));
    } else if (self.direction == ZFModalTransitonDirectionRight) {
        endRect = CGRectMake(CGRectGetWidth(fromViewController.view.frame),
                             0,
                             CGRectGetWidth(fromViewController.view.frame),
                             CGRectGetHeight(fromViewController.view.frame));
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:5
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toViewController.view.layer.transform = CATransform3DIdentity;
                         fromViewController.view.frame = endRect;
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                         self.modalController = nil;
                     }];
    
}

- (void)cancelInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:5
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         toViewController.view.transform = CGAffineTransformMakeScale(self.scaleDownRatio, self.scaleDownRatio);
                         
                         fromViewController.view.frame = CGRectMake(0,0,
                                                                    CGRectGetWidth(fromViewController.view.frame),
                                                                    CGRectGetHeight(fromViewController.view.frame));
                         
                         
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:NO];
                     }];
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isDismiss = NO;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isDismiss = YES;
    
    // Must return nil in ios8 beta
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        // OS version >= 8.0
        if (self.isInteractive) {
            return nil;
        }
    }
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    // Return nil if we are not interactive
    if (self.isInteractive && self.dragable) {
        self.isDismiss = YES;
        return self;
    }
    
    return nil;
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.direction == ZFModalTransitonDirectionBottom) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.direction == ZFModalTransitonDirectionBottom) {
        return YES;
    }
    return NO;
}

@end

// Gesture Class Implement
@interface ZFDetectScrollViewEndGestureRecognizer ()
@property (nonatomic, strong) NSNumber *isFail;
@end

@implementation ZFDetectScrollViewEndGestureRecognizer

- (void)reset
{
    [super reset];
    self.isFail = nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (!self.scrollview) {
        return;
    }
    
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [touches.anyObject locationInView:self.view];
    CGPoint prevPoint = [touches.anyObject previousLocationInView:self.view];
    
    if (self.isFail) {
        if (self.isFail.boolValue) {
            self.state = UIGestureRecognizerStateFailed;
        }
        return;
    }
    
    if (nowPoint.y > prevPoint.y && self.scrollview.contentOffset.y <= 0) {
        self.isFail = @NO;
    } else if (self.scrollview.contentOffset.y >= 0) {
        self.state = UIGestureRecognizerStateFailed;
        self.isFail = @YES;
    } else {
        self.isFail = @NO;
    }
    
}

@end
