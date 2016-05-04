//
//  WorkoutVideoViewController.m
//  Beast
//
//  Created by Kevin Yang on 4/30/16.
//  Copyright (c) 2016 Beast. All rights reserved.
//

#import "WorkoutVideoViewController.h"
#import <PBJVideoPlayer/PBJVideoPlayer.h>

@interface WorkoutVideoViewController () <PBJVideoPlayerControllerDelegate>
@property (nonatomic, strong) PBJVideoPlayerController *videoPlayerController;
@end

@implementation WorkoutVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupPBJVideo];
    [self playVideo];
    [self setupSwipeGestureRecognizer];
}


- (void)setupSwipeGestureRecognizer{
    UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDownFrom:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeUpGestureRecognizer];
}

- (void)setupPBJVideo{
    self.videoPlayerController = [[PBJVideoPlayerController alloc] init];
    self.videoPlayerController.delegate = self;
    self.videoPlayerController.view.frame = self.view.bounds;
}

- (void)playVideo{
    //play video
    self.videoPlayerController.videoPath = @"http://manuchopra.in/videos/work.mp4";
    [self addChildViewController:self.videoPlayerController];
    [self.view addSubview:self.videoPlayerController.view];
    [self.videoPlayerController didMoveToParentViewController:self];
    [self.videoPlayerController playFromBeginning];
}


- (void)handleSwipeDownFrom:(UIGestureRecognizer*)recognizer {
    NSLog(@"swipeDown");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
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
