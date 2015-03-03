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
@property BOOL scrollable;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dragable = YES;
    self.scrollable = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    ModalViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ModalViewController"];
    modalVC.isScrollable = !self.scrollable;
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = self.dragable;
    self.animator.bounces = NO;
    self.animator.behindViewAlpha = 0.5f;
    self.animator.behindViewScale = 0.5f;
    self.animator.transitionDuration = 0.7f;

    if (self.scrollable) {
      [self.animator setContentScrollView:modalVC.scrollView];
    }
    
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"Left"]) {
        self.animator.direction = ZFModalTransitonDirectionLeft;
    } else if ([title isEqualToString:@"Right"]) {
        self.animator.direction = ZFModalTransitonDirectionRight;
    } else if ([title isEqualToString:@"Top"]) {
        self.animator.direction = ZFModalTransitonDirectionTop;
    } else if ([title isEqualToString:@"Bottom & Top"]) {
        self.animator.direction = ZFModalTransitonDirectionBottom|ZFModalTransitonDirectionTop;
    } else {
        self.animator.direction = ZFModalTransitonDirectionBottom;
    }
    
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
}

- (IBAction)scrollableChanged:(UISwitch *)sender {
  if (sender.on) {
    self.scrollable = YES;
  }
  else {
    self.scrollable = NO;
  }
}

- (IBAction)dragableChanged:(UISwitch *)sender
{
    if (sender.on) {
        self.dragable = YES;
    } else {
        self.dragable = NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
