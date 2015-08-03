//
//  ExerciseViewController.m
//  Gifted Kids
//
//  Created by 李诣 on 5/17/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "ExerciseViewController.h"
#import "Exercise.h"
#import "ExerciseResultsViewController.h"
#import "DateManager.h"

#import "StudentLearnedWord+Add.h"
#import "StudentLearnedComponent+Add.h"
#import "Student.h"

#import "Word+Add.h"
#import "StructureComponent+Add.h"
#import "Sentence+Add.h"

#define VIEW_BACKGROUND_COLOR [UIColor colorWithRed:241.194626391/255 green:241.187391579/255 blue:241.191495359/255 alpha:1.0]
#define CORRECT_LABEL_TEXT_COLOR [UIColor colorWithRed:101.176927686/255 green:145.954925716/255 blue:27.740179673/255 alpha:1.0]
#define INCORRECT_LABEL_TEXT_COLOR [UIColor colorWithRed:149.395793080/255 green:8.521802723/255 blue:15.810369272/255 alpha:1.0]


@interface ExerciseViewController ()

// Display

@property (strong, nonatomic) IBOutlet UIButton *checkButton;

@property (strong, nonatomic) UIButton *resultLabel;

@property (nonatomic) BOOL shouldContinue;

@property (strong, nonatomic) IBOutlet SingleChoiceView *singleChoiceView;

@property (strong, nonatomic) IBOutlet MultipleChoiceView *multipleChoiceView;

@property (strong, nonatomic) IBOutlet TypeTranslationView *typeTranslationView;

@property (strong, nonatomic) IBOutlet BlockTranslationView *blockTranslationView;

@property (strong, nonatomic) NSArray* allViews;

@property (strong, nonatomic) UIView* currentView;


// Questions

@property (strong, nonatomic) Student* student;

@property (strong, nonatomic) Exercise* exercise;

@property (strong, nonatomic) NSArray* allWords;

@property (strong, nonatomic) NSMutableArray* wordsToBeReviewed;

@property (strong, nonatomic) NSMutableArray* componentsToBeReviewed;

@property (strong, nonatomic) NSMutableArray* sentencesToBeReviewed;

@property (nonatomic) int waitlistSentences;

@property (strong, nonatomic) id currentItem;   // Sentence or Word that is displayed


// Question Type

@property (nonatomic) size_t singleChoiceCount;

@property (nonatomic) size_t multipleChoiceCount;

@property (nonatomic) size_t typeTranslationCount;

@property (nonatomic) size_t blockTranslationCount;


// Results

@property (nonatomic) size_t correctProblemsCount;

@property (nonatomic) size_t incorrectProblemsCount;

@property (nonatomic, strong) NSMutableArray* learnedWords;

@property (nonatomic, strong) NSMutableArray* reviewedWords;

@property (nonatomic, strong) NSMutableArray* learnedComponents;

@property (nonatomic, strong) NSMutableArray* reviewedComponents;

@end


@implementation ExerciseViewController

@synthesize context = _context;

@synthesize exerciseName = _exerciseName;

@synthesize checkButton = _checkButton;

@synthesize resultLabel = _resultLabel;

@synthesize shouldContinue = _shouldContinue;

@synthesize singleChoiceView = _singleChoiceView;

@synthesize multipleChoiceView = _multipleChoiceView;

@synthesize typeTranslationView = _typeTranslationView;

@synthesize blockTranslationView = _blockTranslationView;

@synthesize allViews = _allViews;

@synthesize currentView = _currentView;

@synthesize student = _student;

@synthesize exercise = _exercise;

@synthesize componentsToBeReviewed = _componentsToBeReviewed;

@synthesize allWords = _allWords;

@synthesize wordsToBeReviewed= _wordsToBeReviewed;

@synthesize sentencesToBeReviewed = _sentencesToBeReviewed;

@synthesize waitlistSentences = _waitlistSentences;

@synthesize currentItem = _currentItem;

@synthesize singleChoiceCount = _singleChoiceCount;

@synthesize multipleChoiceCount = _multipleChoiceCount;

@synthesize typeTranslationCount = _typeTranslationCount;

@synthesize blockTranslationCount = _blockTranslationCount;

@synthesize correctProblemsCount = _correctProblemsCount;

@synthesize incorrectProblemsCount = _incorrectProblemsCount;

@synthesize learnedWords = _learnedWords;

@synthesize reviewedWords = _reviewedWords;

@synthesize learnedComponents = _learnedComponents;

@synthesize reviewedComponents = _reviewedComponents;


- (NSMutableArray*)learnedWords
{
    if (! _learnedWords) {
        _learnedWords = [NSMutableArray array];
    }
    
    return _learnedWords;
}

- (NSMutableArray*)reviewedWords
{
    if (! _reviewedWords) {
        _reviewedWords = [NSMutableArray array];
    }
    
    return _reviewedWords;
}

- (NSMutableArray*)learnedComponents
{
    if (! _learnedComponents) {
        _learnedComponents = [NSMutableArray array];
    }
    
    return _learnedComponents;
}

- (NSMutableArray*)reviewedComponents
{
    if (! _reviewedComponents) {
        _reviewedComponents = [NSMutableArray array];
    }
    
    return _reviewedComponents;
}


- (void)setCurrentView:(UIView *)currentView
{
    if (_currentView != currentView) {
        _currentView = currentView;
        
        for (UIView* view in self.allViews) {
            if (view == currentView) {
                [view setAlpha:1.0];
            }
            else {
                [view setAlpha:0];
            }
        }
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeView];
    
    
    // Get Student
    NSFetchRequest* request_student = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    request_student.predicate = [NSPredicate predicateWithFormat:@"username == %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]];
    NSError* error = nil;
    NSArray* match_student = [self.context executeFetchRequest:request_student error:&error];
    self.student = [match_student lastObject];
    
    // Load Exercise Data
    if ([self.exerciseName isEqualToString:@"Review"]) {
        [self getReview];
    }
    else {
        [self getExercise];
        
        // Load Components and Words to be tested
        [self getComponents];
        [self getWords];
        [self getSentences];
    }
    
    
    // Start Exercise
    [self startExercise];
}

- (void)initializeView
{
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR;
    self.navigationItem.title = self.exerciseName;
    self.shouldContinue = NO;
    self.waitlistSentences = 0;
    
    // Check button
    [self.checkButton setBackgroundImage:[UIImage imageNamed:@"Check-Enabled.png"] forState:UIControlStateNormal];
    [self.checkButton setBackgroundImage:[UIImage imageNamed:@"Check-Disabled.png"] forState:UIControlStateDisabled];
    
    self.resultLabel = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.resultLabel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.resultLabel setTitleEdgeInsets:UIEdgeInsetsMake(0, 80, 0, 0)];
    [self.resultLabel.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.resultLabel.titleLabel setNumberOfLines:5];
    [self.resultLabel setEnabled:NO];
    [self.view addSubview:self.resultLabel];
    [self hideResultLabel];
    
    
    // Views
    self.allViews = [NSArray arrayWithObjects:self.singleChoiceView,
                     self.multipleChoiceView,
                     self.typeTranslationView,
                     self.blockTranslationView, nil];
    
    self.singleChoiceView.delegate = self;
    [self.singleChoiceView setup];
    
    self.multipleChoiceView.delegate = self;
    [self.multipleChoiceView setup];
    
    self.typeTranslationView.delegate = self;
    [self.typeTranslationView setup];
    
    self.blockTranslationView.delegate = self;
    [self.blockTranslationView setup];
}

- (void)startExercise
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (self.wordsToBeReviewed.count || self.componentsToBeReviewed) {
            NSLog(@"Starting exercise");
            self.correctProblemsCount = 0;
            self.incorrectProblemsCount = 0;
            
            [self showNextExercise];
        }
        else {
            NSLog(@"No exercise exists");
//            [self.navigationController popViewControllerAnimated:NO];
        }
    });
}

//- (void)printAllSentences
//{
//    dispatch_async(dispatch_get_main_queue(), ^(void){
//        NSLog(@"#Start - Print all sentences#");
//        NSFetchRequest* request_sentences = [NSFetchRequest fetchRequestWithEntityName:@"Sentence"];
//        request_sentences.sortDescriptors = [NSArray arrayWithObjects:
//                                             [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES], nil];
//        NSError* error = nil;
//        NSArray* match_sentences = [self.context executeFetchRequest:request_sentences error:&error];
//        
//        for (Sentence* sentence in match_sentences) {
//            NSLog(@"Sentence %d: %@ (%d words)", [sentence.uid intValue], sentence.english, (int)[sentence.usesWords count]);
//        }
//        NSLog(@"#End - Print all sentences#");
//    });
//}
//
//- (void)printAllWords
//{
//    dispatch_async(dispatch_get_main_queue(), ^(void){
//        NSLog(@"#Start - Print all words#");
//        NSFetchRequest* request_words = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
//        request_words.sortDescriptors = [NSArray arrayWithObjects:
//                                         [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES], nil];
//        NSError* error = nil;
//        NSArray* match_words = [self.context executeFetchRequest:request_words error:&error];
//        
//        for (Word* word in match_words) {
//            NSLog(@"Word %d: %@", [word.uid intValue], word.english);
//        }
//        NSLog(@"#End - Print all words#");
//    });
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetCheckButton
{
    [self.checkButton setBackgroundImage:[UIImage imageNamed:@"Check-Enabled.png"] forState:UIControlStateNormal];
    [self.checkButton setEnabled:NO];
}


#pragma mark - Initialize View

- (void)showSingleChoiceViewWithPrompt:(NSString*)prompt
                              question:(NSString*)question
                            andOptions:(NSArray*)options
{
    self.currentView = self.singleChoiceView;
    [self.singleChoiceView updateWithPrompt:prompt question:question andOptions:options];
    
    [self resetCheckButton];
}

- (void)showMultipleChoiceViewWithPrompt:(NSString*)prompt
                                question:(NSString*)question
                         requiredAnswers:(NSArray*)requiredAnswers
                              andOptions:(NSArray*)options
{
    self.currentView = self.multipleChoiceView;
    [self.multipleChoiceView updateWithPrompt:prompt question:question requiredAnswers:requiredAnswers andOptions:options];
    
    [self resetCheckButton];
}

- (void)showTypeTranslationViewWithPrompt:(NSString*)prompt
                              andQuestion:(NSString*)question
{
    self.currentView = self.typeTranslationView;
    [self.typeTranslationView updateWithPrompt:prompt andQuestion:question];
    
    [self resetCheckButton];
}

