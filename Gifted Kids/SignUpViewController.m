//
//  SignUpViewController.m
//  Gifted Kids
//
//  Created by 李诣 on 5/22/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "SignUpViewController.h"
#import "Student+Add.h"
#import "Word.h"
#import "StudentLearnedWord+Add.h"
#import "LogInViewController.h"
#import "DateManager.h"

// Library to send request to server
#import "AFNetworkManager.h"

#define VIEW_BACKGROUND_COLOR [UIColor colorWithRed:19.849724472/255 green:160.192457736/255 blue:238.374204934/255 alpha:1.0]


@interface SignUpViewController () <UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *formTableView;

@property (strong, nonatomic) IBOutlet UIButton *createButton;

@property (strong, nonatomic) NSArray* formFields;

@property (strong, nonatomic) NSMutableArray* textFields;


@property (strong, nonatomic) NSMutableArray* textFieldState;

@property (nonatomic) size_t filledTextFields;

@property (strong, nonatomic) NSString* email;

@end


@implementation SignUpViewController

@synthesize context = _context;

@synthesize formTableView = _formTableView;

@synthesize createButton = _createButton;

@synthesize formFields = _formFields;

@synthesize textFields = _textFields;

@synthesize textFieldState = _textFieldState;

@synthesize filledTextFields = _filledTextFields;

@synthesize email = _email;


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
    
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR;
    [self.navigationController setNavigationBarHidden:YES];
    
    self.formFields = [NSArray arrayWithObjects:@"全名", @"邮箱", @"密码", @"年级", nil];
    self.textFields = [NSMutableArray array];
    self.textFieldState = [NSMutableArray arrayWithObjects:
                           [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:1], nil];
    self.filledTextFields = 1;
    
    self.formTableView.dataSource = self;
    [self.formTableView reloadData];
    
    [self.createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.createButton setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createButtonPressed:(id)sender
{
    NSLog(@"Creating new student account...");
    
    /*
     * Name
     * Email
     * Password
     * Grade
     */
    NSMutableArray* studentInfo = [NSMutableArray array];
    for (UITextField* textField in self.textFields) {
        [studentInfo addObject:textField.text];
    }
    NSLog(@"Got student info: %@", studentInfo);
    
    // Package all the paras in a student field
    NSDictionary *parameters = @{@"student":@{@"name":studentInfo[0],
                                              @"email":studentInfo[1],
                                              @"password":studentInfo[2],
                                              @"grade":studentInfo[3]}
                                 };
    
    // Send a POST request to back-end server to create the student user.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@CREATE_STUDENT_URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Server response object: %@", responseObject);
        
        if([responseObject[@"status"]  isEqual: (@"Existed")]) {
            NSLog(@"Server: An account already exists under the email address %@. Please log in instead.", studentInfo[1]);
            NSLog(@"Student not created");
            self.email = studentInfo[1];
            UIAlertView* emailExistsAlert = [[UIAlertView alloc] initWithTitle:@"邮箱已被使用"
                                                                       message:@"是否要登陆？"
                                                                      delegate:self
                                                             cancelButtonTitle:@"取消"
                                                             otherButtonTitles:@"登陆", nil];
            [emailExistsAlert show];
            return;
        }
        else if([responseObject[@"status"]  isEqual: (@"Failure")]) {
            NSLog(@"Server: Unknown Failure of signing up!");
            // !!! Add future re_direction to the user page here.
        }
        else if([responseObject[@"status"]  isEqual: (@"Created")]) {
            NSLog(@"Server: Created successfully!");
            
            id studentObject = responseObject[@"student"];
            NSLog(@"Student: %@", studentObject[@"id"]);
            
            // Save student email and student id to UserDefaults
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:studentObject[@"email"] forKey:@"StudentEmail"];
//            [userDefaults setObject:studentObject[@"id"] forKey:@"StudentID"];
            [userDefaults synchronize];
            NSLog(@"Local: Logged In");
            
            // Request server to create student record
            [self requestCreateStudentRecord];
            
            // Create student
            Student* student = [Student studentWithEmail:studentInfo[1]
                                                username:studentInfo[0]
                                             andPassword:studentInfo[2]
                                  inManagedObjectContext:self.context];
            if (! student) {
                NSLog(@"Local ERROR: Could not create student");
                return;
            }
            
            NSString* name = studentInfo[0];
            if (! [name isEqualToString:@""]) {
                student.name = name;
            }
            
            student.grade = [NSNumber numberWithInt:[studentInfo[3] intValue]];
            
            [self addLearnedWordsAndComponentsForStudent:student];
            
            NSError* error = nil;
            [self.context save:&error];
            NSLog(@"Local: New student account created");
            
            
            // Redirect to Home Screen
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Server: ERROR when performing POST operation: %@", error);
    }];
}

- (void)requestCreateStudentRecord
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@CREATE_STUDENT_RECORD_URL parameters:nil
          success:^(AFHTTPRequestOperation* operation, id responseObject) {
              NSLog(@"SERVER Success: created student record, response %@", responseObject);
          }
          failure:^(AFHTTPRequestOperation* operation, NSError* error) {
              NSLog(@"SERVER Failed to create student record. Error: %@", error);
          }];
}

