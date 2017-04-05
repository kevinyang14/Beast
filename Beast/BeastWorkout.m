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
        _name = name;
        _exerciseArray = exerciseArray;
    }
    return self;
}

- (id)initWithName:(NSString *)name lvl:(NSString*)lvl equipment:(NSString*)equipment bodyParts:(NSString*)bodyParts exerciseArray:(NSArray*)exerciseArray andTime:(NSNumber*)time{
    self = [super init];
    if (self) {
        _name = name;
        _lvl = lvl;
        _equipment = equipment;
        _bodyParts = bodyParts;
        _exerciseArray = exerciseArray;
        _time = time;
    }
    return self;
}

- (NSString *)description{
//    return [NSString stringWithFormat:@"%@m • %@ • %@ ", _time, _equipment, _bodyParts];
    
    return [NSString stringWithFormat:@"• %@ mins", _time];

}

- (void)printValues{
    NSLog(@"%@:\n",_name);
    NSLog(@"lvl %@\n", _lvl);
    NSLog(@"equipment %@\n", _equipment);
    NSLog(@"bodyParts %@\n", _bodyParts);
    NSLog(@"exerciseArray %@\n", _exerciseArray);
    NSLog(@"time %@m\n", _time);
}

@synthesize name = _name;
@synthesize lvl = _lvl;
@synthesize equipment = _equipment;
@synthesize bodyParts = _bodyParts;
@synthesize exerciseArray = _exerciseArray;
@synthesize time = _time;
@end
