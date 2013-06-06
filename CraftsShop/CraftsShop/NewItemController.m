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

#import "NewItemController.h"

@interface NewItemController ()

@end

@implementation NewItemController

@synthesize itemNameField, itemDescriptionField, itemPricefield, itemImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // add the recognizers to the image view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImage:)];
    [self.itemImage addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    // check if we have a user setup in the app if not call the screen to block access to the rest
    // of the functionality
    CBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    if ( ![delegate loadCredentials] ) {
        [self.tabBarController performSegueWithIdentifier:@"login-segue" sender:self];
    }
    // finish the setup of the image view
    self.itemImage.userInteractionEnabled = YES;
    self.itemImage.contentMode = UIViewContentModeScaleAspectFill;
}

/**
 Grabs the new image and resizes it for upload
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    // scale the image to have a maximum width of 800
    CGFloat currentWidth = image.size.width;
    CGFloat scale = 800 / currentWidth;
    
    CGSize newSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.itemImage.image = newImage;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)addImage:(id)sender {
    UIImagePickerController *imagePickController = [[UIImagePickerController alloc]init];
    imagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickController.delegate = self;
    imagePickController.allowsEditing = YES;
    [self presentViewController:imagePickController animated:YES completion:^{
        
    }];
}

/**
 Saves a new item in the database
 */
- (IBAction)createItem:(id)sender {
    CBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    NSDictionary *itemData = @{
        @"user" : delegate.helper.authUsername,
        @"item_name" : self.itemNameField.text,
        @"item_description" : self.itemDescriptionField.text,
        @"item_price" : self.itemPricefield.text
        };
    
    CBHelperAttachment *imageFile = [[CBHelperAttachment alloc] initForFile:self.itemNameField.text withData:UIImageJPEGRepresentation(self.itemImage.image, 0.9)];
    
    if ( delegate.helper ) {
        [delegate.helper insertDocument:itemData inCollection:@"items" withFiles:@[ imageFile ] whenDone:^(CBHelperResponseInfo *response) {
            NSLog(@"Create item output: %@", response.responseString);
        }];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
