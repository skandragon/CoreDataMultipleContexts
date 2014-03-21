//
//  AppDelegate.m
//  CoreDataMultipleContexts
//
//  Created by Michael Graff on 3/21/14.
//  Copyright (c) 2014 Michael Graff. All rights reserved.
//

#import "AppDelegate.h"
#import "Person.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self _setupCoreDataStack];


    [self _makeRecords];
}

- (void)_makeRecords
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (int i = 0 ; i < 10 ; i++)
            [self _makeRecord: 1000];
    });
}

- (void)_makeRecord: (int)count
{
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self._managedObjectContext;

    [temporaryContext performBlock: ^{
        int count_copy = count;
        NSError *error;

        while (count_copy-- > 0) {
            Person *person = [NSEntityDescription insertNewObjectForEntityForName: @"Person"
                                                           inManagedObjectContext: temporaryContext];
            person.name = @"Michael";
            person.title = @"Engineer";
        }

        if ([temporaryContext save: &error]) {
            NSLog(@"Person saved to temporaryContext");
        } else {
            NSLog(@"Error saving temporaryContext: %@", [error localizedDescription]);
        }
    }];
}

- (void)_setupCoreDataStack
{
    NSError *error = nil;

    // Set up the managed object model.
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource: @"CoreDataMultipleContexts" withExtension: @"momd"];
    self._managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];

    // Set up the persistent store coordinator.
    NSURL *storeURL = [NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath]
                                              stringByAppendingPathComponent: @"Database.db"]];
    NSLog(@"Url: %@", storeURL);

    error = nil;
    self._persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                        initWithManagedObjectModel: self._managedObjectModel];

    if (![self._persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                        configuration: nil
                                                                  URL: storeURL
                                                              options: nil
                                                                error: &error]) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }

    // Create the writer MOC.
    self._privateWriterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    [self._privateWriterContext setPersistentStoreCoordinator: self._persistentStoreCoordinator];

    // Create the main thread MOC.
    self._managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    self._managedObjectContext.parentContext = self._privateWriterContext;

    // Subscribe to change notifications.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_mocDidSaveNotification:)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: nil];
}

- (void)_mocDidSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *savedContext = [notification object];

    // Ignore change notifications for the top MOC.
    if (savedContext.parentContext == nil) {
        return;
    }

    // Ignore changes for other databases.
    if (self._privateWriterContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator) {
        return;
    }

    [savedContext.parentContext performBlock: ^{
        NSError *error;

        [savedContext.parentContext mergeChangesFromContextDidSaveNotification: notification];
        if (![savedContext.parentContext save: &error]) {
            NSLog(@"Error saving context %@: %@", savedContext.parentContext, [error localizedDescription]);
        }
    }];
}

@end
