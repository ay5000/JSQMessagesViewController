//
//  UIView+TSJSQConstraintsAdditions.m
//  AutoLayoutCoding
//
//  Created by ; on 5/12/14.
//  Copyright (c) 2014 SV. All rights reserved.
//
#import "UIView+TSJSQConstraintsAdditions.h"

@implementation UIView (TSJSQConstraintsAdditions)

+ (id)autolayoutView
{
	UIView *view = [UIView new];
	[view setupViewForAutolayout];
	[view setBackgroundColor:[UIColor grayColor]];
#if TECH_TALK
	[view setBackgroundColor:[UIColor colorWithRed:arc4random() / (CGFloat)UINT32_MAX green:arc4random() / (CGFloat)UINT32_MAX blue:arc4random() / (CGFloat)UINT32_MAX alpha:1.0]];
#endif
	return view;
}

- (void)setupViewForAutolayout
{
	[self setTranslatesAutoresizingMaskIntoConstraints:NO];
#if TECH_TALK
	[self setBackgroundColor:[UIColor colorWithRed:arc4random() / (CGFloat)UINT32_MAX green:arc4random() / (CGFloat)UINT32_MAX blue:arc4random() / (CGFloat)UINT32_MAX alpha:1.0]];
#endif
}

#pragma mark -
#pragma mark Helpers

+ (UIView *)commonSuperviewOfView:(UIView *)aView andView:(UIView *)anotherView
{
	NSMutableArray *superviews = [NSMutableArray arrayWithObject:aView];
	UIView *view = aView;
	while ( view.superview ) {
		[superviews addObject:view.superview];
		view = view.superview;
	}
	
	view = anotherView;
	while (view) {
		if ( [superviews containsObject:view] )
			return view;
		view = view.superview;
	}
	
	return nil;
}

+ (NSLayoutAttribute)attributeFromEdge:(ALViewEdges)edge
{
	switch (edge) {
		case ALViewEdgeBottom:
			return NSLayoutAttributeBottom;
		case ALViewEdgeLeft:
			return NSLayoutAttributeLeading;
		case ALViewEdgeRight:
			return NSLayoutAttributeTrailing;
		case ALViewEdgeTop:
			return NSLayoutAttributeTop;
		default:
			return 0;
			break;
	}
}

+ (NSLayoutAttribute)attributeFromAlignProperty:(ALAlignProperties)alignProperty
{
	switch (alignProperty) {
		case ALAlignPropertyTop:
			return NSLayoutAttributeTop;
		case ALAlignPropertyBottom:
			return NSLayoutAttributeBottom;
		case ALAlignPropertyLeft:
			return NSLayoutAttributeLeft;
		case ALAlignPropertyRight:
			return NSLayoutAttributeRight;
		case ALAlignPropertyCenterX:
			return NSLayoutAttributeCenterX;
		case ALAlignPropertyCenterY:
			return NSLayoutAttributeCenterY;
			
		default:
			return 0;
			break;
	}
}

+ (ALViewEdges)oppositeEdge:(ALViewEdges)edge
{
	switch (edge) {
		case ALViewEdgeBottom:
			return ALViewEdgeTop;
		case ALViewEdgeLeft:
			return ALViewEdgeRight;
		case ALViewEdgeRight:
			return ALViewEdgeLeft;
		case ALViewEdgeTop:
			return ALViewEdgeBottom;
			
		default:
			return 0;
			break;
	}
}

+ (NSLayoutAttribute)attributeFromProperty:(ALViewDimensions)property
{
	switch (property) {
		case ALViewDimentionHeight:
			return NSLayoutAttributeHeight;
		case ALViewDimensionWidth:
			return NSLayoutAttributeWidth;
			
		default:
			return 0;
			break;
	}
}

#pragma mark -
#pragma mark Pin Views

- (NSArray *)pinToView:(UIView *)view edges:(ALViewEdges)edge spacing:(CGFloat)spacing relation:(NSLayoutRelation)relation
{
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:4];
	if ( edge & ALViewEdgeTop )
		[arr addObject:[self addPinToView:view edge:ALViewEdgeTop spacing:spacing relation:relation]];
	
	if ( edge & ALViewEdgeBottom )
		[arr addObject:[view addPinToView:self edge:ALViewEdgeTop spacing:spacing relation:relation]];
	
	if ( edge & ALViewEdgeLeft )
		[arr addObject:[self addPinToView:view edge:ALViewEdgeLeft spacing:spacing relation:relation]];
	
	if ( edge & ALViewEdgeRight )
		[arr addObject:[view addPinToView:self edge:ALViewEdgeLeft spacing:spacing relation:relation]];
		 
	return arr;
}

- (NSArray *)pinToView:(UIView *)view edges:(ALViewEdges)edge spacing:(CGFloat)spacing
{
	return [self pinToView:view edges:edge spacing:spacing relation:NSLayoutRelationEqual];
}

