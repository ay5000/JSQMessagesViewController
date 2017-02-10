//
//  TSRecordingToolbarView.m
//  talktala
//
//  Created by Oana Ban on 16/04/15.
//  Copyright (c) 2015 Groop Internet Platform inc. All rights reserved.
//

#import "TSRecordingToolbarView.h"

@interface TSRecordingToolbarView ()

@property (weak, nonatomic,readwrite) IBOutlet UILabel *timerLabel;


@end

@implementation TSRecordingToolbarView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.timerLabel.text = @"00:00";
    self.timerLabel.alpha = 1.0;
    
}

#pragma mark - Public methods

- (void)startDeleteAnimation {

}

- (void)resetUIState {
    self.timerLabel.textColor = [UIColor colorWithRed:219.0/255.0
                                                green:219.0/255.0
                                                 blue:219.0/255.0 alpha:1.0];
    
    self.timerLabel.alpha = 0.0;
}

- (void)didPassedSeconds:(int)sec {
    
    if (sec < 0) {
        //self.timerLabel.text = @"";
        return;
    } else {
        /*
        self.timerLabel.textColor = [UIColor colorWithRed:233.0/255.0
                                                    green:0
                                                     blue:107.0/255.0 alpha:1.0];*/
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
