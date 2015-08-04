//
//  DateManager.h
//  Mom's Secretary
//
//  Created by 李诣 on 7/10/13.
//  Copyright (c) 2013 Yi Li 李诣. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface DateManager : NSObject

+ (NSDate*)today;

+ (NSDate*)now;

+ (NSString*)nowString;

+ (NSDate*)dateDays:(int)days afterDate:(NSDate*)date;

+ (NSInteger)daysFrom:(NSDate*)startDate to:(NSDate*)endDate;

+ (NSString*)stringWithDate:(NSDate*)date;

@end
