//
//  Exercise.h
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StructureComponent, Student, Unit, Word;

@interface Exercise : NSManagedObject

@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *doneByStudents;
@property (nonatomic, retain) Unit *inUnit;
@property (nonatomic, retain) NSSet *testsWords;
@property (nonatomic, retain) NSSet *testsComponents;
@end

@interface Exercise (CoreDataGeneratedAccessors)

- (void)addDoneByStudentsObject:(Student *)value;
- (void)removeDoneByStudentsObject:(Student *)value;
- (void)addDoneByStudents:(NSSet *)values;
- (void)removeDoneByStudents:(NSSet *)values;

- (void)addTestsWordsObject:(Word *)value;
- (void)removeTestsWordsObject:(Word *)value;
- (void)addTestsWords:(NSSet *)values;
- (void)removeTestsWords:(NSSet *)values;

- (void)addTestsComponentsObject:(StructureComponent *)value;
- (void)removeTestsComponentsObject:(StructureComponent *)value;
- (void)addTestsComponents:(NSSet *)values;
- (void)removeTestsComponents:(NSSet *)values;

@end
