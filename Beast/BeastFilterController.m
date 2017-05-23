//
//  BeastFilterController.m
//  Beast
//
//  Created by Kevin Yang on 5/7/17.
//  Copyright © 2017 Beast. All rights reserved.
//

#import "BeastFilterController.h"
#import "BeastColors.h"
#import <ChameleonFramework/Chameleon.h>

@interface BeastFilterController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *workoutButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@end

@implementation BeastFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createFilterBar];
    [self createWorkoutButton];
    [self createPageView];
    // Do any additional setup after loading the view.
}

- (void)createPageView{
    NSArray * colorsArray = @[[BeastColors darkBlue], [BeastColors reddishPink], [BeastColors lightOrange]];
    CGRect frame = CGRectMake(0.0, 0.0, 0.0, 0.0);
    for (int i = 0; i < [colorsArray count]; i++){
        frame.origin.x = self.scrollView.frame.size.width * (float)i;
        frame.size = self.scrollView.frame.size;
        UIView *view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = colorsArray[i];
        [self.scrollView addSubview:view];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * (float)colorsArray.count, self.scrollView.frame.size.height);
    self.pageControl.numberOfPages = colorsArray.count;
    self.scrollView.layer.cornerRadius = 14.0;
    self.scrollView.layer.masksToBounds = YES;
}

- (void)createWorkoutButton{
    self.workoutButton.backgroundColor = [BeastColors lightBlue];
    self.workoutButton.layer.cornerRadius = 35.0;
    self.workoutButton.clipsToBounds = YES;
}

- (void)createFilterBar
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    
    int x = 0;
    NSArray *emojis = @[@"⭐️", @"😊", @"☠", @"🔥", @"🦄", @"🏀", @"🌊", @"🎈"];
    for (int i = 0; i < [emojis count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(buttonPress:)
         forControlEvents:UIControlEventTouchUpInside];
        button.userInteractionEnabled = YES;
        NSString *emoji = [emojis objectAtIndex:i];
        [button setTitle:emoji forState:UIControlStateNormal];
        [button.titleLabel setFont: [UIFont boldSystemFontOfSize:25.0]];
        [button.titleLabel setTextAlignment: NSTextAlignmentCenter];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0.5, 0, 0)];//set ur title insects also
        
        button.frame = CGRectMake(x, 24, 60, 60);
        button.layer.cornerRadius = button.frame.size.height/2;
        button.clipsToBounds = YES;

        [scrollView addSubview:button];
        x += button.frame.size.width + 10;
    }
    scrollView.contentSize = CGSizeMake(x, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator =  NO;

    scrollView.backgroundColor = [BeastColors lightBlue];
    [self.view addSubview:scrollView];
}

- (void) buttonPress:(UIButton *)button {

    NSLog(@"\n\nBUTTON IS PRESSED %@", button.titleLabel.text);
    UIColor *selectedColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    
    if(button.selected){
        NSLog(@"\nselected");
        button.backgroundColor = [BeastColors lightBlue];
        [button setSelected:NO];
    }else{
        NSLog(@"\nis not selected");
        button.backgroundColor = selectedColor;
        [button setSelected:YES];
    }
}

- (IBAction)pageChange:(UIPageControl *)sender {
    CGFloat x = self.pageControl.currentPage * self.scrollView.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
    NSLog(@"SCROLLING");
    NSInteger pageNumber = roundf(scrollView.contentOffset.x / (scrollView.frame.size.width));
    self.pageControl.currentPage = pageNumber;
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
