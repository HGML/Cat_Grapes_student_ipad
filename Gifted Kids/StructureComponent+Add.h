//
//  StructureComponent+Add.h
//  Gifted Kids
//
//  Created by Yi Li on 7/20/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "StructureComponent.h"

@interface StructureComponent (Add)

+ (StructureComponent*)structureComponentWithID:(NSNumber*)ID
                                           name:(NSString*)name
                                      andFamily:(NSString*)family
                                      reducible:(BOOL)reducible
                                     inExercise:(Exercise*)exercise
                         inManagedObjectContext:(NSManagedObjectContext*)context;

@end
