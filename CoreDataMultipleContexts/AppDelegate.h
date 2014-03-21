//
//  AppDelegate.h
//  CoreDataMultipleContexts
//
//  Created by Michael Graff on 3/21/14.
//  Copyright (c) 2014 Michael Graff. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (strong) NSManagedObjectModel *_managedObjectModel;
@property (strong) NSPersistentStoreCoordinator *_persistentStoreCoordinator;
@property (strong) NSManagedObjectContext *_managedObjectContext;
@property (strong) NSManagedObjectContext *_privateWriterContext;

- (void)_setupCoreDataStack;

@end
