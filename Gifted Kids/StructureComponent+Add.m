//
//  StructureComponent+Add.m
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "StructureComponent+Add.h"

@implementation StructureComponent (Add)

+ (StructureComponent*)structureComponentWithID:(NSNumber*)ID
                                           name:(NSString*)name
                                      andFamily:(NSString*)family
                                      reducible:(BOOL)reducible
                                     inExercise:(Exercise*)exercise
                         inManagedObjectContext:(NSManagedObjectContext*)context
{
    StructureComponent* structureComponent = nil;
    
    NSFetchRequest* request_id = [NSFetchRequest fetchRequestWithEntityName:@"StructureComponent"];
    request_id.predicate = [NSPredicate predicateWithFormat:@"uid == %@", ID];
    NSError* error = nil;
    NSArray* match_id = [context executeFetchRequest:request_id error:&error];
    
    if (! match_id || [match_id count] > 1) {
        NSLog(@"ERROR: Error when fetching StructureComponent with ID %@.", ID);
        NSLog(@"\tmatch = %@", match_id);
    }
    else if ([match_id count] == 1) {
        structureComponent = [match_id lastObject];
        structureComponent.name = name;
        structureComponent.family = family;
        structureComponent.reducible = [NSNumber numberWithBool:reducible];
        structureComponent.testedInExercise = exercise;
        NSLog(@"ERROR: StructureComponent already exists with ID %@. Replaced.", ID);
    }
    else {   // [match_id count] == 0
        structureComponent = [NSEntityDescription insertNewObjectForEntityForName:@"StructureComponent"
                                                           inManagedObjectContext:context];
        structureComponent.uid = ID;
        structureComponent.name = name;
        structureComponent.family = family;
        structureComponent.reducible = [NSNumber numberWithBool:reducible];
        structureComponent.testedInExercise = exercise;
        NSLog(@"StructureComponent created");
    }
    
    return structureComponent;
}

@end
