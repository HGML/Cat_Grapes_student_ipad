//
//  VideoPlayerViewController.h
//  Gifted Kids
//
//  Created by 李诣 on 5/15/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VideoPlayerViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext* context;

@property (nonatomic, strong) NSString* videoName;

@end
