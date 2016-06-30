//
//  MirrorViewController.m
//  Beast
//
//  Created by Kevin Yang on 24/06/2016.
//  Copyright © 2016 Beast. All rights reserved.
//

#import "MirrorViewController.h"
#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"
#import "ImageViewController.h"
#import "ViewUtils.h"
#import "BeastColors.h"

@interface MirrorViewController ()
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UIButton *snapButton;
@end

@implementation MirrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMirror];
    [self setupSwipeGestureRecognizer];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.snapButton.center = self.view.contentCenter;
    self.snapButton.bottom = self.view.height - 35.0;
}

- (void)setupMirror{
    self.view.backgroundColor = [BeastColors darkBlack];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    // camera with video recording capability
    self.camera =  [[LLSimpleCamera alloc] initWithVideoEnabled:YES];
    
    // camera with precise quality, position and video parameters.
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionFront
                                             videoEnabled:YES];
    // attach to the view
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    // ----- camera buttons -------- //
    
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapButton.frame = CGRectMake(0, 0, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.bounds.size.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.snapButton];
}

- (void)snapButtonPressed:(UIButton *)button
{
    __weak typeof(self) weakSelf = self;
        // capture
        [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
            if(!error) {
                ImageViewController *imageVC = [[ImageViewController alloc] initWithImage:image];
                [weakSelf presentViewController:imageVC animated:NO completion:nil];
            }
            else {
                NSLog(@"An error has occured: %@", error);
            }
        } exactSeenImage:YES];
}

#pragma mark - Swipe Methods

- (void)setupSwipeGestureRecognizer{
    UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)handleSwipeFrom:(UIGestureRecognizer*)recognizer {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
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
