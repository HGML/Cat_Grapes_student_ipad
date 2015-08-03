//
//  TypeTranslationView.h
//  Gifted Kids
//
//  Created by 李诣 on 5/18/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TypeTranslationViewDelegate <NSObject>

- (void)setCheckButtonEnabled:(BOOL)enabled;

- (void)checkPressed:(id)sender;

- (void)keyboardWillAppear:(CGRect)keyboardFrame
                  duration:(NSTimeInterval)duration
                     curve:(UIViewAnimationCurve)curve;

- (void)keyboardWillDisappear:(CGRect)keyboardFrame
                     duration:(NSTimeInterval)duration
                        curve:(UIViewAnimationCurve)curve;

@end


@interface TypeTranslationView : UIView <UITextViewDelegate>

@property (strong, nonatomic) id<TypeTranslationViewDelegate> delegate;

- (void)setup;

- (void)updateWithPrompt:(NSString*)prompt
               andQuestion:(NSString*)question;

- (void)dismissKeyboard;

- (NSString*)translation;

@end
