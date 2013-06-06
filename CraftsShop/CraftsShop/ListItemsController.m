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

#import "ListItemsController.h"

@interface ListItemsController ()

@end

@implementation ListItemsController

@synthesize items;

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
        //[self performSegueWithIdentifier:@"login-segue" sender:self];
        [self.tabBarController performSegueWithIdentifier:@"login-segue" sender:self];
        return;
    }
    
    [self loadItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// load the list of items from the cloud database
- (void)loadItems {
    CBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if ( delegate.helper ) {
        [delegate.helper searchAllDocumentsInCollection:@"items" whenDone:^(CBHelperResponseInfo *response) {
            if ( [response.responseData isKindOfClass:[NSArray class]] ) {
                NSArray *receivedItems = (NSArray*)response.responseData;
                self.items = [[NSMutableArray alloc] init];
                // loop over the items and populate the array
                for (NSDictionary *curItem in receivedItems) {
                    CraftsShopItem *newItem = [[CraftsShopItem alloc] init];
                    newItem.itemName = [curItem valueForKey:@"item_name"];
                    newItem.itemDescription = [curItem valueForKey:@"item_description"];
                    newItem.itemPrice = [curItem valueForKey:@"item_price"];
                    newItem.itemName = [curItem valueForKey:@"item_name"];
                    
                    // if we have files attached
                    NSArray *files = [curItem valueForKey:@"cb_files"];
                    if ( [files count] > 0 ) {
                        NSDictionary *fileInfo = files[0];
                        newItem.itemPictureId = [fileInfo valueForKey:@"file_id"];
                        // kick off the download of the file. We reload the data at the end to make sure
                        // the picture is displayed in the UITableView
                        [delegate.helper downloadFileData:newItem.itemPictureId whenDone:^(NSData *fileContent) {
                            newItem.itemPicture = fileContent;
                            [self.tableView reloadData];
                        }];
                    }
                    
                    [self.items addObject:newItem];
                
                }
                
                [self.tableView reloadData];
            }
        }];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    CraftsShopItem *curItem = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = curItem.itemName;
    cell.detailTextLabel.text = curItem.itemDescription;
    cell.imageView.image = [UIImage imageWithData:curItem.itemPicture];
    
    return cell;
}

#pragma mark - Table view delegate

// add to basket when an item is clicked
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CraftsShopItem *item = [self.items objectAtIndex:indexPath.row];
    
    if ( item != NULL ) {
        CBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        // loop over the view controllers to add the counter to the correct tab
        for ( UIViewController *curController in self.tabBarController.viewControllers ) {
            if ( [curController isKindOfClass:[CartController class]] ) {
                [delegate addToCart:item fromController:curController];
            }
        }
    }
}

@end
