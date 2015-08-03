//
//  Video+Add.h
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Video.h"

@interface Video (Add)

+ (Video*)videoWithID:(NSNumber*)ID
           andYoukuID:(NSString*)youkuID
               inUnit:(Unit*)unit
inManagedObjectContext:(NSManagedObjectContext*)context;

@end
