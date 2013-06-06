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

#import "CreateUserController.h"

@interface CreateUserController ()

- (void)showAlert:(NSString*)text;

@end

@implementation CreateUserController

@synthesize usernameField, passwordField, emailField;

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

- (IBAction)createUser:(id)sender {
    CBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if ( delegate.helper ) {
        // check if a user with the same username already exists
        CBDataSearchConditionGroup *search = [[CBDataSearchConditionGroup alloc] initWithField:@"username" is:CBOperatorEqual to:self.usernameField.text];
        
        [delegate.helper searchDocumentWithConditions:search inCollection:@"users" whenDone:^(CBHelperResponseInfo *response) {
            // the response is not empty
            if ( response.responseData != NULL && [response.responseData isKindOfClass:[NSArray class]] ) {
                
                // load into an array
                NSArray *users = (NSArray*)response.responseData;
                
                // we have found a user with those credentials
                if ( [users count] > 0 ) {
                    [self showAlert:@"This username is taken"];
                } else {
                    // register the new user
                    NSDictionary *newUser = @{ @"username" : self.usernameField.text, @"password" : [CBHelper md5:self.passwordField.text] };
                    
                    [delegate.helper insertDocument:newUser inCollection:@"users" whenDone:^(CBHelperResponseInfo *response) {
                        if ( response.responseData != NULL ) {
                            NSString *output = (NSString*)response.responseData;
                            // new user created
                            if ( [output isEqualToString:@"Inserted"] ) {
                                
                                delegate.helper.authPassword = [CBHelper md5:self.passwordField.text];
                                delegate.helper.authUsername = self.usernameField.text;
                                
                                [delegate saveCredentials:self.usernameField.text andPassword:[CBHelper md5:self.passwordField.text]];
                                
                                if ([self respondsToSelector:@selector(presentingViewController)]) {
                                    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
                                        
                                    }];
                                }
                            }
                        } else {
                            [self showAlert:@"Something went wrong. Please try again later."];
                        }
                    }];
                    
                }
            } else {
                [self showAlert:@"Something went wrong. Please try again later."];
            }
        }];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
