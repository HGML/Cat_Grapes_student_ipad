//
//  ExerciseResultsViewController.m
//  Gifted Kids
//
//  Created by 李诣 on 5/28/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "ExerciseResultsViewController.h"
#import "DateManager.h"

#import "Word.h"
#import "StructureComponent.h"
#import "StudentLearnedWord.h"
#import "StudentLearnedComponent.h"


@interface ExerciseResultsViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end


@implementation ExerciseResultsViewController

@synthesize context = _context;

@synthesize textView = _textView;


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
    
    
    // Back button
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed)];
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    [self loadReport];
    
//    // Report
//    NSArray* match = [self.dbManager executeQuery:
//                      [NSString stringWithFormat:@"SELECT wid, nextTestDate, testInterval, history FROM LearnedWord WHERE sid = %d", self.studentID]];
//    self.textView.text = [match componentsJoinedByString:@"\n"];
}

- (void)backButtonPressed
{
    UIViewController* destination = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popToViewController:destination animated:YES];
}

//
//@property (nonatomic, retain) NSDate * dateLearned;
//@property (nonatomic, retain) NSNumber * daysSinceLearned;
//@property (nonatomic, retain) NSString * history;
//@property (nonatomic, retain) NSDate * nextTestDate;
//@property (nonatomic, retain) NSNumber * strength;
//@property (nonatomic, retain) NSString * studentUsername;
//@property (nonatomic, retain) NSNumber * testInterval;
//@property (nonatomic, retain) NSNumber * wordID;

