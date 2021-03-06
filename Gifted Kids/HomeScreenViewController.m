//
//  HomeScreenViewController.m
//  Gifted Kids
//
//  Created by 李诣 on 5/15/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "HomeScreenViewController.h"

#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Student.h"
#import "Unit+Add.h"
#import "Video+Add.h"
#import "Exercise+Add.h"

#import "UnitCollectionViewCell.h"
#import "VideoCollectionViewCell.h"
#import "ExerciseCollectionViewCell.h"
#import "UnitFooterView.h"

#import "SignUpLogInViewController.h"
#import "VideoPlayerViewController.h"
#import "ExerciseViewController.h"

#import "DateManager.h"
#import "AFNetworkManager.h"

#import "StudentLearnedWord.h"
#import "StudentLearnedComponent.h"


@interface HomeScreenViewController ()

@property (strong, nonatomic) Student* student;

@end


@implementation HomeScreenViewController

@synthesize context = _context;

@synthesize units = _units;

@synthesize student = _student;


- (void)setUnits:(NSArray *)units
{
    if (_units != units) {
        _units = units;
        [self.collectionView reloadData];
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
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    
    self.navigationItem.title = @"课程";
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
//    [self fetchAllStudents];
}

//- (void)fetchAllStudents
//{
//    dispatch_async(dispatch_get_main_queue(), ^(void){
//        NSFetchRequest* request_students = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
//        NSError* error = nil;
//        NSArray* match_students = [self.context executeFetchRequest:request_students error:&error];
//        if (! match_students) {
//            NSLog(@"ERROR: Error when fetching students");
//        }
//        else {
//            NSLog(@"Students: %d", (int)match_students.count);
//        }
//    });
//}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
//    NSError* error = nil;
//    NSFetchRequest* request_words = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
//    request_words.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
//    NSArray* match_words = [self.context executeFetchRequest:request_words error:&error];
//    NSLog(@"%ld words in database", match_words.count);
//    
//    NSFetchRequest* request_components = [NSFetchRequest fetchRequestWithEntityName:@"StructureComponent"];
//    request_components.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
//    NSArray* match_components = [self.context executeFetchRequest:request_components error:&error];
//    NSLog(@"%ld components in database", match_components.count);
//    
//    NSFetchRequest* request_sentences = [NSFetchRequest fetchRequestWithEntityName:@"Sentence"];
//    request_sentences.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
//    NSArray* match_sentences = [self.context executeFetchRequest:request_sentences error:&error];
//    NSLog(@"%ld sentences in database", match_sentences.count);
    
    [self getUser];
    
//    if (self.student && ! self.units) {
//        [self setLearnedUnits];
//    }
}

