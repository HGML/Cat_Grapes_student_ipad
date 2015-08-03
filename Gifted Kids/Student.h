//
//  Student.h
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise, Parent, Unit, Video;

@interface Student : NSManagedObject

@property (nonatomic, retain) NSNumber * curExercise;
@property (nonatomic, retain) NSNumber * curUnit;
@property (nonatomic, retain) NSNumber * curVideo;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * grade;
@property (nonatomic, retain) NSNumber * initialInterval;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * school;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *didExercises;
@property (nonatomic, retain) NSSet *hasParents;
@property (nonatomic, retain) NSSet *learnedUnits;
@property (nonatomic, retain) NSSet *watchedVideos;
@end

@interface Student (CoreDataGeneratedAccessors)

- (void)addDidExercisesObject:(Exercise *)value;
- (void)removeDidExercisesObject:(Exercise *)value;
- (void)addDidExercises:(NSSet *)values;
- (void)removeDidExercises:(NSSet *)values;

- (void)addHasParentsObject:(Parent *)value;
- (void)removeHasParentsObject:(Parent *)value;
- (void)addHasParents:(NSSet *)values;
- (void)removeHasParents:(NSSet *)values;

- (void)addLearnedUnitsObject:(Unit *)value;
- (void)removeLearnedUnitsObject:(Unit *)value;
- (void)addLearnedUnits:(NSSet *)values;
- (void)removeLearnedUnits:(NSSet *)values;

- (void)addWatchedVideosObject:(Video *)value;
- (void)removeWatchedVideosObject:(Video *)value;
- (void)addWatchedVideos:(NSSet *)values;
- (void)removeWatchedVideos:(NSSet *)values;

@end
