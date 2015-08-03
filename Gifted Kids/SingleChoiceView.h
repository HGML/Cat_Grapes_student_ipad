//
//  SingleChoiceView.h
//  Gifted Kids
//
//  Created by 李诣 on 5/18/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SingleChoiceViewDelegate <NSObject>

- (void)setCheckButtonEnabled:(BOOL)enabled;

@end


@interface SingleChoiceView : UIView

@property (strong, nonatomic) id<SingleChoiceViewDelegate> delegate;

- (void)setup;

- (void)updateWithPrompt:(NSString*)prompt
               question:(NSString*)question
             andOptions:(NSArray*)options;

- (NSString*)selectedOption;

@end
