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
@property CATransform3D tempTransform;
@end

void ZFTransitionViewsFromContext(id<UIViewControllerContextTransitioning> transitionContext, UIView **fromView, UIView **toView)
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if ([transitionContext respondsToSelector:@selector(viewForKey:)])
    {
        *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    }
    else
    {
        *fromView = fromViewController.view;
        *toView = toViewController.view;
    }
}

@implementation ZFModalTransitionAnimator

- (instancetype)initWithModalViewController:(UIViewController *)modalViewController
{
    self = [super init];
    if (self) {
        _modalController = modalViewController;
        _direction = ZFModalTransitonDirectionBottom;
        _dragable = NO;
        _bounces = YES;
        _behindViewScale = 0.9f;
        _behindViewAlpha = 1.0f;
        _transitionDuration = 0.8f;

        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)setDragable:(BOOL)dragable
{
    _dragable = dragable;
    if (_dragable) {
        self.gesture = [[ZFDetectScrollViewEndGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.gesture.delegate = self;
        [self.modalController.view addGestureRecognizer:self.gesture];
    } else {
        if (self.gesture) {
            [self.modalController.view removeGestureRecognizer:self.gesture];
            self.gesture = nil;
        }
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
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isInteractive) {
        return;
    }

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *fromView, *toView;
    ZFTransitionViewsFromContext(transitionContext, &fromView, &toView);
    
    UIView *containerView = [transitionContext containerView];

    if (!self.isDismiss) {

        CGRect startRect;

        [containerView addSubview:toView];

        toView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        if (self.direction == ZFModalTransitonDirectionBottom) {
            startRect = CGRectMake(0,
                                   CGRectGetHeight(containerView.frame),
                                   CGRectGetWidth(containerView.bounds),
                                   CGRectGetHeight(containerView.bounds));
        } else if (self.direction == ZFModalTransitonDirectionLeft) {
            startRect = CGRectMake(-CGRectGetWidth(containerView.frame),
                                   0,
                                   CGRectGetWidth(containerView.bounds),
                                   CGRectGetHeight(containerView.bounds));
        } else if (self.direction == ZFModalTransitonDirectionRight) {
            startRect = CGRectMake(CGRectGetWidth(containerView.frame),
                                   0,
                                   CGRectGetWidth(containerView.bounds),
                                   CGRectGetHeight(containerView.bounds));
        }

        CGPoint transformedPoint = CGPointApplyAffineTransform(startRect.origin, toView.transform);
        toView.frame = CGRectMake(transformedPoint.x, transformedPoint.y, startRect.size.width, startRect.size.height);

        [fromViewController beginAppearanceTransition:NO animated:YES];

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{

                             fromView.transform = CGAffineTransformScale(fromView.transform, self.behindViewScale, self.behindViewScale);
                             fromView.alpha = self.behindViewAlpha;

                             toView.frame = CGRectMake(0,0,
                                                                      CGRectGetWidth(toView.frame),
                                                                      CGRectGetHeight(toView.frame));


                         } completion:^(BOOL finished) {

                             [fromViewController endAppearanceTransition];

                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];

                         }];
    } else {

        [containerView addSubview:toView];
        [containerView bringSubviewToFront:fromView];

        if (![self isPriorToIOS8]) {
            toView.layer.transform = CATransform3DScale(toView.layer.transform, self.behindViewScale, self.behindViewScale, 1);
        }

        toView.alpha = self.behindViewAlpha;

        CGRect endRect;

        if (self.direction == ZFModalTransitonDirectionBottom) {
            endRect = CGRectMake(0,
                                 CGRectGetHeight(fromView.bounds),
                                 CGRectGetWidth(fromView.frame),
                                 CGRectGetHeight(fromView.frame));
        } else if (self.direction == ZFModalTransitonDirectionLeft) {
            endRect = CGRectMake(-CGRectGetWidth(fromView.bounds),
                                 0,
                                 CGRectGetWidth(fromView.frame),
                                 CGRectGetHeight(fromView.frame));
        } else if (self.direction == ZFModalTransitonDirectionRight) {
            endRect = CGRectMake(CGRectGetWidth(fromView.bounds),
                                 0,
                                 CGRectGetWidth(fromView.frame),
                                 CGRectGetHeight(fromView.frame));
        }

        CGPoint transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromView.transform);
        endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);

        [toViewController beginAppearanceTransition:YES animated:YES];

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGFloat scaleBack = (1 / self.behindViewScale);
                             toView.layer.transform = CATransform3DScale(toView.layer.transform, scaleBack, scaleBack, 1);
                             toView.alpha = 1.0f;
                             fromView.frame = endRect;
                         } completion:^(BOOL finished) {
                             
                             [toViewController endAppearanceTransition];
                             
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             
                             self.modalController = nil;
                         }];
    }
}

# pragma mark - Gesture

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    // Location reference
    CGPoint location = [recognizer locationInView:self.modalController.view.window];
    location = CGPointApplyAffineTransform(location, CGAffineTransformInvert(recognizer.view.transform));
    // Velocity reference
    CGPoint velocity = [recognizer velocityInView:[self.modalController.view window]];
    velocity = CGPointApplyAffineTransform(velocity, CGAffineTransformInvert(recognizer.view.transform));

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
        self.isInteractive = NO;
    }
}

