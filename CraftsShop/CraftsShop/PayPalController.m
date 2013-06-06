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

#import "PayPalController.h"

@interface PayPalController ()

@end

@implementation PayPalController

@synthesize payPalWebView, payPalUrl;

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

// when the view appears set the url in the webview and initiate the transaction
- (void)viewDidAppear:(BOOL)animated {
    NSURL *url = [NSURL URLWithString:self.payPalUrl];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.payPalWebView.delegate = self;
    //Load the request in the UIWebView.
    [self.payPalWebView loadRequest:requestObj];
}

// we use the delegate to monitor the status of the transaction. Once we are done we hide the modal
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    CBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return [appDelegate.helper readPayPalResponse:request whenDone:^(CBHelperResponseInfo *response) {
        NSDictionary *tmpData = (NSDictionary *)response.responseData;
        if ([tmpData objectForKey:@"status"] != NULL)
        {
            NSString* status = (NSString *)[tmpData objectForKey:@"status"];
            // here we should read the status and check whether the transaction was cancelled or completed
            NSLog(@"%@", status);
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }];
}

@end
