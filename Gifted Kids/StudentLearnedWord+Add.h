//
//  StudentLearnedWord+Add.h
//  Gifted Kids
//
//  Created by 李诣 on 5/24/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "StudentLearnedWord.h"

@interface StudentLearnedWord (Add)

+ (StudentLearnedWord*)student:(NSString*)studentUsername
                   learnedWord:(NSNumber*)wordID
                        onDate:(NSDate*)dateLearned
        inManagedObjectContext:(NSManagedObjectContext*)context;

@end