#pragma mark -

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;

    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *fromView, *toView;
    ZFTransitionViewsFromContext(transitionContext, &fromView, &toView);
    
	[toViewController beginAppearanceTransition:YES animated:YES];

    if (![self isPriorToIOS8]) {
        toView.layer.transform = CATransform3DScale(toView.layer.transform, self.behindViewScale, self.behindViewScale, 1);
    }

    self.tempTransform = toView.layer.transform;

    toView.alpha = self.behindViewAlpha;
    [[transitionContext containerView] addSubview:toView];
    [[transitionContext containerView] bringSubviewToFront:fromView];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    if (!self.bounces && percentComplete < 0) {
        percentComplete = 0;
    }

    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIView *fromView, *toView;
    ZFTransitionViewsFromContext(transitionContext, &fromView, &toView);
    
    CATransform3D transform = CATransform3DMakeScale(
                                                     1 + (((1 / self.behindViewScale) - 1) * percentComplete),
                                                     1 + (((1 / self.behindViewScale) - 1) * percentComplete), 1);
    toView.layer.transform = CATransform3DConcat(self.tempTransform, transform);

    toView.alpha = self.behindViewAlpha + ((1 - self.behindViewAlpha) * percentComplete);

    CGRect updateRect;
    if (self.direction == ZFModalTransitonDirectionBottom) {
        updateRect = CGRectMake(0,
                                (CGRectGetHeight(fromView.bounds) * percentComplete),
                                CGRectGetWidth(fromView.frame),
                                CGRectGetHeight(fromView.frame));
    } else if (self.direction == ZFModalTransitonDirectionLeft) {
        updateRect = CGRectMake(-(CGRectGetWidth(fromView.bounds) * percentComplete),
                                0,
                                CGRectGetWidth(fromView.frame),
                                CGRectGetHeight(fromView.frame));
    } else if (self.direction == ZFModalTransitonDirectionRight) {
        updateRect = CGRectMake(CGRectGetWidth(fromView.bounds) * percentComplete,
                                0,
                                CGRectGetWidth(fromView.frame),
                                CGRectGetHeight(fromView.frame));
    }

    // reset to zero if x and y has unexpected value to prevent crash
    if (isnan(updateRect.origin.x) || isinf(updateRect.origin.x)) {
        updateRect.origin.x = 0;
    }
    if (isnan(updateRect.origin.y) || isinf(updateRect.origin.y)) {
        updateRect.origin.y = 0;
    }

    CGPoint transformedPoint = CGPointApplyAffineTransform(updateRect.origin, fromView.transform);
    updateRect = CGRectMake(transformedPoint.x, transformedPoint.y, updateRect.size.width, updateRect.size.height);

    fromView.frame = updateRect;
}

- (void)finishInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *fromView, *toView;
    ZFTransitionViewsFromContext(transitionContext, &fromView, &toView);

    CGRect endRect;

    if (self.direction == ZFModalTransitonDirectionBottom) {
        endRect = CGRectMake(0,
                             CGRectGetHeight(fromView.bounds),
                             CGRectGetWidth(fromView.frame),
                             CGRectGetHeight(fromView.frame));
    } else if (self.direction == ZFModalTransitonDirectionLeft) {
        endRect = CGRectMake(-CGRectGetWidth(fromView.bounds),
                             0,
                             CGRectGetWidth(fromView.frame),
                             CGRectGetHeight(fromView.frame));
    } else if (self.direction == ZFModalTransitonDirectionRight) {
        endRect = CGRectMake(CGRectGetWidth(fromView.bounds),
                             0,
                             CGRectGetWidth(fromView.frame),
                             CGRectGetHeight(fromView.frame));
    }

    CGPoint transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromView.transform);
    endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);

    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGFloat scaleBack = (1 / self.behindViewScale);
                         toView.layer.transform = CATransform3DScale(self.tempTransform, scaleBack, scaleBack, 1);
                         toView.alpha = 1.0f;
                         fromView.frame = endRect;
                     } completion:^(BOOL finished) {

						 [toViewController endAppearanceTransition];

                         [transitionContext completeTransition:YES];
                         self.modalController = nil;
                     }];

}

- (void)cancelInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *fromView, *toView;
    ZFTransitionViewsFromContext(transitionContext, &fromView, &toView);

    [toViewController beginAppearanceTransition:NO animated:YES];

    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{

                         toView.layer.transform = self.tempTransform;
                         toView.alpha = self.behindViewAlpha;

                         fromView.frame = CGRectMake(0,0,
                                                                    CGRectGetWidth(fromView.frame),
                                                                    CGRectGetHeight(fromView.frame));


                     } completion:^(BOOL finished) {

						 [toViewController endAppearanceTransition];

                         [transitionContext completeTransition:NO];
                         [toView removeFromSuperview];
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

#pragma mark - Utils

- (BOOL)isPriorToIOS8
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        // OS version >= 8.0
        return YES;
    }
    return NO;
}

#pragma mark - Orientation

- (void)orientationChanged:(NSNotification *)notification
{
    UIViewController *backViewController = self.modalController.presentingViewController;
    backViewController.view.bounds = backViewController.view.window.bounds;
    if (![self isPriorToIOS8]) {
        backViewController.view.layer.transform = CATransform3DScale(backViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
    }
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

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
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

    CGFloat topVerticalOffset = -self.scrollview.contentInset.top;

    if (nowPoint.y > prevPoint.y && self.scrollview.contentOffset.y <= topVerticalOffset) {
        self.isFail = @NO;
    } else if (self.scrollview.contentOffset.y >= topVerticalOffset) {
        self.state = UIGestureRecognizerStateFailed;
        self.isFail = @YES;
    } else {
        self.isFail = @NO;
    }

}

@end
