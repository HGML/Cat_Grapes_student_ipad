//
//  DateManager.m
//  Mom's Secretary
//
//  Created by 李诣 on 7/10/13.
//  Copyright (c) 2013 Yi Li 李诣. All rights reserved.
//


#import "DateManager.h"


#define HR_PER_DAY 24
#define MIN_PER_HR 60
#define SEC_PER_MIN 60


@implementation DateManager

+ (NSDate*)today
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"HKT"]];
    NSString* todayString = [formatter stringFromDate:[NSDate date]];
    return [formatter dateFromString:todayString];
}

+ (NSDate*)now
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"HKT"]];
    NSString* nowString = [formatter stringFromDate:[NSDate date]];
    return [formatter dateFromString:nowString];
}

+ (NSString*)nowString
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"HKT"]];
    return [formatter stringFromDate:[NSDate date]];
}

+ (NSDate*)dateDays:(int)days afterDate:(NSDate*)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString* originString = [formatter stringFromDate:date];
    NSDate* origin = [formatter dateFromString:originString];
    NSDate* result = [NSDate dateWithTimeInterval:days * HR_PER_DAY * MIN_PER_HR * SEC_PER_MIN sinceDate:origin];
    
    return result;
}

+ (NSInteger)daysFrom:(NSDate*)startDate to:(NSDate*)endDate
{
    NSDateComponents* difference = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
    
    return difference.day;
}

+ (NSString*)stringWithDate:(NSDate*)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:date];
}

//+ (BOOL)date:(NSString*)date1 isLessThanDate:(NSString*)date2
//{
//    NSArray* date1Components = [date1 componentsSeparatedByString:@"-"];
//    NSArray* date2Components = [date2 componentsSeparatedByString:@"-"];
//    
//    if ([[date1Components objectAtIndex:0] integerValue] < [[date2Components objectAtIndex:0] integerValue]) {
//        return YES;
//    }
//    else if ([[date1Components objectAtIndex:1] integerValue] < [[date2Components objectAtIndex:1] integerValue]) {
//        return YES;
//    }
//    else if ([[date1Components objectAtIndex:2] integerValue] < [[date2Components objectAtIndex:2] integerValue]) {
//        return YES;
//    }
//    else {
//        return NO;
//    }
//}

@end
