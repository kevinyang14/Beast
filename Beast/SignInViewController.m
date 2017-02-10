//
//  SignInViewController.m
//  Beast
//
//  Created by Kevin Yang on 1/23/17.
//  Copyright © 2017 Beast. All rights reserved.
//

#import "SignInViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
@import Firebase;


@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.email becomeFirstResponder];
    [self formatSVProgressHUD];
}


- (void)formatSVProgressHUD{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
}


#pragma mark IBAction Methods

- (IBAction)cancelButton:(id)sender {
    [self resignAllResponders];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signInButton:(id)sender {
    NSString *email = self.email.text;
    NSString *password = self.password.text;
    [self signInHelper];
    NSLog(@"Email: %@\n", email);
    NSLog(@"Password: %@\n", password);
}

#pragma mark Processing Methods

- (BOOL)areTextFieldsFilled{
    NSString *username = self.email.text;
    NSString *password = self.password.text;
    
    if(username.length == 0 || password.length == 0){
        [AppDelegate alertWithTitle:@"Oops" andMessage:@"You forgot something"];
        return NO;
    }
    
    return YES;
}

- (void)resignAllResponders{
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
}

#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.email) {
        [self.password becomeFirstResponder];
    }else if(textField == self.password){
        [self signInHelper];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark IBAction Methods
- (void)signInHelper{
    [self resignAllResponders];
    if([self areTextFieldsFilled]){
        [self signInWithFirebase];
    }
}

#pragma mark Firebase Methods

- (void)signInWithFirebase{
    
    NSString *email = self.email.text;
    NSString *password = self.password.text;
    
    [[FIRAuth auth] signInWithEmail:email
                           password:password
                         completion:^(FIRUser *user, NSError *error) {
         if(error){
             NSLog(@"error %@", error);
             [SVProgressHUD showErrorWithStatus:@"Fail Whale 🐳"];
         }else{
             NSLog(@"login successful");
             [self performSegueWithIdentifier:@"signInSegue" sender:self];
         }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