- (void)showBlockTranslationViewWithPrompt:(NSString*)prompt
                                  question:(NSString*)question
                            andWordOptions:(NSArray*)wordOptions
{
    self.currentView = self.blockTranslationView;
    [self.blockTranslationView updateWithPrompt:prompt question:question andWordOptions:wordOptions];
    
    [self resetCheckButton];
}


#pragma mark - Delegate (Single Choice View, Multiple Choice View, Type Translation View)

- (void)setCheckButtonEnabled:(BOOL)enabled
{
    [self.checkButton setEnabled:enabled];
}

- (void)keyboardWillAppear:(CGRect)keyboardFrame
                  duration:(NSTimeInterval)duration
                     curve:(UIViewAnimationCurve)curve
{
    CGRect curFrame = self.checkButton.frame;
    CGRect newFrame = CGRectMake(curFrame.origin.x, curFrame.origin.y - keyboardFrame.size.height, curFrame.size.width, curFrame.size.height);
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.checkButton.frame = newFrame;
    } completion:nil];
}

- (void)keyboardWillDisappear:(CGRect)keyboardFrame
                     duration:(NSTimeInterval)duration
                        curve:(UIViewAnimationCurve)curve
{
    CGRect curFrame = self.checkButton.frame;
    CGRect newFrame = CGRectMake(curFrame.origin.x, curFrame.origin.y + keyboardFrame.size.height, curFrame.size.width, curFrame.size.height);
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.checkButton.frame = newFrame;
    } completion:nil];
}


#pragma mark - Fetch Review Structures, Words, and Sentences

- (void)getReview
{
    NSError* error = nil;
    NSDate* endDate = [DateManager dateDays:5 afterDate:[DateManager today]];
    
    
    // Get Words
    NSDate* date = [DateManager today];
    while (! [self.wordsToBeReviewed count] && ! [date isEqualToDate:endDate]) {
        NSFetchRequest* request_slw = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
        request_slw.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ && nextTestDate == %@", self.student.username, [DateManager today]];
        request_slw.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"strength" ascending:YES], nil];
        NSArray* match_slw = [self.context executeFetchRequest:request_slw error:&error];
        NSMutableArray* words = [NSMutableArray array];
        for (StudentLearnedWord* slw in match_slw) {
            NSFetchRequest* request_word = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
            request_word.predicate = [NSPredicate predicateWithFormat:@"uid == %@", slw.wordID];
            NSArray* match_word = [self.context executeFetchRequest:request_word error:&error];
            [words addObject:[match_word lastObject]];
        }
        self.wordsToBeReviewed = words;
        
        date = [DateManager dateDays:1 afterDate:date];
    }
    
    
    // Get Distractors for Words
    if ([self.wordsToBeReviewed count]) {
        NSFetchRequest* request_distractorSlw = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
        request_distractorSlw.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@", self.student.username];
        request_distractorSlw.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"strength" ascending:YES], nil];
        request_distractorSlw.fetchLimit = [self.wordsToBeReviewed count] * 4;
        NSArray* match_distractorSlw = [self.context executeFetchRequest:request_distractorSlw error:&error];
        NSMutableArray* distractors = [NSMutableArray array];
        for (StudentLearnedWord* slw in match_distractorSlw) {
            NSFetchRequest* request_word = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
            request_word.predicate = [NSPredicate predicateWithFormat:@"uid == %@", slw.wordID];
            NSArray* match_word = [self.context executeFetchRequest:request_word error:&error];
            [distractors addObject:[match_word lastObject]];
        }
        self.allWords = distractors;
    }
    
    
    // Get Structure Components
    date = [DateManager today];
    while (! self.componentsToBeReviewed && ! [date isEqualToDate:endDate]) {
        NSFetchRequest* request_slc = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedComponent"];
        request_slc.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ && nextTestDate == %@", self.student.username, [DateManager today]];
        request_slc.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"strength" ascending:YES], nil];
        NSArray* match_slc = [self.context executeFetchRequest:request_slc error:&error];
        NSMutableArray* components = [NSMutableArray array];
        for (StudentLearnedComponent* slc in match_slc) {
            NSFetchRequest* request_component = [NSFetchRequest fetchRequestWithEntityName:@"StructureComponent"];
            request_component.predicate = [NSPredicate predicateWithFormat:@"uid == %@", slc.componentID];
            NSArray* match_component = [self.context executeFetchRequest:request_component error:&error];
            [components addObject:[match_component lastObject]];
        }
        self.componentsToBeReviewed = components && [components count] ? components : nil;
        
        date = [DateManager dateDays:1 afterDate:date];
    }
    
    
    // Get Sentences
    if (self.componentsToBeReviewed) {
        NSFetchRequest* request_sentences = [NSFetchRequest fetchRequestWithEntityName:@"Sentence"];
        request_sentences.predicate = [NSPredicate predicateWithFormat:@"usesComponents IN %@", self.componentsToBeReviewed];
        request_sentences.sortDescriptors = [NSArray arrayWithObjects:
                                             [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES], nil];
        NSArray* match_sentences = [self.context executeFetchRequest:request_sentences error:&error];
        NSMutableArray* usable_sentences = [NSMutableArray array];
        for (Sentence* sentence in match_sentences) {
            BOOL usable = YES;
            for (Word* word in sentence.usesWords) {
                NSFetchRequest* request_learned = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
                request_learned.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ && wordID == %@", self.student.username, word.uid];
                NSArray* match_learned = [self.context executeFetchRequest:request_learned error:&error];
                if (! match_learned || ! [match_learned count]) {
                    usable = NO;
                    break;
                }
            }
            
            if (usable) {
                [usable_sentences addObject:sentence];
            }
        }
        self.sentencesToBeReviewed = usable_sentences;
    }
    
    if (! [self.wordsToBeReviewed count] && ! [self.sentencesToBeReviewed count]) {
        NSLog(@"No review for today");
        return;
    }
    else {
        NSLog(@"Review for today: %d words, %d structure components, %d sentences", (int)[self.wordsToBeReviewed count], (int)[self.componentsToBeReviewed count], (int)[self.sentencesToBeReviewed count]);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExerciseViewControllerDidFetchSentencesNotification" object:self];
}


#pragma mark - Fetch Exercise Structures, Words, and Sentences

- (void)getExercise
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSArray* components = [self.exerciseName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ."]];
        int unit = [components[components.count - 2] intValue];
        int index = [components[components.count - 1] intValue];
        size_t exerciseID = 10000 + unit * 100 + index;
        
        NSFetchRequest* request_exercise = [NSFetchRequest fetchRequestWithEntityName:@"Exercise"];
        request_exercise.predicate = [NSPredicate predicateWithFormat:@"uid == %ld", exerciseID];
        NSError* error = nil;
        NSArray* match_exercise = [self.context executeFetchRequest:request_exercise error:&error];
        
        if (! match_exercise || [match_exercise count] > 1) {
            NSLog(@"ERROR: Error when fetching exercise with ID %ld", exerciseID);
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([match_exercise count] == 0) {
            NSLog(@"ERROR: No exercise exists with ID %ld", exerciseID);
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            self.exercise = [match_exercise lastObject];
            NSLog(@"Fetched exercise");
        }
    });
}

- (void)getComponents
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSFetchRequest* request_components = [NSFetchRequest fetchRequestWithEntityName:@"StructureComponent"];
        request_components.predicate = [NSPredicate predicateWithFormat:@"%@ IN testedInExercise", self.exercise];
        request_components.sortDescriptors = [NSArray arrayWithObjects:
                                              [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES], nil];
        NSError* error = nil;
        NSArray* match_components = [self.context executeFetchRequest:request_components error:&error];
        
        if (! match_components) {
            NSLog(@"ERROR: Error when fetching structures for exercise %@", self.exercise.uid);
//        [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([match_components count] == 0) {
            NSLog(@"ERROR: No structures exist for exercise %@", self.exercise.uid);
//        [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            self.componentsToBeReviewed = [match_components mutableCopy];
            NSLog(@"Fetched %d components", (int)[self.componentsToBeReviewed count]);
        }
    });
}

- (void)getWords
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSFetchRequest* request_words = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
        request_words.predicate = [NSPredicate predicateWithFormat:@"%@ IN testedInExercise", self.exercise];
        request_words.sortDescriptors = [NSArray arrayWithObjects:
                                         [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES], nil];
        NSError* error = nil;
        NSArray* match_words = [self.context executeFetchRequest:request_words error:&error];
        
        if (! match_words) {
            NSLog(@"ERROR: Error when fetching words for exercise %@", self.exercise.uid);
            //        [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([match_words count] == 0) {
            NSLog(@"ERROR: No words exist for exercise %@", self.exercise.uid);
            //        [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            self.allWords = match_words;
            self.wordsToBeReviewed = [match_words mutableCopy];
            NSLog(@"Fetched %d words", (int)[self.allWords count]);
        }
    });
}

- (void)getSentences
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        // Fetch all sentences that uses components tested in this exercise
        NSFetchRequest* request_sentences = [NSFetchRequest fetchRequestWithEntityName:@"Sentence"];
//        request_sentences.predicate = [NSPredicate predicateWithFormat:@"ANY usesComponents IN %@", self.componentsToBeReviewed];
        if (self.exercise.uid.integerValue == 10101) {
            request_sentences.predicate = [NSPredicate predicateWithFormat:@"uid == %@", [NSNumber numberWithInteger:110310010]];
        }
        else if (self.exercise.uid.integerValue == 10102) {
            request_sentences.predicate = [NSPredicate predicateWithFormat:@"uid == %@", [NSNumber numberWithInteger:110510003]];
        }
        else if (self.exercise.uid.integerValue == 10201) {
            request_sentences.predicate = [NSPredicate predicateWithFormat:@"uid == %@", [NSNumber numberWithInteger:1020001]];
        }
        else if (self.exercise.uid.integerValue == 10202) {
            request_sentences.predicate = [NSPredicate predicateWithFormat:@"uid == %@", [NSNumber numberWithInteger:1020001]];
        }
        request_sentences.sortDescriptors = [NSArray arrayWithObjects:
                                             [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES], nil];
        NSError* error = nil;
        NSArray* match_sentences = [self.context executeFetchRequest:request_sentences error:&error];
        
        if (! match_sentences) {
            NSLog(@"ERROR: Error when fetching sentences for exercise %@", self.exercise.uid);
            //        [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([match_sentences count] == 0) {
            NSLog(@"ERROR: No sentences exist for exercise %@", self.exercise.uid);
            //        [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            // Remove sentences that contain words the student has not learned
            NSMutableArray* usable_sentences = [NSMutableArray array];
            for (Sentence* sentence in match_sentences) {
                BOOL usable = YES;
                for (Word* word in sentence.usesWords) {
                    if ([self.wordsToBeReviewed containsObject:word]) {
                        continue;
                    }
                    
                    NSFetchRequest* request_learned = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
                    request_learned.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ && wordID == %@", self.student.username, word.uid];
                    NSArray* match_learned = [self.context executeFetchRequest:request_learned error:&error];
                    if (! match_learned || ! [match_learned count]) {
                        usable = NO;
                        break;
                    }
                }
                
                if (usable) {
                    [usable_sentences addObject:sentence];
                }
            }
            
            self.sentencesToBeReviewed = [match_sentences mutableCopy];
            NSLog(@"Fetched %d sentences", (int)[self.sentencesToBeReviewed count]);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ExerciseViewControllerDidFetchSentencesNotification" object:self];
    });
}


