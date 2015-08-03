//
//  StudentLearnedWord+Add.m
//  Gifted Kids
//
//  Created by 李诣 on 5/24/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "StudentLearnedWord+Add.h"

@implementation StudentLearnedWord (Add)

+ (StudentLearnedWord*)student:(NSString*)studentUsername
                   learnedWord:(NSNumber*)wordID
                        onDate:(NSDate*)dateLearned
        inManagedObjectContext:(NSManagedObjectContext*)context
{
    StudentLearnedWord* studentLearnedWord = nil;
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
    request.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ AND wordID == %@", studentUsername, wordID];
    NSError* error = nil;
    NSArray* match = [context executeFetchRequest:request error:&error];
    
    if (! match || [match count] > 1) {
        NSLog(@"ERROR: Error when fetching StudentLearnedWord with student %@ and wordID %@.", studentUsername, wordID);
        NSLog(@"\tmatch = %@", match);
    }
    else if ([match count] == 1) {
        studentLearnedWord = [match lastObject];
        NSLog(@"ERROR: StudentLearnedWord already exists with student %@ and wordID %@.", studentUsername, wordID);
    }
    else {   // [match count] == 0
        studentLearnedWord = [NSEntityDescription insertNewObjectForEntityForName:@"StudentLearnedWord" inManagedObjectContext:context];
        studentLearnedWord.studentUsername = studentUsername;
        studentLearnedWord.wordID = wordID;
        studentLearnedWord.dateLearned = dateLearned;
        NSLog(@"StudentLearnedWord created");
    }
    
    return studentLearnedWord;
}

@end
