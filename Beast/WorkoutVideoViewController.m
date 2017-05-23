//
//  WorkoutVideoViewController.m
//  Beast
//
//  Created by Kevin Yang on 4/30/16.
//  Copyright (c) 2016 Beast. All rights reserved.
//

#import "WorkoutVideoViewController.h"
#import <PBJVideoPlayer/PBJVideoPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "ChameleonFramework/Chameleon.h"
#import <AudioToolbox/AudioServices.h>
#import "FirebaseRefs.h"

@import Firebase;

@interface WorkoutVideoViewController () <PBJVideoPlayerControllerDelegate>
@property (nonatomic, strong) PBJVideoPlayerController *videoPlayerController;
@property (strong, nonatomic) CAShapeLayer *progressBarLayer;
@property (strong, nonatomic) FIRStorageReference *storageRef;
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

//- (void)playVideo{
////    [self.videoPlayerController stop];
//    int exerciseID = [[self.exerciseArray objectAtIndex:self.videoCount] intValue];
//    NSString *url = [NSString stringWithFormat:@"http://yangkev.in/videos/%d.m4v", exerciseID];
//    self.videoPlayerController.videoPath = url;
//    [self.videoPlayerController playFromBeginning];
//}

- (void)playVideo{
    NSLog(@"videoCount %d vs. exerciseArray %lu \n\n", self.videoCount, (unsigned long)[self.exerciseArray count]);

    NSNumber *exerciseNum = [self.exerciseArray objectAtIndex:self.videoCount] ;
    NSURL *url = [FirebaseRefs videoLocalURL:exerciseNum];
    NSString *urlPath = [url absoluteString];
    self.videoPlayerController.videoPath = urlPath;
    NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:urlPath error: NULL];
    [self.videoPlayerController playFromBeginning];
    
    // NSNumber *size = [fileDictionary objectForKey:NSFileSize];
    //NSLog(@"file size %@", size);
    //[self printAllFiles];
}

- (void)printAllFiles{
    NSLog(@"printAllFiles");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'm4v'"];
    for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate]) {
        // Enumerate each .png file in directory
        NSLog(@"%@", fileURL);
    }
}


- (void)playNextVideo{
    //play next video, if there are videos left to play

    if(self.videoCount < [self.exerciseArray count]-1) {
        NSLog(@"\n\n-----------IF------------");
        self.videoCount++;
        [self playVideo];
        [self incrementProgressBar];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }else{
        NSLog(@"\n\n-----------ELSE------------");
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
    
    
}

#pragma mark delegate methods
- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer{
//    NSLog(@"VIDEO WILL START");
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
   //    self.progressBarLayer.strokeColor = ([UIColor colorWithGradientStyle:UIGradientStyleLeftToRight
//                                                              withFrame:self.view.frame
//                                                              andColors:@[[self color1],[self color2]]]).CGColor;

//    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
//    strokeAnimation.delegate = self;
//    strokeAnimation.duration = 30.0;
//    strokeAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
//    strokeAnimation.toValue = [NSNumber numberWithFloat:0.0f];
//    [self.progressBarLayer addAnimation:strokeAnimation forKey:@"strokeEndAnimation"];
}

- (void)incrementProgressBar{
    float pastVideoNum = (float)self.videoCount;
    float presentVideoNum = (float)self.videoCount+1.0;
    float totalVideoNum = (float)[self.exerciseArray count];
    //NSLog(@"pastVideoNum %f \n presentVideoNum: %f \n totalVideoNum %f \n ", pastVideoNum, presentVideoNum, totalVideoNum);
    float startValue = 1.0 - (float)(pastVideoNum/totalVideoNum);
    float endValue = 1.0 - (float)(presentVideoNum/totalVideoNum);
    //NSLog(@"startValue %f, endValue %f", startValue, endValue);
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeAnimation.delegate = self;
    strokeAnimation.duration = 1.0;
    strokeAnimation.fromValue = [NSNumber numberWithFloat:startValue];
    strokeAnimation.toValue = [NSNumber numberWithFloat:endValue];
    strokeAnimation.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    strokeAnimation.fillMode = kCAFillModeForwards;
    strokeAnimation.removedOnCompletion = false;
    [self.progressBarLayer addAnimation:strokeAnimation forKey:@"strokeStart"];
    self.progressBarLayer.strokeColor = ([UIColor colorWithGradientStyle:UIGradientStyleLeftToRight
                                                               withFrame:self.view.frame
                                                               andColors:@[[self color1],[self color2]]]).CGColor;
}

#pragma mark ShakeGestureRecognizer

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(event.type == UIEventSubtypeMotionShake){
        NSLog(@"SHAKE SHAKE/n");
        [self playNextVideo];
    }
}


#pragma mark Gesture Recognizers

//Swipe

- (void)setupSwipeGestureRecognizer{
    UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)handleSwipeFrom:(UIGestureRecognizer*)recognizer {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}


//Tap

- (void)setupTapGestureRecognizer{
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];

}

- (void)handleTapFrom:(UIGestureRecognizer*)recognizer {
    [self playNextVideo];
}


#pragma mark Helper Methods

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIColor *) color1 {return HexColor(@"#76F6E5");}
- (UIColor *) color2 {return HexColor(@"#00C6FE");}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
