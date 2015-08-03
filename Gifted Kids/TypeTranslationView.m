//
//  TypeTranslationView.m
//  Gifted Kids
//
//  Created by 李诣 on 5/18/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "TypeTranslationView.h"

#define VIEW_BACKGROUND_COLOR [UIColor colorWithRed:241.194626391/255 green:241.187391579/255 blue:241.191495359/255 alpha:1.0]


@interface TypeTranslationView ()

@property (strong, nonatomic) IBOutlet UILabel *promptLabel;

@property (strong, nonatomic) IBOutlet UILabel *questionLabel;

@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic) BOOL checkEnabled;

@end


@implementation TypeTranslationView

@synthesize delegate = _delegate;

@synthesize promptLabel = _promptLabel;

@synthesize questionLabel = _questionLabel;

@synthesize textView = _textView;

@synthesize checkEnabled = _checkEnabled;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)setup
{
    self.backgroundColor = VIEW_BACKGROUND_COLOR;
    
    self.textView.delegate = self;
    [self registerForKeyboardNotifications];
}

- (void)updateWithPrompt:(NSString*)prompt
               andQuestion:(NSString*)question
{
    [self reset];
    self.promptLabel.text = prompt;
    self.questionLabel.text = question;
}

- (void)reset
{
    self.textView.text = @"";
    self.checkEnabled = NO;
}

- (void)dismissKeyboard
{
    [self.textView resignFirstResponder];
}

- (NSString*)translation
{
    return self.textView.text;
}


#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // Resize textView
    CGRect textViewFrame = self.textView.frame;
    CGRect newFrame = CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y, textViewFrame.size.width, textViewFrame.size.height - keyboardFrame.size.height);
    [UIView animateWithDuration:duration animations:^(void){
        self.textView.frame = newFrame;
    }];
    
    // Move check button
    [self.delegate keyboardWillAppear:keyboardFrame duration:duration curve:curve];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    // Resize textView
    CGRect textViewFrame = self.textView.frame;
    CGRect newFrame = CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y, textViewFrame.size.width, textViewFrame.size.height + keyboardFrame.size.height);
    [UIView animateWithDuration:duration animations:^(void){
        self.textView.frame = newFrame;
    }];
    
    // Move check button
    [self.delegate keyboardWillDisappear:keyboardFrame duration:duration curve:curve];
}


#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    // Toggle check button state
    if ([textView.text isEqualToString:@""]) {
        if (self.checkEnabled) {
            self.checkEnabled = NO;
            [self.delegate setCheckButtonEnabled:NO];
        }
    }
    else {
        if (! self.checkEnabled) {
            self.checkEnabled = YES;
            [self.delegate setCheckButtonEnabled:YES];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Hides keyboard when Return is pressed
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if (self.checkEnabled) {
            [self.delegate checkPressed:self];
        }
        return NO;
    }
    
    return YES;
}

@end
