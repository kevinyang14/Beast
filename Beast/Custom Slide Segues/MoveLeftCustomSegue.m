//
//  SlideLeftCustomSegue.m
//  Hello
//
//  Created by Kevin Yang on 9/11/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "MoveLeftCustomSegue.h"
#import <QuartzCore/QuartzCore.h>

@implementation MoveLeftCustomSegue

- (void)perform{
    UIViewController *srcViewController = (UIViewController *) self.sourceViewController;
    UIViewController *destViewController = (UIViewController *) self.destinationViewController;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [srcViewController.view.window.layer addAnimation:transition forKey:nil];
    
    [srcViewController presentViewController:destViewController animated:NO completion:nil];
}

@end
