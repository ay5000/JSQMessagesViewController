//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "UIImage+JSQMessages.h"


@interface JSQMessagesMediaViewBubbleImageMasker ()

@property (strong, nonatomic, readwrite) JSQMessagesBubbleImageFactory *bubbleImageFactory;
@property (strong, nonatomic, readwrite) NSMutableArray<JSQMessagesBubbleImageFactory*> *bubbleFactories;

- (void)jsq_maskView:(UIView *)view withImage:(UIImage *)image;

@end


@implementation JSQMessagesMediaViewBubbleImageMasker

#pragma mark - Initialization


- (instancetype)init {
    return [self initWithClusterImageFactory:JSQBubbleClusterNone];
}
 

- (instancetype)initWithBubbleImageFactory:(JSQMessagesBubbleImageFactory *)bubbleImageFactory {
    NSParameterAssert(bubbleImageFactory != nil);
    
    self = [super init];
    if (self) {
        _bubbleImageFactory = bubbleImageFactory;
    }
    return self;
}

-(instancetype)initWithClusterBubbleImageFactories {
    
    self = [super init];
    
    if(self) {
        self.bubbleFactories = [[NSMutableArray alloc] init];
        
        [self.bubbleFactories addObject:[[JSQMessagesBubbleImageFactory alloc]
                                     initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessImage] capInsets:UIEdgeInsetsZero]];
        
        [self.bubbleFactories addObject:[[JSQMessagesBubbleImageFactory alloc]
                                     initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessClusterStartImage] capInsets:UIEdgeInsetsZero]];
        
        [self.bubbleFactories addObject:[[JSQMessagesBubbleImageFactory alloc]
                                     initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessClusterMiddleImage] capInsets:UIEdgeInsetsZero]];
        
        [self.bubbleFactories addObject:[[JSQMessagesBubbleImageFactory alloc]
                                     initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessClusterEndImage] capInsets:UIEdgeInsetsZero]];
        
        for(id i in _bubbleFactories) {
            NSAssert(i != nil,@"Invalid setup for JSQMessagesMediaViewBubbleImageMasker cluster bubble factories");
        }
    }
    
    return self;
}

-(instancetype)initWithClusterImageFactory:(JSQBubbleClusterType)clusterType {
    
    self = [super init];
    
    if(self) {

        switch(clusterType) {
            case JSQBubbleClusterNone:
                self.bubbleImageFactory = [[JSQMessagesBubbleImageFactory alloc]
                                       initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessImage] capInsets:UIEdgeInsetsZero];
                break;
            case JSQBubbleClusterStart:
                self.bubbleImageFactory = [[JSQMessagesBubbleImageFactory alloc]
                                       initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessClusterStartImage] capInsets:UIEdgeInsetsZero];
                break;
            case JSQBubbleClusterMiddle:
                self.bubbleImageFactory = [[JSQMessagesBubbleImageFactory alloc]
                                       initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessClusterMiddleImage] capInsets:UIEdgeInsetsZero];
                break;
            case JSQBubbleClusterEnd:
                self.bubbleImageFactory = [[JSQMessagesBubbleImageFactory alloc]
                                       initWithBubbleImage:[UIImage jsq_bubbleCompactTaillessClusterEndImage] capInsets:UIEdgeInsetsZero];
                break;
            default:
                NSAssert(NO,@"Invalid JSQBubbleClusterType provided");
        }
        

        
        NSAssert(self.bubbleImageFactory != nil,@"Invalid setup for JSQMessagesMediaViewBubbleImageMasker cluster bubble factory");
    }
    
    return self;
}

#pragma mark - View masking

- (void)applyOutgoingBubbleImageMaskToMediaView:(UIView *)mediaView
{
    JSQMessagesBubbleImage *bubbleImageData = [_bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    [self jsq_maskView:mediaView withImage:[bubbleImageData messageBubbleImage]];
}

- (void)applyIncomingBubbleImageMaskToMediaView:(UIView *)mediaView
{
    JSQMessagesBubbleImage *bubbleImageData = [_bubbleImageFactory incomingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    [self jsq_maskView:mediaView withImage:[bubbleImageData messageBubbleImage]];
}

+ (void)applyBubbleImageMaskToMediaView:(UIView *)mediaView isOutgoing:(BOOL)isOutgoing
{
    JSQMessagesMediaViewBubbleImageMasker *masker = [[JSQMessagesMediaViewBubbleImageMasker alloc] init];
    
    if (isOutgoing) {
        [masker applyOutgoingBubbleImageMaskToMediaView:mediaView];
    }
    else {
        [masker applyIncomingBubbleImageMaskToMediaView:mediaView];
    }
}

+ (void)applyBubbleImageMaskToMediaView:(UIView *)mediaView isOutgoing:(BOOL)isOutgoing clusterType:(JSQBubbleClusterType)clusterType {
    
    JSQMessagesMediaViewBubbleImageMasker *masker = [[JSQMessagesMediaViewBubbleImageMasker alloc] initWithClusterImageFactory:clusterType];
    
    if (isOutgoing) {
        [masker applyOutgoingBubbleImageMaskToMediaView:mediaView];
    }
    else {
        [masker applyIncomingBubbleImageMaskToMediaView:mediaView];
    }
    
}

#pragma mark - Private

- (void)jsq_maskView:(UIView *)view withImage:(UIImage *)image
{
    NSParameterAssert(view != nil);
    NSParameterAssert(image != nil);
    
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 0 , 0);// 2.0f, 2.0f); AY Change
    
    view.layer.mask = imageViewMask.layer;
}

@end
