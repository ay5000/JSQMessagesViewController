//
//  JESMessagesBorderView.m
//  Pods
//
//  Created by Allan on 12/6/16.
//
//

#import <UIKit/UIKit.h>
#import "JSQMessagesBorderView.h"
#import <QuartzCore/QuartzCore.h>
#import "JSQMessagesCollectionViewLayoutAttributes.h"

@implementation JSQMessagesBorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
        //self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    JSQMessagesCollectionViewLayoutAttributes *attrs = (JSQMessagesCollectionViewLayoutAttributes*)layoutAttributes;
    self.backgroundColor = attrs.color;
}

@end
