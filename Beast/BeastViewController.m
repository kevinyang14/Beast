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
#import "FirebaseRefs.h"
#import "WorkoutVideoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BeastColors.h"
@import Firebase;

@interface BeastViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *workoutsArray;
@property (weak, nonatomic) IBOutlet UIButton *workoutButton;
@property (strong, nonatomic) FIRDatabaseReference *databaseRef;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@end

@implementation BeastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFirebase];
    [self setupUI];
    [self setupSwipeGestureRecognizer];
//    [self uploadAllWorkouts];
    [self downloadWorkouts];
}


#pragma mark - Firebase Methods

- (void)setupFirebase{
    self.databaseRef = [FirebaseRefs databaseRef];
    self.storageRef = [FirebaseRefs storageRef];
}

// Download workout info from Firebase Database
- (void)downloadWorkouts{
    [self.databaseRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"\n\n\n");
        NSLog(@"Firebase Backend:");
        NSLog(@"%@", snapshot.value);
        NSDictionary *firebaseDictionary = snapshot.value;
        NSDictionary *workoutsDictionary = [firebaseDictionary objectForKey:@"workouts"];
        for (NSString* key in [workoutsDictionary allKeys])
        {
            NSDictionary *workoutDictionary = [workoutsDictionary objectForKey:key];
            BeastWorkout *beastWorkout = [self beastWorkoutFromDict:workoutDictionary];
            [self.workoutsArray addObject:beastWorkout];
        }
        [self downloadAllVideoWorkouts];
        [self.tableView reloadData];
        [self selectDefaultWorkout];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (BeastWorkout *)beastWorkoutFromDict:(NSDictionary *)workoutDictionary{
    NSString *name = [workoutDictionary objectForKey:@"name"];
    NSString *lvl = [workoutDictionary objectForKey:@"lvl"];
    NSNumber *time = [workoutDictionary objectForKey:@"time"];
    NSString *equipment = [workoutDictionary objectForKey:@"equipment"];
    NSString *bodyParts = [workoutDictionary objectForKey:@"body parts"];
    NSArray *exerciseArray = [workoutDictionary objectForKey:@"exerciseArray"];
    BeastWorkout *beastWorkout = [[BeastWorkout alloc] initWithName:name lvl:lvl equipment:equipment bodyParts:bodyParts exerciseArray:exerciseArray andTime:time];
    [beastWorkout printValues];
    return beastWorkout;
}


- (void)downloadAllVideoWorkouts{
    for (BeastWorkout *workout in self.workoutsArray) {
        [self downloadVideoWorkout:workout];
    }
}

- (void)downloadVideoWorkout:(BeastWorkout *)workout{
    NSArray *exerciseArray = workout.exerciseArray;
    for (NSNumber *exerciseNum in exerciseArray) {
        if([self isExerciseDownloaded:exerciseNum] == NO) [self downloadExercise:exerciseNum];
    }
}

- (void)downloadExercise:(NSNumber *)videoNumber{
    // Get firebaseRef & localURL
    FIRStorageReference *firebaseRef = [FirebaseRefs videoFirebaseRef:videoNumber];
    NSURL *localURL = [FirebaseRefs videoLocalURL:videoNumber];
    NSLog(@"downloading video %@", videoNumber);
    // Download to the local filesystem
    [firebaseRef writeToFile:localURL completion:^(NSURL *URL, NSError *error){
        if (error != nil) {
            //Error!
            NSLog(@"error %@", error);
        } else {
            //Success!
            //NSLog(@"fileURL: %@", [URL path]);
        }
    }];
}

- (BOOL)isWorkoutDownloaded:(NSArray *)exerciseArray{
    for (NSNumber *exerciseNum in exerciseArray) {
        if([self isExerciseDownloaded:exerciseNum] == NO) return NO;
    }
    return YES;
}

- (BOOL)isExerciseDownloaded:(NSNumber *)videoNum{
    NSURL *fileURL = [FirebaseRefs videoLocalURL:videoNum];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[fileURL path]]) return YES;
    return NO;
}


//-----------------------1-Time Upload--------------------//

- (void)uploadAllWorkouts{
    NSArray* array = [self createBeastWorkouts];
    for (BeastWorkout *workout in array){
        [self uploadWorkout:workout];
    }
}

- (NSArray *)createBeastWorkouts{
    BeastWorkout *one = [[BeastWorkout alloc] initWithName:@"Superman Strong" lvl:@"🐯" equipment:@"gym equipment" bodyParts:@"chest & back" exerciseArray:@[@"6",@"7",@"11",@"12",@"13",@"14",@"15",@"16"] andTime:@30];
    
    BeastWorkout *two = [[BeastWorkout alloc] initWithName:@"5x5" lvl:@"🐼" equipment:@"gym equipment" bodyParts:@"full body" exerciseArray:@[@"1",@"2",@"3",@"4",@"5"] andTime:@40];
    
    BeastWorkout *three = [[BeastWorkout alloc] initWithName:@"6 Pack Abs" lvl:@"🐳" equipment:@"no equipment" bodyParts:@"abs" exerciseArray:@[@"20",@"21",@"22",@"23",@"24",@"25"] andTime:@10];
    
    BeastWorkout *four = [[BeastWorkout alloc] initWithName:@"Batman Biceps" lvl:@"🦁" equipment:@"dumbbells" bodyParts:@"biceps & triceps" exerciseArray:@[@"8",@"9",@"10",@"17"] andTime:@30];
    
    
    BeastWorkout *five = [[BeastWorkout alloc] initWithName:@"Beast Blast" lvl:@"🦄" equipment:@"gym equipment" bodyParts:@"full body" exerciseArray:@[@"6", @"7",@"8",@"9",@"10",@"17",@"18"] andTime:@30];
    
    
    BeastWorkout *six = [[BeastWorkout alloc] initWithName:@"Killer Home Workout" lvl:@"🐢" equipment:@"no equipment" bodyParts:@"abs" exerciseArray:@[@"18",@"19",@"21",@"22",@"23"] andTime:@10];
    
    return @[one, two, three, four, five, six];
}

