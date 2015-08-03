//
//  LogInViewController.h
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewController : UIViewController <UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext* context;

@property (nonatomic, strong) NSString* email;

@end
