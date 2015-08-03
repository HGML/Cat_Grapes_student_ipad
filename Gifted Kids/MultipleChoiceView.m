//
//  MultipleChoiceView.m
//  Gifted Kids
//
//  Created by 李诣 on 5/18/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "MultipleChoiceView.h"

#define VIEW_BACKGROUND_COLOR [UIColor colorWithRed:241.194626391/255 green:241.187391579/255 blue:241.191495359/255 alpha:1.0]


@interface MultipleChoiceView ()

@property (strong, nonatomic) IBOutlet UILabel *promptLabel;

@property (strong, nonatomic) IBOutlet UILabel *questionLabel;

@property (strong, nonatomic) IBOutlet UIButton *option_1;

@property (strong, nonatomic) IBOutlet UIButton *option_2;

@property (strong, nonatomic) IBOutlet UIButton *option_3;

@property (strong, nonatomic) NSArray* buttons;

@property (strong, nonatomic) NSMutableArray* selectedButtons;

@end


@implementation MultipleChoiceView

@synthesize delegate = _delegate;

@synthesize requiredAnswers = _requiredAnswers;

@synthesize promptLabel = _promptLabel;

@synthesize questionLabel = _questionLabel;

@synthesize option_1 = _option_1;

@synthesize option_2 = _option_2;

@synthesize option_3 = _option_3;

@synthesize buttons = _buttons;

@synthesize selectedButtons = _selectedButtons;


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
    
    self.buttons = [NSArray arrayWithObjects:self.option_1, self.option_2, self.option_3, nil];
    for (size_t i = 0; i < 3; ++i) {
        UIButton* button = self.buttons[i];
        [button setBackgroundImage:[UIImage imageNamed:@"Multiple Choice Button-Unselected.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"Multiple Choice Button-Selected.png"] forState:UIControlStateSelected];
        [button setTag:i];
    }
}

- (void)updateWithPrompt:(NSString*)prompt
                question:(NSString*)question
         requiredAnswers:(NSArray *)requiredAnswers
              andOptions:(NSArray *)options
{
    [self reset];
    
    if ([options count] != 3) {
        NSLog(@"Error: expected 3 options, got %d options.", (int)[options count]);
    }
    
    self.requiredAnswers = requiredAnswers;
    self.promptLabel.text = prompt;
    self.questionLabel.text = question;
    for (size_t i = 0; i < 3; ++i) {
        UIButton* button = self.buttons[i];
        button.titleLabel.text = options[i];
        [button setTitle:options[i] forState:UIControlStateNormal];
        [button setTitle:options[i] forState:UIControlStateSelected];
        button.selected = NO;
    }
}

- (void)reset
{
    self.selectedButtons = [NSMutableArray array];
    [self.delegate setCheckButtonEnabled:NO];
}


#pragma mark - Option Pressed

- (IBAction)optionPressed:(id)sender
{
    // Reverse state
    UIButton* button = (UIButton*)sender;
    [button setSelected:! button.selected];
    
    // Update selectedButtons
    if ([self.selectedButtons containsObject:button]) {
        [self.selectedButtons removeObject:button];
        
        if (! [self.selectedButtons count]) {
            [self.delegate setCheckButtonEnabled:NO];
        }
    }
    else {
        if (! [self.selectedButtons count]) {
            [self.delegate setCheckButtonEnabled:YES];
        }
        
        [self.selectedButtons addObject:button];
    }
}


#pragma mark - Selected Options

- (NSArray*)selectedOptions
{
    NSMutableArray* selectedOptions = [NSMutableArray array];
    for (UIButton* button in self.selectedButtons) {
        [selectedOptions addObject:button.titleLabel.text];
    }
    return selectedOptions;
}

@end
