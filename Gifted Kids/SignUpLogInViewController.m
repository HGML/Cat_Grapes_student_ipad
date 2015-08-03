//
//  SignUpLogInViewController.m
//  Gifted Kids
//
//  Created by 李诣 on 5/22/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "SignUpLogInViewController.h"

#import "SignUpViewController.h"
#import "LogInViewController.h"

#define VIEW_BACKGROUND_COLOR [UIColor colorWithRed:19.849724472/255 green:160.192457736/255 blue:238.374204934/255 alpha:1.0]


@interface SignUpLogInViewController ()

@property (strong, nonatomic) IBOutlet UIButton *signUpButton;

@property (strong, nonatomic) IBOutlet UIButton *logInButton;

@end

@implementation SignUpLogInViewController

@synthesize context = _context;

@synthesize signUpButton = _signUpButton;

@synthesize logInButton = _logInButton;

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
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.view.backgroundColor = VIEW_BACKGROUND_COLOR;
    [self.signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
//    UIColor* color = self.logInButton.titleLabel.textColor;
//    CGFloat red, green, blue, alpha;
//    [color getRed:&red green:&green blue:&blue alpha:&alpha];
//    NSLog(@"Color: %f/255, %f/255, %f/255, %f", red * 255000, green * 255000, blue * 255000, alpha);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Sign Up"]) {
        [segue.destinationViewController setContext:self.context];
    }
    else if ([segue.identifier isEqualToString:@"Log In"]) {
        [segue.destinationViewController setContext:self.context];
    }
}

@end
