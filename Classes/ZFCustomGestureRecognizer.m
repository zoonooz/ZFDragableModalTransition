//
//  ZFCustomGestureRecognizer.m
//  todaytask
//
//  Created by Amornchai Kanokpullwad on 5/13/14.
//  Copyright (c) 2014 zoonref. All rights reserved.
//

#import "ZFCustomGestureRecognizer.h"

@interface ZFCustomGestureRecognizer ()
@property (nonatomic, strong) NSNumber *isFail;
@end

@implementation ZFCustomGestureRecognizer

- (void)reset
{
    [super reset];
    self.isFail = nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
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
