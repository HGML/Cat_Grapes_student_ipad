//
//  Word+Add.m
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Word+Add.h"

@implementation Word (Add)

+ (Word*)wordWithID:(NSNumber*)ID
            english:(NSString*)English
            chinese:(NSString*)Chinese
    andPartOfSpeech:(NSString*)POS
         inExercise:(Exercise*)exercise
inManagedObjectContext:(NSManagedObjectContext*)context
{
    Word* word = nil;
    
    NSFetchRequest* request_id = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request_id.predicate = [NSPredicate predicateWithFormat:@"uid == %@", ID];
    NSError* error = nil;
    NSArray* match_id = [context executeFetchRequest:request_id error:&error];
    
    if (! match_id || [match_id count] > 1) {
        NSLog(@"ERROR: Error when fetching word with ID %@.", ID);
        NSLog(@"\tmatch = %@", match_id);
    }
    else if ([match_id count] == 1) {
        word = [match_id lastObject];
        word.english = English;
        word.chinese = Chinese;
        word.partOfSpeech = POS;
        word.testedInExercise = exercise;
        NSLog(@"ERROR: Word already exists with ID %@. Replaced.", ID);
    }
    else {   // [match_id count] == 0
        NSFetchRequest* request_word = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
        request_word.predicate = [NSPredicate predicateWithFormat:@"english == %@ AND chinese == %@ AND partOfSpeech == %@", English, Chinese, POS];
        NSArray* match_word = [context executeFetchRequest:request_word error:&error];
        if (! match_word || [match_word count] > 1) {
            NSLog(@"ERROR: Error when fetching word (%@, %@, %@).", English, Chinese, POS);
            NSLog(@"\tmatch = %@", match_word);
        }
        else if ([match_word count] == 1) {
            word = [match_word lastObject];
            word.uid = ID;
            word.english = English;
            word.chinese = Chinese;
            word.partOfSpeech = POS;
            word.testedInExercise = exercise;
            NSLog(@"ERROR: Word (%@, %@, %@) already exists. Replaced.", English, Chinese, POS);
        }
        else {
            word = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:context];
            word.uid = ID;
            word.english = English;
            word.chinese = Chinese;
            word.partOfSpeech = POS;
            word.testedInExercise = exercise;
            NSLog(@"Word created");
        }
    }
    
    return word;
}

@end
