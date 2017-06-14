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
#import "BeastWorkout.h"
#import "FirebaseRefs.h"
#import "WorkoutVideoViewController.h"
#import "BeastCollectionCell.h"
@import Firebase;

@interface BeastFilterController () <UICollectionViewDataSource, UICollectionViewDelegate>
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *workoutButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) FIRDatabaseReference *databaseRef;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (strong, nonatomic) NSMutableArray *filterEmojiArray;
@property (strong, nonatomic) NSMutableArray *filterWordsArray;
@property (strong, nonatomic) NSDictionary *emojiTofilterDictionary;
@property (strong, nonatomic) NSMutableDictionary *filterToBooleanDictionary;
@property (strong, nonatomic) NSString *mostRecentFilter;
@property int numFilters;
@property (weak, nonatomic) IBOutlet UILabel *filterTitle;


//WORKOUT ARRAYS
@property (strong, nonatomic) NSMutableArray *workoutsArray;
@property (strong, nonatomic) NSMutableArray *filteredWorkoutsArray;
@property (strong, nonatomic) NSDictionary *filterToVideosDictionary;

@end

@implementation BeastFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFirebase];
    [self initializeValues];
    [self downloadWorkouts];
    [self setupUI];
    [self createFilterBar];
    [self createWorkoutButton];
   // [self createPageView];
}

- (void)setupUI{
    self.collectionView.layer.cornerRadius = 20.0;
    self.collectionView.layer.masksToBounds = YES;
    self.filterTitle.text = @"begin";
}


- (void)initializeValues{
//    NSArray *array1 = @[@"⭐️", @"😊", @"☠", @"🔥", @"🦄", @"🏀", @"🌊", @"🎈"];
    NSArray *array1 = @[@"⭐️", @"😊", @"☠", @"🔥", @"🏀", @"🎈"];
    self.filterEmojiArray = [array1 mutableCopy];
    
    
    
    
    self.filterToVideosDictionary = @{
                                     @"⭐️" : @[@3],
                                     @"😊" : @[@0,@2,@3,@5],
                                     @"☠" : @[@1, @2],
                                     @"🔥" : @[@2, @3, @5],
                                     @"🏀" : @[@3, @4, @5],
                                     @"🎈" : @[@4, @5]
                                     };
    //FilterToVideos video numbers are normalized from 0-6, instead of 1-7 for easier array access
    
    
    self.emojiTofilterDictionary = @{
                             @"⭐️" : @"recommended",
                             @"😊" : @"beginner",
                             @"☠" : @"legendary",
                             @"🔥" : @"fat-burning",
                             @"🏀" : @"sport",
                             @"🎈" : @"fun"
                             };
    NSDictionary *filterToBoolean = @{
                                   @"recommended" : @NO,
                                   @"beginner" :  @NO,
                                   @"legendary" : @NO,
                                   @"cardio": @NO,
                                   @"sport" : @NO,
                                   @"fun": @NO
                                   };

    
    self.filterToBooleanDictionary = [filterToBoolean mutableCopy];
    
    [self buildFilterTitle];
}

- (void)updateFilteredWorkoutArray{
    self.filteredWorkoutsArray = [[NSMutableArray alloc] init];
    NSArray *filteredVideosArray = [self.filterToVideosDictionary objectForKey:self.mostRecentFilter];
    NSLog(@"FILTERED VIDEOS ARRAY%@", filteredVideosArray);
    //create new filtered workouts array
    for (NSNumber *videoIndex in filteredVideosArray){
        int videoIndexInt = [videoIndex integerValue];
        BeastWorkout *workout = self.workoutsArray[videoIndexInt];
        NSLog(@"WORKOUT OBJECT - %@ lvl%@", workout.name, workout.lvl);
        [self.filteredWorkoutsArray addObject:workout];
    }
    self.pageControl.numberOfPages = [self.filteredWorkoutsArray count];
    [self.collectionView reloadData];
}

#pragma mark - Dynamic Title Methods

- (NSString *)buildFilterTitle{
    NSString *title = @"begin ";
    NSLog(@"\n\nDICTIONARY%@\n\n", self.filterToBooleanDictionary);
 
    for (NSString *key in [self.filterToBooleanDictionary allKeys] ) {
        NSLog(@"\n\nKEY %@\n\n", key);
        NSNumber *isFilter = [self.filterToBooleanDictionary objectForKey:key];
        NSLog(@"\n\nOBJECT %@\n\n", isFilter);
        if([isFilter boolValue]){
            NSLog(@"YES");
            NSString *keyPlusSpace = [NSString stringWithFormat:@"%@ ", key];
            title = [title stringByAppendingString:keyPlusSpace];
        }else{
            NSLog(@"NO");
        }
    }
    NSLog(@"%@", title);
    return title;
}


#pragma mark FilterBar Methods

- (void) addFilter:(NSString *)filter{
    NSNumber *filterBool = [NSNumber numberWithBool:YES];
    [self.filterToBooleanDictionary setObject:filterBool forKey:filter];
}

- (void) removeFilter:(NSString *)filter{
    NSNumber *filterBool = [NSNumber numberWithBool:NO];
    [self.filterToBooleanDictionary setObject:filterBool forKey:filter];
}

- (void) filterButtonPressed:(UIButton *)button {
    NSString *emojiKey = button.titleLabel.text;
    NSLog(@"\n\n\nEmoji%@\n\n\n", emojiKey);

    NSString *filter = [self.emojiTofilterDictionary objectForKey:emojiKey];
    
    UIColor *selectedColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    
   
        if(button.selected){ //UNCLICK FILTER
            button.backgroundColor = [BeastColors lightBlue];
            [button setSelected:NO];
            [self removeFilter:filter];
            self.numFilters = self.numFilters-1;
        }else{ //CLICK FILTER
             if(self.numFilters <=1){
                button.backgroundColor = selectedColor;
                [button setSelected:YES];
                [self addFilter:filter];
                self.mostRecentFilter = emojiKey;
                NSLog(@"\n\n\nMOST RECENT FILTER %@", self.mostRecentFilter);
                self.numFilters = self.numFilters+1;
                 [self updateFilteredWorkoutArray];
             }
        }
    

    self.filterTitle.text = [self buildFilterTitle];
}


