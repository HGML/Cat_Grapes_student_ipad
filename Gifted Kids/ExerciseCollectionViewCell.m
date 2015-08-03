//
//  ExerciseCollectionViewCell.m
//  Gifted Kids
//
//  Created by 李诣 on 5/15/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "ExerciseCollectionViewCell.h"

@implementation ExerciseCollectionViewCell

@synthesize backgroundImage = _backgroundImage;

@synthesize exerciseNameLabel = _exerciseNameLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundImage.image = [UIImage imageNamed:@"Red Circle.png"];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
