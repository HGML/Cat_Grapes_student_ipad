//
//  ExerciseResultsViewController.h
//  Gifted Kids
//
//  Created by 李诣 on 5/28/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExerciseResultsViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext* context;

@property (nonatomic) size_t correctProblemsCount;

@property (nonatomic) size_t incorrectProblemsCount;

@end