- (void)addLearnedWordsAndComponentsForStudent:(Student*)student
{
    NSInteger grade = student.grade.integerValue;
    
    // Add StudentLearnedWord
    NSError* error = nil;
    NSFetchRequest* request_words = [NSFetchRequest fetchRequestWithEntityName:@"Word"];
    request_words.predicate = [NSPredicate predicateWithFormat:@"%ld <= uid && uid < %ld", 10000000, (1100 + grade) * 10000];
    request_words.propertiesToFetch = [NSArray arrayWithObject:@"uid"];
    request_words.sortDescriptors = [NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]];
    NSArray* match_words = [self.context executeFetchRequest:request_words error:&error];
    
    for (Word* word in match_words) {
        StudentLearnedWord* slw = [StudentLearnedWord student:student.username
                                                  learnedWord:word.uid
                                                       onDate:[DateManager dateDays:-1 afterDate:[DateManager today]]
                                       inManagedObjectContext:self.context];
        slw.strength = [NSNumber numberWithInt:100];
    }
    
    
    // Add StudentLearnedComponent
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.formFields count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Form Cell"];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Form Cell"];
    }
    
    cell.textLabel.text = self.formFields[indexPath.row];
    
    if (indexPath.row != 5) {   // Not photo
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(85, 10, 290, 30)];
        textField.textColor = [UIColor blackColor];
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.tag = indexPath.row;
        
        textField.delegate = self;
        [textField addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        [textField setEnabled:YES];
        
        if (indexPath.row == 0) {   // Name
            [textField becomeFirstResponder];
//            textField.text = @"Emma Li";
        }
        else if (indexPath.row == 1) {   // Email
            textField.keyboardType = UIKeyboardTypeEmailAddress;
//            textField.text = @"hgliyi@yahoo.com";
        }
        else if (indexPath.row == 2) {   // Password
            textField.secureTextEntry = YES;
//            textField.text = @"hgml1217";
        }
        else if (indexPath.row == 3) {   // Grade
            textField.text = @"3";
            [textField setEnabled:NO];   // must use stepper; do not permit direct editting
            
            CGRect frame = CGRectMake(275, 10, 100, 30);
            UIStepper* stepper = [[UIStepper alloc] initWithFrame:frame];
            [stepper setMinimumValue:1];
            [stepper setMaximumValue:9];
            [stepper setWraps:YES];
            [stepper addTarget:self
                        action:@selector(stepperValueChanged:)
              forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:stepper];
        }
        
        [self.textFields addObject:textField];
        [cell.contentView addSubview:textField];
    }
    else {   // Photo
        UIButton* imageButton = [[UIButton alloc] initWithFrame:CGRectMake(85, 5, 40, 40)];
        [imageButton setBackgroundImage:[UIImage imageNamed:@"Smiley.png"] forState:UIControlStateNormal];
        [imageButton addTarget:self
                        action:@selector(headPicImagePressed:)
              forControlEvents:UIControlEventTouchUpInside];
        [imageButton setEnabled:YES];
        [cell.contentView addSubview:imageButton];
    }
    
    return cell;
}


#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag != [self.textFields count] - 1) {
        [self.textFields[textField.tag + 1] becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (IBAction)textFieldDidChange:(UITextField*)textField
{
    size_t tag = textField.tag;
    NSString* text = textField.text;
    
    if ([text isEqualToString:@""] && [self.textFieldState[tag] intValue] != 0) {
        self.textFieldState[tag] = [NSNumber numberWithInt:0];
        self.filledTextFields = self.filledTextFields - 1;
        
        if (self.createButton.enabled) {
            [self.createButton setEnabled:NO];
        }
    }
    else if (! [text isEqualToString:@""] && [self.textFieldState[tag] intValue] == 0) {
        self.textFieldState[tag] = [NSNumber numberWithInt:1];
        self.filledTextFields = self.filledTextFields + 1;
        
        if (self.filledTextFields == 4) {
            [self.createButton setEnabled:YES];
        }
        else if (self.createButton.enabled) {
            [self.createButton setEnabled:NO];
        }
    }
}


#pragma mark - Stepper

- (IBAction)stepperValueChanged:(UIStepper*)sender
{
    UITextField* stepperFormField = [self.textFields objectAtIndex:4];
    [stepperFormField setText:[NSString stringWithFormat:@"%.f", sender.value]];
}


#pragma mark - Head Pic

- (IBAction)headPicImagePressed:(id)sender
{
    NSLog(@"Head Pic");
}


#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"登陆"]) {
        [self performSegueWithIdentifier:@"Log In" sender:alertView];
    }
    else if ([alertView.title isEqualToString:@"用户名已被使用"]
             && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"好"]) {
        UITextField* textField = [self.textFields objectAtIndex:2];
        [textField becomeFirstResponder];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Log In"]) {
        [segue.destinationViewController setEmail:self.email];
    }
}

@end
