//
//  MultipleChoiceView.h
//  Gifted Kids
//
//  Created by 李诣 on 5/18/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MultipleChoiceViewDelegate <NSObject>

- (void)setCheckButtonEnabled:(BOOL)enabled;

@end


@interface MultipleChoiceView : UIView

@property (strong, nonatomic) id<MultipleChoiceViewDelegate> delegate;

@property (strong, nonatomic) NSArray* requiredAnswers;

- (void)setup;

- (void)updateWithPrompt:(NSString*)prompt
                question:(NSString*)question
         requiredAnswers:(NSArray*)requiredAnswers
              andOptions:(NSArray*)options;

- (NSArray*)selectedOptions;

@end
