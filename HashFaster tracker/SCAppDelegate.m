//
//  SCAppDelegate.m
//  HashFaster tracker
//
//  Created by Yury Nechaev on 05.02.14.
//  Copyright (c) 2014 Slowpoke Codemasters. All rights reserved.
//

#import "SCAppDelegate.h"
#import "SCViewController.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "SCMapping.h"

// Use a class extension to expose access to MagicalRecord's private setter methods
@interface NSManagedObjectContext ()
+ (void)MR_setRootSavingContext:(NSManagedObjectContext *)context;
+ (void)MR_setDefaultContext:(NSManagedObjectContext *)moc;
@end

@implementation SCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupDB];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    SCViewController *vc = [[SCViewController alloc] init];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window setRootViewController:navC];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupDB
{
    // Configure RestKit's Core Data stack
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"]];
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    self.managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"HashFaster-tracker.sqlite"];
    NSError *error = nil;
    NSDictionary *options = @{  NSMigratePersistentStoresAutomaticallyOption: @(YES),
                                NSInferMappingModelAutomaticallyOption: @(YES)};
    NSPersistentStore *persistentStore = [self.managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:options error:&error];
    if (!persistentStore) {
        RKLogError(@"Failed adding persistent store at path '%@': %@", storePath, error);
        BOOL isMigrationError = [error code] == NSPersistentStoreIncompatibleVersionHashError || [error code] == NSMigrationMissingSourceModelError;
        if ([[error domain] isEqualToString:NSCocoaErrorDomain] && isMigrationError)
        {
            // Could not open the database, so... kill it!
            NSError *fileError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:storePath error:&fileError];
            if (fileError) {
                RKLogError(@"Error deleting database %@: %@", [storePath lastPathComponent], error.localizedDescription);
            } else {
                RKLogError(@"Removed incompatible model version: %@", [storePath lastPathComponent]);
            }
            // Try one more time to create the store
            persistentStore = [self.managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:options error:&error];
            if (persistentStore)
            {
                RKLogDebug(@"Successfully created new database model");
                // If we successfully added a store, remove the error that was initially created
                error = nil;
            }
        }
    }
    [self.managedObjectStore createManagedObjectContexts];
    
    // Configure MagicalRecord to use RestKit's Core Data stack
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:self.managedObjectStore.persistentStoreCoordinator];
    [NSManagedObjectContext MR_setRootSavingContext:self.managedObjectStore.persistentStoreManagedObjectContext];
    [NSManagedObjectContext MR_setDefaultContext:self.managedObjectStore.mainQueueManagedObjectContext];
}

- (void)saveContext
{
    [MagicalRecord saveWithBlock:nil completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"MR SAVE SUCCESS");
        } else {
            if (error) {
                NSLog(@"MR ERROR: %@", error.localizedDescription);
            }
        }
    }];
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
    [self saveContext];
}

@end