- (void)uploadWorkout:(BeastWorkout *)workout{
    FIRDatabaseReference *workoutRef = [[self.databaseRef child:@"workouts"] childByAutoId];
    [[workoutRef child:@"name"] setValue:workout.name];
    [[workoutRef child:@"lvl"] setValue:workout.lvl];
    [[workoutRef child:@"time"] setValue:workout.time];
    [[workoutRef child:@"equipment"] setValue:workout.equipment];
    [[workoutRef child:@"body parts"] setValue:workout.bodyParts];
    [[workoutRef child:@"exerciseArray"] setValue:workout.exerciseArray];
}


#pragma mark - IBAction Methods

- (IBAction)justWorkout:(id)sender {
    NSInteger randomIndex = arc4random()%[self.workoutsArray count];
    NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:randomIndex inSection:0];
    [self.tableView selectRowAtIndexPath:selectedCellIndexPath animated:false scrollPosition:UITableViewScrollPositionMiddle];
    [self performSegueWithIdentifier:@"blastSegue" sender:sender];
}

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
    cell.lvlLabel.text = workout.lvl;
    cell.descriptionLabel.text = [workout description];
    NSString *imageName = [self imageAtIndex:(int)indexPath.row];
    cell.workoutPhoto.image = [UIImage imageNamed:imageName];
    
    [self setupCellStyle:cell];
    
    //Grey out video, if not downloaded
    if (![self isWorkoutDownloaded:workout.exerciseArray]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    //Change highlight color
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = [BeastColors darkBlue];
    cell.selectedBackgroundView =  customColorView;

    return cell;
}

- (void)setupCellStyle:(BeastCell *)cell{
    cell.backgroundColor = [UIColor clearColor];
    cell.workoutPhoto.layer.cornerRadius = 25.0;
    cell.workoutPhoto.layer.masksToBounds = YES;
}

#pragma mark - UI Magic

- (void)setupUI
{
    [self setupNavbar];
    self.view.backgroundColor = [BeastColors darkBlack];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)selectDefaultWorkout{
    NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:selectedCellIndexPath animated:false scrollPosition:UITableViewScrollPositionMiddle];
}


- (CGRect)trueFrame:(CGRect)oldFrame{
    return CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height+10);
}

- (void)setupNavbar{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor =  [BeastColors darkBlack];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"BEAST";
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"MyriadPro-BoldIt" size:26], NSFontAttributeName,
                                    [BeastColors lightBlue], NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:fontAttributes];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//
//#pragma mark - App Colors
//
//- (UIColor *) lightBlue {return HexColor(@"#76F6E5");}
//
//- (UIColor *) darkBlue {return HexColor(@"#0E5461");}
//
//- (UIColor *) lightOrange {return HexColor(@"#F99A02");}
//
//- (UIColor *) darkOrange {return HexColor(@"#3F2617");}
//
//- (UIColor *) darkBlack{ return HexColor(@"#181C20");}
//
//- (UIColor *) separatorGray{ return HexColor(@"#FFFFFF");}


#pragma mark - Cell Population Methods

- (NSString *)imageAtIndex:(int)number{
    int index = number%4;
    NSArray *imageNames = @[@"batman.png", @"superman.png", @"hulk.png", @"wonderwoman.png"];
    return [imageNames objectAtIndex:index];
}

- (NSString *)emojiAtIndex:(int)index{
    NSArray *imageNames = @[@"🐯", @"🐼", @"🐳", @"🦁", @"🦄", @"🐢"];
    return [imageNames objectAtIndex:index];
}

#pragma mark - Helper Methods

- (NSMutableArray *)workoutsArray{
    if(!_workoutsArray){
        _workoutsArray = [[NSMutableArray alloc] init];
    }
    return _workoutsArray;
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


#pragma mark - Swipe Methods

- (void)setupSwipeGestureRecognizer{
    UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeGestureRecognizer];
}

- (void)handleSwipeFrom:(UIGestureRecognizer*)recognizer {
    NSLog(@"Swipe to Mirror!");
    [self performSegueWithIdentifier:@"MirrorSegue" sender:self];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"VideoSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WorkoutVideoViewController* vc = [segue destinationViewController];
        BeastWorkout *workout = [self.workoutsArray objectAtIndex:indexPath.row];
        vc.exerciseArray = workout.exerciseArray;
    }
}


@end
