//
//  Word+Add.h
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Word.h"

@interface Word (Add)

+ (Word*)wordWithID:(NSNumber*)ID
            english:(NSString*)English
            chinese:(NSString*)Chinese
    andPartOfSpeech:(NSString*)POS
         inExercise:(Exercise*)exercise
inManagedObjectContext:(NSManagedObjectContext*)context;

@end
