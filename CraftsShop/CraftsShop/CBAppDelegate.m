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

#import "CBAppDelegate.h"

@implementation CBAppDelegate

@synthesize helper;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize the CBHelper object
    self.helper = [[CBHelper alloc] initForApp:@"test-crafts-shop" withSecret:@"02a0d3f6e2a6b5f4cb28e134571f1f37"];
    self.helper.debugMode = YES;
    [self.helper setPassword:@"cbc06180efdc9db4ac573c99c224405f"];
    
    self.cart = [[NSMutableArray alloc] init];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// save the credentials from a login or register screen
- (void)saveCredentials:(NSString*)username andPassword:(NSString*)password {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *settingsFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cb_settings.plist"];
    
    NSMutableDictionary *set = [[NSMutableDictionary alloc] init];
    [set setValue:username forKey:@"username"];
    [set setValue:password forKey:@"password"];
    
    [set writeToFile:settingsFile atomically:NO];
}

// load the credentials if they are saved. This is called from all view controllers
- (BOOL)loadCredentials {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *settingsFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cb_settings.plist"];
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:settingsFile] ) {
        NSMutableDictionary *set = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsFile];
        if ( ![set objectForKey:@"username"] ) {
            return NO;
        } else {
            self.helper.authUsername = [set objectForKey:@"username"];
            self.helper.authPassword = [set objectForKey:@"password"];
            return YES;
        }
    } else {
        return NO;
    }
}

// adds an item to the cart and increases the counter on the tab.
- (void)addToCart:(CraftsShopItem*)item fromController:(UIViewController*)controller {
    [self.cart addObject:item];
    
    NSDictionary *userCart = @{ @"user" : self.helper.authUsername, @"items" : self.cart };
    
    CBDataSearchConditionGroup *search = [[CBDataSearchConditionGroup alloc] initWithField:@"user" is:CBOperatorEqual to:self.helper.authUsername];
    search.isUpsert = YES;
    
    [self.helper updateDocument:userCart where:search inCollection:@"cart"];
    
    [controller.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%i", [self.cart count]]];
}

@end
