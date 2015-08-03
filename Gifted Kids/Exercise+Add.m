//
//  Exercise+Add.m
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Exercise+Add.h"

@implementation Exercise (Add)

+ (Exercise*)exerciseWithID:(NSNumber*)ID
                     inUnit:(Unit*)unit
   withManagedObjectContext:(NSManagedObjectContext*)context
{
    Exercise* exercise = nil;
    
    NSFetchRequest* request_id = [NSFetchRequest fetchRequestWithEntityName:@"Exercise"];
    request_id.predicate = [NSPredicate predicateWithFormat:@"uid == %@", ID];
    NSError* error = nil;
    NSArray* match_id = [context executeFetchRequest:request_id error:&error];
    
    if (! match_id || [match_id count] > 1) {
        NSLog(@"ERROR: Error when fetching exercise with ID %@.", ID);
        NSLog(@"\tmatch = %@", match_id);
    }
    else if ([match_id count] == 1) {
        exercise = [match_id lastObject];
        NSLog(@"ERROR: Exercise already exists with ID %@.", ID);
    }
    else {   // [match_id count] == 0
        exercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:context];
        exercise.uid = ID;
        exercise.inUnit = unit;
        NSLog(@"Exercise created");
    }
    
    return exercise;
}

@end
