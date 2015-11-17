//
//  TSRecordingToolbarView.m
//  talktala
//
//  Created by Oana Ban on 16/04/15.
//  Copyright (c) 2015 Groop Internet Platform inc. All rights reserved.
//

#import "TSRecordingToolbarView.h"

@interface TSRecordingToolbarView ()

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *trashImageView;

@end

@implementation TSRecordingToolbarView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.timerLabel.text = @"";
    self.leftRedMicImageView.image = [self.leftRedMicImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - Public methods

- (void)startDeleteAnimation {
    self.leftRedMicImageView.hidden = YES;
    self.trashImageView.hidden = NO;
}

- (void)resetUIState {
    self.leftRedMicImageView.hidden = NO;
    self.trashImageView.hidden = YES;
}

- (void)didPassedSeconds:(int)sec {
    if (sec < 0) {
        self.leftRedMicImageView.tintColor = [UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
        self.timerLabel.text = @"";
        return;
    } else {
        self.leftRedMicImageView.tintColor = [UIColor redColor];
    }
    
    int min = (sec / 60) % 60;
    int seconds = sec  - min * 60;
    
    NSMutableString *guaranteedTimeToReply = [NSMutableString string];
    
    if (min < 10) {
        [guaranteedTimeToReply appendFormat:@"0%zd:", min];
    } else {
        [guaranteedTimeToReply appendFormat:@"%zd:", min];
    }
    
    if (seconds < 10) {
        [guaranteedTimeToReply appendFormat:@"0%zd", seconds];
    } else {
        [guaranteedTimeToReply appendFormat:@"%zd", seconds];
    }
    
    self.timerLabel.text = guaranteedTimeToReply;
}


- (BOOL)isDeleteAnimationInProgress {
    return !self.trashImageView.hidden;
}

- (void)setCustomFontFamily:(NSString *)fontFamily {
    UIFont *font = self.timerLabel.font;
    NSString *finalFontName = [self customFontNameFromFontFamily:fontFamily initialFont:font];
    self.timerLabel.font = [UIFont fontWithName:finalFontName size:font.pointSize];
    
    font = self.cancelButton.titleLabel.font;
    finalFontName = [self customFontNameFromFontFamily:fontFamily initialFont:font];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:finalFontName size:font.pointSize];
    
    font = self.sendButton.titleLabel.font;
    finalFontName = [self customFontNameFromFontFamily:fontFamily initialFont:font];
    self.sendButton.titleLabel.font = [UIFont fontWithName:finalFontName size:font.pointSize];
}

#pragma mark - Private methods

- (NSString *)customFontNameFromFontFamily:(NSString *)fontFamily initialFont:(UIFont *)initialFont {
    NSArray *components = [initialFont.fontName componentsSeparatedByString:@"-"];
    NSString *fontType = nil;
    
    if (components.count > 1) {
        fontType = [components lastObject];
        NSString *fontName = [NSString stringWithFormat:@"%@-%@", fontFamily, fontType];
        
        // check if font exists, otherwise return the fontName without any special type
        if ([UIFont fontWithName:fontName size:10]) {
            return fontName;
        }
    }
    
    if ([UIFont fontWithName:fontFamily size:10]) {
        return fontFamily;
    }
    
    // invalid font family
    return initialFont.fontName;
}

@end
