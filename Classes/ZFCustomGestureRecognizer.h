//
//  ZFCustomGestureRecognizer.h
//  todaytask
//
//  Created by Amornchai Kanokpullwad on 5/13/14.
//  Copyright (c) 2014 zoonref. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface ZFCustomGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, weak) UIScrollView *scrollview;

@end
