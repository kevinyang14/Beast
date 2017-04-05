//
//  FriendCell.h
//  Beast
//
//  Created by Kevin Yang on 3/9/17.
//  Copyright © 2017 Beast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIButton *wantsToWorkoutButton;
@end
