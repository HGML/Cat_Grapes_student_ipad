//
//  Student+Add.h
//  Gifted Kids
//
//  Created by 李诣 on 5/21/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Student.h"

@interface Student (Add)

+ (Student*)studentWithEmail:(NSString*)email
                    username:(NSString*)username
                    andPassword:(NSString*)password
         inManagedObjectContext:(NSManagedObjectContext*)context;

@end
