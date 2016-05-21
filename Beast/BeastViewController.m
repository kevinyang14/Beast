//
//  BeastViewController.m
//  Beast
//
//  Created by Kevin Yang on 4/22/16.
//  Copyright (c) 2016 Beast. All rights reserved.
//

#import "BeastViewController.h"
#import "BeastCell.h"
#import <QuartzCore/QuartzCore.h>
#import <ChameleonFramework/Chameleon.h>

@interface BeastViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *workoutsArray;
@property (weak, nonatomic) IBOutlet UIButton *workoutButton;
@end

@implementation BeastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];

}

- (NSMutableArray *)workoutsArray{
    if(!_workoutsArray){
        _workoutsArray = [[NSMutableArray alloc] init];
    }
    return _workoutsArray;
}

#pragma mark - UI Magic


- (void)setupUI
{
    [self setupNavbar];
    self.view.backgroundColor = [self darkBlack];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = HexColor(@"#2E2F33");

//    self.tableView.separatorColor = [UIColor clearColor];
}


- (CGRect)trueFrame:(CGRect)oldFrame{
    return CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height+10);
}

- (void)setupNavbar{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor =  [self darkBlack];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"BEAST";
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"MyriadPro-BoldIt" size:26], NSFontAttributeName,
                                    [self lightOrange], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:fontAttributes];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)printFontNames{
    NSArray *fontFamilies = [UIFont familyNames];
    for (int i = 0; i < [fontFamilies count]; i++)
    {
        NSString *fontFamily = [fontFamilies objectAtIndex:i];
        NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
        NSLog (@"%@: %@", fontFamily, fontNames);
    }
}

#pragma mark - App Colors

- (UIColor *) lightOrange {return HexColor(@"#F99A02");}

- (UIColor *) darkOrange {return HexColor(@"#3F2617");}

- (UIColor *) darkBlack{ return HexColor(@"#181C20");}

- (UIColor *) beastBlack{ return [[UIColor alloc] initWithRed:36.0/255.0 green:36.0/255.0 blue:36.0/255.0 alpha:1];}

//- (UIColor *) beastDarkBlack{ return [[UIColor alloc] initWithRed:18.0/255.0 green:19.0/255.0 blue:20.0/255.0 alpha:1];}



- (UIColor *) beastOrange{ return [[UIColor alloc] initWithRed:243.0/255.0 green:144.0/255.0 blue:83.0/255.0 alpha:1];}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BeastCell";
    BeastCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Create BeastCell
    cell.workoutLabel.text = [self getRandomWorkoutName];
    cell.beastLabel.text =[self getRandomBeastEmoji];
    cell.numViewsLabel.text = [self getRandomViewCount];
    NSString *imageName = [self getRandomImageName];
    cell.workoutPhoto.image = [UIImage imageNamed:imageName];
    
    //Change highlight color
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = [self darkOrange];
    cell.selectedBackgroundView =  customColorView;
    
    [self setupCellStyle:cell];

    return cell;
}

- (void)setupCellStyle:(BeastCell *)cell{
    cell.backgroundColor = [UIColor clearColor];
    cell.workoutPhoto.layer.cornerRadius = 25.0;
    cell.workoutPhoto.layer.masksToBounds = YES;
}

- (NSString *)getRandomWorkoutName{
    NSArray *workoutNames = @[@"Superman Strong", @"Batman Ripped", @"Wonder Woman", @"Hulk Buff"];
    return workoutNames[arc4random()%workoutNames.count];
}


- (NSString *)getRandomBeastEmoji{
    NSArray *beastEmojis = @[@"🐯", @"🐼", @"🐷", @"🦁", @"🐳", @"🦄", @"🐢", @"🐲"];
    return beastEmojis[arc4random()%beastEmojis.count];
}

- (NSString *)getRandomImageName{
    NSArray *imageNames = @[@"batman.png", @"superman.png", @"hulk.png", @"wonderwoman.png"];
    return imageNames[arc4random()%imageNames.count];
}

- (NSString *)getRandomViewCount{
    int numViews = arc4random()%200000;
    return [NSString stringWithFormat:@"%d followers", numViews];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (void)setupWorkoutButton{
//    CGRect trueButtonFrame = [self trueFrame:self.workoutButton.frame];
//    NSLog(@"%f %f %f %f\n\n",trueButtonFrame.size.height, trueButtonFrame.size.width, trueButtonFrame.origin.x, trueButtonFrame.origin.y);
//
//    NSLog(@"%f %f %f %f\n\n",self.workoutButton.frame.size.height, self.workoutButton.frame.size.width, self.workoutButton.frame.origin.x, self.workoutButton.frame.origin.y);
//
//    self.workoutButton.layer.cornerRadius = 28.0;
//    self.workoutButton.backgroundColor = ([UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
//                           withFrame:[self trueFrame:self.workoutButton.frame]
//                           andColors:@[HexColor(@"#FAD961"),HexColor(@"#F76B1C")]]);
//}

@end