- (void)getUser
{
    NSString* email = [[NSUserDefaults standardUserDefaults] objectForKey:@"StudentEmail"];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* serverLoggedIn = [userDefaults objectForKey:@"ServerLoggedIn"];
    
    if (! email) {
        [self performSegueWithIdentifier:@"Sign Up Log In" sender:self];
    }
    else if (! serverLoggedIn.boolValue) {
        // Package all the paras in a student field
        NSDictionary *parameters = @{@"student":@{@"email":[userDefaults objectForKey:@"StudentEmail"],
                                                  @"password":[userDefaults objectForKey:@"StudentPassword"]}
                                     };
        
        // Send a POST request to back-end server to log in student user
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:@LOGIN_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Server response object: %@", responseObject);
            
            if([responseObject[@"status"]  isEqual: (@"Login Failure")])
            {
                NSLog(@"Server: No student account exists with email %@ and password %@.",
                      [userDefaults objectForKey:@"StudentEmail"], [userDefaults objectForKey:@"StudentPassword"]);
                
                [self performSegueWithIdentifier:@"Sign Up Log In" sender:self];
                return;
            }
            else if([responseObject[@"status"]  isEqual: (@"Login Success")])
            {
                NSLog(@"Server: Logged in successfully!");
                
                // Save student email to UserDefaults
                NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"ServerLoggedIn"];
                [userDefaults synchronize];
                NSLog(@"Local: Logged In");
                
                // Request latest data from server
                [self getLatestDataFromServer];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    else {
//        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
//        request.predicate = [NSPredicate predicateWithFormat:@"email == %@", email];
//        NSError* error = nil;
//        NSArray* match = [self.context executeFetchRequest:request error:&error];
//        if (! match || [match count] > 1) {
//            NSLog(@"ERROR: Error when fetching students");
//        }
//        else if ([match count] == 0) {
//            NSLog(@"ERROR: No user exists with email %@", email);
//            NSLog(@"Please log in or sign up.");
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserEmail"];
//            [self performSegueWithIdentifier:@"Sign Up Log In" sender:self];
//        }
//        else {
//            self.student = [match lastObject];
//            NSLog(@"Logged in for student %@", self.student.username);
//            
//            [self getUnits];
//        }
        
        [self getLatestDataFromServer];
    }
}

- (void)getLatestDataFromServer
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    NSDate* lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastUpdateDate"];
    
    // Request current Student Records
    [manager GET:@GET_STUDENT_RECORDS_URL parameters:nil
         success:^(AFHTTPRequestOperation* operation, id responseObject) {
             NSLog(@"SERVER Success: got current Student Records");
             
             id studentRecord = responseObject[@"current_record"];
             NSNumber* bookID = studentRecord[@"book_id"];
             NSNumber* unitID = studentRecord[@"unit_id"];
             NSNumber* caseID = studentRecord[@"case_id"];
             
             // Request resources (Words, Components, and Sentences) for current case
             NSDictionary *caseInfo = @{@"caseInfo":@{@"book_id":bookID,
                                                      @"unit_number":unitID,
                                                      @"case_number":caseID}
                                        };
             [manager GET:@GET_CASE_RESOURCES_URL parameters:caseInfo
                  success:^(AFHTTPRequestOperation* operation, id responseObject) {
                      NSLog(@"SERVER Success: got resources for current case");
                  }
                  failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                      NSLog(@"SERVER Failed to get resources for current case; Error: %@", error);
                  }];
         }
         failure:^(AFHTTPRequestOperation* operation, NSError* error) {
             NSLog(@"SERVER Failed to get current Student Records; Error: %@", error);
         }];
    
    // Request updated StudentLearnedWords and StudentLearnedComponents
    [manager GET:@GET_STUDENT_LEARNED_WORDS_URL parameters:lastUpdateDate
         success:^(AFHTTPRequestOperation* operation, id responseObject) {
             NSLog(@"SERVER Success: got updated StudentLearnedWords");
         }
         failure:^(AFHTTPRequestOperation* operation, NSError* error) {
             NSLog(@"SERVER Failed to get updated StudentLearnedWords; Error: %@", error);
         }];
    [manager GET:@GET_STUDENT_LEARNED_COMPONENTS_URL parameters:lastUpdateDate
         success:^(AFHTTPRequestOperation* operation, id responseObject) {
             NSLog(@"SERVER Success: got updated StudentLearnedComponents");
         }
         failure:^(AFHTTPRequestOperation* operation, NSError* error) {
             NSLog(@"SERVER Failed to get current StudentLearnedComponents; Error: %@", error);
         }];
    
    
    // Update LastGetDate
    [[NSUserDefaults standardUserDefaults] setObject:[DateManager now] forKey:@"LastGetDate"];
    
    // Update records to server (TEST PURPOSES ONLY!)
    [self writeTestRecordsToServer];
}

- (void)writeTestRecordsToServer
{
//    [self addStudentLearnedWordsToServer];
//    [self updateStudentLearnedWordsToServer];
    [self addStudentLearnedComponentsToServer];
//    [self updateStudentLearnedComponentsToServer];
    
    // Update LastUpdateDate
    // SHOULD ONLY UPDATE IF ALL RESQUESTS SUCCEEDED
    [[NSUserDefaults standardUserDefaults] setObject:[DateManager now] forKey:@"LastUpdateDate"];
}

- (void)addStudentLearnedWordsToServer
{
    // Package all the parameters in a learnedWords field
    NSDictionary* slw1 = @{@"word_id":@1,
                           @"current_strength":@100,
                           @"test_interval":@2
                           };
    NSDictionary* slw2 = @{@"word_id":@2,
                           @"current_strength":@0,
                           @"test_interval":@1
                           };
    NSDictionary* slw3 = @{@"word_id":@10,
                           @"current_strength":@0,
                           @"test_interval":@1
                           };
    NSDictionary *parameters = @{@"learnedWords":@{@1:slw1,
                                                   @2:slw2,
                                                   @3:slw3}
                                 };
    
    // Send a POST request to back-end server to add new StudentLearnedWords
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@ADD_LEARNED_WORDS_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"SERVER Success: added new learnedWords");
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"SERVER Failed to add new learnedWords: %@", error);
          }];
}

