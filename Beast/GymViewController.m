//
//  GymViewController.m
//  Beast
//
//  Created by Kevin Yang on 03/07/2016.
//  Copyright © 2016 Beast. All rights reserved.
//

#import "GymViewController.h"

@interface GymViewController ()
@end

@implementation GymViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackground];
    [self setupSwipeLeftGestureRecognizer];
    // Do any additional setup after loading the view.
}

- (void)setBackground {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    UIImage *image = [UIImage imageNamed:@"gym.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

#pragma mark - Swipe Methods

- (void)setupSwipeLeftGestureRecognizer{
    UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipeFrom:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)handleLeftSwipeFrom:(UIGestureRecognizer*)recognizer {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
