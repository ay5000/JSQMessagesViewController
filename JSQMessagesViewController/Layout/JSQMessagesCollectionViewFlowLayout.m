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
//
//  Ideas for springy collection view layout taken from Ash Furrow
//  ASHSpringyCollectionView
//  https://github.com/AshFurrow/ASHSpringyCollectionView
//

#import "JSQMessagesCollectionViewFlowLayout.h"

#import "JSQMessageData.h"

#import "JSQMessagesCollectionView.h"
#import "JSQMessagesCollectionViewCell.h"

#import "JSQMessagesCollectionViewLayoutAttributes.h"
#import "JSQMessagesCollectionViewFlowLayoutInvalidationContext.h"

#import "UIImage+JSQMessages.h"

#import "JSQMessagesBorderView.h"


const CGFloat kJSQMessagesCollectionViewCellLabelHeightDefault = 20.0f;
const CGFloat kJSQMessagesCollectionViewAvatarSizeDefault = 30.0f;

#define MESSAGES_CONTENT_BUTTON_MIN_WIDTH 290 // Oana change
#define DECORATION_BORDER_IDENTIFIER @"JSQMessagesBorderView"

#define SEPARATOR_COLOR_GRAY [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0]
#define SEPARATOR_COLOR_CLEAR [UIColor clearColor]

@interface JSQMessagesCollectionViewFlowLayout ()

@property (strong, nonatomic) NSCache *messageBubbleCache;

@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) NSMutableSet *visibleIndexPaths;

@property (assign, nonatomic) CGFloat latestDelta;

@property (assign, nonatomic, readonly) NSUInteger bubbleImageAssetWidth;

- (void)jsq_configureFlowLayout;

- (void)jsq_didReceiveApplicationMemoryWarningNotification:(NSNotification *)notification;
- (void)jsq_didReceiveDeviceOrientationDidChangeNotification:(NSNotification *)notification;

- (void)jsq_resetLayout;
- (void)jsq_resetDynamicAnimator;

- (void)jsq_configureMessageCellLayoutAttributes:(JSQMessagesCollectionViewLayoutAttributes *)layoutAttributes;
- (CGSize)jsq_avatarSizeForIndexPath:(NSIndexPath *)indexPath;

- (UIAttachmentBehavior *)jsq_springBehaviorWithLayoutAttributesItem:(UICollectionViewLayoutAttributes *)item;
- (void)jsq_addNewlyVisibleBehaviorsFromVisibleItems:(NSArray *)visibleItems;
- (void)jsq_removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:(NSSet *)visibleItemsIndexPaths;
- (void)jsq_adjustSpringBehavior:(UIAttachmentBehavior *)springBehavior forTouchLocation:(CGPoint)touchLocation;

@property (nonatomic, assign) UIEdgeInsets messageBubbleTextViewTextContainerInsetsSystem;
@property (nonatomic, assign) UIEdgeInsets messageBubbleTextViewTextContainerInsetsLiveVideo;
@property (nonatomic, assign) UIEdgeInsets messageBubbleTextViewTextContainerInsetsWelcome;


@end



@implementation JSQMessagesCollectionViewFlowLayout

@dynamic collectionView;

#pragma mark - Initialization


- (void)jsq_configureFlowLayout
{
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.sectionInset = UIEdgeInsetsMake(10.0f, 4.0f, 20.0f, 4.0f);
    self.minimumLineSpacing = 3.0f;//1/[UIScreen mainScreen].scale;
    
    _bubbleImageAssetWidth = [UIImage jsq_bubbleCompactImage].size.width;
    
    _messageBubbleCache = [NSCache new];
    _messageBubbleCache.name = @"JSQMessagesCollectionViewFlowLayout.messageBubbleCache";
    _messageBubbleCache.countLimit = 200;
    
    _messageBubbleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _messageBubbleLeftRightMargin = 5.0f;  //Oana change;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _messageBubbleLeftRightMargin = 50.0f;
    }
    
    _messageBubbleTextViewFrameInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 6.0f);
    _messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(7.0f, 14.0f, 7.0f, 14.0f);
    _messageBubbleTextViewTextContainerInsetsSystem = UIEdgeInsetsMake(2.0f, 23.0f, 0.0f, 14.0f);
    _messageBubbleTextViewTextContainerInsetsLiveVideo = UIEdgeInsetsMake(46.0f, 14.0f, 7.0f, 14.0f);
    
    _messageBubbleTextViewTextContainerInsetsWelcome = UIEdgeInsetsMake(100.0f, 14.0f, 7.0f, 14.0f);

    
    CGSize defaultAvatarSize = CGSizeMake(kJSQMessagesCollectionViewAvatarSizeDefault, kJSQMessagesCollectionViewAvatarSizeDefault);
    _incomingAvatarViewSize = defaultAvatarSize;
    _outgoingAvatarViewSize = defaultAvatarSize;
    
    _springinessEnabled = NO;
    _springResistanceFactor = 1000;
    
    [self registerClass:[JSQMessagesBorderView class] forDecorationViewOfKind:DECORATION_BORDER_IDENTIFIER];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveApplicationMemoryWarningNotification:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveDeviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self jsq_configureFlowLayout];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self jsq_configureFlowLayout];
}

