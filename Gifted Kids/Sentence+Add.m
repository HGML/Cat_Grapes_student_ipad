//
//  Sentence+Add.m
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Sentence+Add.h"

@implementation Sentence (Add)

+ (Sentence*)sentenceWithID:(NSNumber*)ID
                    english:(NSString*)English
                    chinese:(NSString*)Chinese
                  structure:(NSString*)structure
                    andCore:(NSString*)core
   usingStructureComponents:(NSSet*)structureComponents
                 usingWords:(NSSet*)words
     inManagedObjectContext:(NSManagedObjectContext*)context
{
    Sentence* sentence = nil;
    
    NSFetchRequest* request_id = [NSFetchRequest fetchRequestWithEntityName:@"Sentence"];
    request_id.predicate = [NSPredicate predicateWithFormat:@"uid == %@", ID];
    NSError* error = nil;
    NSArray* match_id = [context executeFetchRequest:request_id error:&error];
    
    if (! match_id || [match_id count] > 1) {
        NSLog(@"ERROR: Error when fetching sentence with ID %@.", ID);
        NSLog(@"\tmatch = %@", match_id);
    }
    else if ([match_id count] == 1) {
        sentence = [match_id lastObject];
        sentence.english = English;
        sentence.chinese = Chinese;
        sentence.structure = structure;
        sentence.core = core;
        sentence.usesComponents = structureComponents;
        [sentence addUsesWords:words];
        NSLog(@"ERROR: Sentence already exists with ID %@. Replaced.", ID);
    }
    else {   // [match_id count] == 0
        NSFetchRequest* request_sentence = [NSFetchRequest fetchRequestWithEntityName:@"Sentence"];
        request_sentence.predicate = [NSPredicate predicateWithFormat:@"english == %@ AND chinese == %@", English, Chinese];
        NSArray* match_sentence = [context executeFetchRequest:request_sentence error:&error];
        if (! match_sentence || [match_sentence count] > 1) {
            NSLog(@"ERROR: Error when fetching sentence %@ (%@).", English, Chinese);
            NSLog(@"\tmatch = %@", match_sentence);
        }
        else if ([match_sentence count] == 1) {
            sentence = [match_sentence lastObject];
            sentence.uid = ID;
            sentence.english = English;
            sentence.chinese = Chinese;
            sentence.structure = structure;
            sentence.core = core;
            sentence.usesComponents = structureComponents;
            [sentence addUsesWords:words];
            NSLog(@"ERROR: Sentence %@ (%@) already exists. Replaced.", English, Chinese);
        }
        else {
            sentence = [NSEntityDescription insertNewObjectForEntityForName:@"Sentence" inManagedObjectContext:context];
            sentence.uid = ID;
            sentence.english = English;
            sentence.chinese = Chinese;
            sentence.structure = structure;
            sentence.core = core;
            sentence.usesComponents = structureComponents;
            [sentence addUsesWords:words];
            NSLog(@"Sentence created");
        }
    }
    
    NSLog(@"Add: Sentence %@: %d, %d", sentence.uid, (int)[sentence.usesWords count], (int)[sentence.usesComponents count]);
    
    return sentence;
}

@end