#pragma mark - Update Exercise

- (void)showNextExercise
{
    if (! [self.sentencesToBeReviewed count] && ! [self.wordsToBeReviewed count]) {
        NSLog(@"Exercise Done");
        
        // Sync to Bmob
        [self syncToBmob];
        
        // Show Report
        [self performSegueWithIdentifier:@"Show Exercise Results" sender:self];
        
        return;
    }
    
    if (! [self.sentencesToBeReviewed count]) {
        [self showNextWord];
    }
    else if (! [self.wordsToBeReviewed count] || self.waitlistSentences) {
        [self showNextSentence];
    }
    else {
        int index = arc4random() % 2;
        switch (index) {
            case 0:
                [self showNextSentence];
                break;
            case 1:
                [self showNextWord];
                break;
            default:
                break;
        }
    }
}

- (void)showNextSentence
{
    // Get Sentence
    int sentenceIndex = 0;
    if (! self.waitlistSentences) {
        sentenceIndex = arc4random() % [self.sentencesToBeReviewed count];
    }
    else {
        self.waitlistSentences = self.waitlistSentences - 1;
    }
    Sentence* sentence = [self.sentencesToBeReviewed objectAtIndex:sentenceIndex];
    [self.sentencesToBeReviewed removeObject:sentence];
//    [self.sentencesToBeReviewed removeObjectAtIndex:sentenceIndex];
    self.currentItem = sentence;
    
    // Get Available Question Types
    NSMutableArray* availableQuestionTypes = [NSMutableArray arrayWithObjects:@"TypeTranslation", @"BlockTranslation", nil];
    NSMutableArray* distractors = [[sentence.distractors componentsSeparatedByString:@"; "] mutableCopy];
    if (distractors && [distractors count] >= 3) {
        [availableQuestionTypes addObject:@"SingleChoice"];
        [availableQuestionTypes addObject:@"MultipleChoice"];
    }
    else if (distractors && [distractors count] >= 2) {
        [availableQuestionTypes addObject:@"MultipleChoice"];
    }
    
    // Choose Question Type
    NSString* questionType = @"BlockTranslation";
    size_t min = self.blockTranslationCount;
    questionType = self.typeTranslationCount < min ? @"TypeTranslation" : questionType;
    min = self.typeTranslationCount < min ? self.typeTranslationCount : min;
    if ([availableQuestionTypes containsObject:@"MultipleChoice"]) {
        questionType = self.multipleChoiceCount < min ? @"MultipleChoice" : questionType;
        min = self.multipleChoiceCount < min ? self.multipleChoiceCount : min;
    }
    if ([availableQuestionTypes containsObject:@"SingleChoice"]) {
        questionType = self.singleChoiceCount < min ? @"SingleChoice" : questionType;
        min = self.singleChoiceCount < min ? self.singleChoiceCount : min;
    }
    
    // Show View
    if ([questionType isEqualToString:@"BlockTranslation"]) {
        self.blockTranslationCount = self.blockTranslationCount + 1;
        
        NSMutableArray* mutableWords = [[sentence.english componentsSeparatedByString:@" "] mutableCopy];
        for (int i = 0; i < [mutableWords count]; i ++) {
            NSString* word = [mutableWords objectAtIndex:i];
            char lastChar = [word characterAtIndex:word.length - 1];
            if (lastChar < 'A' || lastChar > 'z') {
                word = [word substringToIndex:word.length - 1];
                [mutableWords replaceObjectAtIndex:i withObject:word];
            }
        }
        
        [self showBlockTranslationViewWithPrompt:@"翻译句子" question:sentence.chinese andWordOptions:mutableWords];
    }
    else if ([questionType isEqualToString:@"TypeTranslation"]) {
        self.typeTranslationCount = self.typeTranslationCount + 1;
        
        [self showTypeTranslationViewWithPrompt:@"翻译句子" andQuestion:sentence.chinese];
    }
    else if ([questionType isEqualToString:@"MultipleChoice"]) {
        self.multipleChoiceCount = self.multipleChoiceCount + 1;
        
        NSMutableArray* options = [NSMutableArray array];
        NSMutableArray* requiredAnswers = [NSMutableArray array];
        
        // Add equivalent to options (if any)
        if (sentence.equivalents && ! [sentence.equivalents isEqualToString:@""]) {
            NSMutableArray* equivalents = [[sentence.equivalents componentsSeparatedByString:@"; "] mutableCopy];
            int selectIndex = arc4random() % [equivalents count];
            NSString* option = [equivalents objectAtIndex:selectIndex];
            [equivalents removeObjectAtIndex:selectIndex];
            [options addObject:option];
            [requiredAnswers addObject:option];
        }
        
        // Add distractors
        while ([options count] < 2) {
            int selectIndex = arc4random() % [distractors count];
            NSString* option = [distractors objectAtIndex:selectIndex];
            [distractors removeObjectAtIndex:selectIndex];
            if ([options count]) {
                int insertIndex = arc4random() % [options count];
                [options insertObject:option atIndex:insertIndex];
            }
            else {
                [options addObject:option];
            }
        }
        
        // Add correct option
        int insertIndex = arc4random() % [options count];
        [options insertObject:sentence.english atIndex:insertIndex];
        [requiredAnswers insertObject:sentence.english atIndex:0];
        
        [self showMultipleChoiceViewWithPrompt:@"选择所有正确的翻译" question:sentence.chinese requiredAnswers:requiredAnswers andOptions:options];
    }
    else if ([questionType isEqualToString:@"SingleChoice"]) {
        self.singleChoiceCount = self.singleChoiceCount + 1;
        
        NSMutableArray* options = [NSMutableArray array];
        while ([options count] < 3) {
            int selectIndex = arc4random() % [distractors count];
            NSString* option = [distractors objectAtIndex:selectIndex];
            [distractors removeObjectAtIndex:selectIndex];
            if ([options count]) {
                int insertIndex = arc4random() % [options count];
                [options insertObject:option atIndex:insertIndex];
            }
            else {
                [options addObject:option];
            }
        }
        
        int insertIndex = arc4random() % [options count];
        [options insertObject:sentence.english atIndex:insertIndex];
        
        [self showSingleChoiceViewWithPrompt:@"选择正确的翻译" question:sentence.chinese andOptions:options];
    }
}

- (void)showNextWord
{
    // Get Word
    int wordIndex = arc4random() % [self.wordsToBeReviewed count];
    Word* word = [self.wordsToBeReviewed objectAtIndex:wordIndex];
    [self.wordsToBeReviewed removeObjectAtIndex:wordIndex];
    self.currentItem = word;
    NSMutableArray* distractors = [self.allWords mutableCopy];
    [distractors removeObject:word];
    
    // If not enough distractors
    if (distractors.count < 3) {
        self.wordsToBeReviewed = [NSMutableArray array];   // TEST PURPOSES ONLY
        [self showNextExercise];
        return;
    }
    
    
    // Show View
    self.singleChoiceCount = self.singleChoiceCount + 1;
    
    NSMutableArray* options = [NSMutableArray array];
    while ([options count] < 3) {
        int selectIndex = arc4random() % [distractors count];
        Word* distractor = [distractors objectAtIndex:selectIndex];
        NSString* option = distractor.english;
        [distractors removeObjectAtIndex:selectIndex];
        if ([option isEqualToString:word.english]) {
            continue;
        }
        
        if ([options count]) {
            int insertIndex = arc4random() % [options count];
            [options insertObject:option atIndex:insertIndex];
        }
        else {
            [options addObject:option];
        }
    }
    
    int insertIndex = arc4random() % [options count];
    [options insertObject:word.english atIndex:insertIndex];
    
    [self showSingleChoiceViewWithPrompt:@"选择正确的翻译" question:word.chinese andOptions:options];
}


#pragma mark - Back

