//
//  BeastWorkout.h
//  Beast
//
//  Created by Kevin Yang on 08/06/2016.
//  Copyright © 2016 Beast. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeastWorkout : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *exerciseArray; //exercise numbers returned in numbers

- (id)initWithName:(NSString *)name andExerciseArray:(NSMutableArray*) exerciseArray;

@end
