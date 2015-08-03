//
//  StudentLearnedComponent+Add.m
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "StudentLearnedComponent+Add.h"

@implementation StudentLearnedComponent (Add)

+ (StudentLearnedComponent*)student:(NSString*)studentUsername
                   learnedComponent:(NSNumber*)componentID
                             onDate:(NSDate*)dateLearned
             inManagedObjectContext:(NSManagedObjectContext*)context
{
    StudentLearnedComponent* studentLearnedComponent = nil;
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedComponent"];
    request.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ AND componentID == %@", studentUsername, componentID];
    NSError* error = nil;
    NSArray* match = [context executeFetchRequest:request error:&error];
    
    if (! match || [match count] > 1) {
        NSLog(@"ERROR: Error when fetching StudentLearnedComponent with student %@ and componentID %@.", studentUsername, componentID);
        NSLog(@"\tmatch = %@", match);
    }
    else if ([match count] == 1) {
        studentLearnedComponent = [match lastObject];
        NSLog(@"ERROR: StudentLearnedComponent already exists with student %@ and componentID %@.", studentUsername, componentID);
    }
    else {   // [match count] == 0
        studentLearnedComponent = [NSEntityDescription insertNewObjectForEntityForName:@"StudentLearnedComponent" inManagedObjectContext:context];
        studentLearnedComponent.studentUsername = studentUsername;
        studentLearnedComponent.componentID = componentID;
        studentLearnedComponent.dateLearned = dateLearned;
        NSLog(@"StudentLearnedComponent created");
    }
    
    return studentLearnedComponent;
}

@end
