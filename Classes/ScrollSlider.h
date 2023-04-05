//
//  ScrollSlider.h
//  BEUEngine
//
//  Created by Chris Mele on 7/21/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"

@class ScrollSliderItem;

@interface ScrollSlider : CCLayer {
	//Array of slider items for the scroll slider
	NSMutableArray *sliderItems;
	
	//Node containing all slide items
	CCNode *slider;
	
	//how much padding should be between each item
	float padding;
	
	//is the scroller horizontal
	BOOL horizontal;
	
	//minimum movement speed of the slider needed to switch to the next or prev item
	float minSwitchSpeed;
	
	
	//current item index
	int currentIndex;
	
	//the point where the current menu item will be centered on
	CGPoint origin;
	
	//speed in seconds that the slider will move
	float slideSpeed;
	
	//rect to allow touch events in 
	CGRect rect;
	
	CGPoint startPoint;
	CGPoint startPosition;
	
	NSDate *startTime;
	
	BOOL touching;
	
	id changedTarget;
	SEL changedSelector;
}


@property(nonatomic,assign) id changedTarget;
@property(nonatomic) SEL changedSelector;


-(id)initWithOrigin:(CGPoint)origin_ rect:(CGRect)rect_;

-(void)removeTouchDelegate;

//called once item is changed
-(void)changedItem:(int)index;

//add or remove item from the slider
-(void)addItem:(ScrollSliderItem *)item;
-(void)removeItem:(ScrollSliderItem *)item;

//method to update positions of all the slider items,
//should be called if any of the properties like horizontal or padding have been changed, or if items are added/removed
-(void)updateSlider;

//goto an item in the slider by index, should the goto be animated?
-(void)gotoItem:(int)index animated:(BOOL)animated;

//next item
-(void)next;

//prev item
-(void)prev;

//get the absolute distance from the center for a specific item
-(float)getItemDistFromCenter:(ScrollSliderItem *)item;

-(ScrollSliderItem *)getItemByIndex:(int)index;

//Get the closest item to the center
-(int)getClosestIndex;

@end

@interface ScrollSliderItem : CCNode <CCTargetedTouchDelegate>
{
	//ScrollSliderItem's will always be moved to their origin when being set
	
	//target and selector for when the item is pressed
	id target;
	SEL selector;
	
	//Maximum distance the touch to press the item can move from its start point and still invoke the pressed selector
	float maxDistMoved;
	
	//Define the site of your item here, this is needed so items with extra nodes added will not computer by default
	CGSize itemSize;
	
	CGPoint startPoint;
}

@property(nonatomic) CGSize itemSize;

-(id)initWithTarget:(id)target_ selector:(SEL)selector_ size:(CGSize)size_;
+(id)itemWithTarget:(id)target_ selector:(SEL)selector_ size:(CGSize)size_;
-(void)addToDispatcher;
-(void)removeFromDispatcher;

-(void)itemDown;
-(void)itemUp;
-(void)itemPressed;


@end