- (NSLayoutConstraint *)addPinToView:(UIView *)view edge:(ALViewEdges)edge spacing:(CGFloat)spacing relation:(NSLayoutRelation)relation
{
	UIView *commonSuperview = [UIView commonSuperviewOfView:self andView:view];
	NSLayoutAttribute attribute1 = [UIView attributeFromEdge:edge];
	NSLayoutAttribute attribute2 = [UIView attributeFromEdge:[UIView oppositeEdge:edge]];
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute1 relatedBy:relation toItem:view attribute:attribute2 multiplier:1.0 constant:spacing];
	[commonSuperview addConstraint:constraint];
	return constraint;
}

#pragma mark -
#pragma mark Align Views

- (NSArray *)alignToView:(UIView *)view alignProperties:(ALAlignProperties)alignProperty spacing:(CGFloat)spacing relation:(NSLayoutRelation)relation
{
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:6];
	if ( alignProperty & ALAlignPropertyTop )
		[arr addObject:[self addAlignToView:view alignProperty:ALAlignPropertyTop spacing:spacing relation:relation]];
	
	if ( alignProperty & ALAlignPropertyBottom )
		[arr addObject:[view addAlignToView:self alignProperty:ALAlignPropertyBottom spacing:spacing relation:relation]];
	
	if ( alignProperty & ALAlignPropertyLeft )
		[arr addObject:[self addAlignToView:view alignProperty:ALAlignPropertyLeft spacing:spacing relation:relation]];
	
	if ( alignProperty & ALAlignPropertyRight )
		[arr addObject:[view addAlignToView:self alignProperty:ALAlignPropertyRight spacing:spacing relation:relation]];
	
	if ( alignProperty & ALAlignPropertyCenterX)
		[arr addObject:[self addAlignToView:view alignProperty:ALAlignPropertyCenterX spacing:spacing relation:relation]];
	
	if ( alignProperty & ALAlignPropertyCenterY)
		[arr addObject:[self addAlignToView:view alignProperty:ALAlignPropertyCenterY spacing:spacing relation:relation]];
	
	return arr;
}

- (NSArray *)alignToView:(UIView *)view alignProperties:(ALAlignProperties)alignProperty spacing:(CGFloat)spacing
{
	return [self alignToView:view alignProperties:alignProperty spacing:spacing relation:NSLayoutRelationEqual];
}

- (NSLayoutConstraint *)addAlignToView:(UIView *)view alignProperty:(ALAlignProperties)alignProperty spacing:(CGFloat)spacing relation:(NSLayoutRelation)relation
{
	UIView *commonSuperview = [UIView commonSuperviewOfView:self andView:view];
	NSLayoutAttribute attribute = [UIView attributeFromAlignProperty:alignProperty];
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:view attribute:attribute multiplier:1.0 constant:spacing];
	[commonSuperview addConstraint:constraint];
	return constraint;
}

#pragma mark -
#pragma mark Dimensions

- (NSLayoutConstraint *)constraintForDimension:(ALViewDimensions)property
{
	NSLayoutAttribute attribute = [UIView attributeFromProperty:property];
	if ( attribute == NSLayoutAttributeNotAnAttribute ) return nil;
	
	for (NSLayoutConstraint *constraint in self.constraints) {
		if ( constraint.firstItem == self && constraint.secondItem == nil && constraint.firstAttribute == attribute && constraint.secondAttribute == NSLayoutAttributeNotAnAttribute )
			return constraint;
	}
	
	return nil;
}

- (NSArray *)addDimensions:(ALViewDimensions)property value:(CGFloat)value
{
	return [self addDimensions:property value:value relation:NSLayoutRelationEqual];
}

- (NSArray *)addDimensions:(ALViewDimensions)property value:(CGFloat)value relation:(NSLayoutRelation)relation
{
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:2];
	
	if ( property & ALViewDimensionWidth ) {
		NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:value];
		[self addConstraint:constraint];
		[arr addObject:constraint];
	}
	
	if ( property & ALViewDimentionHeight ) {
		NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:value];
		[self addConstraint:constraint];
		[arr addObject:constraint];
	}
	
	return arr;
}

- (NSArray *)equalDimensions:(ALViewDimensions)property toView:(UIView *)view
{
	return [self matchDimensions:property toView:view relation:NSLayoutRelationEqual];
}

- (NSArray *)matchDimensions:(ALViewDimensions)property toView:(UIView *)view relation:(NSLayoutRelation)relation value:(CGFloat)value {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:2];
	
	if ( property & ALViewDimensionWidth )
		[arr addObject:[self pinViewProperty:ALViewDimensionWidth toView:view relation:relation value:value]];
	
	if ( property & ALViewDimentionHeight )
		[arr addObject:[self pinViewProperty:ALViewDimentionHeight toView:view relation:relation value:value]];
	return arr;
}

