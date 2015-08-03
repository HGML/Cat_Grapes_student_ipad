//
//  StructureComponent.h
//  Gifted Kids
//
//  Created by Yi Li on 8/7/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise, Sentence;

@interface StructureComponent : NSManagedObject

@property (nonatomic, retain) NSString * family;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSNumber * reducible;
@property (nonatomic, retain) NSSet *inSentence;
@property (nonatomic, retain) NSSet *isMainInSentence;
@property (nonatomic, retain) Exercise *testedInExercise;
@end

@interface StructureComponent (CoreDataGeneratedAccessors)

- (void)addInSentenceObject:(Sentence *)value;
- (void)removeInSentenceObject:(Sentence *)value;
- (void)addInSentence:(NSSet *)values;
- (void)removeInSentence:(NSSet *)values;

- (void)addIsMainInSentenceObject:(Sentence *)value;
- (void)removeIsMainInSentenceObject:(Sentence *)value;
- (void)addIsMainInSentence:(NSSet *)values;
- (void)removeIsMainInSentence:(NSSet *)values;

@end
