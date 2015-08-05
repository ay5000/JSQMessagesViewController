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

#import "JSQMessagesToolbarContentView.h"

#import "UIView+JSQMessages.h"
#import "UIView+TSJSQConstraintsAdditions.h"

const CGFloat kJSQMessagesToolbarContentViewHorizontalSpacingDefault = 8.0f;


@interface JSQMessagesToolbarContentView () {
    NSLayoutConstraint *_lastRightBarButtonItemWidthConstraint;
    int _defaultRightBarButtonItemWidth;
    NSLayoutConstraint *_firstRightBarButtonItemWidthConstraint;
}

@property (weak, nonatomic) IBOutlet JSQMessagesComposerTextView *textView;

@property (weak, nonatomic) IBOutlet UIView *leftBarButtonContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBarButtonContainerViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *rightBarButtonContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBarButtonContainerViewWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftHorizontalSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightHorizontalSpacingConstraint;

@end

// Oana change - JSQMessagesToolbarContentView.xib - added a top turquize line

@implementation JSQMessagesToolbarContentView

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([JSQMessagesToolbarContentView class])
                          bundle:[NSBundle mainBundle]];
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.leftHorizontalSpacingConstraint.constant = kJSQMessagesToolbarContentViewHorizontalSpacingDefault;
    self.rightHorizontalSpacingConstraint.constant = kJSQMessagesToolbarContentViewHorizontalSpacingDefault;
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc
{
    _textView = nil;
    _leftBarButtonItem = nil;
    _rightBarButtonItem = nil;
    _leftBarButtonContainerView = nil;
    _rightBarButtonContainerView = nil;
}

#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.leftBarButtonContainerView.backgroundColor = backgroundColor;
    self.rightBarButtonContainerView.backgroundColor = backgroundColor;
}

- (void)setLeftBarButtonItem:(UIButton *)leftBarButtonItem
{
    if (_leftBarButtonItem) {
        [_leftBarButtonItem removeFromSuperview];
    }
    
    if (!leftBarButtonItem) {
        _leftBarButtonItem = nil;
        self.leftHorizontalSpacingConstraint.constant = 0.0f;
        self.leftBarButtonItemWidth = 0.0f;
        self.leftBarButtonContainerView.hidden = YES;
        return;
    }
    
    if (CGRectEqualToRect(leftBarButtonItem.frame, CGRectZero)) {
        leftBarButtonItem.frame = self.leftBarButtonContainerView.bounds;
    }
    
    self.leftBarButtonContainerView.hidden = NO;
    self.leftHorizontalSpacingConstraint.constant = kJSQMessagesToolbarContentViewHorizontalSpacingDefault;
    self.leftBarButtonItemWidth = CGRectGetWidth(leftBarButtonItem.frame);
    
    [self.leftBarButtonContainerView addSubview:leftBarButtonItem];
    [self.leftBarButtonContainerView jsq_pinAllEdgesOfSubview:leftBarButtonItem];
    [self setNeedsUpdateConstraints];
    
    _leftBarButtonItem = leftBarButtonItem;
}

- (void)setLeftBarButtonItemWidth:(CGFloat)leftBarButtonItemWidth
{
    self.leftBarButtonContainerViewWidthConstraint.constant = leftBarButtonItemWidth;
    [self setNeedsUpdateConstraints];
}

- (void)setRightBarButtonItem:(UIButton *)rightBarButtonItem
{
    if (_rightBarButtonItem) {
        [_rightBarButtonItem removeFromSuperview];
    }
    
    if (!rightBarButtonItem) {
        _rightBarButtonItem = nil;
        self.rightHorizontalSpacingConstraint.constant = 0.0f;
        self.rightBarButtonItemWidth = 0.0f;
        self.rightBarButtonContainerView.hidden = YES;
        return;
    }
    
    if (CGRectEqualToRect(rightBarButtonItem.frame, CGRectZero)) {
        rightBarButtonItem.frame = self.rightBarButtonContainerView.bounds;
    }
    
    self.rightBarButtonContainerView.hidden = NO;
    self.rightHorizontalSpacingConstraint.constant = kJSQMessagesToolbarContentViewHorizontalSpacingDefault;
    self.rightBarButtonItemWidth = CGRectGetWidth(rightBarButtonItem.frame);
    
    [self.rightBarButtonContainerView addSubview:rightBarButtonItem];
    [self.rightBarButtonContainerView jsq_pinAllEdgesOfSubview:rightBarButtonItem];
    [self setNeedsUpdateConstraints];
    
    _rightBarButtonItem = rightBarButtonItem;
}

