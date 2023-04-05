//
//  ScrollSlider.m
//  BEUEngine
//
//  Created by Chris Mele on 7/21/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "ScrollSlider.h"


@implementation ScrollSlider

@synthesize changedTarget,changedSelector;

-(id)initWithOrigin:(CGPoint)origin_ rect:(CGRect)rect_
{
	self = [super init];
	
	rect = rect_;
	
	sliderItems = [[NSMutableArray alloc] init];
	
	slider = [CCNode node];
	
	[self addChild:slider];
	
	padding = 40.0f;
	horizontal = YES;
	minSwitchSpeed = 200.0f;
	origin = origin_;
	slideSpeed = .5f;
	currentIndex = 0;
	
	touching = NO;
	
	[self updateSlider];
	
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
	
	return self;
}

-(void)removeTouchDelegate
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

-(void)addItem:(ScrollSliderItem *)item
{
	[sliderItems addObject:item];
	[slider addChild:item];
	
	[self updateSlider];
}

-(void)removeItem:(ScrollSliderItem *)item
{
	[sliderItems removeObject:item];
	[slider removeChild:item cleanup:YES];
	[self updateSlider];
}

-(void)updateSlider
{
	int count = 0;
	
	ScrollSliderItem *lastItem = nil;
	
	for ( ScrollSliderItem *item in sliderItems )
	{
		if(lastItem){
			if(horizontal)
			{
				item.position = ccp( lastItem.position.x + lastItem.itemSize.width/2 + padding + item.itemSize.width/2, 0);
			} else {
				item.position = ccp( 0 , lastItem.position.y + lastItem.itemSize.height/2 + padding + item.itemSize.height/2 );
			}
		}
		
		lastItem = item;
		count++;
	}
}

-(void)gotoItem:(int)index animated:(BOOL)animated
{
	[slider stopAllActions];
	
	CGPoint toPoint;
	ScrollSliderItem *item = [self getItemByIndex:index];
	
	if(horizontal)
	{
		toPoint = ccp(origin.x-item.position.x,origin.y);
	} else {
		toPoint = ccp(origin.x,origin.y-item.position.y);
	}
	
	if(animated)
	{
		[slider runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:slideSpeed position:toPoint]
		  ]
		 ];
	} else {
		slider.position = toPoint;
	}
	
	if(currentIndex != index)
	{
		[self changedItem:index];
	}
	
	currentIndex = index;
}

-(void)changedItem:(int)index
{
	[changedTarget performSelector:changedSelector];
}

-(void)next
{
	if([sliderItems count] > currentIndex+1)
	{
		[self gotoItem:currentIndex+1 animated:YES];
	} else {
		[self gotoItem:currentIndex animated:YES];
	}
}

-(void)prev
{
	if(currentIndex-1 >= 0)
	{
		[self gotoItem:currentIndex-1 animated:YES];
	} else {
		[self gotoItem:currentIndex animated:YES];
	}
}

-(float)getItemDistFromCenter:(ScrollSliderItem *)item
{
	if(horizontal)
	{
		return fabsf(slider.position.x - origin.x + item.position.x);
	} else {
		return fabsf(slider.position.y - origin.y + item.position.y);
	}
}

-(ScrollSliderItem *)getItemByIndex:(int)index
{
	return [sliderItems objectAtIndex:index];
}

-(int)getClosestIndex
{
	int closestIndex = -1;
	float closestDist = 999999;
	
	for( ScrollSliderItem *item in sliderItems )
	{
		if(closestIndex == -1) 
		{
			closestDist = [self getItemDistFromCenter:item];
			closestIndex = [sliderItems indexOfObject:item];
			
		} else 
		{
			float dist = [self getItemDistFromCenter:item];
			int index = [sliderItems indexOfObject:item];
			if(dist < closestDist)
			{
				closestDist = dist;
				closestIndex = index;
			}
		}
	}
	
	//NSLog(@"CLOSEST INDEX: %d",closestIndex);
	
	return closestIndex;
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self convertTouchToNodeSpace:touch];
	
	if(CGRectContainsPoint(rect, location) && !touching)
	{
		touching = YES;
		
		startPoint = location;
		startTime = [[NSDate date] retain];
		// do the thing you are timing
		
		startPosition = slider.position;
		
		return YES;
	}
	
	return NO;
	
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self convertTouchToNodeSpace:touch];
	
	float dx = startPoint.x - location.x;
	float dy = startPoint.y - location.y;
	
	if(horizontal)
	{
		slider.position = ccp(startPosition.x - dx,origin.y);
	} else {
		slider.position = ccp(origin.x,startPosition.y - dy);
	}
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self convertTouchToNodeSpace:touch];
	
	float dx = startPoint.x - location.x;
	float dy = startPoint.y - location.y;
	
	NSDate *stop = [NSDate date];
	
	NSTimeInterval duration = [stop timeIntervalSinceDate:startTime];
	
	[startTime release];
	
	float xSpeed = -dx/duration;
	float ySpeed = -dy/duration;
	
	//NSLog(@"TIME: %1.2f, XSpeed: %1.2f, YSpeed: %1.2f",duration,xSpeed,ySpeed);
	
	if(horizontal)
	{
		if(xSpeed > 0 && xSpeed >= minSwitchSpeed)
		{
			[self prev];
		} else if(xSpeed < 0 && xSpeed <= -minSwitchSpeed)
		{
			[self next];
		} else {
			[self gotoItem:[self getClosestIndex] animated:YES];
		}
	} else {
		if(ySpeed >= minSwitchSpeed)
		{
			[self prev];
		} else if(ySpeed <= -minSwitchSpeed)
		{
			[self next];
		} else {
			[self gotoItem:[self getClosestIndex] animated:YES];
		}
	}
	
	touching = NO;
	
}

-(void)dealloc
{
	for( ScrollSliderItem *item in sliderItems )
	{
		[item removeFromDispatcher];
	}
	
	[sliderItems release];
	[super dealloc];
}

@end


@implementation ScrollSliderItem
@synthesize itemSize;
								
					
-(id)initWithTarget:(id)target_ selector:(SEL)selector_ size:(CGSize)size_
{
	self = [super init];
	
	target = target_;
	selector = selector_;
	itemSize = size_;
	
	maxDistMoved = 20.0f;
	[self addToDispatcher];
	return self;
}

+(id)itemWithTarget:(id)target_ selector:(SEL)selector_ size:(CGSize)size_
{
	return [[[self alloc] initWithTarget:target_ selector:selector_ size:size_] autorelease];
}

-(void)addToDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(void)removeFromDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

-(void)itemDown
{
	
}

-(void)itemUp
{
	
}

-(void)itemPressed
{
	[target performSelector:selector withObject:self];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGRect bounds = CGRectMake(-itemSize.width/2,-itemSize.height/2,itemSize.width,itemSize.height);
	CGPoint location = [self convertTouchToNodeSpace:touch];
	
	
	if(CGRectContainsPoint(bounds,location))
	{
		[self itemDown];
		startPoint = [self convertToWorldSpace:location];//location;
		return YES;
	}
	
	return NO;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self itemUp];
	
	CGPoint endPoint = [self convertToWorldSpace:[self convertTouchToNodeSpace:touch]];
	
	float xDist = startPoint.x-endPoint.x;
	float yDist = startPoint.y-endPoint.y;
	
	if(fabsf(xDist) < maxDistMoved && fabsf(yDist) < maxDistMoved)
	{
		[self itemPressed];
	}
}

@end