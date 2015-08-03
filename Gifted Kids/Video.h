//
//  Video.h
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Student, Unit;

@interface Video : NSManagedObject

@property (nonatomic, retain) NSString * frameSize;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * youkuID;
@property (nonatomic, retain) Unit *inUnit;
@property (nonatomic, retain) NSSet *watchedByStudents;
@end

@interface Video (CoreDataGeneratedAccessors)

- (void)addWatchedByStudentsObject:(Student *)value;
- (void)removeWatchedByStudentsObject:(Student *)value;
- (void)addWatchedByStudents:(NSSet *)values;
- (void)removeWatchedByStudents:(NSSet *)values;

@end
