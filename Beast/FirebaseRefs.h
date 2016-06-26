//
//  FirebaseRefs.h
//  Beast
//
//  Created by Kevin Yang on 23/06/2016.
//  Copyright © 2016 Beast. All rights reserved.
//

@import Firebase;
#import <Foundation/Foundation.h>

@interface FirebaseRefs : NSObject

+ (FIRDatabaseReference *)databaseRef;
+ (FIRStorageReference *)storageRef;
+ (NSURL *)videoLocalURL:(NSNumber *)vidNum;
+ (FIRStorageReference *)videoFirebaseRef:(NSNumber *)vidNum;
@end
