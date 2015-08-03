//
//  StudentLearnedComponent+Add.h
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "StudentLearnedComponent.h"

@interface StudentLearnedComponent (Add)

+ (StudentLearnedComponent*)student:(NSString*)studentUsername
                   learnedComponent:(NSNumber*)componentID
                             onDate:(NSDate*)dateLearned
             inManagedObjectContext:(NSManagedObjectContext*)context;

@end
