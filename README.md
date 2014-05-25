# ZFDragableModalTransition

[![Version](https://img.shields.io/cocoapods/v/ZFDragableModalTransition.svg?style=flat)](http://cocoadocs.org/docsets/ZFDragableModalTransition)
[![License](https://img.shields.io/cocoapods/l/ZFDragableModalTransition.svg?style=flat)](http://cocoadocs.org/docsets/ZFDragableModalTransition)
[![Platform](https://img.shields.io/cocoapods/p/ZFDragableModalTransition.svg?style=flat)](http://cocoadocs.org/docsets/ZFDragableModalTransition)

<p align="center"><img src="https://raw.github.com/zoonooz/ZFDragableModalTransition/master/Screenshot/ss.gif"/></p>

## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

```objc
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TaskDetailViewController *detailViewController = segue.destinationViewController;
    detailViewController.task = sender;
    
    // set here
    ZFModalTransitionAnimator *animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:detailViewController];
    animator.dragable = YES;
    animator.direction = ZFModalTransitonDirectionRight;
    [animator setContentScrollView:detailViewController.scrollview];
    
    detailViewController.transitioningDelegate = self.animator;
    detailViewController.modalPresentationStyle = UIModalPresentationCustom;
}
```

## Author

Amornchai Kanokpullwad, amornchai.zoon@gmail.com

## License

ZFDragableModalTransition is available under the MIT license. See the LICENSE file for more info.

