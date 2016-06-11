//
//  WorkoutVideoViewController.m
//  Beast
//
//  Created by Kevin Yang on 4/30/16.
//  Copyright (c) 2016 Beast. All rights reserved.
//

#import "WorkoutVideoViewController.h"
//#import <PBJVideoPlayer/PBJVideoPlayer.h>

#import <PBJVideoPlayer/PBJVideoPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "ChameleonFramework/Chameleon.h"
#import <AudioToolbox/AudioServices.h>

@interface WorkoutVideoViewController () <PBJVideoPlayerControllerDelegate>
@property (nonatomic, strong) PBJVideoPlayerController *videoPlayerController;
@property (strong, nonatomic) CAShapeLayer *progressBarLayer;
@property int videoCount;
@end

@implementation WorkoutVideoViewController
@synthesize exerciseArray = _exerciseArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //video
    [self setupVideo];
    [self playVideo];
    
    //progressbar
    [self createProgressBar];
    
    //gesture recognizers
    [self setupSwipeGestureRecognizer];
    [self setupTapGestureRecognizer];
    self.videoCount = 0;
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [self drawProgressBar];
}

#pragma mark Video

- (void)setupVideo{
    self.videoPlayerController = [[PBJVideoPlayerController alloc] init];
    self.videoPlayerController.delegate = self;
    self.videoPlayerController.view.frame = self.view.bounds;
    self.videoPlayerController.muted = YES;
    
    [self addChildViewController:self.videoPlayerController];
    [self.view addSubview:self.videoPlayerController.view];
    [self.videoPlayerController didMoveToParentViewController:self];
}

- (void)playVideo{
//    [self.videoPlayerController stop];
    int exerciseID = [[self.exerciseArray objectAtIndex:self.videoCount] intValue];
    NSString *url = [NSString stringWithFormat:@"http://yangkev.in/videos/%d.m4v", exerciseID];
    self.videoPlayerController.videoPath = url;
    [self.videoPlayerController playFromBeginning];
}

#pragma mark delegate methods
- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer{
    NSLog(@"VIDEO WILL START");
}

#pragma mark ProgressBar

-(void)createProgressBar
{
    self.progressBarLayer=[CAShapeLayer layer];
    self.progressBarLayer.frame = self.view.bounds;
    self.progressBarLayer.fillColor =[UIColor clearColor].CGColor;
    self.progressBarLayer.path = CGPathCreateWithRect(self.view.bounds, NULL);
    self.progressBarLayer.strokeColor = [UIColor clearColor].CGColor;
    self.progressBarLayer.lineWidth = 15.0;
    [self.view.layer addSublayer:self.progressBarLayer];
}

- (void)drawProgressBar{
    self.progressBarLayer.strokeColor = ([UIColor colorWithGradientStyle:UIGradientStyleLeftToRight
                                                              withFrame:self.view.frame
                                                              andColors:@[[self color1],[self color2]]]).CGColor;

//    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeAnimation.delegate = self;
    strokeAnimation.duration = 30.0;
    strokeAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    strokeAnimation.toValue = [NSNumber numberWithFloat:0.0f];
    [self.progressBarLayer addAnimation:strokeAnimation forKey:@"strokeEndAnimation"];
}

#pragma mark SwipeGesture

- (void)setupSwipeGestureRecognizer{
    UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)handleSwipeFrom:(UIGestureRecognizer*)recognizer {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)setupTapGestureRecognizer{
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)handleTapFrom:(UIGestureRecognizer*)recognizer {
    [self playNextVideo];
}


- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(event.type == UIEventSubtypeMotionShake){
        NSLog(@"SHAKE SHAKE/n");
        [self playNextVideo];
    }
}

- (void)playNextVideo{
    if(self.videoCount < [self.exerciseArray count]-1){
        self.videoCount++;
        NSLog(@"%d", self.videoCount);
    }
    [self playVideo];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIColor *) color1 {return HexColor(@"#76F6E5");}

- (UIColor *) color2 {return HexColor(@"#00C6FE");}


/*

- (UIColor *) color1 {return [[UIColor alloc] initWithRed:238.0/255.0 green:205.0/255.0 blue:163.0/255.0 alpha:1];}

- (UIColor *) color2 {return [[UIColor alloc] initWithRed:239.0/255.0 green:98.0/255.0 blue:159.0/255.0 alpha:1];}

 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
