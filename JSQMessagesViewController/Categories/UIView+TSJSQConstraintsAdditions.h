//
//  UIView+TSJSQConstraintsAdditions.h
//  AutoLayoutCoding
//
//  Created by ; on 5/12/14.
//  Copyright (c) 2014 SV. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TECH_TALK 1

typedef NS_OPTIONS(NSUInteger, ALViewEdges) {
    ALViewEdgeTop		= (1 << 0),
    ALViewEdgeLeft		= (1 << 1),
	ALViewEdgeBottom	= (1 << 2),
	ALViewEdgeRight		= (1 << 3),
};

typedef NS_OPTIONS(NSUInteger, ALAlignProperties) {
    ALAlignPropertyTop		= (1 << 0),
    ALAlignPropertyLeft		= (1 << 1),
    ALAlignPropertyBottom	= (1 << 2),
	ALAlignPropertyRight	= (1 << 3),
	ALAlignPropertyCenterX	= (1 << 4),
	ALAlignPropertyCenterY	= (1 << 5),
};

typedef NS_OPTIONS(NSUInteger, ALViewDimensions) {
    ALViewDimentionHeight	= (1 << 0),
    ALViewDimensionWidth	= (1 << 1),
};

/**
 *  Category on UIView that provides methods for easier use of autolayout programatically.
 */
@interface UIView (TSJSQConstraintsAdditions)

+ (id)autolayoutView;
- (void)setupViewForAutolayout;

/**
 *  Pins views side by side [self] - spacing - [view]
 *
 *  @param view		The View to pin with
 *  @param edge		The edge of the current view that needs to be pinned to the opposite edge of the view
 *  @param spacing	The spacing between views
 *	@param relation	The relation of this constraints
 *
 *	@return			An array of constraints responsible for pining the views on given edges.
 */
- (NSArray *)pinToView:(UIView *)view edges:(ALViewEdges)edge spacing:(CGFloat)spacing;
- (NSArray *)pinToView:(UIView *)view edges:(ALViewEdges)edge spacing:(CGFloat)spacing relation:(NSLayoutRelation)relation;

/**
 *  Aligns two views [ - spacing - [view] self]
 *
 *  @param view          The view that needs to be aligned with this view
 *  @param alignProperty The align property on which the views will be aligned. You can use multiple align properties.
 *  @param spacing       The offset for the alignment
 *  @param relation      The relation of this constraints
 *
 *  @return An array of constraints responsible for aligning the views.
 */
- (NSArray *)alignToView:(UIView *)view alignProperties:(ALAlignProperties)alignProperty spacing:(CGFloat)spacing;
- (NSArray *)alignToView:(UIView *)view alignProperties:(ALAlignProperties)alignProperty spacing:(CGFloat)spacing relation:(NSLayoutRelation)relation;

/**
 *  Returns the constraint that manages the given property
 *
 *  @param property		The property of the view. Obs. Use one of the given view dimensions.
 *  @return				A constraint that manages the given property. Or nil if no such constraint.
 */
- (NSLayoutConstraint *)constraintForDimension:(ALViewDimensions)property;

/**
 *  Adds constraint for a property
 *
 *  @param property The property to be set.
 *  @param value    The value of the property.
 *	@param relation	The relation of this constraints
 *
 *	@return			An array of constraints responsible for the given properties.
 */
- (NSArray *)addDimensions:(ALViewDimensions)property value:(CGFloat)value;
- (NSArray *)addDimensions:(ALViewDimensions)property value:(CGFloat)value relation:(NSLayoutRelation)relation;

/**
 *  Sets the given property equal for the curent view and the given view
 *
 *  @param property The property to be set to equal.
 *  @param view     The view of which property will be set equal to the current view property.
 *	@param relation	The relation of this constraints
 *
 *	@return			An array of constraints responsible for matching the given properties.
 */
- (NSArray *)equalDimensions:(ALViewDimensions)property toView:(UIView *)view;
- (NSArray *)matchDimensions:(ALViewDimensions)property toView:(UIView *)view relation:(NSLayoutRelation)relation;
- (NSArray *)matchDimensions:(ALViewDimensions)property toView:(UIView *)view relation:(NSLayoutRelation)relation value:(CGFloat)value;

/**
 *  Sets the aspect ratio of the current view
 *
 *  @param aspectRatio The value to be set for aspect ratio
 */
- (NSLayoutConstraint *)setAspectRatio:(CGFloat)aspectRatio;
- (NSLayoutConstraint *)setAspectRatio:(CGFloat)aspectRatio relation:(NSLayoutRelation)relation;

@end

/**
 *  Methods for layout multiple views
 */
@interface UIView (ArrayConstraintsAdditions)

+ (void)pinArrayOfViews:(NSArray *)views edge:(ALViewEdges)edge spacing:(CGFloat)spacing relation:(NSLayoutRelation)relation;
+ (void)alignArrayOfViews:(NSArray *)views alignProperty:(ALAlignProperties)alignProperty spacing:(CGFloat)spacing relation:(NSLayoutRelation)relation;
+ (void)matchProperties:(ALViewDimensions)properties ofViews:(NSArray *)views relation:(NSLayoutRelation)relation;
+ (void)equalProperties:(ALViewDimensions)property ofViews:(NSArray *)views;

- (void)arrangeVerticallyArraySubviews:(NSArray *)views spacing:(CGFloat)spacing edgeInsets:(UIEdgeInsets)edgeInsets;
- (void)arrangeHorizontallyArraySubviews:(NSArray *)views spacing:(CGFloat)spacing edgeInsets:(UIEdgeInsets)edgeInsets;

@end
