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

#import "CartController.h"

@interface CartController ()

@end

@implementation CartController

@synthesize payPalUrl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    CBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if ( ![delegate loadCredentials] ) {
        [self.tabBarController performSegueWithIdentifier:@"login-segue" sender:self];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    // Return the number of rows in the section.
    return [delegate.cart count];
}

// load the items from the cart in the application delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CartCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    CraftsShopItem *curItem = [delegate.cart objectAtIndex:indexPath.row];
    cell.textLabel.text = curItem.itemName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$ %@", curItem.itemPrice];
    cell.imageView.image = [UIImage imageWithData:curItem.itemPicture];
    
    return cell;
}

- (IBAction)checkout:(id)sender {
    CGFloat totalPrice = 0;
    int totalItems = 0;
    CBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    CBPayPalBill *newBill = [[CBPayPalBill alloc] init];
    
    // loop over the items and generate the single CBPayPalBillItem
    for ( CraftsShopItem *item in delegate.cart ) {
        // calculate the total price
        totalPrice += item.itemPrice.doubleValue;
        totalItems++;
        
        CBPayPalBillItem *ppItem = [[CBPayPalBillItem alloc] init];
        ppItem.name = item.itemName;
        ppItem.description = item.itemDescription;
        ppItem.amount = [NSNumber numberWithDouble:item.itemPrice.doubleValue];
        ppItem.tax = [NSNumber numberWithDouble:0.00];
        ppItem.quantity = [NSNumber numberWithInt:1];
        
        // add the detailed item to the array
        [newBill addNewItem:ppItem];
    }
    
    if ( totalItems > 0 ) {
        // create the bill details with the total
        newBill.name = @"Cloudbase.io Crafts Shop";
        newBill.description = [NSString stringWithFormat:@"This is a bill for $%f", totalPrice];;
        newBill.currency = @"USD";
        newBill.invoiceNumber = @"test-invoice-01";
        newBill.paymentCompletedFunction = @"";
        newBill.paymentCancelledFunction = @"";
        
        // call the APIs with the PayPal bill item
        [delegate.helper preparePayPalPurchase:newBill onLiveEnvironment:YES whenDone:^(CBHelperResponseInfo *response) {
            // we have received a response and it was successfull. we should have a checkout url
            if (response.postSuccess && [response.responseData isKindOfClass:[NSDictionary class]]) {
                
                // read the response data
                NSDictionary *tmpData = (NSDictionary *)response.responseData;
                // verify that we have the required checkout_url value
                if ([tmpData objectForKey:@"checkout_url"] != NULL) {
                    // set this to a global variable in the ViewController
                    self.payPalUrl = (NSString *)[tmpData objectForKey:@"checkout_url"];
                    NSLog(@"PayPal Url: %@", self.payPalUrl);
                    // execute a segue which will open a UIWebView in a modal
                    // ViewController. The overriden prepareForSegue method
                    // will send the extracted url to the new ViewController
                    [self performSegueWithIdentifier:@"paypal-browser-segue" sender:self];
                }
            }
        }];
    }
}

// add the url to the PayPal view controller to be read from the UIWebView
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"paypal-browser-segue"] ) {
        PayPalController *controller = segue.destinationViewController;
        controller.payPalUrl = self.payPalUrl;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
