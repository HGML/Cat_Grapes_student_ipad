//
//  ExerciseViewController.h
//  Gifted Kids
//
//  Created by 李诣 on 5/17/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleChoiceView.h"
#import "MultipleChoiceView.h"
#import "TypeTranslationView.h"
#import "BlockTranslationView.h"


@interface ExerciseViewController : UIViewController <SingleChoiceViewDelegate, MultipleChoiceViewDelegate, TypeTranslationViewDelegate, BlockTranslationViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext* context;

@property (nonatomic, strong) NSString* exerciseName;

@end
