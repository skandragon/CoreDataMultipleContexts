//
//  Person.h
//  CoreDataMultipleContexts
//
//  Created by Michael Graff on 3/21/14.
//  Copyright (c) 2014 Michael Graff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * title;

@end
