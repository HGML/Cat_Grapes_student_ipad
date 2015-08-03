//
//  Unit+Add.h
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Unit.h"

@interface Unit (Add)

+ (Unit*)unitWithID:(NSNumber*)ID
           andTitle:(NSString*)title
inManagedObjectContext:(NSManagedObjectContext*)context;

@end
