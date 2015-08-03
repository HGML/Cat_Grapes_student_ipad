//
//  BlockTranslationView.m
//  Gifted Kids
//
//  Created by 李诣 on 5/19/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "BlockTranslationView.h"

#define VIEW_BACKGROUND_COLOR [UIColor colorWithRed:241.194626391/255 green:241.187391579/255 blue:241.191495359/255 alpha:1.0]
#define VIEW_MARGIN 40

#define BUTTON_HEIGHT 52
#define LABEL_INSET 21
#define LETTER_WIDTH 10

#define UNSELECTED_SPACING_WIDTH 12
#define UNSELECTED_SPACING_HEIGHT 10
#define SELECTED_SPACING_WIDTH 4
#define SELECTED_SPACING_HEIGHT 14

#define SELECTED_Y_START 333
#define UNSELECTED_Y_START 673
#define SELECTED_UNSELECTED_BOUNDARY_Y 640


@interface BlockTranslationView ()

@property (strong, nonatomic) IBOutlet UILabel *promptLabel;

@property (strong, nonatomic) IBOutlet UILabel *questionLabel;

@property (strong, nonatomic) NSArray* wordOptions;

@property (strong, nonatomic) NSDictionary* buttons;

@property (strong, nonatomic) NSDictionary* buttonOrigins;

@property (strong, nonatomic) NSMutableArray* selectedButtons;

@property (strong, nonatomic) NSArray* selectedButtonRightEdges;

@property (strong, nonatomic) NSArray* selectedButtonCenters;

@property (nonatomic) CGRect inAnswerFrame;

@property (strong, nonatomic) UIButton* hoveringButton;

@property (nonatomic) BOOL checkEnabled;

@end


@implementation BlockTranslationView

@synthesize promptLabel = _promptLabel;

@synthesize questionLabel = _questionLabel;

@synthesize wordOptions = _wordOptions;

@synthesize buttons = _buttons;

@synthesize buttonOrigins = _buttonOrigins;

@synthesize selectedButtons = _selectedButtons;

@synthesize selectedButtonRightEdges = _selectedButtonRightEdges;

@synthesize selectedButtonCenters = _selectedButtonCenters;

@synthesize inAnswerFrame = _inAnswerFrame;

@synthesize hoveringButton = _hoveringButton;

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
}

- (void)updateWithPrompt:(NSString*)prompt
                question:(NSString*)question
          andWordOptions:(NSArray *)wordOptions
{
    self.promptLabel.text = prompt;
    self.questionLabel.text = question;
    self.wordOptions = wordOptions;
    
    [self reset];
    [self setupWordButtons];
}

- (void)reset
{
    NSArray* allKeys = [self.buttons allKeys];
    for (size_t i = 0; i < [self.buttons count]; ++i) {
        UIButton* button = [self.buttons objectForKey:[allKeys objectAtIndex:i]];
        [button removeFromSuperview];
        button = nil;
    }
    
    self.buttons = [NSMutableDictionary dictionary];
    self.buttonOrigins = [NSMutableDictionary dictionary];
    self.selectedButtons = [NSMutableArray array];
    self.selectedButtonRightEdges = [NSMutableArray array];
    self.selectedButtonCenters = [NSMutableArray array];
    self.inAnswerFrame = CGRectMake(0, 0, 0, 0);
    self.hoveringButton = nil;
    self.checkEnabled = NO;
}

- (NSString*)translation
{
    NSMutableArray* words = [NSMutableArray array];
    for (UIButton* button in self.selectedButtons) {
        [words addObject:button.titleLabel.text];
    }
    NSString* sentence = [words componentsJoinedByString:@" "];
    return sentence;
}


// Word Button

