//
//  BlockTranslationView.h
//  Gifted Kids
//
//  Created by 李诣 on 5/19/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BlockTranslationViewDelegate <NSObject>

- (void)setCheckButtonEnabled:(BOOL)enabled;

@end


@interface BlockTranslationView : UIView

@property (strong, nonatomic) id<BlockTranslationViewDelegate> delegate;

- (void)setup;

- (void)updateWithPrompt:(NSString*)prompt
                question:(NSString*)question
          andWordOptions:(NSArray*)wordOptions;

- (NSString*)translation;

@end
