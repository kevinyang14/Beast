//
//  GymViewController.m
//  Beast
//
//  Created by Kevin Yang on 03/07/2016.
//  Copyright © 2016 Beast. All rights reserved.
//

#import "GymViewController.h"
#import "FriendCell.h"
#import "BeastColors.h"

@interface GymViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *pictureNames;
@property (nonatomic, strong) NSArray *peopleNames;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation GymViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSwipeGestureRecognizer];
    self.pictureNames = @[@"KevinAvatar", @"KeithAvatar", @"ManuAvatar", @"TourajAvatar"];
    self.peopleNames = @[@"Me", @"Keith Yang", @"Manu Chopra", @"Touraj Parang"];

    //remove cell separator after last cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setupNavbar];
}

- (void)setupNavbar{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor =  [BeastColors reddishPink];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"🏋️";
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"MyriadPro" size:35], nil];
    [self.navigationController.navigationBar setTitleTextAttributes:fontAttributes];
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *friendCellID = @"FriendCell";
    FriendCell *friendCell = [tableView dequeueReusableCellWithIdentifier:friendCellID forIndexPath:indexPath];
    NSString *pictureName = [self.pictureNames objectAtIndex:indexPath.row];
    NSString *peopleName = [self.peopleNames objectAtIndex:indexPath.row];

    friendCell.avatar.image = [UIImage imageNamed:pictureName];
    friendCell.name.text = peopleName;
    [self formatCell:friendCell];
    return friendCell;
}


- (void)formatCell:(FriendCell *)cell{
    //extend cell separators to full width
    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
}

//------------------------------------------------------------------------

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
