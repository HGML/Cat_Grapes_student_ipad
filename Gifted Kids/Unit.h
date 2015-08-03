//
//  Unit.h
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise, Student, Video;

@interface Unit : NSManagedObject

@property (nonatomic, retain) NSString * components;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *containsExercises;
@property (nonatomic, retain) NSSet *containsVideos;
@property (nonatomic, retain) NSSet *learnedByStudents;
@end

@interface Unit (CoreDataGeneratedAccessors)

- (void)addContainsExercisesObject:(Exercise *)value;
- (void)removeContainsExercisesObject:(Exercise *)value;
- (void)addContainsExercises:(NSSet *)values;
- (void)removeContainsExercises:(NSSet *)values;

- (void)addContainsVideosObject:(Video *)value;
- (void)removeContainsVideosObject:(Video *)value;
- (void)addContainsVideos:(NSSet *)values;
- (void)removeContainsVideos:(NSSet *)values;

- (void)addLearnedByStudentsObject:(Student *)value;
- (void)removeLearnedByStudentsObject:(Student *)value;
- (void)addLearnedByStudents:(NSSet *)values;
- (void)removeLearnedByStudents:(NSSet *)values;

@end