- (void)updateStudentLearnedWordsToServer
{
    // Package all the parameters in a learnedWords field
    NSDictionary* slw1 = @{@"word_id":@5,
                           @"current_strength":@0,
                           @"test_interval":@1
                           };
    NSDictionary* slw2 = @{@"word_id":@7,
                           @"current_strength":@0,
                           @"test_interval":@1
                           };
    NSDictionary* allUpdateParams = @{@3:slw1,
                                      @5:slw2};
    
    // Send a POST request to back-end server to update each StudentLearnedWords
    for (id learnedWordsID in [allUpdateParams allKeys]) {
        NSDictionary* slw = [allUpdateParams objectForKey:learnedWordsID];
        NSDictionary* parameters = @{@"learnedWords":slw};
        NSString* updateURL = [NSString stringWithFormat:@"%@%@", @UPDATE_LEARNED_WORDS_URL, learnedWordsID];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager PATCH:updateURL
            parameters:parameters
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   NSLog(@"SERVER Success: updated learnedWords");
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   NSLog(@"SERVER Failed to update learnedWords: %@", error);
               }];
    }
}

- (void)addStudentLearnedComponentsToServer
{
    // Package all the parameters in a learnedWords field
    NSDictionary* slc1 = @{@"component_id":@1,
                           @"current_strength":@100,
                           @"test_interval":@2
                           };
    NSDictionary* slc2 = @{@"component_id":@2,
                           @"current_strength":@0,
                           @"test_interval":@1
                           };
    NSDictionary* slc3 = @{@"component_id":@3,
                           @"current_strength":@100,
                           @"test_interval":@2
                           };
    NSDictionary *parameters = @{@"learnedComponents":@{@1:slc1,
                                                        @2:slc2,
                                                        @3:slc3}
                                 };
    
    // Send a POST request to back-end server to add new StudentLearnedComponents
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@ADD_LEARNED_COMPONENTS_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"SERVER Success: added new learnedComponents");
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"SERVER Failed to add new learnedComponents: %@", error);
          }];
}

- (void)updateStudentLearnedComponentsToServer
{
    // Package all the parameters in a learnedComponents field
    NSDictionary* slc1 = @{@"component_id":@1,
                           @"current_strength":@100,
                           @"test_interval":@2
                           };
    NSDictionary* slc2 = @{@"component_id":@2,
                           @"current_strength":@0,
                           @"test_interval":@1
                           };
    NSDictionary* allUpdateParams = @{@1:slc1,
                                      @2:slc2};
    
    // Send a POST request to back-end server to update each StudentLearnedComponents
    for (id learnedComponentsID in [allUpdateParams allKeys]) {
        NSDictionary* slc = [allUpdateParams objectForKey:learnedComponentsID];
        NSDictionary* parameters = @{@"learnedComponents":slc};
        NSString* updateURL = [NSString stringWithFormat:@"%@%@", @UPDATE_LEARNED_COMPONENTS_URL, learnedComponentsID];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager PATCH:updateURL
            parameters:parameters
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   NSLog(@"SERVER Success: updated learnedComponents");
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   NSLog(@"SERVER Failed to update learnedComponents: %@", error);
               }];
    }
}

//- (void)getUnits
//{
//    if (! self.student) {
//        NSLog(@"No student");
//        return;
//    }
//    
//    
//    if (! self.student.learnedUnits || ! self.student.learnedUnits.count) {
//        NSLog(@"No units learned by student. Adding all units...");
//        [self setLearnedUnits];
//    }
//    
//    self.units = [self.student.learnedUnits sortedArrayUsingDescriptors:
//                  [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]]];
//    
//    if (! self.units.count) {
//        NSLog(@"ERROR: No units available");
//    }
//    else {
//        NSLog(@"Student has learned %ld units", self.units.count);
//    }
//}
//
//- (void)setLearnedUnits
//{
//    NSFetchRequest* request_units = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
//    NSError* error = nil;
//    NSArray* match_units = [self.context executeFetchRequest:request_units error:&error];
//    if (! match_units || ! match_units.count) {
//        NSLog(@"ERROR: No units available");
//    }
//    else {
//        [self.student addLearnedUnits:[NSSet setWithArray:match_units]];
//    }
//}