- (NSArray *)matchDimensions:(ALViewDimensions)property toView:(UIView *)view relation:(NSLayoutRelation)relation
{
	return [self matchDimensions:property toView:view relation:relation value:0.0f];
}

- (NSLayoutConstraint *)pinViewProperty:(ALViewDimensions)property toView:(UIView *)view relation:(NSLayoutRelation)relation value:(CGFloat)value
{
	UIView *commonSuperview = [UIView commonSuperviewOfView:self andView:view];
	NSLayoutAttribute attribute = [UIView attributeFromProperty:property];
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:attribute relatedBy:relation toItem:view attribute:attribute multiplier:1.0 constant:value];
	[commonSuperview addConstraint:constraint];
	return constraint;
}


#pragma mark -
#pragma mark Aspect ratio

- (NSLayoutConstraint *)setAspectRatio:(CGFloat)aspectRatio
{
	return [self setAspectRatio:aspectRatio relation:NSLayoutRelationEqual];
}

- (NSLayoutConstraint *)setAspectRatio:(CGFloat)aspectRatio relation:(NSLayoutRelation)relation
{
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:relation toItem:self attribute:NSLayoutAttributeHeight multiplier:aspectRatio constant:0.0];
	[self addConstraint:constraint];
	return constraint;
}

@end


/**
 *  Adds constraints for an array of views
 */
@implementation UIView (ArrayConstraintsAdditions)

+ (void)pinArrayOfViews:(NSArray *)views edge:(ALViewEdges)edge spacing:(CGFloat)spacing relation:(NSLayoutRelation)relation
{
	if ( views.count < 2 ) return;
	UIView *previousView = [views firstObject];
	for (NSInteger i = 1; i < views.count; i ++) {
		UIView *view = views[i];
		[previousView pinToView:view edges:edge spacing:spacing relation:relation];
		previousView = view;
	}
}

+ (void)alignArrayOfViews:(NSArray *)views alignProperty:(ALAlignProperties)alignProperty spacing:(CGFloat)spacing relation:(NSLayoutRelation)relation
{
	if ( views.count < 2 ) return;
	UIView *previousView = [views firstObject];
	for (NSInteger i = 1; i < views.count; i ++) {
		UIView *view = views[i];
		[previousView alignToView:view alignProperties:alignProperty spacing:spacing relation:relation];
		previousView = view;
	}
}


+ (void)equalProperties:(ALViewDimensions)property ofViews:(NSArray *)views
{
	if ( views.count < 2 ) return;
	UIView *previousView = [views firstObject];
	for (NSInteger i = 1; i < views.count; i ++) {
		UIView *view = views[i];
		[view equalDimensions:property toView:previousView];
		previousView = view;
	}
}

+ (void)matchProperties:(ALViewDimensions)properties ofViews:(NSArray *)views relation:(NSLayoutRelation)relation
{
	if ( views.count < 2 ) return;
	UIView *previousView = [views firstObject];
	for (NSInteger i = 1; i < views.count; i ++) {
		UIView *view = views[i];
		[view matchDimensions:properties toView:previousView relation:relation];
		previousView = view;
	}
}

- (void)arrangeVerticallyArraySubviews:(NSArray *)views spacing:(CGFloat)spacing edgeInsets:(UIEdgeInsets)edgeInsets
{
	[[views firstObject] alignToView:self alignProperties:( ALAlignPropertyTop ) spacing:edgeInsets.top];
	[[views lastObject] alignToView:self alignProperties:( ALAlignPropertyBottom ) spacing:edgeInsets.bottom];
	
	[[views firstObject] alignToView:self alignProperties:( ALAlignPropertyRight ) spacing:edgeInsets.right];
	[[views firstObject] alignToView:self alignProperties:( ALAlignPropertyLeft ) spacing:edgeInsets.left];
	
	[UIView alignArrayOfViews:views alignProperty:( ALAlignPropertyLeft | ALAlignPropertyRight ) spacing:0.0 relation:NSLayoutRelationEqual];
	[UIView pinArrayOfViews:views edge:( ALViewEdgeBottom ) spacing:spacing relation:NSLayoutRelationEqual];
}

- (void)arrangeHorizontallyArraySubviews:(NSArray *)views spacing:(CGFloat)spacing edgeInsets:(UIEdgeInsets)edgeInsets
{
	[[views firstObject] alignToView:self alignProperties:( ALAlignPropertyLeft ) spacing:spacing];
	[[views lastObject] alignToView:self alignProperties:( ALAlignPropertyRight ) spacing:spacing];
	
	[UIView alignArrayOfViews:views alignProperty:( ALAlignPropertyTop | ALAlignPropertyBottom ) spacing:spacing relation:NSLayoutRelationEqual];
	[UIView pinArrayOfViews:views edge:( ALViewEdgeRight ) spacing:spacing relation:NSLayoutRelationEqual];
}

@end