- (void)setupWordButtons
{
    NSMutableDictionary* mutableButtons = [NSMutableDictionary dictionary];
    NSMutableDictionary* mutableButtonOrigins = [NSMutableDictionary dictionary];
    
    float rightBorder = self.frame.size.width - VIEW_MARGIN;
    
    float x = VIEW_MARGIN;
    float y = UNSELECTED_Y_START;
    int tag = 1000;
    int lineTagStart = 1000;
    
    NSMutableArray* wordsLeft = [self.wordOptions mutableCopy];
    while ([wordsLeft count]) {
        int index = arc4random() % [wordsLeft count];
        NSString* word = [wordsLeft objectAtIndex:index];
        
        size_t width = word.length * LETTER_WIDTH + 2 * LABEL_INSET;
        
        if (x + width > rightBorder) {
            // Center current line
            float blankWidth = rightBorder - x + UNSELECTED_SPACING_WIDTH;
            for (int tagToMove = lineTagStart; tagToMove < tag; ++ tagToMove) {
                UIButton* buttonToMove = [mutableButtons objectForKey:[NSNumber numberWithInt:tagToMove]];
                CGPoint newOrigin = CGPointMake(buttonToMove.frame.origin.x + blankWidth / 2, buttonToMove.frame.origin.y);
                buttonToMove.frame = CGRectMake(newOrigin.x, newOrigin.y, buttonToMove.frame.size.width, buttonToMove.frame.size.height);
                
                [mutableButtonOrigins setObject:[NSValue valueWithCGPoint:newOrigin]
                                         forKey:[NSNumber numberWithInt:tagToMove]];
            }
            lineTagStart = tag;
            
            // Start new line
            x = VIEW_MARGIN;
            y = y + BUTTON_HEIGHT + UNSELECTED_SPACING_HEIGHT;
        }
        
        if (y + BUTTON_HEIGHT > self.frame.size.height) {
            break;
        }
        
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(x, y, width, BUTTON_HEIGHT);
        [button setBackgroundImage:[UIImage imageNamed:@"Word Button.png"] forState:UIControlStateNormal];
        
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:22];
        [button setTitle:word forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSwipeGestureRecognizerFor:button];
        [self addLongPressGestureRecognizerFor:button];
        button.tag = tag;
        
        [mutableButtons setObject:button
                           forKey:[NSNumber numberWithInt:tag]];
        [mutableButtonOrigins setObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]
                                 forKey:[NSNumber numberWithInt:tag]];
        
        [self addSubview:button];
        
        x = x + width + UNSELECTED_SPACING_WIDTH;
        tag = tag + 1;
        
        [wordsLeft removeObjectAtIndex:index];
        
        if (! [wordsLeft count]) {
            // Center current line
            float blankWidth = rightBorder - x + UNSELECTED_SPACING_WIDTH;
            for (int tagToMove = lineTagStart; tagToMove < tag; ++ tagToMove) {
                UIButton* buttonToMove = [mutableButtons objectForKey:[NSNumber numberWithInt:tagToMove]];
                CGPoint newOrigin = CGPointMake(buttonToMove.frame.origin.x + blankWidth / 2, buttonToMove.frame.origin.y);
                buttonToMove.frame = CGRectMake(newOrigin.x, newOrigin.y, buttonToMove.frame.size.width, buttonToMove.frame.size.height);
                
                [mutableButtonOrigins setObject:[NSValue valueWithCGPoint:newOrigin]
                                         forKey:[NSNumber numberWithInt:tagToMove]];
            }
        }
    }
    
    self.buttons = mutableButtons;
    self.buttonOrigins = mutableButtonOrigins;
}