- (void)loadReport
{
    NSMutableArray* report = [NSMutableArray array];
    NSMutableArray* words = [NSMutableArray array];
    NSMutableArray* structures = [NSMutableArray array];
    
    // Problem Result Counts
    size_t correctProblems = self.correctProblemsCount;
    size_t incorrectProblems = self.incorrectProblemsCount;
    size_t totalProblems = correctProblems + incorrectProblems;
    [report addObject:[NSString stringWithFormat:@"Problems\nCorrect: %zu/%zu (%.2f%%); Incorrect: %zu/%zu (%.2f%%)\n", correctProblems, totalProblems, (double)correctProblems/totalProblems*100, incorrectProblems, totalProblems, (double)incorrectProblems/totalProblems*100]];
    
    // Word Result Counts
    size_t correctWords = 0;
    size_t incorrectWords = 0;
    size_t totalWords = 0;
    
    // Structure Result Counts
    size_t correctStructures = 0;
    size_t incorrectStructures = 0;
    size_t totalStructures = 0;
    
    
    NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
    
    // Get words
    NSFetchRequest* request_learnedWord = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
    request_learnedWord.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@", username];
    request_learnedWord.sortDescriptors = [NSArray arrayWithObject:
                                    [NSSortDescriptor sortDescriptorWithKey:@"wordID" ascending:YES]];
    NSError* error = nil;
    NSArray* match_learnedWord = [self.context executeFetchRequest:request_learnedWord error:&error];
    for (StudentLearnedWord* slw in match_learnedWord) {
        if (! [slw.nextTestDate isEqualToDate:[DateManager dateDays:[slw.testInterval intValue] afterDate:[DateManager today]]]) {
            continue;
        }
        
        NSNumber* wordID = slw.wordID;
        NSFetchRequest* request_word = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
        request_word.predicate = [NSPredicate predicateWithFormat:@"uid == %@", wordID];
        NSArray* match_word = [self.context executeFetchRequest:request_word error:&error];
        Word* word = [match_word lastObject];
        
        ++ totalWords;
        if ([[[slw.history componentsSeparatedByString:@"; "] lastObject] intValue] == 5) {
            ++ correctWords;
        }
        else {
            ++ incorrectWords;
        }
        
        [words addObject:[NSString stringWithFormat:@"%@, %@, %@~%@ (%@), %@, (%@)", wordID, word.english, [DateManager stringWithDate:slw.dateLearned], [DateManager stringWithDate:slw.nextTestDate], slw.testInterval, slw.strength, slw.history]];
    }
    
    // Get structure components
    NSFetchRequest* request_learnedComponent = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedComponent"];
    request_learnedComponent.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@", username];
    request_learnedComponent.sortDescriptors = [NSArray arrayWithObject:
                                           [NSSortDescriptor sortDescriptorWithKey:@"componentID" ascending:YES]];
    NSArray* match_learnedComponent = [self.context executeFetchRequest:request_learnedComponent error:&error];
    for (StudentLearnedComponent* slc in match_learnedComponent) {
        if (! [slc.nextTestDate isEqualToDate:[DateManager dateDays:[slc.testInterval intValue] afterDate:[DateManager today]]]) {
            continue;
        }
        
        NSNumber* componentID = slc.componentID;
        NSFetchRequest* request_component = [NSFetchRequest fetchRequestWithEntityName:@"StructureComponent"];
        request_component.predicate = [NSPredicate predicateWithFormat:@"uid == %@", componentID];
        NSArray* match_component = [self.context executeFetchRequest:request_component error:&error];
        StructureComponent* component = [match_component lastObject];
        
        ++ totalStructures;
        if ([[[slc.history componentsSeparatedByString:@"; "] lastObject] intValue] == 5) {
            ++ correctStructures;
        }
        else {
            ++ incorrectStructures;
        }
        
        [structures addObject:[NSString stringWithFormat:@"%@, %@, %@~%@ (%@), %@, (%@)", componentID, component.name, [DateManager stringWithDate:slc.dateLearned], [DateManager stringWithDate:slc.nextTestDate], slc.testInterval, slc.strength, slc.history]];
    }
    
    
    [report addObject:[NSString stringWithFormat:@"Words\nCorrect: %zu/%zu (%.2f%%); Incorrect: %zu/%zu (%.2f%%)\n", correctWords, totalWords, (double)correctWords/totalWords*100, incorrectWords, totalWords, (double)incorrectWords/totalWords*100]];
    [report addObject:[NSString stringWithFormat:@"Structures\nCorrect: %zu/%zu (%.2f%%); Incorrect: %zu/%zu (%.2f%%)\n", correctStructures, totalStructures, (double)correctStructures/totalStructures*100, incorrectStructures, totalStructures, (double)incorrectStructures/totalStructures*100]];
    
    
    [report addObject:@"id, name, dateLearned ~ nextTestDate (interval), strength, (history)"];
    [report addObjectsFromArray:words];
    [report addObjectsFromArray:structures];
    
    
    // Get New Words
    NSFetchRequest* request_newWord = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
    request_newWord.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ AND dateLearned == %@", username, [DateManager today]];
    request_newWord.sortDescriptors = [NSArray arrayWithObject:
                                           [NSSortDescriptor sortDescriptorWithKey:@"wordID" ascending:YES]];
    NSArray* match_newWord = [self.context executeFetchRequest:request_newWord error:&error];
    size_t newWords = match_newWord ? (size_t)[match_newWord count] : 0;
    
    // Get New Components
    NSFetchRequest* request_newComponent = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedComponent"];
    request_newComponent.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@ AND dateLearned == %@", username, [DateManager today]];
    request_newComponent.sortDescriptors = [NSArray arrayWithObject:
                                                [NSSortDescriptor sortDescriptorWithKey:@"componentID" ascending:YES]];
    NSArray* match_newComponent = [self.context executeFetchRequest:request_newComponent error:&error];
    size_t newComponents = match_newComponent ? (size_t)[match_newComponent count] : 0;
    
    if (newWords && newComponents) {
        [report addObject:[NSString stringWithFormat:@"Learned %zu new words and %zu new components", newWords, newComponents]];
    }
    else if (newWords) {
        [report addObject:[NSString stringWithFormat:@"Learned %zu new words", newWords]];
    }
    else if (newComponents) {
        [report addObject:[NSString stringWithFormat:@"Learned %zu new components", newComponents]];
    }
    
    size_t oldWords = totalWords - newWords;
    size_t oldComponents = totalStructures - newComponents;
    if (oldWords && oldComponents) {
        [report addObject:[NSString stringWithFormat:@"Reviewed %zu words and %zu components", oldWords, oldComponents]];
    }
    else if (oldWords) {
        [report addObject:[NSString stringWithFormat:@"Reviewed %zu words", oldWords]];
    }
    else if (oldComponents) {
        [report addObject:[NSString stringWithFormat:@"Reviewed %zu components", oldComponents]];
    }
    
    
    // Show report
    self.textView.text = [report componentsJoinedByString:@"\n"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
