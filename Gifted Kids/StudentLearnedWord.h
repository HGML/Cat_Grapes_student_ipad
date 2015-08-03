//
//  StudentLearnedWord.h
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StudentLearnedWord : NSManagedObject

@property (nonatomic, retain) NSDate * dateLearned;
@property (nonatomic, retain) NSNumber * daysSinceLearned;
@property (nonatomic, retain) NSString * history;
@property (nonatomic, retain) NSDate * nextTestDate;
@property (nonatomic, retain) NSNumber * strength;
@property (nonatomic, retain) NSString * studentUsername;
@property (nonatomic, retain) NSNumber * testInterval;
@property (nonatomic, retain) NSNumber * wordID;

@end
