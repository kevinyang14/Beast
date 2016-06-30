//
//  FirebaseRefs.m
//  Beast
//
//  Created by Kevin Yang on 23/06/2016.
//  Copyright © 2016 Beast. All rights reserved.
//

#import "FirebaseRefs.h"


@implementation FirebaseRefs


+ (FIRDatabaseReference *)databaseRef{
    return [[FIRDatabase database] reference];
}

+ (FIRStorageReference *)storageRef{
    return [[FIRStorage storage] referenceForURL:@"gs://beast-5e34d.appspot.com"];
}

//Video (LocalURL)
+ (NSURL *)videoLocalURL:(NSNumber *)vidNum{
    NSString *fileName = [NSString stringWithFormat:@"%@.m4v", vidNum];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *URL = [documentsURL URLByAppendingPathComponent:fileName];
//    NSLog(@"URL = %@", [URL path]);
    return URL;
}

//Video (FirebaseRef)

+ (FIRStorageReference *)videoFirebaseRef:(NSNumber *)vidNum{
    NSString *videoURL = [NSString stringWithFormat:@"videos/%@.m4v", vidNum];
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage reference];
    FIRStorageReference *firebaseRef = [storageRef child:videoURL];
//    NSLog(@"firebaseRef = %@", firebaseRef);
    return firebaseRef;
}

@end