- (UIColor *)randomBackgroundColor:(int) index{
    NSArray * colorsArray = @[[BeastColors lightBlue], [BeastColors lightOrange]];
    int oddOrEven = index % 2;
    return colorsArray[oddOrEven];
}

- (void)createFilterBar
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    
    int x = 0;
    
    for (int i = 0; i < [self.filterEmojiArray count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(filterButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        button.userInteractionEnabled = YES;
        NSString *emoji = [self.filterEmojiArray objectAtIndex:i];
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

#pragma mark <UICollectionViewDataSource>

- (void)selectDefaultWorkout{
    NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:0 inSection:0];
    [self.collectionView selectItemAtIndexPath:selectedCellIndexPath animated:false scrollPosition:UICollectionViewScrollPositionLeft];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.filteredWorkoutsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BeastCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"workoutCell" forIndexPath:indexPath];
    //get workout object
    BeastWorkout *workout = self.filteredWorkoutsArray[indexPath.row];
    int lvl = [self getVideoNumberFromBeastWorkout:workout];
    NSString *imageName = [NSString stringWithFormat:@"cover%d.jpg", lvl];
    cell.imageView.image = [UIImage imageNamed:imageName];
    return cell;
}

- (int)getVideoNumberFromBeastWorkout:(BeastWorkout *)workout{
    return [[self convertStringToNumber:workout.lvl] integerValue];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.collectionView.frame.size;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // If you need to use the touched cell, you can retrieve it like so
    // UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    NSLog(@"\n\ntouched cell at indexPath %ld\n\n", (long)indexPath.row);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    self.pageControl.currentPage = indexPath.row;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"WorkoutVideoSegue"]) {
        UICollectionViewCell *cell = (UICollectionViewCell *)sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        WorkoutVideoViewController* vc = [segue destinationViewController];
        BeastWorkout *workout = [self.filteredWorkoutsArray objectAtIndex:indexPath.row];
        vc.exerciseArray = workout.exerciseArray;
    }
}


#pragma mark PageControl Methods

- (IBAction)pageChange:(UIPageControl *)sender {
    //CGFloat x = self.pageControl.currentPage * self.scrollView.frame.size.width;
    //[self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}


#pragma mark WorkoutButton Methods

- (void)createWorkoutButton{
    self.workoutButton.backgroundColor = [BeastColors lightBlue];
    self.workoutButton.layer.cornerRadius = 35.0;
    self.workoutButton.clipsToBounds = YES;
}

- (IBAction)justWorkoutButton:(id)sender {
    NSInteger randomIndex = arc4random()%[self.workoutsArray count];
    NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:randomIndex inSection:0];
    [self.collectionView selectItemAtIndexPath:selectedCellIndexPath
                                      animated:false
                                scrollPosition:UICollectionViewScrollPositionNone];
    BeastCollectionCell *cell = (BeastCollectionCell *)[self.collectionView cellForItemAtIndexPath:selectedCellIndexPath];
    [self performSegueWithIdentifier:@"WorkoutVideoSegue" sender:cell];
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
        self.filteredWorkoutsArray = self.workoutsArray;
        //SORT WORKOUT ARRAY
        [self sortWorkoutArray];
        [self downloadAllVideoWorkouts];
        [self.collectionView reloadData];
        [self selectDefaultWorkout];
        self.pageControl.numberOfPages = [self.workoutsArray count];
        NSLog(@"\n\n\n workoutArrayCount %lu \n\n\n", (unsigned long)[self.workoutsArray count]);
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


#pragma mark - Helper Methods

- (NSMutableArray *)workoutsArray{
    if(!_workoutsArray){
        _workoutsArray = [[NSMutableArray alloc] init];
    }
    return _workoutsArray;
}

- (NSMutableArray *)filterEmojiArray{
    if(!_filterEmojiArray){
        _filterEmojiArray = [[NSMutableArray alloc] init];
    }
    return _filterEmojiArray;
}

- (NSMutableArray *)filterWordsArray{
    if(!_filterWordsArray){
        _filterWordsArray = [[NSMutableArray alloc] init];
    }
    return _filterWordsArray;
}


#pragma mark Sort Firebase Array

-(void)sortWorkoutArray{
    NSArray *sortedArray = [self.workoutsArray sortedArrayUsingComparator:^NSComparisonResult(BeastWorkout *w1, BeastWorkout *w2){
        NSNumber *w1LVL = [self convertStringToNumber:w1.lvl];
        NSNumber *w2LVL = [self convertStringToNumber:w2.lvl];
//        NSLog(@"lvlNumber %d", [w1LVL integerValue]);
//        NSLog(@"lvlNumber %d", [w2LVL integerValue]);
        return [w1LVL compare:w2LVL];
    }];
    self.workoutsArray = [sortedArray mutableCopy];
}

-(NSNumber *)convertStringToNumber:(NSString *)stringNumber{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    return [f numberFromString:stringNumber];
}

/*
 #pragma mark Scrollview Methods
 
 
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
 
 -(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
 NSLog(@"SCROLLING");
 NSInteger pageNumber = roundf(scrollView.contentOffset.x / (scrollView.frame.size.width));
 self.pageControl.currentPage = pageNumber;
 }
 
 */



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
