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
#import <QuartzCore/QuartzCore.h>

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface MirrorViewController ()
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UIButton *snapButton;
@end

@implementation MirrorViewController

#pragma mark View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMirror];
    [self setupSwipeGestureRecognizer];
    // Do any additional setup after loading the view.
    [NSTimer scheduledTimerWithTimeInterval:0.3f
                                     target:self selector:@selector(addHeartAuto:) userInfo:nil repeats:YES];
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

#pragma mark Mirror

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
    
    [self createButton];
}

- (void)createButton{
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.snapButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];
    self.snapButton.titleLabel.text = @"🐯";
    self.snapButton.frame = CGRectMake(0, 0, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.bounds.size.width / 2.0f;
    self.snapButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9].CGColor;
    self.snapButton.layer.borderWidth = 4.0f;
    //    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
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

#pragma mark - Emoji Methods

- (void)addHeartAuto:(NSTimer *)timer{
    [self addHeart];
}

- (void)addHeart {
    UIImageView *heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2.0, kScreenHeight * 9.0/10.0, 40, 40)];
    
    heartImageView.image = [UIImage imageNamed:@"tiger"];
    heartImageView.transform = CGAffineTransformMakeScale(0, 0);
    [self.camera.view addSubview:heartImageView];
    
    CGFloat duration = 5 + (arc4random() % 5 - 2);
    [UIView animateWithDuration:0.3 animations:^{
        heartImageView.transform = CGAffineTransformMakeScale(1, 1);                                    //1. animate from tiny heart to heart
        NSArray *rotateValues = @[[NSNumber numberWithDouble:0.01], [NSNumber numberWithDouble:-0.01]];
        double rotateNumber = [[rotateValues objectAtIndex:arc4random()%2] doubleValue];
        heartImageView.transform = CGAffineTransformMakeRotation(rotateNumber * (arc4random() % 20));   //2. rotate the heart
    }];
    [UIView animateWithDuration:duration animations:^{                                                  //3. make the heart transparent over time
        heartImageView.alpha = 0;
    }];
    CAKeyframeAnimation *animation = [self createAnimation:heartImageView.frame];                       //4. make heart float to the top
    animation.duration = duration;
    [heartImageView.layer addAnimation:animation forKey:@"position"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration + 0.5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [heartImageView removeFromSuperview];
    });
}

- (CAKeyframeAnimation *)createAnimation:(CGRect)frame {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    
    int height = -100 + arc4random() % 40 - 20;
    int xOffset = frame.origin.x;
    int yOffset = frame.origin.y;
    int waveWidth = 50;
    CGPoint p1 = CGPointMake(xOffset, height * 0 + yOffset);
    CGPoint p2 = CGPointMake(xOffset, height * 1 + yOffset);
    CGPoint p3 = CGPointMake(xOffset, height * 2 + yOffset);
    CGPoint p4 = CGPointMake(xOffset, height * 2 + yOffset);
    
    CGPathMoveToPoint(path, NULL, p1.x,p1.y);
    
    if (arc4random() % 2) {
        CGPathAddQuadCurveToPoint(path, NULL, p1.x - arc4random() % waveWidth, p1.y + height / 2.0, p2.x, p2.y);
        CGPathAddQuadCurveToPoint(path, NULL, p2.x + arc4random() % waveWidth, p2.y + height / 2.0, p3.x, p3.y);
        CGPathAddQuadCurveToPoint(path, NULL, p3.x - arc4random() % waveWidth, p3.y + height / 2.0, p4.x, p4.y);
    } else {
        CGPathAddQuadCurveToPoint(path, NULL, p1.x + arc4random() % waveWidth, p1.y + height / 2.0, p2.x, p2.y);
        CGPathAddQuadCurveToPoint(path, NULL, p2.x - arc4random() % waveWidth, p2.y + height / 2.0, p3.x, p3.y);
        CGPathAddQuadCurveToPoint(path, NULL, p3.x + arc4random() % waveWidth, p3.y + height / 2.0, p4.x, p4.y);
    }
    animation.path = path;
    animation.calculationMode = kCAAnimationCubicPaced;
    CGPathRelease(path);
    return animation;
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