- (IBAction)quitButtonPressed:(id)sender
{
    UIAlertView* quitAlert = [[UIAlertView alloc] initWithTitle:@"确定要退出吗？" message:@"进度将会丢失" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
    [quitAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"退出"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Check Response

- (IBAction)checkPressed:(id)sender
{
    if (self.shouldContinue) {
        self.shouldContinue = NO;
        [self hideResultLabel];
        [self showNextExercise];
        return;
    }
    
    // Get Check Answers and Show Result Label
    if ([self.currentView isKindOfClass:[SingleChoiceView class]]) {
        NSString* requiredAnswer;
        if ([self.currentItem isKindOfClass:[Word class]]) {
            Word* word = (Word*)self.currentItem;
            requiredAnswer = word.english;
        }
        else if ([self.currentItem isKindOfClass:[Sentence class]]) {
            Sentence* sentence = (Sentence*)self.currentItem;
            requiredAnswer = sentence.english;
        }
        
        [self checkSingleChoiceItem:self.currentItem
                       withResponse:self.singleChoiceView.selectedOption
                   andCorrectAnswer:requiredAnswer];
    }
    else if ([self.currentView isKindOfClass:[MultipleChoiceView class]]) {
        [self checkMultipleChoiceItem:self.currentItem
                        withResponses:self.multipleChoiceView.selectedOptions
                    andCorrectAnswers:self.multipleChoiceView.requiredAnswers];
    }
    else if ([self.currentView isKindOfClass:[TypeTranslationView class]]) {
        [self.typeTranslationView dismissKeyboard];
        
        NSMutableArray* correctAnswers = [NSMutableArray array];
        Sentence* sentence = (Sentence*)self.currentItem;
        [correctAnswers addObject:sentence.english];
        if (sentence.equivalents && ! [sentence.equivalents isEqualToString:@""]) {
            [correctAnswers addObjectsFromArray:[sentence.equivalents componentsSeparatedByString:@"; "]];
        }
        
        [self checkTypeTranslationItem:self.currentItem
                          withResponse:self.typeTranslationView.translation
                     andCorrectAnswers:correctAnswers];
    }
    else if ([self.currentView isKindOfClass:[BlockTranslationView class]]) {
        NSMutableArray* correctAnswers = [NSMutableArray array];
        Sentence* sentence = (Sentence*)self.currentItem;
        [correctAnswers addObject:sentence.english];
        if (sentence.equivalents && ! [sentence.equivalents isEqualToString:@""]) {
            [correctAnswers addObjectsFromArray:[sentence.equivalents componentsSeparatedByString:@"; "]];
        }
        
        [self checkBlockTranslationItem:self.currentItem
                           withResponse:self.blockTranslationView.translation
                      andCorrectAnswers:correctAnswers];
    }
    
    
    // Save and Continue
    [self.context save:nil];
    NSLog(@"Saved");
    
    [self.checkButton setBackgroundImage:[UIImage imageNamed:@"Continue.png"] forState:UIControlStateNormal];
    self.shouldContinue = YES;
}

- (void)checkSingleChoiceItem:(id)item withResponse:(NSString*)response andCorrectAnswer:(NSString*)correctAnswer
{
    if ([response isEqualToString:correctAnswer]) {
        NSLog(@"Correct");
        ++ self.correctProblemsCount;
        
        if ([item isKindOfClass:[Word class]]) {
            [self updateRightWord:(Word*)item];
        }
        else {
            [self updateRightSentence:(Sentence*)item];
        }
        
        [self showCorrectResultLabelWithMessage:[[NSAttributedString alloc] initWithString:[self correctMessage]]];
        return;
    }
    else {
        NSLog(@"Incorrect");
        ++ self.incorrectProblemsCount;
        
        if ([item isKindOfClass:[Word class]]) {
            Word* word = (Word*)item;
            
            [self updateWrongWord:word];
            
            NSFetchRequest* request_wrongWord = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
            request_wrongWord.predicate = [NSPredicate predicateWithFormat:@"english == %@", response];
            NSError* error = nil;
            NSArray* match_wrongWord = [self.context executeFetchRequest:request_wrongWord error:&error];
            if ([match_wrongWord count] == 1) {
                [self updateWrongWord:[match_wrongWord lastObject]];
            }
        }
        else {
            NSLog(@"!!! --- REVISION NEEDED (checkSingleChoice - sentence) --- !!!");
            [self updateWrongSentence:(Sentence*)item answer:response closestCorrectAnswer:correctAnswer andWrongComponents:nil];
        }
        
        [self showIncorrectResultLabelWithMessage:[self incorrectMessageWithCorrection:[[NSAttributedString alloc] initWithString:correctAnswer]]];
    }
}

- (void)checkMultipleChoiceItem:(id)item withResponses:(NSArray*)responses andCorrectAnswers:(NSArray*)correctAnswers
{
    NSMutableArray* missedAnswers = [correctAnswers mutableCopy];
    for (NSString* response in responses) {
        if (! [missedAnswers containsObject:response]) {
            NSLog(@"Incorrect");
            ++ self.incorrectProblemsCount;
            
            [self updateWrongSentence:(Sentence*)item answer:response closestCorrectAnswer:[correctAnswers firstObject] andWrongComponents:nil];
            [self showIncorrectResultLabelWithMessage:[[NSAttributedString alloc] initWithString:[self wrongSelectionMessageWithCorrection:[correctAnswers componentsJoinedByString:@"\n"]]]];
            return;
        }
        else {
            [missedAnswers removeObject:response];
        }
    }
    
    if ([missedAnswers count]) {
        NSLog(@"Incorrect");
        ++ self.incorrectProblemsCount;
        
        [self updateWrongSentence:(Sentence*)item answer:[responses firstObject] closestCorrectAnswer:[missedAnswers firstObject] andWrongComponents:nil];
        [self showIncorrectResultLabelWithMessage:[[NSAttributedString alloc] initWithString:[self missedSelectionMessageWithMissing:[missedAnswers componentsJoinedByString:@"\n"]]]];
        return;
    }
    else {
        NSLog(@"Correct");
        ++ self.correctProblemsCount;
        
        [self updateRightSentence:(Sentence*)item];
        [self showCorrectResultLabelWithMessage:[[NSAttributedString alloc] initWithString:[self correctMessage]]];
    }
}

- (void)checkTypeTranslationItem:(id)item withResponse:(NSString*)response andCorrectAnswers:(NSArray*)correctAnswers
{
    Sentence* sentence = (Sentence*)item;
    
    NSString* simplifiedResponse = [self simplifiedString:response];
    NSMutableArray* mutableCorrectAnswers = [correctAnswers mutableCopy];
    NSMutableArray* mutableSimplifiedCorrectAnswers = [NSMutableArray array];
    for (NSString* answer in correctAnswers) {
        [mutableSimplifiedCorrectAnswers addObject:[self simplifiedString:answer]];
    }
    NSArray* simplifiedCorrectAnswers = mutableSimplifiedCorrectAnswers;
    
    for (NSString* correctAnswer in simplifiedCorrectAnswers) {
        if ([simplifiedResponse isEqualToString:correctAnswer]) {
            NSLog(@"Correct");
            ++ self.correctProblemsCount;
            
            [self updateRightSentence:(Sentence*)item];
            
            [mutableCorrectAnswers removeObjectAtIndex:[mutableSimplifiedCorrectAnswers indexOfObject:correctAnswer]];
            [mutableSimplifiedCorrectAnswers removeObject:correctAnswer];
            
            if (mutableCorrectAnswers.count) {
                [self showCorrectResultLabelWithMessage:[[NSAttributedString alloc] initWithString:[self correctMessageWithAlternative:[mutableCorrectAnswers firstObject]]]];
                return;
            }
            else {
                [self showCorrectResultLabelWithMessage:[[NSAttributedString alloc] initWithString:[self correctMessage]]];
                return;
            }
        }
    }
    
    // Find correct answer that is closest to user response
    NSString* closestAnswer = [simplifiedCorrectAnswers firstObject];
    int smallestDistance = [self LevenshteinDistanceBetweenArraysA:[closestAnswer componentsSeparatedByString:@" "]
                                                              andB:[simplifiedResponse componentsSeparatedByString:@" "]];
    for (NSString* simplifiedCorrectAnswer in simplifiedCorrectAnswers) {
        int distance = [self LevenshteinDistanceBetweenArraysA:[simplifiedCorrectAnswer componentsSeparatedByString:@" "]
                                                          andB:[simplifiedResponse componentsSeparatedByString:@" "]];
        if (distance < smallestDistance) {
            closestAnswer = simplifiedCorrectAnswer;
            smallestDistance = distance;
        }
    }
    NSString* fullClosestAnswer = [correctAnswers objectAtIndex:[simplifiedCorrectAnswers indexOfObject:closestAnswer]];
    NSArray* closestAnswerArray = [closestAnswer componentsSeparatedByString:@" "];
    
    // Mark parts of correct answer that user missed
    NSMutableAttributedString* attributedAnswer = [[NSMutableAttributedString alloc] initWithString:fullClosestAnswer];
    NSMutableArray* userResponseArray = [[simplifiedResponse componentsSeparatedByString:@" "] mutableCopy];
    
    NSArray* components = [sentence.structure componentsSeparatedByString:@" "];
    NSMutableArray* wrongComponentIndices = [NSMutableArray array];
    
    NSString* unprocessedString = fullClosestAnswer;
    for (size_t wordIndex = 0; wordIndex < closestAnswerArray.count; ++wordIndex) {
        NSString* word = [closestAnswerArray objectAtIndex:wordIndex];
        NSRange rangeOfWord = [fullClosestAnswer rangeOfString:word
                                                       options:NSCaseInsensitiveSearch
                                                         range:[fullClosestAnswer rangeOfString:unprocessedString]];
        
        if (! [userResponseArray containsObject:word]) {   // user response does not contain the word
            // underline the word in attributed answer
            [attributedAnswer addAttribute:NSUnderlineStyleAttributeName
                                     value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                                     range:rangeOfWord];
            
            // check misspelling
            NSString* userWord = [userResponseArray firstObject];
            if (userWord) {
                int distance = [self LevenshteinDistanceBetweenStringsA:word andB:userWord];
                if (distance <= word.length/2) {
                    [userResponseArray removeObjectAtIndex:0];
                }
                else {
                    // add word index to wrongComponentIndex
                    [wrongComponentIndices addObject:[NSNumber numberWithUnsignedLong:wordIndex]];
                }
            }
        }
        else {
            if (! [[userResponseArray firstObject] isEqualToString:word]) {   // word not in the correct order
                // underline the word in attributed answer
                [attributedAnswer addAttribute:NSUnderlineStyleAttributeName
                                         value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                                         range:rangeOfWord];
                
                // add word index to wrongComponentIndex
                [wrongComponentIndices addObject:[NSNumber numberWithUnsignedLong:wordIndex]];
                
                // remove word from userResponseArray
                long index = [userResponseArray indexOfObject:word];
                [userResponseArray removeObjectAtIndex:index];
            }
            else {
                long index = [userResponseArray indexOfObject:word];
                [userResponseArray removeObjectAtIndex:index];
            }
        }
        
        // Move unprocessed string to after the word
        unprocessedString = [fullClosestAnswer substringFromIndex:rangeOfWord.location + rangeOfWord.length];
    }
    
    StructureComponent* testWrongComponent = ((Sentence*)item).usesComponents.allObjects.firstObject;   // !!! TEST PURPOSES ONLY !!!
    NSLog(@"Wrong component: %@", testWrongComponent.name);   // !!! TEST PURPOSES ONLY !!!
    NSSet* wrongComponents = [NSSet setWithObject:testWrongComponent];   // !!! TEST PURPOSES ONLY !!!
    [self updateWrongSentence:(Sentence*)item answer:response closestCorrectAnswer:fullClosestAnswer andWrongComponents:[wrongComponents allObjects]];
    
    [self showIncorrectResultLabelWithMessage:attributedAnswer];
}

- (void)checkBlockTranslationItem:(id)item withResponse:(NSString*)response andCorrectAnswers:(NSArray*)correctAnswers
{
    Sentence* sentence = (Sentence*)item;
    
    NSString* simplifiedResponse = [self simplifiedString:response];
    NSMutableArray* mutableCorrectAnswers = [correctAnswers mutableCopy];
    NSMutableArray* mutableSimplifiedCorrectAnswers = [NSMutableArray array];
    for (NSString* answer in correctAnswers) {
        [mutableSimplifiedCorrectAnswers addObject:[self simplifiedString:answer]];
    }
    NSArray* simplifiedCorrectAnswers = mutableSimplifiedCorrectAnswers;
    
    // Check if user response is exact match for any of the correct answers
    for (NSString* correctAnswer in simplifiedCorrectAnswers) {
        if ([simplifiedResponse isEqualToString:correctAnswer]) {
            NSLog(@"Correct");
            ++ self.correctProblemsCount;
            
            [self updateRightSentence:(Sentence*)item];
            
            [mutableCorrectAnswers removeObjectAtIndex:[mutableSimplifiedCorrectAnswers indexOfObject:correctAnswer]];
            [mutableSimplifiedCorrectAnswers removeObject:correctAnswer];
            
            if (mutableCorrectAnswers.count) {
                [self showCorrectResultLabelWithMessage:[[NSAttributedString alloc] initWithString:[self correctMessageWithAlternative:[mutableCorrectAnswers firstObject]]]];
                return;
            }
            else {
                [self showCorrectResultLabelWithMessage:[[NSAttributedString alloc] initWithString:[self correctMessage]]];
                return;
            }
        }
    }
    
    
    // Find correct answer that is closest to user response
    NSString* closestAnswer = [simplifiedCorrectAnswers firstObject];
    int smallestDistance = [self LevenshteinDistanceBetweenArraysA:[closestAnswer componentsSeparatedByString:@" "]
                                                              andB:[simplifiedResponse componentsSeparatedByString:@" "]];
    for (NSString* simplifiedCorrectAnswer in simplifiedCorrectAnswers) {
        int distance = [self LevenshteinDistanceBetweenArraysA:[simplifiedCorrectAnswer componentsSeparatedByString:@" "]
                                                          andB:[simplifiedResponse componentsSeparatedByString:@" "]];
        if (distance < smallestDistance) {
            closestAnswer = simplifiedCorrectAnswer;
            smallestDistance = distance;
        }
    }
    NSString* fullClosestAnswer = [correctAnswers objectAtIndex:[simplifiedCorrectAnswers indexOfObject:closestAnswer]];
    NSArray* closestAnswerArray = [closestAnswer componentsSeparatedByString:@" "];
    
    // Mark parts of correct answer that user missed
    NSArray* components = [sentence.structure componentsSeparatedByString:@" "];
    NSMutableArray* wrongComponentIndices = [NSMutableArray array];
    
    NSMutableAttributedString* attributedAnswer = [[NSMutableAttributedString alloc] initWithString:fullClosestAnswer];
    NSMutableArray* userResponseArray = [[simplifiedResponse componentsSeparatedByString:@" "] mutableCopy];
    NSString* unprocessedString = fullClosestAnswer;
    for (size_t wordIndex = 0; wordIndex < closestAnswerArray.count; ++wordIndex) {
        NSString* word = [closestAnswerArray objectAtIndex:wordIndex];
        NSRange rangeOfWord = [fullClosestAnswer rangeOfString:word
                                                       options:NSCaseInsensitiveSearch
                                                         range:[fullClosestAnswer rangeOfString:unprocessedString]];
        
        if (! [userResponseArray containsObject:word]) {   // user response does not contain the word
            // underline the word in attributed answer
            [attributedAnswer addAttribute:NSUnderlineStyleAttributeName
                                     value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                                     range:rangeOfWord];
            
            // add word index to wrongComponentIndex
            [wrongComponentIndices addObject:[NSNumber numberWithUnsignedLong:wordIndex]];
        }
        else {
            if (! [[userResponseArray firstObject] isEqualToString:word]) {   // word not in the correct order
                // underline the word in attributed answer
                [attributedAnswer addAttribute:NSUnderlineStyleAttributeName
                                         value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                                         range:rangeOfWord];
                
                // remove word from userResponseArray
                long index = [userResponseArray indexOfObject:word];
                [userResponseArray removeObjectAtIndex:index];
                
                // add word index to wrongComponentIndex
                [wrongComponentIndices addObject:[NSNumber numberWithUnsignedLong:wordIndex]];
            }
            else {   // component is correct
                long index = [userResponseArray indexOfObject:word];
                [userResponseArray removeObjectAtIndex:index];
            }
        }
        
        // Move unprocessed string to after the word
        unprocessedString = [fullClosestAnswer substringFromIndex:rangeOfWord.location + rangeOfWord.length];
    }
    
    StructureComponent* testWrongComponent = ((Sentence*)item).usesComponents.allObjects.firstObject;   // !!! TEST PURPOSES ONLY !!!
    NSLog(@"Wrong component: %@", testWrongComponent.name);   // !!! TEST PURPOSES ONLY !!!
    NSSet* wrongComponents = [NSSet setWithObject:testWrongComponent];   // !!! TEST PURPOSES ONLY !!!
    if (wrongComponents.count) {
        [self updateWrongSentence:(Sentence*)item answer:response closestCorrectAnswer:fullClosestAnswer andWrongComponents:[wrongComponents allObjects]];
    }
    
    [self showIncorrectResultLabelWithMessage:attributedAnswer];
}

- (StructureComponent*)componentWithName:(NSString*)componentName
{
    NSError* error = nil;
    NSFetchRequest* request_component = [NSFetchRequest fetchRequestWithEntityName:@"StructureComponent"];
    request_component.predicate = [NSPredicate predicateWithFormat:@"name == %@", componentName];
    NSArray* match_component = [self.context executeFetchRequest:request_component error:&error];
    if (! match_component.count) {
        NSLog(@"ERROR: No match found for component with name: %@", componentName);
        return nil;
    }
    
    return [match_component lastObject];
}

- (NSString*)familyForComponent:(NSString*)componentName
{
    StructureComponent* component = [self componentWithName:componentName];
    if (! component) {
        return nil;
    }
    
    return component.family;
}

- (NSString*)simplifiedString:(NSString*)string
{
    NSMutableArray* mutableWords = [[string componentsSeparatedByString:@" "] mutableCopy];
    
    for (int i = 0; i < [mutableWords count]; i ++) {
        NSString* word = [mutableWords objectAtIndex:i];
        if ([word isEqualToString:@""]) {
            continue;
        }
        
        // Trim punctuation from beginning and end
        char firstChar = [word characterAtIndex:0];
        if (firstChar < 'A' || firstChar > 'z') {
            word = [word substringFromIndex:1];
        }
        char lastChar = [word characterAtIndex:word.length - 1];
        if (lastChar < 'A' || lastChar > 'z') {
            word = [word substringToIndex:word.length - 1];
        }
        
        // Change to all lower case
        word = [word lowercaseString];
        
        // Change ’ to '
        NSArray* components = [word componentsSeparatedByString:@"’"];
        word = [components componentsJoinedByString:@"'"];
        
        [mutableWords replaceObjectAtIndex:i withObject:word];
    }
    
    
    return [mutableWords componentsJoinedByString:@" "];
}

- (int)LevenshteinDistanceBetweenStringsA:(NSString*)a andB:(NSString*)b
{
    NSMutableArray* arrayA = [NSMutableArray array];
    for (size_t index = 0; index < a.length; ++index) {
        [arrayA addObject:[a substringWithRange:NSMakeRange(index, 1)]];
    }
    
    NSMutableArray* arrayB = [NSMutableArray array];
    for (size_t index = 0; index < b.length; ++index) {
        [arrayB addObject:[b substringWithRange:NSMakeRange(index, 1)]];
    }
    
    return [self LevenshteinDistanceBetweenArraysA:arrayA andB:arrayB];
}

- (int)LevenshteinDistanceBetweenArraysA:(NSArray*)a andB:(NSArray*)b
{
    // Degenerate Cases
    if (a.count == b.count) {
        BOOL same = YES;
        for (size_t index = 0; index < a.count; ++index) {
            if (! [[a objectAtIndex:index] isEqual:[b objectAtIndex:index]])
            {
                same = NO;
                break;
            }
        }
        if (same) {
            return 0;
        }
    }
    
    // Create 2 working arrays of integer distances
    NSMutableArray* prevRow = [NSMutableArray array];
    NSMutableArray* curRow = [NSMutableArray array];
    
    // Initialize prevRow (the previous row of distances)
    //   This row is A[0][i]: edit distance for an empty s
    //   The distance is just the number of items to delete from t
    for (int j = 0; j <= b.count; ++j) {
        [prevRow insertObject:[NSNumber numberWithInt:j] atIndex:j];
    }
    
    // calculate curRow (current row distances) from the previous row prevRow
    for (int i = 0; i < a.count; ++i) {
        // clear curRow
        curRow = [NSMutableArray array];
        
        // first element of curRow is A[i+1][0]
        [curRow insertObject:[NSNumber numberWithInt:i+1] atIndex:0];
        
        // use formula to fill in the rest of the row
        for (int j = 0; j < b.count; ++j) {
            int cost = [[a objectAtIndex:i] isEqual:[b objectAtIndex:j]] ? 0 : 1;
            int distance = MIN(MIN([[prevRow objectAtIndex:j+1] intValue] + 1,
                                   [[curRow objectAtIndex:j] intValue] + 1),
                               [[prevRow objectAtIndex:j] intValue] + cost);
            [curRow insertObject:[NSNumber numberWithInt:distance] atIndex:j+1];
        }
        
        // copy curRow to prevRow for next iteration
        prevRow = curRow;
    }
    
    int distance = [[curRow lastObject] intValue];
    return distance;
}


#pragma mark - Result Message

- (NSString*)correctMessage
{
    return @"正确";
}

- (NSString*)correctMessageWithAlternative:(NSString*)alternative
{
    return [NSString stringWithFormat:@"其他正确翻译：\n%@", alternative];
}

- (NSAttributedString*)incorrectMessageWithCorrection:(NSAttributedString*)correction
{
    NSMutableAttributedString* msg = [[NSMutableAttributedString alloc] initWithString:@"错啦！\n正确的翻译：\n"];
    [msg appendAttributedString:correction];
    return msg;
}

- (NSString*)wrongSelectionMessageWithCorrection:(NSString*)correction
{
    return [NSString stringWithFormat:@"错啦！\n正确的翻译：\n%@", correction];
}

- (NSString*)missedSelectionMessageWithMissing:(NSString*)missing
{
    return [NSString stringWithFormat:@"漏了一个正确的翻译：\n%@", missing];
}


#pragma mark - Result Label

- (void)showCorrectResultLabelWithMessage:(NSAttributedString*)msg
{
    // Set Background
    [self.resultLabel setBackgroundImage:[UIImage imageNamed:@"Flag-Correct.png"] forState:UIControlStateDisabled];
    
    // Set Title Font
//    [self.resultLabel setTitleColor:CORRECT_LABEL_TEXT_COLOR forState:UIControlStateDisabled];
    if ([[msg string] isEqualToString:@"正确"]) {
        [self.resultLabel.titleLabel setFont:[UIFont systemFontOfSize:36]];
    }
    else {
        [self.resultLabel.titleLabel setFont:[UIFont systemFontOfSize:20]];
    }
    
    // Set Title Color
    NSMutableAttributedString* mutableMsg = [msg mutableCopy];
    [mutableMsg addAttribute:NSForegroundColorAttributeName value:CORRECT_LABEL_TEXT_COLOR range:NSMakeRange(0, msg.length)];
    
    // Set Title
    [self.resultLabel setAttributedTitle:mutableMsg forState:UIControlStateDisabled];
    
    // Show
    [self.resultLabel setAlpha:1];
    self.resultLabel.frame = CGRectMake(327, 1024, 441, 88);
    [UIView animateWithDuration:0.2 animations:^(void){
        self.resultLabel.frame = CGRectMake(327, 539, 441, 88);
    }];
}

- (void)showIncorrectResultLabelWithMessage:(NSAttributedString*)msg
{
    // Set Background
    [self.resultLabel setBackgroundImage:[UIImage imageNamed:@"Flag-Incorrect.png"] forState:UIControlStateDisabled];
    
    // Set Title Font
//    [self.resultLabel setTitleColor:INCORRECT_LABEL_TEXT_COLOR forState:UIControlStateDisabled];
    [self.resultLabel.titleLabel setFont:[UIFont systemFontOfSize:24]];
    
    // Set Title Color
    NSMutableAttributedString* mutableMsg = [msg mutableCopy];
    [mutableMsg addAttribute:NSForegroundColorAttributeName value:INCORRECT_LABEL_TEXT_COLOR range:NSMakeRange(0, msg.length)];
    
    // Set Title
    [self.resultLabel setAttributedTitle:mutableMsg forState:UIControlStateDisabled];
    
    // Show
    [self.resultLabel setAlpha:1];
    self.resultLabel.frame = CGRectMake(327, 1024, 441, 157);
    [UIView animateWithDuration:0.2 animations:^(void){
        self.resultLabel.frame = CGRectMake(327, 556, 441, 157);
    }];
}

- (void)hideResultLabel
{
    [self.resultLabel setAlpha:0];
}


#pragma mark - Update Database

- (void)updateRightSentence:(Sentence*)sentence
{
    // Update right components
    NSSet* components = sentence.usesComponents;
    for (StructureComponent* component in components) {
        [self.componentsToBeReviewed removeObject:component];
        [self updateRightComponent:component];
    }
    
    // For waitlistSentences, remove sentences that are complete sub-sentences of the right sentence
    NSMutableArray* newToBeReviewed = [NSMutableArray array];
    for (size_t i = 0; i < self.waitlistSentences; ++i) {
        Sentence* toBeReviewed = self.sentencesToBeReviewed[i];
        
        NSRange rangeInRightSentence = [sentence.english rangeOfString:toBeReviewed.english];
        if (rangeInRightSentence.location == NSNotFound) {
            [newToBeReviewed addObject:toBeReviewed];
        }
        else {
            self.waitlistSentences = self.waitlistSentences - 1;
        }
    }
    
    // Remove sentences of the same component from self.sentencesToBeReviewed
    for (size_t i = self.waitlistSentences; i < [self.sentencesToBeReviewed count]; ++i) {
        Sentence* toBeReviewed = self.sentencesToBeReviewed[i];
        
        BOOL shouldReview = NO;
        for (StructureComponent* component in toBeReviewed.usesComponents) {
            if ([self.componentsToBeReviewed containsObject:component]) {
                shouldReview = YES;
                break;
            }
        }
        if (shouldReview) {
            [newToBeReviewed addObject:toBeReviewed];
        }
    }
    self.sentencesToBeReviewed = newToBeReviewed;
    NSLog(@"Remaining sentences: %ld", self.sentencesToBeReviewed.count);
    
    // Update right words and Remove words from self.wordsToBeReviewed
    NSSet* words = sentence.usesWords;
    for (Word* word in words) {
        [self.wordsToBeReviewed removeObject:word];
        [self updateRightWord:word];
    }
}

- (void)updateWrongSentence:(Sentence*)sentence answer:(NSString*)userResponse closestCorrectAnswer:(NSString*)closestCorrectAnswer andWrongComponents:(NSArray*)wrongComponents
{
    // Check whether words are correct and update wrong words
    BOOL wordsCorrect = YES;
    NSString* simplifiedUserResponse = [self simplifiedString:userResponse];
    NSArray* userResponseWords = [simplifiedUserResponse componentsSeparatedByString:@" "];
    NSArray* sentenceWords = [sentence.usesWords allObjects];
    NSMutableArray* mutableSentenceWords = [NSMutableArray array];
    for (Word* word in sentenceWords) {
        [mutableSentenceWords addObject:[word.english lowercaseString]];
    }
    NSArray* sentenceWordsSimplified = mutableSentenceWords;
    
    // user word not in correct answer
    for (NSString* userResponseWord in userResponseWords) {
        if (! [mutableSentenceWords containsObject:userResponseWord]) {
            wordsCorrect = NO;
            NSFetchRequest* request_wrongWord = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
            request_wrongWord.predicate = [NSPredicate predicateWithFormat:@"english == %@", userResponseWord];
            NSArray* match_wrongWord = [self.context executeFetchRequest:request_wrongWord error:nil];
            if (match_wrongWord && [match_wrongWord count]) {
                for (Word* word in match_wrongWord) {
                    [self updateWrongWord:word];
                }
            }
        }
        else {
            [self updateRightWord:[sentenceWords objectAtIndex:[sentenceWordsSimplified indexOfObject:userResponseWord]]];
            [mutableSentenceWords removeObject:userResponseWord];
        }
    }
    
    // not all words in correct answer is used
    for (NSString* sentenceWord in mutableSentenceWords) {
        wordsCorrect = NO;
        [self updateWrongWord:[sentenceWords objectAtIndex:[sentenceWordsSimplified indexOfObject:sentenceWord]]];
    }
    
    
    // Determine whether structure is correct
    if (! wrongComponents || ! wrongComponents.count) {
        return;
    }
    
    // Add sentences using wrong components to self.sentencesToBeReviewed
    NSFetchRequest* request_sentences = [NSFetchRequest fetchRequestWithEntityName:@"Sentence"];
    NSString* predicateFormat = @"%@ IN usesComponents";
    for (size_t i = 1; i < wrongComponents.count; ++i) {
        predicateFormat = [predicateFormat stringByAppendingString:@" || %@ IN usesComponents"];
    }
    [NSPredicate predicateWithFormat:predicateFormat argumentArray:wrongComponents];
    request_sentences.predicate = [NSPredicate predicateWithFormat:@"%@ IN usesComponents", @"wrong component"];
    request_sentences.sortDescriptors = [NSArray arrayWithObject:
                                        [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
    NSArray* match_sentences = [self.context executeFetchRequest:request_sentences error:nil];
    for (Sentence* match in match_sentences) {
        if ([self.sentencesToBeReviewed containsObject:match]) {   // sentence already in sentencesToBeReviewed
            continue;
        }
        
        BOOL shouldAddSentence = YES;
        for (Word* word in match.usesWords) {
            NSFetchRequest* request_studentLearnedWord = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
            request_studentLearnedWord.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ AND wordID == %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"], word.uid];
            NSArray* match_studentLearnedWord = [self.context executeFetchRequest:request_studentLearnedWord error:nil];
            if (! match_studentLearnedWord || [match_studentLearnedWord count] > 1) {
                NSLog(@"ERROR: Error when fetching StudentLearnedWord with student %@ and wordID %@.", [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"], word.uid);
            }
            else if ([match_studentLearnedWord count] == 0) {   // sentence contains word that student does not know
                shouldAddSentence = NO;
                break;
            }
        }
        if (shouldAddSentence) {
            [self.sentencesToBeReviewed addObject:sentence];
            break;
        }
    }
    
    NSLog(@"Remaining sentences: %ld", self.sentencesToBeReviewed.count);
    
    // Update wrong structure
    for (StructureComponent* component in wrongComponents) {
        [self updateWrongComponent:component];
    }
}

- (void)updateRightWord:(Word*)word
{
    // Check if StudentLearnedWord exists, and create if necessary
    NSFetchRequest* request_studentLearnedWord = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
    request_studentLearnedWord.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ AND wordID == %@", self.student.username, word.uid];
    NSArray* match_studentLearnedWord = [self.context executeFetchRequest:request_studentLearnedWord error:nil];
    if (! [match_studentLearnedWord count]) {
        StudentLearnedWord* slw = [StudentLearnedWord student:self.student.username learnedWord:word.uid onDate:[DateManager today] inManagedObjectContext:self.context];
        slw.history = @"5";
        slw.strength = [NSNumber numberWithInt:100];
        slw.daysSinceLearned = [NSNumber numberWithInt:0];
        slw.testInterval = self.student.initialInterval;
        slw.nextTestDate = [DateManager dateDays:[slw.testInterval intValue] afterDate:[DateManager today]];
        
        [self.learnedWords addObject:word.uid];
        
        return;
    }
    
    
    StudentLearnedWord* slw = [match_studentLearnedWord lastObject];
    
    [self.reviewedWords addObject:word.uid];
    
    // Check if StudentLearnedWord has been updated today
    if (slw.nextTestDate == [DateManager dateDays:[slw.testInterval intValue] afterDate:[DateManager today]]) {
        int strength = [slw.strength intValue];
        NSMutableArray* history = [[slw.history componentsSeparatedByString:@"; "] mutableCopy];
        if ([[history lastObject] intValue] == 5) {   // Was correct last time
            int newStrength = (100 + strength) / 4;
            slw.strength = [NSNumber numberWithInt:newStrength];
            return;
        }
        else {   // Was incorrect last time
            int newStrength = (100 + strength) / 2;
            [history removeLastObject];
            [history addObject:[NSNumber numberWithInt:5]];
            slw.history = [history componentsJoinedByString:@"; "];
            slw.strength = [NSNumber numberWithInt:newStrength];
            return;
        }
    }
    else {   // StudentLearnedWord has not been updated today
        int strength = [slw.strength intValue];
        NSMutableArray* history = [[slw.history componentsSeparatedByString:@"; "] mutableCopy];
        int daysSinceLearned = (int)[DateManager daysFrom:slw.dateLearned to:[DateManager today]];
        for (size_t i = [history count]; i < daysSinceLearned; ++i) {
            strength = (int)(strength * [history count] / ([history count] + 1));
            [history addObject:[NSNumber numberWithInt:0]];
        }
        strength = (int)((strength * [history count] + 100) / ([history count] + 1));
        [history addObject:[NSNumber numberWithInt:5]];
        slw.history = [history componentsJoinedByString:@"; "];
        slw.strength = [NSNumber numberWithInt:strength];
        slw.daysSinceLearned = [NSNumber numberWithInt:daysSinceLearned];
        slw.testInterval = [NSNumber numberWithInt:[slw.testInterval intValue] + 1];
        slw.nextTestDate = [DateManager dateDays:[slw.testInterval intValue] afterDate:[DateManager today]];
    }
}

- (void)updateWrongWord:(Word*)word
{
    // Check if StudentLearnedWord exists, and create if necessary
    NSFetchRequest* request_studentLearnedWord = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
    request_studentLearnedWord.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ AND wordID == %@", self.student.username, word.uid];
    NSArray* match_studentLearnedWord = [self.context executeFetchRequest:request_studentLearnedWord error:nil];
    if (! [match_studentLearnedWord count]) {
        StudentLearnedWord* slw = [StudentLearnedWord student:self.student.username learnedWord:word.uid onDate:[DateManager today] inManagedObjectContext:self.context];
        slw.history = @"1";
        slw.strength = [NSNumber numberWithInt:20];
        slw.daysSinceLearned = [NSNumber numberWithInt:0];
        slw.testInterval = [NSNumber numberWithInt:1];
        slw.nextTestDate = [DateManager dateDays:1 afterDate:[DateManager today]];
        
        [self.learnedWords addObject:word.uid];
        
        return;
    }
    
    
    StudentLearnedWord* slw = [match_studentLearnedWord lastObject];
    
    [self.reviewedWords addObject:word.uid];
    
    // Check if StudentLearnedWord has been updated today
    if (slw.nextTestDate == [DateManager dateDays:[slw.testInterval intValue] afterDate:[DateManager today]]) {
        int strength = [slw.strength intValue];
        NSMutableArray* history = [[slw.history componentsSeparatedByString:@"; "] mutableCopy];
        if ([[history lastObject] intValue] == 1) {   // Was incorrect last time
            int newStrength = (20 + strength) / 4;
            slw.strength = [NSNumber numberWithInt:newStrength];
            return;
        }
        else {   // Was correct last time
            int newStrength = (20 + strength) / 2;
            [history removeLastObject];
            [history addObject:[NSNumber numberWithInt:1]];
            slw.history = [history componentsJoinedByString:@"; "];
            slw.strength = [NSNumber numberWithInt:newStrength];
            return;
        }
    }
    else {   // StudentLearnedWord has not been updated today
        int strength = [slw.strength intValue];
        NSMutableArray* history = [[slw.history componentsSeparatedByString:@"; "] mutableCopy];
        int daysSinceLearned = (int)[DateManager daysFrom:slw.dateLearned to:[DateManager today]];
        for (size_t i = [history count]; i < daysSinceLearned; ++i) {
            strength = (int)(strength * [history count] / ([history count] + 1));
            [history addObject:[NSNumber numberWithInt:0]];
        }
        strength = (int)((strength * [history count] + 20) / ([history count] + 1));
        [history addObject:[NSNumber numberWithInt:1]];
        slw.history = [history componentsJoinedByString:@"; "];
        slw.strength = [NSNumber numberWithInt:strength];
        slw.daysSinceLearned = [NSNumber numberWithInt:daysSinceLearned];
        slw.testInterval = [NSNumber numberWithInt:1];
        slw.nextTestDate = [DateManager dateDays:1 afterDate:[DateManager today]];
    }
}

- (void)updateRightComponent:(StructureComponent*)component
{
    // Check if StudentLearnedStructure exists, and create if necessary
    NSFetchRequest* request_studentLearnedComponent = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedComponent"];
    request_studentLearnedComponent.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ AND componentID == %@", self.student.username, component.uid];
    NSArray* match_studentLearnedComponent = [self.context executeFetchRequest:request_studentLearnedComponent error:nil];
    if (! [match_studentLearnedComponent count]) {
        StudentLearnedComponent* slc = [StudentLearnedComponent student:self.student.username learnedComponent:component.uid onDate:[DateManager today] inManagedObjectContext:self.context];
        slc.history = @"5";
        slc.strength = [NSNumber numberWithInt:100];
        slc.daysSinceLearned = [NSNumber numberWithInt:0];
        slc.testInterval = self.student.initialInterval;
        slc.nextTestDate = [DateManager dateDays:[slc.testInterval intValue] afterDate:[DateManager today]];
        
        [self.learnedComponents addObject:component.uid];
        
        return;
    }
    
    
    StudentLearnedComponent* slc = [match_studentLearnedComponent lastObject];
    
    [self.reviewedComponents addObject:component.uid];
    
    // Check if StudentLearnedComponent has been updated today
    if (slc.nextTestDate == [DateManager dateDays:[slc.testInterval intValue] afterDate:[DateManager today]]) {
        int strength = [slc.strength intValue];
        NSMutableArray* history = [[slc.history componentsSeparatedByString:@"; "] mutableCopy];
        if ([[history lastObject] intValue] == 5) {   // Was correct last time
            int newStrength = (100 + strength) / 4;
            slc.strength = [NSNumber numberWithInt:newStrength];
            return;
        }
        else {   // Was incorrect last time
            int newStrength = (100 + strength) / 2;
            [history removeLastObject];
            [history addObject:[NSNumber numberWithInt:5]];
            slc.history = [history componentsJoinedByString:@"; "];
            slc.strength = [NSNumber numberWithInt:newStrength];
            return;
        }
    }
    
    // StudentLearnedStructure has not been updated today
    int strength = [slc.strength intValue];
    NSMutableArray* history = [[slc.history componentsSeparatedByString:@"; "] mutableCopy];
    int daysSinceLearned = (int)[DateManager daysFrom:slc.dateLearned to:[DateManager today]];
    for (size_t i = [history count]; i < daysSinceLearned; ++i) {
        strength = (int)(strength * [history count] / ([history count] + 1));
        [history addObject:[NSNumber numberWithInt:0]];
    }
    strength = (int)((strength * [history count] + 100) / ([history count] + 1));
    [history addObject:[NSNumber numberWithInt:5]];
    slc.history = [history componentsJoinedByString:@"; "];
    slc.strength = [NSNumber numberWithInt:strength];
    slc.daysSinceLearned = [NSNumber numberWithInt:daysSinceLearned];
    slc.testInterval = [NSNumber numberWithInt:[slc.testInterval intValue] + 1];
    slc.nextTestDate = [DateManager dateDays:[slc.testInterval intValue] afterDate:[DateManager today]];
}

- (void)updateWrongComponent:(StructureComponent*)component
{
    // Check if StudentLearnedComponent exists, and create if necessary
    NSFetchRequest* request_studentLearnedComponent = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedComponent"];
    request_studentLearnedComponent.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ AND componentID == %@", self.student.username, component.uid];
    NSArray* match_studentLearnedComponent = [self.context executeFetchRequest:request_studentLearnedComponent error:nil];
    if (! [match_studentLearnedComponent count]) {
        StudentLearnedComponent* slc = [StudentLearnedComponent student:self.student.username learnedComponent:component.uid onDate:[DateManager today] inManagedObjectContext:self.context];
        slc.history = @"1";
        slc.strength = [NSNumber numberWithInt:20];
        slc.daysSinceLearned = [NSNumber numberWithInt:0];
        slc.testInterval = [NSNumber numberWithInt:1];
        slc.nextTestDate = [DateManager dateDays:[slc.testInterval intValue] afterDate:[DateManager today]];
        
        [self.learnedComponents addObject:component.uid];
        
        return;
    }
    
    
    StudentLearnedComponent* slc = [match_studentLearnedComponent lastObject];
    
    [self.reviewedComponents addObject:component.uid];
    
    // Check if StudentLearnedComponent has been updated today
    if (slc.nextTestDate == [DateManager dateDays:[slc.testInterval intValue] afterDate:[DateManager today]]) {
        int strength = [slc.strength intValue];
        NSMutableArray* history = [[slc.history componentsSeparatedByString:@"; "] mutableCopy];
        if ([[history lastObject] intValue] == 1) {   // Was incorrect last time
            int newStrength = (20 + strength) / 4;
            slc.strength = [NSNumber numberWithInt:newStrength];
            return;
        }
        else {   // Was correct last time
            int newStrength = (20 + strength) / 2;
            [history removeLastObject];
            [history addObject:[NSNumber numberWithInt:1]];
            slc.history = [history componentsJoinedByString:@"; "];
            slc.strength = [NSNumber numberWithInt:newStrength];
            return;
        }
    }
    
    // StudentLearnedStructure has not been updated today
    int strength = [slc.strength intValue];
    NSMutableArray* history = [[slc.history componentsSeparatedByString:@"; "] mutableCopy];
    int daysSinceLearned = (int)[DateManager daysFrom:slc.dateLearned to:[DateManager today]];
    for (size_t i = [history count]; i < daysSinceLearned; ++i) {
        strength = (int)(strength * [history count] / ([history count] + 1));
        [history addObject:[NSNumber numberWithInt:0]];
    }
    strength = (int)((strength * [history count] + 20) / ([history count] + 1));
    [history addObject:[NSNumber numberWithInt:1]];
    slc.history = [history componentsJoinedByString:@"; "];
    slc.strength = [NSNumber numberWithInt:strength];
    slc.daysSinceLearned = [NSNumber numberWithInt:daysSinceLearned];
    slc.testInterval = [NSNumber numberWithInt:[slc.testInterval intValue] + 1];
    slc.nextTestDate = [DateManager dateDays:[slc.testInterval intValue] afterDate:[DateManager today]];
}


#pragma mark - Sync to Bmob

- (void)syncToBmob
{
    [self sortReviewedAndLearnedWordsAndComponents];
    
    [self syncStudentInfo];
    [self syncStudentDidExercise];
    [self syncStudentLearnedWord];
    [self syncStudentLearnedComponent];
}

- (void)sortReviewedAndLearnedWordsAndComponents
{
    [self.learnedWords sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    [self.reviewedWords sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    [self.learnedComponents sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    [self.reviewedComponents sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
}

- (void)syncStudentInfo
{
//    NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
//    BmobQuery* query_studentInfo = [BmobQuery queryWithClassName:@"StudentInfo"];
//    [query_studentInfo whereKey:@"studentUsername" equalTo:username];
//    [query_studentInfo findObjectsInBackgroundWithBlock:^(NSArray* match, NSError* error){
//        if (error) {
//            NSLog(@"ERROR: Error when fetching StudentInfo; msg: %@", error.description);
//        }
//        else if (! match.count) {   // no entry exists
//            NSLog(@"ERROR: Can't find StudentInfo in Bmob for student: %@", username);
//        }
//        else {   // entry exists
//            BmobObject* info = [match lastObject];
//            NSInteger previousTotalActiveDays = [[info objectForKey:@"totalActiveDays"] integerValue];
//            NSInteger previousConsecutiveActiveDays = [[info objectForKey:@"consecutiveActiveDays"] integerValue];
//            NSDate* lastActiveDay = [info objectForKey:@"lastActiveDay"];
//            
//            if (lastActiveDay == [DateManager today]) {   // already active today
//                NSLog(@"Updated StudentInfo in Bmob");
//                return;
//            }
//            else if (lastActiveDay == [DateManager dateDays:-1 afterDate:[DateManager today]]) {   // was active yesterday
//                [info setObject:[NSNumber numberWithInteger:previousConsecutiveActiveDays + 1] forKey:@"consecutiveActiveDays"];
//            }
//            else {
//                [info setObject:[NSNumber numberWithInteger:1] forKey:@"consecutiveActiveDays"];
//            }
//            
//            [info setObject:[DateManager today] forKey:@"lastActiveDay"];
//            [info setObject:[NSNumber numberWithInteger:previousTotalActiveDays + 1] forKey:@"totalActiveDays"];
//            
//            
//            [info updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError* error){
//                if (isSuccessful) {
//                    NSLog(@"Updated StudentInfo in Bmob");
//                }
//                else {
//                    NSLog(@"ERROR: Failed to update StudentInfo in Bmob; msg: %@", error.description);
//                }
//            }];
//        }
//    }];
}

- (void)syncStudentDidExercise
{
//    BmobObject* studentDidExercise = [BmobObject objectWithClassName:@"StudentDidExercise"];
//    [studentDidExercise setObject:[DateManager today] forKey:@"date"];
//    
//    if ([self.exerciseName isEqualToString:@"Review"]) {
//        [studentDidExercise setObject:[NSNumber numberWithBool:YES] forKey:@"isReview"];
//        [studentDidExercise setObject:[NSNumber numberWithInteger:[[DateManager nowString] integerValue]] forKey:@"exerciseUid"];
//    }
//    else {
//        [studentDidExercise setObject:[NSNumber numberWithBool:NO] forKey:@"isReview"];
//        [studentDidExercise setObject:self.exercise.uid forKey:@"exerciseUid"];
//        
//        [studentDidExercise setObject:[self.learnedWords componentsJoinedByString:@", "] forKey:@"learnedWords"];
//        [studentDidExercise setObject:[self.learnedComponents componentsJoinedByString:@", "] forKey:@"learnedComponents"];
//    }
//    
//    [studentDidExercise setObject:[self.reviewedWords componentsJoinedByString:@", "] forKey:@"reviewedWords"];
//    [studentDidExercise setObject:[self.reviewedComponents componentsJoinedByString:@", "] forKey:@"reviewedComponents"];
//    
//    // NEED TO CHANGE! Difficult words
//    [studentDidExercise setObject:nil forKey:@"difficultWords"];
//    
//    
//    [studentDidExercise saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError* error){
//        if (isSuccessful) {
//            NSLog(@"Saved StudentDidExercise in Bmob");
//        }
//        else {
//            NSLog(@"ERROR: Failed to save StudentDidExercise in Bmob; msg: %@", error.description);
//        }
//    }];
}

- (void)syncStudentLearnedWord
{
//    NSError* err = nil;
//    NSString* studentUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
//    NSFetchRequest* request_allSlw = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
//    request_allSlw.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@", studentUsername];
//    request_allSlw.propertiesToFetch = [NSArray arrayWithObject:@"wordID"];
//    request_allSlw.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"wordID" ascending:YES]];
//    NSArray* match_allSlw = [self.context executeFetchRequest:request_allSlw error:&err];
//    NSMutableArray* allSlwID = [NSMutableArray arrayWithCapacity:match_allSlw.count];
//    for (StudentLearnedWord* studentLearnedWord in match_allSlw) {
//        [allSlwID addObject:studentLearnedWord.wordID];
//    }
//    
//    BmobQuery* query_slw = [BmobQuery queryWithClassName:@"StudentLearnedWord"];
//    [query_slw whereKey:@"studentUsername" equalTo:studentUsername];
//    [query_slw whereKey:@"date" equalTo:[DateManager today]];
//    [query_slw findObjectsInBackgroundWithBlock:^(NSArray* match, NSError* error){
//        if (error) {
//            NSLog(@"ERROR: Error when fetching StudentLearnedWord; msg: %@", error.description);
//        }
//        else if (match.count) {   // entry exists for today
//            BmobObject* slw = [match lastObject];
//            
//            NSMutableSet* learnedWordsSet = [NSMutableSet setWithArray:self.learnedWords];
//            NSString* oldLearnedWords = [slw objectForKey:@"dailyNewWords"];
//            for (NSString* obj in [oldLearnedWords componentsSeparatedByString:@", "]) {
//                [learnedWordsSet addObject:[NSNumber numberWithInteger:obj.integerValue]];
//            }
//            NSArray* newLearnedWords = [[learnedWordsSet allObjects] sortedArrayUsingDescriptors:
//                                        [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
//            
//            [slw setObject:[newLearnedWords componentsJoinedByString:@", "] forKey:@"dailyNewWords"];
//            [slw setObject:[NSNumber numberWithInteger:newLearnedWords.count] forKey:@"dailyNewWordsCount"];
//            [slw setObject:[allSlwID componentsJoinedByString:@", "] forKey:@"allWords"];
//            [slw setObject:[NSNumber numberWithInteger:allSlwID.count] forKey:@"allWordsCount"];
//            
//            [slw updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError* error){
//                if (isSuccessful) {
//                    NSLog(@"Updated StudentLearnedWord in Bmob");
//                }
//                else {
//                    NSLog(@"ERROR: Failed to update StudentLearnedWord in Bmob; msg: %@", error.description);
//                }
//            }];
//        }
//        else {   // no entry exists for today
//            BmobObject* slw = [BmobObject objectWithClassName:@"StudentLearnedWord"];
//            [slw setObject:studentUsername forKey:@"studentUsername"];
//            [slw setObject:[DateManager today] forKey:@"date"];
//            [slw setObject:[self.learnedWords componentsJoinedByString:@", "] forKey:@"dailyNewWords"];
//            [slw setObject:[NSNumber numberWithInteger:self.learnedWords.count] forKey:@"dailyNewWordsCount"];
//            [slw setObject:[allSlwID componentsJoinedByString:@", "] forKey:@"allWords"];
//            [slw setObject:[NSNumber numberWithInteger:allSlwID.count] forKey:@"allWordsCount"];
//            
//            [slw saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError* error){
//                if (isSuccessful) {
//                    NSLog(@"Saved StudentLearnedWord in Bmob");
//                }
//                else {
//                    NSLog(@"ERROR: Failed to save StudentLearnedWord in Bmob; msg: %@", error.description);
//                }
//            }];
//        }
//    }];
}

- (void)syncStudentLearnedComponent
{
//    NSError* err = nil;
//    NSString* studentUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
//    NSFetchRequest* request_allSlc = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedComponent"];
//    request_allSlc.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@", studentUsername];
//    request_allSlc.propertiesToFetch = [NSArray arrayWithObject:@"componentID"];
//    request_allSlc.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"componentID" ascending:YES]];
//    NSArray* match_allSlc = [self.context executeFetchRequest:request_allSlc error:&err];
//    NSMutableArray* allSlcID = [NSMutableArray arrayWithCapacity:match_allSlc.count];
//    for (StudentLearnedComponent* studentLearnedComponent in match_allSlc) {
//        [allSlcID addObject:studentLearnedComponent.componentID];
//    }
//    
//    BmobQuery* query_slc = [BmobQuery queryWithClassName:@"StudentLearnedComponent"];
//    [query_slc whereKey:@"studentUsername" equalTo:studentUsername];
//    [query_slc whereKey:@"date" equalTo:[DateManager today]];
//    [query_slc findObjectsInBackgroundWithBlock:^(NSArray* match, NSError* error){
//        if (error) {
//            NSLog(@"ERROR: Error when fetching StudentLearnedComponent; msg: %@", error.description);
//        }
//        else if (match.count) {   // entry exists for today
//            BmobObject* slc = [match lastObject];
//            
//            NSMutableSet* learnedComponentsSet = [NSMutableSet setWithArray:self.learnedComponents];
//            NSString* oldLearnedComponents = [slc objectForKey:@"dailyNewComponents"];
//            for (NSString* obj in [oldLearnedComponents componentsSeparatedByString:@", "]) {
//                [learnedComponentsSet addObject:[NSNumber numberWithInteger:obj.integerValue]];
//            }
//            NSArray* newLearnedComponents = [[learnedComponentsSet allObjects] sortedArrayUsingDescriptors:
//                                             [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
//            
//            [slc setObject:[newLearnedComponents componentsJoinedByString:@", "] forKey:@"dailyNewComponents"];
//            [slc setObject:[NSNumber numberWithInteger:newLearnedComponents.count] forKey:@"dailyNewComponentsCount"];
//            [slc setObject:[allSlcID componentsJoinedByString:@", "] forKey:@"allComponents"];
//            [slc setObject:[NSNumber numberWithInteger:allSlcID.count] forKey:@"allComponentsCount"];
//            
//            [slc updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError* error){
//                if (isSuccessful) {
//                    NSLog(@"Updated StudentLearnedComponent in Bmob");
//                }
//                else {
//                    NSLog(@"ERROR: Failed to update StudentLearnedComponent in Bmob; msg: %@", error.description);
//                }
//            }];
//        }
//        else {   // no entry exists for today
//            BmobObject* slc = [BmobObject objectWithClassName:@"StudentLearnedComponent"];
//            [slc setObject:studentUsername forKey:@"studentUsername"];
//            [slc setObject:[DateManager today] forKey:@"date"];
//            [slc setObject:[self.learnedComponents componentsJoinedByString:@", "] forKey:@"dailyNewComponents"];
//            [slc setObject:[NSNumber numberWithInteger:self.learnedComponents.count] forKey:@"dailyNewComponentsCount"];
//            [slc setObject:[allSlcID componentsJoinedByString:@", "] forKey:@"allComponents"];
//            [slc setObject:[NSNumber numberWithInteger:allSlcID.count] forKey:@"allComponentsCount"];
//            
//            [slc saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError* error){
//                if (isSuccessful) {
//                    NSLog(@"Saved StudentLearnedComponent in Bmob");
//                }
//                else {
//                    NSLog(@"ERROR: Failed to save StudentLearnedComponent in Bmob; msg: %@", error.description);
//                }
//            }];
//        }
//    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Exercise Results"]) {
        [segue.destinationViewController setContext:self.context];
        [segue.destinationViewController setCorrectProblemsCount:self.correctProblemsCount];
        [segue.destinationViewController setIncorrectProblemsCount:self.incorrectProblemsCount];
    }
    else if ([segue.identifier isEqualToString:@"View Database"]) {
        [segue.destinationViewController setContext:self.context];
        [segue.destinationViewController setStudent:self.student];
    }
}


@end
