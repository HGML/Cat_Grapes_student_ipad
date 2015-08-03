//
//  Unit+Add.m
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Unit+Add.h"

@implementation Unit (Add)

+ (Unit*)unitWithID:(NSNumber*)ID
           andTitle:(NSString*)title
inManagedObjectContext:(NSManagedObjectContext*)context
{
    Unit* unit = nil;
    
    NSFetchRequest* request_id = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request_id.predicate = [NSPredicate predicateWithFormat:@"uid == %@", ID];
    NSError* error = nil;
    NSArray* match_id = [context executeFetchRequest:request_id error:&error];
    
    if (! match_id || [match_id count] > 1) {
        NSLog(@"ERROR: Error when fetching unit with ID %@.", ID);
        NSLog(@"\tmatch = %@", match_id);
    }
    else if ([match_id count] == 1) {
        unit = [match_id lastObject];
        NSLog(@"ERROR: Unit already exists with ID %@.", ID);
    }
    else {   // [match_id count] == 0
        unit = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:context];
        unit.uid = ID;
        unit.title = title;
        NSLog(@"Unit created");
    }
    
    return unit;
}

@end
