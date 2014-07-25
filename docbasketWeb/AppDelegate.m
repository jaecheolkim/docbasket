//
//  AppDelegate.m
//  docbasketWeb
//
//  Created by jaecheol kim on 6/16/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//
//#import <Parse/Parse.h>

#import "AppDelegate.h"
#import "GlobalValue.h"
#import "DBKLocationManager.h"
#import "DocbaketAPIClient.h"
#import "Docbasket.h"
#import "DocbasketService.h"
#import "ParseHelper.h"
#import "UIAlertView+Blocks.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
            
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    [ParseHelper sharedInstance];
    
    if(!IsEmpty(GVALUE.userID)) [PARSE subscribePushChannel:GVALUE.userID];
    
    
    [DBKSERVICE startmanager];
    


    
    return YES;
}


// Parse remote push notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    // Store the deviceToken in the current installation and save it to Parse.

    [PARSE saveNotificationDeviceToken:deviceToken];
}

// Parse remote push notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Noti = %@", userInfo);
//    Log    : Noti = {
//        aps =     {
//            alert = "You are invited.";
//        };
//        "basket_id" = "c611e338-a34e-4223-9f7c-60125834580d";
//        latitude = "37.5634937627978";
//        longitude = "126.985602378845";
//        title = "\Uad7f\Ubaa8\Ub2dd";
//    }

    UIApplicationState state = [application applicationState];
    
    if(!IsEmpty(userInfo))
    {
        if ( state == UIApplicationStateActive ) { // 포그라운드
            NSLog(@"UIApplicationStateActive");
            //메시지 메뉴 리프레싱
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageMenuEventHandler"
                                                                object:self
                                                              userInfo:@{@"Msg":@"refresh"}];

            
        } else { // 백그라운드, 잠금상태
            NSLog(@"UIApplicationStateBackground");
            
            GVALUE.badgeValue = (int)([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
            GVALUE.notiBasketID = userInfo[@"basket_id"];
            NSString *basketTitle = userInfo[@"title"];
//            NSString *msg = [NSString stringWithFormat:@"%@ \n %@", basketTitle, GVALUE.notiBasketID];
            NSLog(@"notfication basketName = %@ \n basketID = %@", basketTitle, GVALUE.notiBasketID);

            // 여기서 해당 페이지로 분기해야 함.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SideMenuEventHandler"
                                                                object:self
                                                              userInfo:@{@"Msg":@"moveToMessage"}];

        }
    }
    
    [PARSE handlePush:userInfo];
}

// Local push notification
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    GVALUE.badgeValue = (int)([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
    
    UIApplicationState state = [application applicationState]; //[[UIApplication sharedApplication ]applicationState]
    if ( state == UIApplicationStateActive ) { // 포그라운드
        NSLog(@"UIApplicationStateActive");
        
        //메시지 메뉴 리프레싱
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageMenuEventHandler"
                                                            object:self
                                                          userInfo:@{@"Msg":@"refresh"}];

        
    } else { // 백그라운드, 잠금상태
        NSLog(@"UIApplicationStateBackground");
        
        // 여기서 해당 페이지로 분기 해야 함.

        GVALUE.notiBasketID = notification.userInfo[@"baksetID"];
        NSString *basketTitle = notification.userInfo[@"title"];
//        NSString *msg = [NSString stringWithFormat:@"%@ \n %@", basketTitle, GVALUE.notiBasketID];
        NSLog(@"notfication basketName = %@ \n basketID = %@", basketTitle, GVALUE.notiBasketID);

        // 여기서 해당 페이지로 분기해야 함.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SideMenuEventHandler"
                                                            object:self
                                                          userInfo:@{@"Msg":@"moveToMessage"}];
    }

}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [DocbaketAPIClient postUserTracking:GVALUE.trackingArray];
    
    [self saveWebViewCookie];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //[[DBKLocationManager sharedInstance] startMonitoringSignificantLocationChanges];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self loadWebViewCookie];
    //[[DBKLocationManager sharedInstance] stopMonitoringSignificantLocationChanges];
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    [DBKSERVICE stopmanager];
    
    [self saveContext];
}



- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"docbasketWeb" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"docbasketWeb.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}





#pragma mark - Application's Cookie Handler 

- (void)saveWebViewCookie
{
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    NSLog(@"PersisteWebCookie : %@",cookies );
    
    
    NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"MySavedCookies"];
    NSLog(@"%@", @"PersisteWebCookie Saved");
}

- (void)loadWebViewCookie
{
    NSLog(@"%@", @"PersisteWebCookie");
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:@"MySavedCookies"];
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    NSLog(@"%@", @"PersisteWebCookie Restored");
}





@end
