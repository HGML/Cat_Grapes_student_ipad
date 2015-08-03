//
//  Word.h
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise, Sentence;

@interface Word : NSManagedObject

@property (nonatomic, retain) NSString * chinese;
@property (nonatomic, retain) NSString * distractors;
@property (nonatomic, retain) NSString * english;
@property (nonatomic, retain) NSString * family;
@property (nonatomic, retain) NSString * partOfSpeech;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) Exercise *testedInExercise;
@property (nonatomic, retain) NSSet *usedInSentences;
@end

@interface Word (CoreDataGeneratedAccessors)

- (void)addUsedInSentencesObject:(Sentence *)value;
- (void)removeUsedInSentencesObject:(Sentence *)value;
- (void)addUsedInSentences:(NSSet *)values;
- (void)removeUsedInSentences:(NSSet *)values;

@end