+ (Class)layoutAttributesClass
{
    return [JSQMessagesCollectionViewLayoutAttributes class];
}

+ (Class)invalidationContextClass
{
    return [JSQMessagesCollectionViewFlowLayoutInvalidationContext class];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _messageBubbleFont = nil;
    
    [_messageBubbleCache removeAllObjects];
    _messageBubbleCache = nil;
    
    [_dynamicAnimator removeAllBehaviors];
    _dynamicAnimator = nil;
    
    [_visibleIndexPaths removeAllObjects];
    _visibleIndexPaths = nil;
}

#pragma mark - Setters

- (void)setSpringinessEnabled:(BOOL)springinessEnabled
{
    if (_springinessEnabled == springinessEnabled) {
        return;
    }
    
    _springinessEnabled = springinessEnabled;
    
    if (!springinessEnabled) {
        [_dynamicAnimator removeAllBehaviors];
        [_visibleIndexPaths removeAllObjects];
    }
    [self invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleFont:(UIFont *)messageBubbleFont
{
    if ([_messageBubbleFont isEqual:messageBubbleFont]) {
        return;
    }
    
    NSParameterAssert(messageBubbleFont != nil);
    _messageBubbleFont = messageBubbleFont;
    [self invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleLeftRightMargin:(CGFloat)messageBubbleLeftRightMargin
{
    NSParameterAssert(messageBubbleLeftRightMargin >= 0.0f);
    _messageBubbleLeftRightMargin = ceilf(messageBubbleLeftRightMargin);
    [self invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setMessageBubbleTextViewTextContainerInsets:(UIEdgeInsets)messageBubbleTextContainerInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(_messageBubbleTextViewTextContainerInsets, messageBubbleTextContainerInsets)) {
        return;
    }
    
    _messageBubbleTextViewTextContainerInsets = messageBubbleTextContainerInsets;
    [self invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setIncomingAvatarViewSize:(CGSize)incomingAvatarViewSize
{
    if (CGSizeEqualToSize(_incomingAvatarViewSize, incomingAvatarViewSize)) {
        return;
    }
    
    _incomingAvatarViewSize = incomingAvatarViewSize;
    [self invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setOutgoingAvatarViewSize:(CGSize)outgoingAvatarViewSize
{
    if (CGSizeEqualToSize(_outgoingAvatarViewSize, outgoingAvatarViewSize)) {
        return;
    }
    
    _outgoingAvatarViewSize = outgoingAvatarViewSize;
    [self invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)setCacheLimit:(NSUInteger)cacheLimit
{
    self.messageBubbleCache.countLimit = cacheLimit;
}

#pragma mark - Getters

- (CGFloat)itemWidth
{
    return CGRectGetWidth(self.collectionView.frame) - self.sectionInset.left - self.sectionInset.right;
}

- (UIDynamicAnimator *)dynamicAnimator
{
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    return _dynamicAnimator;
}

- (NSMutableSet *)visibleIndexPaths
{
    if (!_visibleIndexPaths) {
        _visibleIndexPaths = [NSMutableSet new];
    }
    return _visibleIndexPaths;
}

- (NSUInteger)cacheLimit
{
    return self.messageBubbleCache.countLimit;
}

#pragma mark - Notifications

- (void)jsq_didReceiveApplicationMemoryWarningNotification:(NSNotification *)notification
{
    [self jsq_resetLayout];
}

- (void)jsq_didReceiveDeviceOrientationDidChangeNotification:(NSNotification *)notification
{
    [self jsq_resetLayout];
    [self invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

#pragma mark - Collection view flow layout

- (void)invalidateLayoutWithContext:(JSQMessagesCollectionViewFlowLayoutInvalidationContext *)context
{
    if (context.invalidateDataSourceCounts) {
        context.invalidateFlowLayoutAttributes = YES;
        context.invalidateFlowLayoutDelegateMetrics = YES;
        
    }
    
    if (context.invalidateFlowLayoutAttributes
        || context.invalidateFlowLayoutDelegateMetrics) {
        [self jsq_resetDynamicAnimator];
    }
    
    if (context.invalidateFlowLayoutMessagesCache) {
        [self jsq_resetLayout];
    }
    
    [super invalidateLayoutWithContext:context];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (self.springinessEnabled) {
        //  pad rect to avoid flickering
        CGFloat padding = -100.0f;
        CGRect visibleRect = CGRectInset(self.collectionView.bounds, padding, padding);
        
        NSArray *visibleItems = [super layoutAttributesForElementsInRect:visibleRect];
        NSSet *visibleItemsIndexPaths = [NSSet setWithArray:[visibleItems valueForKey:NSStringFromSelector(@selector(indexPath))]];
        
        [self jsq_removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:visibleItemsIndexPaths];
        
        [self jsq_addNewlyVisibleBehaviorsFromVisibleItems:visibleItems];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesInRect = [super layoutAttributesForElementsInRect:rect];
    
    if (self.springinessEnabled) {
        NSMutableArray *attributesInRectCopy = [attributesInRect mutableCopy];
        NSArray *dynamicAttributes = [self.dynamicAnimator itemsInRect:rect];
        
        //  avoid duplicate attributes
        //  use dynamic animator attribute item instead of regular item, if it exists
        for (UICollectionViewLayoutAttributes *eachItem in attributesInRect) {
            
            for (UICollectionViewLayoutAttributes *eachDynamicItem in dynamicAttributes) {
                if ([eachItem.indexPath isEqual:eachDynamicItem.indexPath]
                    && eachItem.representedElementCategory == eachDynamicItem.representedElementCategory) {
                    
                    [attributesInRectCopy removeObject:eachItem];
                    [attributesInRectCopy addObject:eachDynamicItem];
                    continue;
                }
            }
        }
        
        attributesInRect = attributesInRectCopy;
    }
    
    NSMutableArray *mutableAttributes = [NSMutableArray arrayWithArray:attributesInRect];
    
    [attributesInRect enumerateObjectsUsingBlock:^(JSQMessagesCollectionViewLayoutAttributes *attributesItem, NSUInteger idx, BOOL *stop) {
        if (attributesItem.representedElementCategory == UICollectionElementCategoryCell) {
            [self jsq_configureMessageCellLayoutAttributes:attributesItem];
            //[mutableAttributes addObjectsFromArray:[self jsq_addDecoratorViews:attributesItem]];
        }
        else {
            attributesItem.zIndex = -1;
        }
    }];
    
    ////// AY Testing
    //Inspiration from https://github.com/ericchapman/ios_decoration_view/
    
    CGFloat sepHeight = 1/[UIScreen mainScreen].scale;
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in attributesInRect)
    {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        
        id<JSQMessageData> messageItem = [self.collectionView.dataSource collectionView:self.collectionView messageDataForItemAtIndexPath:indexPath];

        if (indexPath.item >= 0 && layoutAttributes.representedElementKind == UICollectionElementCategoryCell)
        {
            id <UICollectionViewDelegateFlowLayout> delegate = (id <UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
            
            JSQMessagesCollectionViewLayoutAttributes *separatorAttributes = [JSQMessagesCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:DECORATION_BORDER_IDENTIFIER withIndexPath:indexPath];
            
            CGRect cellFrame = layoutAttributes.frame;
            
            separatorAttributes.frame = CGRectMake(cellFrame.origin.x-30, cellFrame.origin.y - sepHeight, cellFrame.size.width + 100, sepHeight);
            separatorAttributes.zIndex = 1000;
            
            
            BOOL lastMsgIsCenteredMessage = NO;
            
            if(indexPath.item > 0) {
                
                NSIndexPath *path = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
                
                //Last message was a centered message
                if([[self.collectionView.dataSource collectionView:self.collectionView messageDataForItemAtIndexPath:path] isCenteredMessage]) {
                    lastMsgIsCenteredMessage = YES;
                }
            }
            
            if(([messageItem isCenteredMessage] || lastMsgIsCenteredMessage) && indexPath.item > 0) {
                separatorAttributes.color = SEPARATOR_COLOR_GRAY;
            } else {
                separatorAttributes.color = SEPARATOR_COLOR_CLEAR;
            }
            
            //separatorAttributes.color = [UIColor blueColor];
            
            [mutableAttributes addObject:separatorAttributes];
        }
    }
    
    
    
    return mutableAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewLayoutAttributes *customAttributes = (JSQMessagesCollectionViewLayoutAttributes *)[super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (customAttributes.representedElementCategory == UICollectionElementCategoryCell) {
        [self jsq_configureMessageCellLayoutAttributes:customAttributes];
    }
    
    
    return customAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    

    
    if (self.springinessEnabled) {
        UIScrollView *scrollView = self.collectionView;
        CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
        
        self.latestDelta = delta;
        
        CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
        
        [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
            [self jsq_adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
            [self.dynamicAnimator updateItemUsingCurrentState:[springBehaviour.items firstObject]];
        }];
    }
    
    return YES;
    
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    
    return NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger index, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            
            if (self.springinessEnabled && [self.dynamicAnimator layoutAttributesForCellAtIndexPath:updateItem.indexPathAfterUpdate]) {
                *stop = YES;
            }
            
            CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.bounds);
            
            JSQMessagesCollectionViewLayoutAttributes *attributes = [JSQMessagesCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
            
            if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
                [self jsq_configureMessageCellLayoutAttributes:attributes];
            }
            
            attributes.frame = CGRectMake(0.0f,
                                          collectionViewHeight + CGRectGetHeight(attributes.frame),
                                          CGRectGetWidth(attributes.frame),
                                          CGRectGetHeight(attributes.frame));
            
            if (self.springinessEnabled) {
                UIAttachmentBehavior *springBehaviour = [self jsq_springBehaviorWithLayoutAttributesItem:attributes];
                [self.dynamicAnimator addBehavior:springBehaviour];
            }
        }
    }];
}

#pragma mark - Invalidation utilities

- (void)jsq_resetLayout
{
    [self.messageBubbleCache removeAllObjects];
    [self jsq_resetDynamicAnimator];
}

- (void)jsq_resetDynamicAnimator
{
    if (self.springinessEnabled) {
        [self.dynamicAnimator removeAllBehaviors];
        [self.visibleIndexPaths removeAllObjects];
    }
}

#pragma mark - Message cell layout utilities

-(UIEdgeInsets)getInsetsForIndexPath:(NSIndexPath*)indexPath {
    
    id<JSQMessageData> messageItem = [self.collectionView.dataSource collectionView:self.collectionView messageDataForItemAtIndexPath:indexPath];
    
    if([messageItem isLiveVideoMessage]) {
        return _messageBubbleTextViewTextContainerInsetsLiveVideo;
    } else if([messageItem isWelcomeMessage]) {
        return _messageBubbleTextViewTextContainerInsetsWelcome;
    } else if([messageItem isCenteredMessage]) {
        return _messageBubbleTextViewTextContainerInsetsSystem;
    } else {
        return _messageBubbleTextViewTextContainerInsets;
    }
}

- (CGSize)messageBubbleSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<JSQMessageData> messageItem = [self.collectionView.dataSource collectionView:self.collectionView messageDataForItemAtIndexPath:indexPath];
    
    // Oanaa change - commented
//    NSValue *cachedSize = [self.messageBubbleCache objectForKey:@([messageItem messageHash])];
//    if (cachedSize != nil) {
//        return [cachedSize CGSizeValue];
//    }
    
    CGSize finalSize = CGSizeZero;
    
    if ([messageItem isMediaMessage]) {
        finalSize = [[messageItem media] mediaViewDisplaySize];
    }  else {
        // Oana change
        if (messageItem.isBlurredMessage) {
            CGSize blurredSize = [self.collectionView.dataSource sizeOfBlurredCell];
            [self.messageBubbleCache setObject:[NSValue valueWithCGSize:blurredSize] forKey:indexPath];
            
            return blurredSize;
        }
        
        if (messageItem.isAudioMessage) {
            CGSize blurredSize = [self.collectionView.dataSource sizeOfAudioMessageCell];
            [self.messageBubbleCache setObject:[NSValue valueWithCGSize:blurredSize] forKey:indexPath];
            
            return blurredSize;
        }
        
        //////
        
        CGSize avatarSize = [self jsq_avatarSizeForIndexPath:indexPath];
        
        UIEdgeInsets textInsets = [self getInsetsForIndexPath:indexPath];
        
        //  from the cell xibs, there is a 2 point space between avatar and bubble
        CGFloat spacingBetweenAvatarAndBubble = 2.0f;
        CGFloat horizontalContainerInsets = textInsets.left + textInsets.right;
        CGFloat horizontalFrameInsets = self.messageBubbleTextViewFrameInsets.left + self.messageBubbleTextViewFrameInsets.right;
        
        CGFloat horizontalInsetsTotal = horizontalContainerInsets + horizontalFrameInsets + spacingBetweenAvatarAndBubble;
        CGFloat maximumTextWidth = self.itemWidth - avatarSize.width - self.messageBubbleLeftRightMargin - horizontalInsetsTotal;
        
        UIFont *textFont = [self.collectionView.dataSource customTextFontForItemAtIndexPath:indexPath]; // Oana change
        // Annie's change
        BOOL isIPAD = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        if ([messageItem isTextMessage] && isIPAD) {
            maximumTextWidth = ([[UIScreen mainScreen] bounds].size.width / 4) * 3;
        }
        CGRect stringRect = [[messageItem text] boundingRectWithSize:CGSizeMake(maximumTextWidth, CGFLOAT_MAX)
                                                             options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                          attributes:@{ NSFontAttributeName : textFont ? textFont : self.messageBubbleFont} // Oana change
                                                             context:nil];
        
        CGSize stringSize = CGRectIntegral(stringRect).size;
        
        CGFloat verticalContainerInsets = textInsets.top + textInsets.bottom;
        CGFloat verticalFrameInsets = self.messageBubbleTextViewFrameInsets.top + self.messageBubbleTextViewFrameInsets.bottom;
        
        //  add extra 2 points of space, because `boundingRectWithSize:` is slightly off
        //  not sure why. magix. (shrug) if you know, submit a PR
        CGFloat verticalInsets = verticalContainerInsets + verticalFrameInsets + 2.0f; //ay change - added back in
        
        //  same as above, an extra 2 points of magix
        CGFloat finalWidth = MAX(stringSize.width + horizontalInsetsTotal, self.bubbleImageAssetWidth) + 2.0f;
        
        // Oana change
        if (messageItem.hasMessageButton && finalWidth < MESSAGES_CONTENT_BUTTON_MIN_WIDTH) {
            finalWidth = MESSAGES_CONTENT_BUTTON_MIN_WIDTH;
        }
        
        if([messageItem isCenteredMessage]) {
            finalSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 20,stringSize.height + verticalInsets);
        } else {
            finalSize = CGSizeMake(finalWidth, stringSize.height + verticalInsets);
        }
        // Annie's change
        if ([messageItem isTextMessage] && isIPAD) {
            if (finalWidth >= maximumTextWidth) {
                finalSize = CGSizeMake(maximumTextWidth, stringSize.height + verticalInsets);
            } else {
                finalSize = CGSizeMake(finalWidth, stringSize.height + verticalInsets);
            }
        }
    }
    [self.messageBubbleCache setObject:[NSValue valueWithCGSize:finalSize] forKey:@([messageItem messageHash])];
    
    return finalSize;
}



- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize messageBubbleSize = [self messageBubbleSizeForItemAtIndexPath:indexPath];
    JSQMessagesCollectionViewLayoutAttributes *attributes = (JSQMessagesCollectionViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:indexPath];
    
    CGFloat finalHeight = messageBubbleSize.height;
    finalHeight += attributes.cellTopLabelHeight;
    finalHeight += attributes.messageBubbleTopLabelHeight;
    finalHeight += attributes.cellBottomLabelHeight;
    
    return CGSizeMake(self.itemWidth, ceilf(finalHeight));
}

- (void)jsq_configureMessageCellLayoutAttributes:(JSQMessagesCollectionViewLayoutAttributes *)layoutAttributes
{
    NSIndexPath *indexPath = layoutAttributes.indexPath;
    
    CGSize messageBubbleSize = [self messageBubbleSizeForItemAtIndexPath:indexPath];
    //    CGFloat remainingItemWidthForBubble = self.itemWidth - [self jsq_avatarSizeForIndexPath:indexPath].width;
    //
    //    CGFloat textPadding = _messageBubbleTextViewTextContainerInsets.top +  _messageBubbleTextViewTextContainerInsets.bottom + _messageBubbleTextViewTextContainerInsets.right + _messageBubbleTextViewTextContainerInsets.left;
    //    CGFloat messageBubblePadding = MAX(0,remainingItemWidthForBubble - messageBubbleSize.width - textPadding); // Oana change
    
    layoutAttributes.messageBubbleContainerViewWidth = messageBubbleSize.width;
    
    layoutAttributes.textViewFrameInsets = self.messageBubbleTextViewFrameInsets;
    
    layoutAttributes.textViewTextContainerInsets = [self getInsetsForIndexPath:indexPath];
    
    layoutAttributes.messageBubbleFont = self.messageBubbleFont;
    
    layoutAttributes.incomingAvatarViewSize = self.incomingAvatarViewSize;
    
    id<JSQMessageAvatarImageDataSource> avatarImageDataSource = [self.collectionView.dataSource collectionView:self.collectionView avatarImageDataForItemAtIndexPath:indexPath];
    
    if (avatarImageDataSource) {
        layoutAttributes.outgoingAvatarViewSize = self.outgoingAvatarViewSize;
    } else {
        layoutAttributes.outgoingAvatarViewSize = CGSizeZero;
    }
    
    layoutAttributes.cellTopLabelHeight = [self.collectionView.delegate collectionView:self.collectionView
                                                                                layout:self
                                                      heightForCellTopLabelAtIndexPath:indexPath];
    
    // Oana change
    if (layoutAttributes.cellTopLabelHeight == 0) {
        layoutAttributes.textViewFrameInsets = UIEdgeInsetsMake(layoutAttributes.textViewFrameInsets.top, layoutAttributes.textViewFrameInsets.left, layoutAttributes.textViewFrameInsets.bottom, 0);
    }
    
    layoutAttributes.messageBubbleTopLabelHeight = [self.collectionView.delegate collectionView:self.collectionView
                                                                                         layout:self
                                                      heightForMessageBubbleTopLabelAtIndexPath:indexPath];
    
    layoutAttributes.cellBottomLabelHeight = [self.collectionView.delegate collectionView:self.collectionView
                                                                                   layout:self
                                                      heightForCellBottomLabelAtIndexPath:indexPath];
    
    

}

-(NSArray<UICollectionViewLayoutAttributes *> *)jsq_addDecoratorViews:(JSQMessagesCollectionViewLayoutAttributes *)layoutAttributes {
    
    NSMutableArray* attributes = [NSMutableArray array];
    
    NSIndexPath *indexPath = layoutAttributes.indexPath;
    
    id<JSQMessageData> messageItem = [self.collectionView.dataSource collectionView:self.collectionView messageDataForItemAtIndexPath:indexPath];
    
    if([messageItem isCenteredMessage]) {
        
        
        [attributes addObject:[self layoutAttributesForDecorationViewOfKind:DECORATION_BORDER_IDENTIFIER atIndexPath:indexPath]];
        [attributes addObject:[self layoutAttributesForDecorationViewOfKind:DECORATION_BORDER_IDENTIFIER atIndexPath:indexPath]];
    }
    
    return attributes;
}

- (CGSize)jsq_avatarSizeForIndexPath:(NSIndexPath *)indexPath
{
    id<JSQMessageData> messageData = [self.collectionView.dataSource collectionView:self.collectionView messageDataForItemAtIndexPath:indexPath];
    NSString *messageSender = [messageData senderId];
   
    if ([messageSender isEqualToString:[self.collectionView.dataSource senderId]]) {
        return self.outgoingAvatarViewSize;
    }
    
    return self.incomingAvatarViewSize;
}

#pragma mark - Spring behavior utilities

- (UIAttachmentBehavior *)jsq_springBehaviorWithLayoutAttributesItem:(UICollectionViewLayoutAttributes *)item
{
    if (CGSizeEqualToSize(item.frame.size, CGSizeZero)) {
        // adding a spring behavior with zero size will fail in in -prepareForCollectionViewUpdates:
        return nil;
    }
    
    UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
    springBehavior.length = 1.0f;
    springBehavior.damping = 1.0f;
    springBehavior.frequency = 1.0f;
    return springBehavior;
}

- (void)jsq_addNewlyVisibleBehaviorsFromVisibleItems:(NSArray *)visibleItems
{
    //  a "newly visible" item is in `visibleItems` but not in `self.visibleIndexPaths`
    NSIndexSet *indexSet = [visibleItems indexesOfObjectsPassingTest:^BOOL(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop) {
        return ![self.visibleIndexPaths containsObject:item.indexPath];
    }];
    
    NSArray *newlyVisibleItems = [visibleItems objectsAtIndexes:indexSet];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger index, BOOL *stop) {
        UIAttachmentBehavior *springBehaviour = [self jsq_springBehaviorWithLayoutAttributesItem:item];
        [self jsq_adjustSpringBehavior:springBehaviour forTouchLocation:touchLocation];
        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleIndexPaths addObject:item.indexPath];
    }];
}

- (void)jsq_removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths:(NSSet *)visibleItemsIndexPaths
{
    NSArray *behaviors = self.dynamicAnimator.behaviors;
    
    NSIndexSet *indexSet = [behaviors indexesOfObjectsPassingTest:^BOOL(UIAttachmentBehavior *springBehaviour, NSUInteger index, BOOL *stop) {
        UICollectionViewLayoutAttributes *layoutAttributes = [springBehaviour.items firstObject];
        return ![visibleItemsIndexPaths containsObject:layoutAttributes.indexPath];
    }];
    
    NSArray *behaviorsToRemove = [self.dynamicAnimator.behaviors objectsAtIndexes:indexSet];
    
    [behaviorsToRemove enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger index, BOOL *stop) {
        UICollectionViewLayoutAttributes *layoutAttributes = [springBehaviour.items firstObject];
        [self.dynamicAnimator removeBehavior:springBehaviour];
        [self.visibleIndexPaths removeObject:layoutAttributes.indexPath];
    }];
}

- (void)jsq_adjustSpringBehavior:(UIAttachmentBehavior *)springBehavior forTouchLocation:(CGPoint)touchLocation
{
    UICollectionViewLayoutAttributes *item = [springBehavior.items firstObject];
    CGPoint center = item.center;
    
    //  if touch is not (0,0) -- adjust item center "in flight"
    if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
        CGFloat distanceFromTouch = fabs(touchLocation.y - springBehavior.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / self.springResistanceFactor;
        
        if (self.latestDelta < 0.0f) {
            center.y += MAX(self.latestDelta, self.latestDelta * scrollResistance);
        }
        else {
            center.y += MIN(self.latestDelta, self.latestDelta * scrollResistance);
        }
        item.center = center;
    }
}

#pragma mark - Decoration views

-(UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    

    JSQMessagesCollectionViewLayoutAttributes *layoutAttributes = [JSQMessagesCollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];

    return layoutAttributes;
    
}

- (NSArray*)indexPathsOfSeparatorsInRect:(CGRect)rect {
    NSInteger firstCellIndexToShow = floorf(rect.origin.y / self.itemSize.height);
    NSInteger lastCellIndexToShow = floorf((rect.origin.y + CGRectGetHeight(rect)) / self.itemSize.height);
    NSInteger countOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    
    NSMutableArray* indexPaths = [NSMutableArray new];
    for (int i = MAX(firstCellIndexToShow, 0); i <= lastCellIndexToShow; i++) {
        if (i < countOfItems) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    return indexPaths;
}
/*
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath {
    
    UICollectionViewLayoutAttributes *layoutAttributes =  [self layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:decorationIndexPath];
    return layoutAttributes;
}*/

@end
