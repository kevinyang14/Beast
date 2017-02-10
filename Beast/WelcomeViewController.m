//
//  WelcomeViewController.m
//  Beast
//
//  Created by Kevin Yang on 1/23/17.
//  Copyright © 2017 Beast. All rights reserved.
//

#import "WelcomeViewController.h"
#import <ChameleonFramework/Chameleon.h>


@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *lightBlue = [UIColor colorWithHexString:@"89F3FF"];
    UIColor *darkBlue = [UIColor colorWithHexString:@"00C6FE"];
    NSArray *colors = @[lightBlue, darkBlue];
    self.view.backgroundColor = GradientColor(UIGradientStyleTopToBottom, self.view.frame, colors);
// Do any additional setup after loading the view.
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
