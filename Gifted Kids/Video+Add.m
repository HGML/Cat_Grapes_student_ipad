//
//  Video+Add.m
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Video+Add.h"

@implementation Video (Add)

+ (Video*)videoWithID:(NSNumber*)ID
           andYoukuID:(NSString*)youkuID
               inUnit:(Unit*)unit
inManagedObjectContext:(NSManagedObjectContext*)context
{
    Video* video = nil;
    
    NSFetchRequest* request_id = [NSFetchRequest fetchRequestWithEntityName:@"Video"];
    request_id.predicate = [NSPredicate predicateWithFormat:@"uid == %@", ID];
    NSError* error = nil;
    NSArray* match_id = [context executeFetchRequest:request_id error:&error];
    
    if (! match_id || [match_id count] > 1) {
        NSLog(@"ERROR: Error when fetching video with ID %@.", ID);
        NSLog(@"\tmatch = %@", match_id);
    }
    else if ([match_id count] == 1) {
        video = [match_id lastObject];
        NSLog(@"ERROR: Video already exists with ID %@.", ID);
    }
    else {   // [match_id count] == 0
        NSFetchRequest* request_youkuID = [NSFetchRequest fetchRequestWithEntityName:@"Video"];
        request_youkuID.predicate = [NSPredicate predicateWithFormat:@"youkuID == %@", youkuID];
        NSArray* match_youkuID = [context executeFetchRequest:request_youkuID error:&error];
        if (! match_youkuID || [match_youkuID count] > 1) {
            NSLog(@"ERROR: Error when fetching video with YoukuID %@.", youkuID);
            NSLog(@"\tmatch = %@", match_youkuID);
        }
        else if ([match_youkuID count] == 1) {
            NSLog(@"WARNING: Video already exists with YoukuID %@.", youkuID);
        }
        
        video = [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:context];
        video.uid = ID;
        video.youkuID = youkuID;
        video.inUnit = unit;
        NSLog(@"Video created");
    }
    
    return video;
}

@end
