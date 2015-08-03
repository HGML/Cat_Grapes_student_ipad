//
//  Sentence+Add.h
//  Gifted Kids
//
//  Created by 李诣 on 5/23/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "Sentence.h"

@interface Sentence (Add)

+ (Sentence*)sentenceWithID:(NSNumber*)ID
                    english:(NSString*)English
                    chinese:(NSString*)Chinese
                  structure:(NSString*)structure
                    andCore:(NSString*)core
   usingStructureComponents:(NSSet*)structureComponents
                 usingWords:(NSSet*)words
     inManagedObjectContext:(NSManagedObjectContext*)context;

@end
