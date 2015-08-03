//
//  Student+Add.m
//  Gifted Kids
//
//  Created by 李诣 on 5/21/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Student+Add.h"

@implementation Student (Add)

+ (Student*)studentWithEmail:(NSString*)email
                    username:(NSString*)username
                    andPassword:(NSString*)password
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Student* student = nil;
    
    // 1. Check whether email has already been registered
    NSFetchRequest* request_email = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    request_email.predicate = [NSPredicate predicateWithFormat:@"email == %@", email];
    NSError* error = nil;
    NSArray* match_email = [context executeFetchRequest:request_email error:&error];
    if (! match_email || [match_email count] > 1) {
        NSLog(@"ERROR: Error when fetching student with email %@.", email);
        NSLog(@"\tmatch = %@", match_email);
    }
    else if ([match_email count] == 1) {
        student = [match_email lastObject];
        NSLog(@"An account already exists under the email address %@. Please log in instead.", email);
    }
    else {   // 2. Check whether username is available
        NSFetchRequest* request_username = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
        request_username.predicate = [NSPredicate predicateWithFormat:@"username == %@", username];
        NSArray* match_username = [context executeFetchRequest:request_username error:&error];
        if (! match_username || [match_username count] > 1) {
            NSLog(@"ERROR: Error when fetching student with username %@.", username);
            NSLog(@"\tmatch = %@", match_username);
        }
        else if ([match_username count] == 1) {
            NSLog(@"ERROR: The username %@ has already been taken by another user. Please pick another username.", username);
        }
        else {   // Create student
            student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:context];
            
            student.email = email;
            student.username = username;
            student.password = password;
            NSLog(@"Student created");
        }
    }
    
    return student;
}

@end
