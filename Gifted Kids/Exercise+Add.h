//
//  Exercise+Add.h
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Exercise.h"

@interface Exercise (Add)

+ (Exercise*)exerciseWithID:(NSNumber*)ID
                     inUnit:(Unit*)unit
   withManagedObjectContext:(NSManagedObjectContext*)context;

@end
