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
@property (nonatomic, strong) NSString *lvl;
@property (nonatomic, strong) NSString *equipment;
@property (nonatomic, strong) NSString *bodyParts;
@property (nonatomic, strong) NSArray *exerciseArray; //exercise numbers returned in numbers
@property NSNumber* time;

- (id)initWithName:(NSString *)name andExerciseArray:(NSMutableArray*) exerciseArray;

- (id)initWithName:(NSString *)name lvl:(NSString*)lvl equipment:(NSString*)equipment bodyParts:(NSString*)bodyParts exerciseArray:(NSArray*)exerciseArray andTime:(NSNumber*)time;

- (NSString *)description;

- (void)printValues;


@end
