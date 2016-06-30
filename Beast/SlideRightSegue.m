//
//  SlideRightSegue.m
//  Beast
//
//  Created by Kevin Yang on 30/06/2016.
//  Copyright © 2016 Beast. All rights reserved.
//

#import "SlideRightSegue.h"
#import <QuartzCore/QuartzCore.h>


@implementation SlideRightSegue

- (void)perform{
    UIViewController *srcViewController = (UIViewController *) self.sourceViewController;
    UIViewController *destViewController = (UIViewController *) self.destinationViewController;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [srcViewController.view.window.layer addAnimation:transition forKey:nil];
    
    [srcViewController presentViewController:destViewController animated:NO completion:nil];
}

@end
