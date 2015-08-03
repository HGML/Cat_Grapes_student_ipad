//
//  Parent.h
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Student;

@interface Parent : NSManagedObject

@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * relationship;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *hasStudents;
@end

@interface Parent (CoreDataGeneratedAccessors)

- (void)addHasStudentsObject:(Student *)value;
- (void)removeHasStudentsObject:(Student *)value;
- (void)addHasStudents:(NSSet *)values;
- (void)removeHasStudents:(NSSet *)values;

@end
