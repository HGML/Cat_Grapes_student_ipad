//
//  AFNetworkManager.h
//  Gifted Kids
//
//  Created by Yi Li on 15/8/4.
//  Copyright (c) 2015年 Yi Li 李诣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface AFNetworkManager : NSObject

// Sign Up, Log In, Log Out

#define CREATE_STUDENT_URL "http://localhost:3000/students"

#define LOGIN_URL "http://localhost:3000/sessions/create"

#define LOGOUT_URL "http://localhost:3000/students/"   // "http://localhost:3000/students/'student_id'"

@end
	