- (void)setRightBarButtonItemWidth:(CGFloat)rightBarButtonItemWidth
{
    self.rightBarButtonContainerViewWidthConstraint.constant = rightBarButtonItemWidth;
    [self setNeedsUpdateConstraints];
}

#pragma mark - Getters

- (CGFloat)leftBarButtonItemWidth
{
    return self.leftBarButtonContainerViewWidthConstraint.constant;
}

- (CGFloat)rightBarButtonItemWidth
{
    return self.rightBarButtonContainerViewWidthConstraint.constant;
}

#pragma mark - UIView overrides

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self.textView setNeedsDisplay];
}

// Oana new change
#pragma mark - Public methods

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems {
    for (UIButton *button in self.rightBarButtonContainerView.subviews) {
        [button removeFromSuperview];
    }
    
    if (!rightBarButtonItems) {
        _rightBarButtonItem = nil;
        self.rightHorizontalSpacingConstraint.constant = 0.0f;
        self.rightBarButtonItemWidth = 0.0f;
        self.rightBarButtonContainerView.hidden = YES;
        return;
    }
    
    self.rightBarButtonContainerView.hidden = NO;
    self.rightHorizontalSpacingConstraint.constant = kJSQMessagesToolbarContentViewHorizontalSpacingDefault;
    float width = 0;
    
    if (rightBarButtonItems.count >= 2) {
        UIButton *leftButton = rightBarButtonItems[0];
        UIButton *rightButton = rightBarButtonItems[1];
        width += CGRectGetWidth(leftButton.frame);
        width += CGRectGetWidth(rightButton.frame);
        [self.rightBarButtonContainerView addSubview:leftButton];
        [self.rightBarButtonContainerView addSubview:rightButton];
        leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [leftButton addDimensions:ALViewDimentionHeight value:leftButton.frame.size.height];
        [leftButton addDimensions:ALViewDimensionWidth value:leftButton.frame.size.width];
        NSArray *constraints = [leftButton addDimensions:ALViewDimensionWidth value:leftButton.frame.size.width];
        _firstRightBarButtonItemWidthConstraint = [constraints lastObject];
        
        [rightButton addDimensions:ALViewDimentionHeight value:rightButton.frame.size.height];
        constraints = [rightButton addDimensions:ALViewDimensionWidth value:rightButton.frame.size.width];
        _lastRightBarButtonItemWidthConstraint = [constraints lastObject];
        _defaultRightBarButtonItemWidth = _lastRightBarButtonItemWidthConstraint.constant;
        
        [leftButton alignToView:self.rightBarButtonContainerView alignProperties:ALAlignPropertyTop spacing:0];
        [rightButton alignToView:self.rightBarButtonContainerView alignProperties:ALAlignPropertyTop spacing:0];
        [leftButton alignToView:self.rightBarButtonContainerView alignProperties:ALAlignPropertyLeft spacing:0];
        [rightButton alignToView:self.rightBarButtonContainerView alignProperties:ALAlignPropertyRight spacing:0];
    }
    
    self.rightBarButtonItemWidth = width;
    [self setNeedsUpdateConstraints];
    
    _rightBarButtonItem = (rightBarButtonItems.count > 0) ? rightBarButtonItems[0] : nil;
    _lastRightBarButtonItem = (rightBarButtonItems.count > 1) ? rightBarButtonItems[1] : nil;
}

- (void)shouldHideLastRightBarButtonItem:(BOOL)shouldHide {
    _isLastRightBarButtonItemHidden = shouldHide;
    _lastRightBarButtonItemWidthConstraint.constant = shouldHide ? 0 : _defaultRightBarButtonItemWidth;
    self.rightBarButtonItemWidth = _rightBarButtonItem.frame.size.width + _lastRightBarButtonItemWidthConstraint.constant;
    [self layoutIfNeeded];
}

- (void)shouldHideFirstRightBarButtonItem:(BOOL)shouldHide {
    _isFirstRightBarButtonItemHidden = shouldHide;
    _firstRightBarButtonItemWidthConstraint.constant = shouldHide ? 0 : _defaultRightBarButtonItemWidth;
    self.rightBarButtonItemWidth = _rightBarButtonItem.frame.size.width + _lastRightBarButtonItemWidthConstraint.constant;
    [self layoutIfNeeded];
}

@end
