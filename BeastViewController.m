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
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [self beastBlack];
}


- (void)setupNavbar{

    //set bar color
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setBarTintColor:[self beastBlack]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    
    //set title and title color
    [self.navigationItem setTitle:@"BEAST"];
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"MyriadPro-BoldIt" size:26], NSFontAttributeName,
                                    [self beastLightOrange], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:fontAttributes];
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

- (UIColor *) beastLightOrange {return [[UIColor alloc] initWithRed:249.0/255.0 green:154.0/255.0 blue:2.0/255.0 alpha:1];}

- (UIColor *) beastDarkOrange {return [[UIColor alloc] initWithRed:79.0/255.0 green:56.0/255.0 blue:41.0/255.0 alpha:1];}

- (UIColor *) beastBlack{ return [[UIColor alloc] initWithRed:36.0/255.0 green:36.0/255.0 blue:36.0/255.0 alpha:1];}

- (UIColor *) beastOrange{ return [[UIColor alloc] initWithRed:243.0/255.0 green:144.0/255.0 blue:83.0/255.0 alpha:1];}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"here");
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
    customColorView.backgroundColor = [self beastDarkOrange];
    cell.selectedBackgroundView =  customColorView;
    
    [self setupCellStyle:cell];

    return cell;
}


- (void)setupCellStyle:(BeastCell *)cell{
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [self beastBlack];
    cell.workoutPhoto.layer.cornerRadius = 25.0;
    cell.workoutPhoto.layer.masksToBounds = YES;
}

- (NSString *)getRandomWorkoutName{
    NSArray *workoutNames = @[@"Superman Strong", @"Batman Ripped", @"Wonder Woman", @"Hulk Buff"];
    return workoutNames[arc4random()%workoutNames.count];
}


- (NSString *)getRandomBeastEmoji{
    NSArray *beastEmojis = @[@"🐯", @"🐼", @"🐷", @"🐙", @"🐬", @"🐶"];
    return beastEmojis[arc4random()%beastEmojis.count];
}

- (NSString *)getRandomImageName{
    NSArray *imageNames = @[@"batman.png", @"superman.png", @"hulk.png", @"wonderwoman.png"];
    return imageNames[arc4random()%imageNames.count];
}

- (NSString *)getRandomViewCount{
    int numViews = arc4random()%200000;
    return [NSString stringWithFormat:@"%d views", numViews];
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
