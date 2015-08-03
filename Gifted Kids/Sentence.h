//
//  Sentence.h
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StructureComponent, Word;

@interface Sentence : NSManagedObject

@property (nonatomic, retain) NSString * chinese;
@property (nonatomic, retain) NSString * distractors;
@property (nonatomic, retain) NSString * english;
@property (nonatomic, retain) NSString * equivalents;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * structure;
@property (nonatomic, retain) NSString * core;
@property (nonatomic, retain) NSSet *usesWords;
@property (nonatomic, retain) NSSet *usesComponents;
@property (nonatomic, retain) StructureComponent *hasMainComponent;
@end

@interface Sentence (CoreDataGeneratedAccessors)

- (void)addUsesWordsObject:(Word *)value;
- (void)removeUsesWordsObject:(Word *)value;
- (void)addUsesWords:(NSSet *)values;
- (void)removeUsesWords:(NSSet *)values;

- (void)addUsesComponentsObject:(StructureComponent *)value;
- (void)removeUsesComponentsObject:(StructureComponent *)value;
- (void)addUsesComponents:(NSSet *)values;
- (void)removeUsesComponents:(NSSet *)values;

@end
