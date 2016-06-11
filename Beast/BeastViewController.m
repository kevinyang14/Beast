//
//  BeastViewController.m
//  Beast
//
//  Created by Kevin Yang on 4/22/16.
//  Copyright (c) 2016 Beast. All rights reserved.
//

#import "BeastViewController.h"
#import "BeastCell.h"
#import "BeastWorkout.h"
#import "WorkoutVideoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <ChameleonFramework/Chameleon.h>
@import Firebase;

@interface BeastViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *workoutsArray;
@property (weak, nonatomic) IBOutlet UIButton *workoutButton;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@end

@implementation BeastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    [self setupUI];
    [self uploadWorkouts];
    [self downloadWorkouts];
}

- (NSMutableArray *)workoutsArray{
    if(!_workoutsArray){
        _workoutsArray = [[NSMutableArray alloc] init];
    }
    return _workoutsArray;
}

#pragma mark - Firebase Methods

- (void)uploadWorkouts{
    [[[self.ref child:@"workouts"] child:@"Beast Blast"] setValue:@[@"6", @"7",@"8",@"9",@"10",@"17",@"18"]];
    [[[self.ref child:@"workouts"] child:@"Batman Biceps"] setValue:@[@"8",@"9",@"10",@"17"]];
    [[[self.ref child:@"workouts"] child:@"Superman Strong"] setValue:@[@"6",@"7",@"11",@"12",@"13",@"14",@"15",@"16"]];
    [[[self.ref child:@"workouts"] child:@"5x5"] setValue:@[@"1",@"2",@"3",@"4",@"5"]];
    [[[self.ref child:@"workouts"] child:@"6 Pack Abs"] setValue:@[@"20",@"21",@"22",@"23",@"24",@"25"]];
    [[[self.ref child:@"workouts"] child:@"Killer Home Workout"] setValue:@[@"18",@"19",@"21",@"22",@"23"]];
}

- (void)downloadWorkouts{
    [self.ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"\n\n\n");
        NSLog(@"FIREBASE WORKOUTS:");
        NSDictionary *firebaseDictionary = snapshot.value;
        NSDictionary *workoutsDictionary = [firebaseDictionary objectForKey:@"workouts"];
        for (NSString* key in [workoutsDictionary allKeys])
        {
            NSMutableArray *exerciseArray = [workoutsDictionary objectForKey:key];
            BeastWorkout *beastWorkout = [[BeastWorkout alloc] initWithName:key andExerciseArray:exerciseArray];
            [self.workoutsArray addObject:beastWorkout];
//            NSLog(@"%@", beastWorkout);
        }
        [self.tableView reloadData];
    
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}


#pragma mark - UI Magic


- (void)setupUI
{
    [self setupNavbar];
    self.view.backgroundColor = [self darkBlack];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
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
                                    [self lightBlue], NSForegroundColorAttributeName, nil];
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

- (UIColor *) lightBlue {return HexColor(@"#76F6E5");}

- (UIColor *) darkBlue {return HexColor(@"#0E5461");}

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
    return [self.workoutsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BeastCell";
    BeastCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //BeastWorkout Object
    BeastWorkout *workout = [self.workoutsArray objectAtIndex:indexPath.row];
    
    //Create BeastCell
    cell.workoutLabel.text = workout.name;
//    cell.beastLabel.text =[self getRandomBeastEmoji];
    cell.beastLabel.text =[self emojiAtIndex:(int)indexPath.row];
    cell.numViewsLabel.text = [self getRandomViewCount];
//    NSString *imageName = [self getRandomImageName];
    NSString *imageName = [self imageAtIndex:(int)indexPath.row];
    cell.workoutPhoto.image = [UIImage imageNamed:imageName];
    
    //Change highlight color
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = [self darkBlue];
    cell.selectedBackgroundView =  customColorView;
    
    [self setupCellStyle:cell];

    return cell;
}

- (void)setupCellStyle:(BeastCell *)cell{
    cell.backgroundColor = [UIColor clearColor];
    cell.workoutPhoto.layer.cornerRadius = 25.0;
    cell.workoutPhoto.layer.masksToBounds = YES;
}


//---------------ORDERED METHODS-----------//

- (NSString *)imageAtIndex:(int)number{
    int index = number%4;
    NSArray *imageNames = @[@"batman.png", @"superman.png", @"hulk.png", @"wonderwoman.png"];
    return [imageNames objectAtIndex:index];
}

- (NSString *)emojiAtIndex:(int)index{
    NSArray *imageNames = @[@"🐯", @"🐼", @"🐳", @"🦁", @"🦄", @"🐢"];
    return [imageNames objectAtIndex:index];
}

//----------------------------------------//



//--------------RANDOM METHODS--------------//

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

//--------------RANDOM METHODS--------------//



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"blastSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WorkoutVideoViewController* vc = [segue destinationViewController];
        BeastWorkout *workout = [self.workoutsArray objectAtIndex:indexPath.row];
        vc.exerciseArray = workout.exerciseArray;
    }
}


@end
