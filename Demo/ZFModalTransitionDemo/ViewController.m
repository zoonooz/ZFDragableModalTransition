//
//  ViewController.m
//  ZFModalTransitionDemo
//
//  Created by Amornchai Kanokpullwad on 6/4/14.
//  Copyright (c) 2014 zoonref. All rights reserved.
//

#import "ViewController.h"
#import "ModalViewController.h"
#import "ZFModalTransitionAnimator.h"

@interface ViewController ()
@property BOOL dragable;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.dragable = YES;
    if ([self isIOS8]) {
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    ModalViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ModalViewController"];
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = self.dragable;
    self.animator.behindViewAlpha = 0.5f;
    self.animator.behindViewScale = 0.5f;
    
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"Left"]) {
        self.animator.direction = ZFModalTransitonDirectionLeft;
    } else if ([title isEqualToString:@"Right"]) {
        self.animator.direction = ZFModalTransitonDirectionRight;
    } else {
        self.animator.direction = ZFModalTransitonDirectionBottom;
    }
    
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
}

- (IBAction)dragableChanged:(UISwitch *)sender
{
    if (sender.on) {
        self.dragable = YES;
    } else {
        self.dragable = NO;
    }
}

#pragma mark - Utils

- (BOOL)isIOS8
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        // OS version >= 8.0
        return YES;
    }
    return NO;
}

@end
