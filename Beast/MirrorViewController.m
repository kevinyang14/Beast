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
    self.snapButton.bottom = self.view.height - 70.0;
}

#pragma mark Mirror

- (void)setupMirror{
    self.view.backgroundColor = [BeastColors darkBlack];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // camera with video recording capability
    self.camera =  [[LLSimpleCamera alloc] initWithVideoEnabled:YES];
    // camera with precise quality, position and video parameters.
    //    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
    //                                                 position:LLCameraPositionFront
    //                                             videoEnabled:YES];
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionRear
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
            
            NSLog(@"camera clicked");
            
            
            // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
            NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
            
            // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
            NSString* FileParamConstant = @"file";
            
            // the server url to which the image (or the media) is uploaded. Use your server url here
            NSURL* requestURL = [NSURL URLWithString:@"https://api.caloriemama.ai/v1/foodrecognition"];
            
            // create request
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            [request setHTTPShouldHandleCookies:NO];
            [request setTimeoutInterval:30];
            [request setHTTPMethod:@"POST"];
            
            // set Content-Type in HTTP header
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
            [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            //set Authorization
            
            NSString *auth = [NSString stringWithFormat:@"OAuth 12159392527544c97643dba010f53ef6487f5110130eeee67e2"];
            [request setValue:auth forHTTPHeaderField: @"Authorization"];
            
            // post body
            NSMutableData *body = [NSMutableData data];
            
            // Create rectangle from middle of current image
            CGRect croprect = CGRectMake(image.size.width / 4, image.size.height / 4 ,
                                         (image.size.width / 2), (image.size.height / 2));
            
            // Draw new image in current graphics context
            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], croprect);
            
            // Create new cropped UIImage
            UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
            
            // add image data
            NSData *imageData = UIImageJPEGRepresentation(croppedImage, 1.0);
            if (imageData) {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:imageData];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            
            // setting the body of the post to the reqeust
            [request setHTTPBody:body];
            
            // set the content-length
            NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            
            // set URL
            [request setURL:requestURL];
            
            NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&error];
            
            NSString *returnString = [[NSString alloc] initWithData:returnData encoding: NSUTF8StringEncoding];
            
            
            
            NSRange range = [returnString rangeOfString:@"calories"];
            NSString *substring = [[returnString substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            substring =[substring substringToIndex:6];
            substring =[substring substringFromIndex:2];
            
            NSRange range2 = [returnString rangeOfString:@"name"];
            NSString *substring2 = [[returnString substringFromIndex:NSMaxRange(range2)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSRange range4 = [substring2 rangeOfString:@"}"];
            NSString *substring4 = [[substring2 substringToIndex:NSMaxRange(range4)]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSLog(@"Calories:%@",substring);//calories
            
            NSRange range5 = [substring4 rangeOfString:@","];
            
            if (range5.location != NSNotFound){
                
                substring4 = [[substring4 substringToIndex:NSMaxRange(range5)]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            
            substring4 =[substring4 substringFromIndex:3];
            substring4 = [substring4 substringToIndex:[substring4 length] - 2];
            
            NSLog(@"Name:%@",substring4);//name
            
            ImageViewController *imageVC = [[ImageViewController alloc] initWithImage:image];

            imageVC.foodName = substring4;
            imageVC.calories = substring;
            [weakSelf presentViewController:imageVC animated:NO completion:nil];
            
            NSString *valueToSave = @"FAT";
            [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"fitOrFat"];
            [[NSUserDefaults standardUserDefaults] synchronize];
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
    
    heartImageView.image = [UIImage imageNamed:@"gymIcon"];
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
