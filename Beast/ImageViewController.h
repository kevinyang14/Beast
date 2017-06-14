//
//  ImageViewController.h
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 15/11/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic, strong) NSString *foodName;
@property (nonatomic, strong) NSString *calories;

@end
