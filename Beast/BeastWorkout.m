//
//  BeastWorkout.m
//  Beast
//
//  Created by Kevin Yang on 08/06/2016.
//  Copyright © 2016 Beast. All rights reserved.
//

#import "BeastWorkout.h"

@implementation BeastWorkout

- (id)initWithName:(NSString *)name andExerciseArray:(NSMutableArray*) exerciseArray{
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        _name = name;
        _exerciseArray = exerciseArray;
    }
    return self;
}

@synthesize name = _name;
@synthesize exerciseArray = _exerciseArray;

@end
