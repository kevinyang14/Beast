//
//  SignInViewController.m
//  
//
//  Created by Kevin Yang on 1/22/17.
//
//

#import "SignUpViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
@import Firebase;

@interface SignUpViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.email becomeFirstResponder];
    [self formatSVProgressHUD];
}

- (void)formatSVProgressHUD{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
}


#pragma mark IBAction

- (IBAction)cancelButton:(id)sender {
    [self resignAllResponders];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signUpButton:(id)sender {
    NSString *email = self.email.text;
    NSString *password = self.password.text;
    NSLog(@"Email: %@\n", email);
    NSLog(@"Password: %@\n", password);
    [self signUpHelper];
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
        [self signUpHelper];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark IBAction Methods
- (void)signUpHelper{
    [self resignAllResponders];
    if([self areTextFieldsFilled]){
        [self signUpWithFirebase];
    }
}

#pragma mark Firebase Methods

- (void)signUpWithFirebase{
    
    NSString *email = self.email.text;
    NSString *password = self.password.text;
    
    [[FIRAuth auth]
     createUserWithEmail:email
     password:password
     completion:^(FIRUser *_Nullable user,
                  NSError *_Nullable error) {
         if(error){
             NSLog(@"error %@", error);
             [SVProgressHUD showErrorWithStatus:@"Fail Whale 🐳"];
         }else{
             NSLog(@"login successful");
             [self performSegueWithIdentifier:@"signUpSegue" sender:self];
//             [SVProgressHUD showSuccessWithStatus:@"Login Successful 😇"];
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
