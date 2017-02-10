//
//  BeastCell.h
//  Beast
//
//  Created by Kevin Yang on 4/22/16.
//  Copyright (c) 2016 Beast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeastCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *workoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *lvlLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *workoutPhoto;
@end
