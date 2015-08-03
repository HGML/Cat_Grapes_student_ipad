//
//  LogInViewController.m
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "LogInViewController.h"
#import <CoreData/CoreData.h>
#import "Student.h"

// Library to send request to server
#import "AFNetworking.h"

#define VIEW_BACKGROUND_COLOR [UIColor colorWithRed:19.849724472/255 green:160.192457736/255 blue:238.374204934/255 alpha:1.0]

// !!! This can be further included in another file
#define LOGIN_URL "http://localhost:3000/sessions/create"

@interface LogInViewController ()

@property (strong, nonatomic) IBOutlet UITableView *formTableView;

@property (strong, nonatomic) IBOutlet UIButton *logInButton;

@property (strong, nonatomic) NSArray* formFields;

@property (strong, nonatomic) NSMutableArray* textFields;

@property (strong, nonatomic) NSMutableArray* textFieldState;

@property (nonatomic) size_t filledTextFields;

@end


@implementation LogInViewController

@synthesize context = _context;

@synthesize email = _email;

@synthesize formTableView = _formTableView;

@synthesize logInButton = _logInButton;

@synthesize formFields = _formFields;

@synthesize textFields = _textFields;

@synthesize textFieldState = _textFieldState;

@synthesize filledTextFields = _filledTextFields;


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
    
    self.formFields = [NSArray arrayWithObjects:@"用户名", @"密码", nil];
    self.textFields = [NSMutableArray array];
    self.textFieldState = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];
    self.filledTextFields = 0;
    
    self.formTableView.dataSource = self;
    [self.formTableView reloadData];
    
    [self.logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.logInButton setEnabled:NO];
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

- (IBAction)logInButtonPressed:(id)sender
{
    NSLog(@"Logging in...");
    
    NSMutableArray* studentInfo = [NSMutableArray array];
    for (UITextField* textField in self.textFields) {
        [studentInfo addObject:textField.text];
    }
    
    // Send a POST request to back-end server to create the student user.
    // !!!This can be encanpsulated later by add another header file in AFNetworking framework package
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // Package all the paras in a student field
    NSDictionary *parameters = @{@"student":@{@"email":studentInfo[0], @"password":studentInfo[1]}};
    [manager GET:@LOGIN_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Server response object: %@", responseObject);
        
        if([responseObject[@"status"]  isEqual: (@"Login Failure")])
        {
            NSLog(@"Server: No student account exists with email %@ and password %@.", studentInfo[0], studentInfo[1]);
            UIAlertView* noAccountAlert = [[UIAlertView alloc] initWithTitle:@"无法登陆"
                                                                     message:@"用户名或密码错误"
                                                                    delegate:self
                                                           cancelButtonTitle:@"好"
                                                           otherButtonTitles:nil];
            [noAccountAlert show];
            return;
        }
        else if([responseObject[@"status"]  isEqual: (@"Login Success")])
        {
            NSLog(@"Server: Logged in successfully!");
            
            // Save student email to UserDefaults
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:studentInfo[0] forKey:@"UserEmail"];
            [userDefaults synchronize];
            NSLog(@"Local: Logged In");
            
            // Redirect to Home Screen
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    /*
    NSString* email = studentInfo[0];
    NSString* password = studentInfo[1];
    
    NSFetchRequest* request_logIn = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    request_logIn.predicate = [NSPredicate predicateWithFormat:@"email == %@ && password == %@", email, password];
    NSError* error = nil;
    NSArray* match = [self.context executeFetchRequest:request_logIn error:&error];
    if (! match || [match count] > 1) {
        NSLog(@"ERROR: Error when fetching student with email %@ and password %@.", email, password);
        NSLog(@"\tmatch = %@", match);
        NSLog(@"Student not found");
        return;
    }
    else if ([match count] == 0) {
        NSLog(@"ERROR: No student account exists with email %@ and password %@.", email, password);
        NSLog(@"Student not found");
        UIAlertView* noAccountAlert = [[UIAlertView alloc] initWithTitle:@"无法登陆" message:@"用户名或密码错误" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
        [noAccountAlert show];
        return;
    }
    
    Student* student = [match lastObject];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:student.username forKey:@"Username"];
    [userDefaults synchronize];
    NSLog(@"Logged In");
    [self.navigationController popToRootViewControllerAnimated:NO];
     */
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
    
    if (indexPath.row == 0) {   // Email
        textField.placeholder = @"（或电子邮箱）";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        
        if (self.email && ! [self.email isEqualToString:@""]) {
            textField.text = self.email;
        }
        else {
            [textField becomeFirstResponder];
        }
    }
    else if (indexPath.row == 1) {   // Password
        textField.secureTextEntry = YES;
        
        if (self.email && ! [self.email isEqualToString:@""]) {
            [textField becomeFirstResponder];
        }
    }
    
    [textField setEnabled:YES];
    [self.textFields addObject:textField];
    [cell.contentView addSubview:textField];
    
    
    return cell;
}


#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag != [self.textFields count] - 1) {
        [self.textFields[textField.tag + 1] becomeFirstResponder];
    }
    else {
        [self logInButtonPressed:self];
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
        
        if (self.logInButton.enabled) {
            [self.logInButton setEnabled:NO];
        }
    }
    else if (! [text isEqualToString:@""] && [self.textFieldState[tag] intValue] == 0) {
        self.textFieldState[tag] = [NSNumber numberWithInt:1];
        self.filledTextFields = self.filledTextFields + 1;
        
        if (self.filledTextFields == 2) {
            [self.logInButton setEnabled:YES];
        }
    }
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