- (IBAction)logOutPressed:(id)sender
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@LOGOUT_URL parameters:nil
         success:^(AFHTTPRequestOperation* operation, id responseObject) {
             NSLog(@"Logged out of user account %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"StudentEmail"]);
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"StudentEmail"];
//             [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"StudentID"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [self performSegueWithIdentifier:@"Sign Up Log In" sender:self];
         }
         failure:^(AFHTTPRequestOperation* operation, NSError* error) {
             NSLog(@"SERVER: Failed to log out, error: %@", error);
         }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Should be Number of lessons
    return [self.units count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Should be Number of components (videos & exercises) in the lesson
    Unit* unit = self.units[section];
    NSString* unitComponentsString = unit.components;
    NSArray* unitComponents = [unitComponentsString componentsSeparatedByString:@", "];
    return unitComponents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell;
    
    Unit* unit = self.units[indexPath.section];
    NSString* unitComponentsString = unit.components;
    NSArray* unitComponents = [unitComponentsString componentsSeparatedByString:@", "];
    NSString* component = unitComponents[indexPath.row];
    if ([component hasPrefix:@"Unit"]) {
        UnitCollectionViewCell* unitCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UnitCell"
                                                                                     forIndexPath:indexPath];
        unitCell.unitNameLabel.text = component;
        
        cell = unitCell;
    }
    else if ([component hasPrefix:@"Video"]) {
        VideoCollectionViewCell* videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
        videoCell.backgroundImage.image = [UIImage imageNamed:@"Blue Circle.png"];
        if (indexPath.row == 1) {
            videoCell.videoImage.image = [UIImage imageNamed:@"Starfish.png"];
        }
        else {
            
        }
        videoCell.videoNameLabel.text = component;
        
        cell = videoCell;
    }
    else if ([component hasPrefix:@"Exercise"]) {
        ExerciseCollectionViewCell* exerciseCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExerciseCell" forIndexPath:indexPath];
        exerciseCell.backgroundImage.image = [UIImage imageNamed:@"Red Circle.png"];
        exerciseCell.exerciseNameLabel.text = component;
        
        cell = exerciseCell;
    }
    else {
        NSLog(@"ERROR: Unrecognizable Unit Component: %@", component);
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UnitCell" forIndexPath:indexPath];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UnitFooterView* footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
    footer.footerImage.image = [UIImage imageNamed:@"Line.png"];
    
    return footer;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[VideoCollectionViewCell class]]) {
//        [self performSegueWithIdentifier:@"Play Video" sender:cell];
    }
    else if ([cell isKindOfClass:[ExerciseCollectionViewCell class]]) {
        [self performSegueWithIdentifier:@"Show Exercise" sender:cell];
    }
}


#pragma mark - Collection View Flow Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    UIImage* image = [UIImage imageNamed:self.lessonImages[indexPath.section][indexPath.row]];
    //    CGSize size = image.size;
    //
    //    if (indexPath.section == 0) {
    //        CGFloat width = image.size.width * 0.38;
    //        CGFloat height = image.size.height * 0.38;
    //        size = CGSizeMake(width, height);
    //    }
    //    else if (indexPath.section == 1) {
    //        CGFloat width = image.size.width * 0.09;
    //        CGFloat height = image.size.height * 0.09;
    //        size = CGSizeMake(width, height);
    //    }
    
    CGSize size = CGSizeMake(120, 120);
    
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(30, 40, 30, 40);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 30;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Sign Up Log In"]) {
        [segue.destinationViewController setContext:self.context];
    }
    else if ([segue.identifier isEqualToString:@"Play Video"]) {
        [segue.destinationViewController setContext:self.context];
        VideoCollectionViewCell* cell = (VideoCollectionViewCell*)sender;
        [segue.destinationViewController setVideoName:cell.videoNameLabel.text];
    }
    else if ([segue.identifier isEqualToString:@"Show Exercise"]) {
        [segue.destinationViewController setContext:self.context];
        ExerciseCollectionViewCell* cell = (ExerciseCollectionViewCell*)sender;
        [segue.destinationViewController setExerciseName:cell.exerciseNameLabel.text];
    }
    else if ([segue.identifier isEqualToString:@"Show Review"]) {
        [segue.destinationViewController setContext:self.context];
        [segue.destinationViewController setExerciseName:@"Review"];
    }
}

@end
