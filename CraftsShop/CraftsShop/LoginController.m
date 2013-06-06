/* Copyright (C) 2013 cloudbase.io
 
 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License, version 2, as published by
 the Free Software Foundation.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; see the file COPYING.  If not, write to the Free
 Software Foundation, 59 Temple Place - Suite 330, Boston, MA
 02111-1307, USA.
 */

#import "LoginController.h"

@interface LoginController ()

- (void)showAlert:(NSString*)text;

@end

@implementation LoginController

@synthesize usernameField, passwordField;

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlert:(NSString*)text {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:text
                          message:nil
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)doLogin:(id)sender {
    CBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if ( delegate.helper ) {
        // check if the user exists in the database
        CBDataSearchConditionGroup *search = [[CBDataSearchConditionGroup alloc] initWithField:@"username" is:CBOperatorEqual to:self.usernameField.text];
        [search addAnd:@"password" is:CBOperatorEqual to:[CBHelper md5:self.passwordField.text]];
        
        [delegate.helper searchDocumentWithConditions:search inCollection:@"users" whenDone:^(CBHelperResponseInfo *response) {
            // the response is not empty
            if ( response.responseData != NULL && [response.responseData isKindOfClass:[NSArray class]] ) {
                
                // load into an array
                NSArray *users = (NSArray*)response.responseData;
                
                // we have found a user with those credentials
                if ( [users count] > 0 ) {
                    // set the login credentials in the helper class
                    delegate.helper.authUsername = usernameField.text;
                    delegate.helper.authPassword = [CBHelper md5:passwordField.text];
                    
                    [delegate saveCredentials:usernameField.text andPassword:[CBHelper md5:passwordField.text]];
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        // we are logged in
                    }];
                } else {
                    [self showAlert:@"Invalid login credentials"];
                }
            } else {
                [self showAlert:@"Something went wrong. Please try again later"];
            }
        }];

    }
}

- (IBAction)openCreateUser:(id)sender {
    [self performSegueWithIdentifier:@"create-user-segue" sender:self];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
