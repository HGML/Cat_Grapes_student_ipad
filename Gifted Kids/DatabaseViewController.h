//
//  DatabaseViewController.h
//  Gifted Kids
//
//  Created by Yi Li on 6/16/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"


@interface DatabaseViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext* context;

@property (nonatomic, strong) Student* student;

@end
