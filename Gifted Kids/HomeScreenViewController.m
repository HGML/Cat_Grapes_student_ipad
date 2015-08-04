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

#import "AFNetworkManager.h"


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
    
    [self fetchAllStudents];
    
    self.navigationItem.title = @"课程";
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)fetchAllStudents
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSFetchRequest* request_students = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
        NSError* error = nil;
        NSArray* match_students = [self.context executeFetchRequest:request_students error:&error];
        if (! match_students) {
            NSLog(@"ERROR: Error when fetching students");
        }
        else {
            NSLog(@"Students: %d", (int)match_students.count);
        }
    });
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    NSError* error = nil;
    NSFetchRequest* request_words = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request_words.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
    NSArray* match_words = [self.context executeFetchRequest:request_words error:&error];
    NSLog(@"%ld words in database", match_words.count);
    
    NSFetchRequest* request_components = [NSFetchRequest fetchRequestWithEntityName:@"StructureComponent"];
    request_components.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
    NSArray* match_components = [self.context executeFetchRequest:request_components error:&error];
    NSLog(@"%ld components in database", match_components.count);
    
    NSFetchRequest* request_sentences = [NSFetchRequest fetchRequestWithEntityName:@"Sentence"];
    request_sentences.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
    NSArray* match_sentences = [self.context executeFetchRequest:request_sentences error:&error];
    NSLog(@"%ld sentences in database", match_sentences.count);
    
    [self getUser];
    if (self.student && ! self.units) {
        [self setLearnedUnits];
    }
}

- (void)getUser
{
    NSString* email = [[NSUserDefaults standardUserDefaults] objectForKey:@"StudentEmail"];
    if (! email) {
        [self performSegueWithIdentifier:@"Sign Up Log In" sender:self];
    }
    else {
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
        request.predicate = [NSPredicate predicateWithFormat:@"email == %@", email];
        NSError* error = nil;
        NSArray* match = [self.context executeFetchRequest:request error:&error];
        if (! match || [match count] > 1) {
            NSLog(@"ERROR: Error when fetching students");
        }
        else if ([match count] == 0) {
            NSLog(@"ERROR: No user exists with email %@", email);
            NSLog(@"Please log in or sign up.");
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserEmail"];
            [self performSegueWithIdentifier:@"Sign Up Log In" sender:self];
        }
        else {
            self.student = [match lastObject];
            NSLog(@"Logged in for student %@", self.student.username);
            
            [self getUnits];
        }
    }
}

- (void)getUnits
{
    if (! self.student) {
        NSLog(@"No student");
        return;
    }
    
    
    if (! self.student.learnedUnits || ! self.student.learnedUnits.count) {
        NSLog(@"No units learned by student. Adding all units...");
        [self setLearnedUnits];
    }
    
    self.units = [self.student.learnedUnits sortedArrayUsingDescriptors:
                  [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]]];
    
    if (! self.units.count) {
        NSLog(@"ERROR: No units available");
    }
    else {
        NSLog(@"Student has learned %ld units", self.units.count);
    }
}

- (void)setLearnedUnits
{
    NSFetchRequest* request_units = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSError* error = nil;
    NSArray* match_units = [self.context executeFetchRequest:request_units error:&error];
    if (! match_units || ! match_units.count) {
        NSLog(@"ERROR: No units available");
    }
    else {
        [self.student addLearnedUnits:[NSSet setWithArray:match_units]];
    }
}

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
