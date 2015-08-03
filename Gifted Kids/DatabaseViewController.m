//
//  DatabaseViewController.m
//  Gifted Kids
//
//  Created by Yi Li on 6/16/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "DatabaseViewController.h"
#import "StudentLearnedWord.h"
#import "StudentLearnedComponent.h"
#import "Word.h"
#import "StructureComponent.h"

#import "DateManager.h"


@interface DatabaseViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end


@implementation DatabaseViewController

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
    
    [self loadReport];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadReport
{
    NSMutableArray* report = [NSMutableArray array];
    NSMutableArray* words = [NSMutableArray array];
    NSMutableArray* components = [NSMutableArray array];
    
    NSString* username = self.student.username;
    
    // Get words
    NSFetchRequest* request_learnedWord = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedWord"];
    request_learnedWord.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@", username];
    request_learnedWord.sortDescriptors = [NSArray arrayWithObject:
                                           [NSSortDescriptor sortDescriptorWithKey:@"wordID" ascending:YES]];
    NSError* error = nil;
    NSArray* match_learnedWord = [self.context executeFetchRequest:request_learnedWord error:&error];
    for (StudentLearnedWord* slw in match_learnedWord) {
        NSNumber* wordID = slw.wordID;
        NSFetchRequest* request_word = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
        request_word.predicate = [NSPredicate predicateWithFormat:@"uid == %@", wordID];
        NSArray* match_word = [self.context executeFetchRequest:request_word error:&error];
        Word* word = [match_word lastObject];
        [words addObject:[NSString stringWithFormat:@"%@, %@, %@~%@ (%@), %@, (%@)", wordID, word.english, [DateManager stringWithDate:slw.dateLearned], [DateManager stringWithDate:slw.nextTestDate], slw.testInterval, slw.strength, slw.history]];
    }
    
    // Get structure components
    NSFetchRequest* request_learnedComponent = [NSFetchRequest fetchRequestWithEntityName:@"StudentLearnedComponent"];
    request_learnedComponent.predicate = [NSPredicate predicateWithFormat:@"studentUsername == %@", username];
    request_learnedComponent.sortDescriptors = [NSArray arrayWithObject:
                                                [NSSortDescriptor sortDescriptorWithKey:@"structureID" ascending:YES]];
    NSArray* match_learnedComponent = [self.context executeFetchRequest:request_learnedComponent error:&error];
    for (StudentLearnedComponent* slc in match_learnedComponent) {
        NSNumber* componentID = slc.componentID;
        NSFetchRequest* request_component = [NSFetchRequest fetchRequestWithEntityName:@"Component"];
        request_component.predicate = [NSPredicate predicateWithFormat:@"uid == %@", componentID];
        NSArray* match_component = [self.context executeFetchRequest:request_component error:&error];
        StructureComponent* component = [match_component lastObject];
        [components addObject:[NSString stringWithFormat:@"%@, %@, %@~%@ (%@), %@, (%@)", componentID, component.name, [DateManager stringWithDate:slc.dateLearned], [DateManager stringWithDate:slc.nextTestDate], slc.testInterval, slc.strength, slc.history]];
    }
    
    
    [report addObject:@"id, name, dateLearned ~ nextTestDate (interval), strength, (history)"];
    [report addObjectsFromArray:words];
    [report addObjectsFromArray:components];
    
    
    // Show report
    self.textView.text = [report componentsJoinedByString:@"\n"];
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
