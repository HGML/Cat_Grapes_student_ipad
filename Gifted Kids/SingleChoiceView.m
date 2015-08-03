//
//  SingleChoiceView.m
//  Gifted Kids
//
//  Created by 李诣 on 5/18/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "SingleChoiceView.h"

#define VIEW_BACKGROUND_COLOR [UIColor colorWithRed:241.194626391/255 green:241.187391579/255 blue:241.191495359/255 alpha:1.0]


@interface SingleChoiceView ()

@property (strong, nonatomic) IBOutlet UILabel *promptLabel;

@property (strong, nonatomic) IBOutlet UILabel *questionLabel;

@property (strong, nonatomic) IBOutlet UIButton *option_1;

@property (strong, nonatomic) IBOutlet UIButton *option_2;

@property (strong, nonatomic) IBOutlet UIButton *option_3;

@property (strong, nonatomic) IBOutlet UIButton *option_4;

@property (strong, nonatomic) NSArray* buttons;

@property (strong, nonatomic) UIButton* selectedButton;

@end


@implementation SingleChoiceView

@synthesize delegate = _delegate;

@synthesize promptLabel = _promptLabel;

@synthesize questionLabel = _questionLabel;

@synthesize option_1 = _option_1;

@synthesize option_2 = _option_2;

@synthesize option_3 = _option_3;

@synthesize option_4 = _option_4;

@synthesize buttons = _buttons;

@synthesize selectedButton = _selectedButton;


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


#pragma mark - Set Up and Update

- (void)setup
{
    self.backgroundColor = VIEW_BACKGROUND_COLOR;
    
    self.buttons = [NSArray arrayWithObjects:self.option_1, self.option_2, self.option_3, self.option_4, nil];
    self.selectedButton = nil;
    
    for (UIButton* button in self.buttons) {
        [button setBackgroundImage:[UIImage imageNamed:@"Single Choice Button-Unselected.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"Single Choice Button-Selected.png"] forState:UIControlStateSelected];
    }
}

- (void)updateWithPrompt:(NSString*)prompt
               question:(NSString*)question
             andOptions:(NSArray*)options
{
    [self reset];
    
    if ([options count] != 4) {
        NSLog(@"Error: expected 4 options, got %d options.", (int)[options count]);
    }
    
    self.promptLabel.text = prompt;
    self.questionLabel.text = question;
    for (size_t i = 0; i < 4; ++i) {
        UIButton* button = self.buttons[i];
        button.titleLabel.text = options[i];
        [button setTitle:options[i] forState:UIControlStateNormal];
        [button setTitle:options[i] forState:UIControlStateSelected];
        button.selected = NO;
    }
}

- (void)reset
{
    [self.delegate setCheckButtonEnabled:NO];
    self.selectedButton = nil;
}


#pragma mark - Option Pressed

- (IBAction)optionPressed:(id)sender
{
    if (self.selectedButton == sender) {
        return;
    }
    
    // Enable check button if necessary
    if (self.selectedButton == nil) {
        [self.delegate setCheckButtonEnabled:YES];
    }
    
    // Update Selection
    for (UIButton* button in self.buttons) {
        button.selected = (button == sender);
    }
    self.selectedButton = sender;
}


#pragma mark - Selected Option

- (NSString*)selectedOption
{
    return self.selectedButton.titleLabel.text;
}

@end
