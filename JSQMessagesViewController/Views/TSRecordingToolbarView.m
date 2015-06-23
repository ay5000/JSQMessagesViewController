//
//  TSRecordingToolbarView.m
//  talktala
//
//  Created by Oana Ban on 16/04/15.
//  Copyright (c) 2015 Groop Internet Platform inc. All rights reserved.
//

#import "TSRecordingToolbarView.h"

@interface TSRecordingToolbarView ()

@property (weak, nonatomic) IBOutlet UIImageView *rightMicImageView;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *trashImageView;

@end

@implementation TSRecordingToolbarView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.timerLabel.text = @"";
    self.rightMicImageView.image = [self.rightMicImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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

@end