- (IBAction)buttonSelected:(UIButton*)sender
{
    if (! [self.selectedButtons count]) {
        [self.delegate setCheckButtonEnabled:YES];
    }
    
    [self.selectedButtons addObject:sender];
    [self updateAnswer];
    
    [sender removeTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(buttonUnselected:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)buttonUnselected:(UIButton*)sender
{
    [self.selectedButtons removeObject:sender];
    
    if (! [self.selectedButtons count]) {
        [self.delegate setCheckButtonEnabled:NO];
    }
    
    [UIView animateWithDuration:0.4 animations:^(void){
        CGRect frame = sender.frame;
        frame.origin = [[self.buttonOrigins objectForKey:[NSNumber numberWithInteger:sender.tag]] CGPointValue];
        sender.frame = frame;
    }];
    [self updateAnswer];
    
    [sender removeTarget:self action:@selector(buttonUnselected:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateAnswer
{
    int x = VIEW_MARGIN;
    int y = SELECTED_Y_START;
    
    NSMutableArray* selectedRights = [NSMutableArray array];
    NSMutableArray* selectedCenters = [NSMutableArray array];
    
    for (UIButton* button in self.selectedButtons) {
        CGRect frame = button.frame;
        
        // No need to move
        if (frame.origin.x == x && frame.origin.y == y) {
            x = x + frame.size.width + SELECTED_SPACING_WIDTH;
            
            [selectedRights addObject:[NSNumber numberWithFloat:frame.origin.x + frame.size.width]];
            [selectedCenters addObject:[NSNumber numberWithFloat:button.center.x]];
            
            continue;
        }
        
        // New line
        if (x + frame.size.width > self.frame.size.width - VIEW_MARGIN) {
            x = VIEW_MARGIN;
            y = y + BUTTON_HEIGHT + SELECTED_SPACING_HEIGHT;
        }
        
        frame.origin.x = x;
        frame.origin.y = y;
        
        [UIView animateWithDuration:0.4 animations:^(void){
            button.frame = frame;
        }];
        
        x = x + frame.size.width + SELECTED_SPACING_WIDTH;
        
        [selectedRights addObject:[NSNumber numberWithFloat:frame.origin.x + frame.size.width]];
        [selectedCenters addObject:[NSNumber numberWithFloat:button.center.x]];
    }
    
    self.selectedButtonRightEdges = selectedRights;
    self.selectedButtonCenters = selectedCenters;
}


#pragma mark - Gesture Recognizer

// SWIPE - Show Chinese
//- (void)addSwipeGestureRecognizerFor:(UIView*)view
//{
//    UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
//    
//    UISwipeGestureRecognizer* rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
//    
//    
//    [view addGestureRecognizer:leftSwipe];
//    [view addGestureRecognizer:rightSwipe];
//}

//- (void)handleSwipe:(UISwipeGestureRecognizer*)swipe
//{
//    if (swipe.state != UIGestureRecognizerStateBegan && swipe.state != UIGestureRecognizerStateEnded) {
//        return;
//    }
//    
//    UIView* element = [swipe view];
//    if (! [element isKindOfClass:[UIButton class]]) {
//        return;
//    }
//    
//    UIButton* button = (UIButton*)element;
//    NSString* english = button.titleLabel.text;
//    
//    NSArray* match = [self.dbManager executeQuery:[NSString stringWithFormat:@"SELECT id, Chinese FROM LearnedWord, Word WHERE sid = %d AND wid = id AND English = \"%@\"", self.studentID, english]];
//    
//    if (! match || ! [match count]) {
//        match = [self.dbManager executeQuery:[NSString stringWithFormat:@"SELECT id, Chinese FROM LearnedWord, Word WHERE sid = %d AND wid = id AND English = \"%@\"", self.studentID, [english lowercaseString]]];
//    }
//    
//    if (! match || ! [match count]) {
//        NSLog(@"ERROR: No word found for student \"%d\" with English \"%@\"", self.studentID, english);
//        return;
//    }
//    else if ([match count] == 1) {
//        // Get word info
//        NSArray* wordInfos = [[match objectAtIndex:0] componentsSeparatedByString:@"; "];
//        NSInteger wordID = [[wordInfos objectAtIndex:0] integerValue];
//        NSString* chinese = [wordInfos objectAtIndex:1];
//        
//        
//        // Flash chinese
//        UILabel* label = [[UILabel alloc] initWithFrame:button.frame];
//        [label setTextAlignment:NSTextAlignmentCenter];
//        [label setFont:[UIFont systemFontOfSize:16]];
//        label.layer.cornerRadius = 4.0f;
//        [label setAlpha:0];
//        label.text = chinese;
//        [self.view addSubview:label];
//        
//        [UIView animateWithDuration:0.3 animations:^(void) {
//            [label setAlpha:1.0];
//        }];
//        [UIView animateWithDuration:0.3 delay:2.0 options:UIViewAnimationOptionCurveLinear
//                         animations:^(void) {
//                             [label setAlpha:0];
//                         } completion:^(BOOL finished) {}];
//        
//        [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:3.0];
//        
//        
//        // Update LearnedWord
//        NSArray* match = [self.dbManager executeQuery:
//                          [NSString stringWithFormat:@"SELECT dateLearned, nextTestDate, testInterval, history FROM LearnedWord WHERE sid = %d AND wid = %d", self.studentID, wordID]];
//        if (! match || ! [match count]) {
//            NSLog(@"ERROR: No learned word with id \"%d\" for student \"%d\"", wordID, self.studentID);
//            return;
//        }
//        else if ([match count] != 1) {
//            NSLog(@"ERROR: More than one learned word with id \"%d\" for student \"%d\"", wordID, self.studentID);
//            return;
//        }
//        
//        wordInfos = [[match objectAtIndex:0] componentsSeparatedByString:@"; "];
//        NSString* dateLearned = [wordInfos objectAtIndex:0];
//        NSString* nextTestDate = [wordInfos objectAtIndex:1];
//        NSString* testIntervalString = [wordInfos objectAtIndex:2];
//        NSString* historyString = [wordInfos objectAtIndex:3];
//        
//        if ([dateLearned isEqualToString:@"NULL"]) {
//            dateLearned = self.todayString;
//            nextTestDate = dateLearned;
//            testIntervalString = @"1";
//            historyString = @"";
//        }
//        
//        NSInteger testInterval = [testIntervalString integerValue];
//        
//        NSMutableArray* history = [[historyString componentsSeparatedByString:@"; "] mutableCopy];
//        if ([nextTestDate isEqualToString:dateLearned]) {
//            [history removeAllObjects];
//        }
//        
//        int totalDays = [DateManager daysFrom:dateLearned to:self.todayString];
//        for (int i = [history count]; i < totalDays; i ++) {
//            [history addObject:[NSNumber numberWithInt:0]];
//        }
//        [history addObject:[NSNumber numberWithInt:1]];  // !!!- Should take into account requiresRecall -!!!
//        
//        NSString* tomorrow = [DateManager dateStringDays:1 afterDate:self.todayString];
//        
//        [self.dbManager executeQuery:
//         [NSString stringWithFormat:@"UPDATE LearnedWord SET dateLearned = \"%@\", nextTestDate = \"%@\", testInterval = %d, history = \"%@\" WHERE sid = %d AND wid = %d", dateLearned, tomorrow, testInterval, [history componentsJoinedByString:@"; "], self.studentID, wordID]];
//    }
//    else {
//        NSLog(@"More than 1 word found for student \"%d\" with English \"%@\"", self.studentID, english);
//        return;
//    }
//}


// LONG PRESS - Move word button
- (void)addLongPressGestureRecognizerFor:(UIView*)view
{
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.15;
    
    [view addGestureRecognizer:longPress];
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)longPress
{
    UIView* element = [longPress view];
    if (! [element isKindOfClass:[UIButton class]]) {
        return;
    }
    UIButton* button = (UIButton*)element;
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if ([self.selectedButtons containsObject:button]) {   // Button is currently in Answer
            self.inAnswerFrame = button.frame;
            
            [self bringSubviewToFront:button];
        }
        else {   // Button is unselected
            [self bringSubviewToFront:button];
        }
    }
    else if (longPress.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [longPress locationInView:self];
        button.center = point;
        
        if ([self.selectedButtons containsObject:button]) {   // In Answer
            if (button.frame.origin.y + button.frame.size.height < self.inAnswerFrame.origin.y) {
                self.hoveringButton = button;
                [self.selectedButtons removeObject:button];
                [self updateAnswer];
            }
            else if (button.frame.origin.y > self.inAnswerFrame.origin.y + self.inAnswerFrame.size.height) {
                self.hoveringButton = button;
                [self.selectedButtons removeObject:button];
                [self updateAnswer];
            }
            else {
                size_t index = [self.selectedButtons indexOfObject:button];
                
                if (index > 0) {   // not first selected
                    UIButton* previous = [self.selectedButtons objectAtIndex:index - 1];
                    
                    if (previous.frame.origin.y + previous.frame.size.height < button.frame.origin.y) {
                        // Ignore
                    }
                    else if (button.frame.origin.x < previous.frame.origin.x + previous.frame.size.width) {
                        [self.selectedButtons removeObject:button];
                        [self.selectedButtons insertObject:button atIndex:index - 1];
                        [self updateAnswer];
                        
                        self.inAnswerFrame = button.frame;
                    }
                }
                if (index < [self.selectedButtons count] - 1) {   // not last selected
                    UIButton* next = [self.selectedButtons objectAtIndex:index + 1];
                    
                    if (button.frame.origin.y + button.frame.size.height < next.frame.origin.y) {
                        // Ignore
                    }
                    else if (button.center.x > next.center.x) {
                        [self.selectedButtons removeObject:button];
                        [self.selectedButtons insertObject:button atIndex:index + 1];
                        [self updateAnswer];
                        
                        self.inAnswerFrame = button.frame;
                    }
                }
            }
        }
        else if (button == self.hoveringButton) {   // Hovering
            for (long index = [self.selectedButtons count] - 1; index >= 0; index--) {
                if (button.frame.origin.x < [[self.selectedButtonRightEdges objectAtIndex:index] floatValue]) {
                    UIButton* passing = [self.selectedButtons objectAtIndex:index];
                    
                    if (passing.frame.origin.y <= button.frame.origin.y
                        && (passing.frame.origin.y + passing.frame.size.height) > button.frame.origin.y) {
                        [self.selectedButtons removeObject:button];
                        [self.selectedButtons insertObject:button atIndex:index];
                        [self updateAnswer];
                        
                        self.inAnswerFrame = button.frame;
                        
                        break;
                    }
                }
            }
        }
        else {   // Unselected
            if (point.y < SELECTED_UNSELECTED_BOUNDARY_Y) {
                self.hoveringButton = button;
            }
        }
    }
    else if (longPress.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [longPress locationInView:self];
        
        if ([self.selectedButtons containsObject:button]) {   // In Answer
            [UIView animateWithDuration:0.3 animations:^(void){
                button.frame = self.inAnswerFrame;
            }];
        }
        else if (button == self.hoveringButton) {   // Hovering
            if (point.y + BUTTON_HEIGHT / 2 > SELECTED_UNSELECTED_BOUNDARY_Y) {
                [self buttonUnselected:button];
            }
            else {
                [self buttonSelected:button];
            }
        }
        else {   // Unselected
            if (point.y + BUTTON_HEIGHT / 2 > SELECTED_UNSELECTED_BOUNDARY_Y) {
                [self buttonUnselected:button];
            }
        }
    }
}

@end
