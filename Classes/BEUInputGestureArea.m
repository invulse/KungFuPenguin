//
//  BEUInputGestureArea.m
//  BEUEngine
//
//  Created by Chris Mele on 3/14/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUInputGestureArea.h"
#import "cocos2d.h"

@implementation BEUInputGestureArea




-(id)initWithArea:(CGRect)area
{
	if( (self = [super init]) )
	{
		inputArea = area;
		maximumTapDist = 15;
		
		holding = NO;
		minHoldTime = 0.25f;

	}
	
	return self;
}

-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self getLocalTouchPoint:touch];
	if(CGRectContainsPoint(inputArea, location))
	{
		ownedTouch = touch;
		startPos = location;
		
		//holdTimer = [[CCTimer alloc] initWithTarget:self selector:@selector(startHold) interval:minHoldTime];
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(startHold:) forTarget:self interval:minHoldTime paused:NO];//scheduleTimer:holdTimer];
		return YES;
	}
	
	return NO;
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self getLocalTouchPoint:touch];
	float gestureDistance = hypot(location.x-startPos.x, location.y-startPos.y);
	
	if(gestureDistance > maximumTapDist && !holding)
	{
		float vDist = location.y - startPos.y;
		float hDist = location.x - startPos.x;
		if(hDist > 0)
		{
			hasMovedRight = YES;
		}
		
		if(hDist < 0)
		{
			hasMovedLeft = YES;
		}
		
		if(vDist > 0)
		{
			hasMovedUp = YES;
		}
		
		if(vDist < 0)
		{
			hasMovedDown = YES;
		}
		
		notTapping = YES;
		[self cancelHold];
	}
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self getLocalTouchPoint:touch];
	float gestureDistance = hypot(location.x-startPos.x, location.y-startPos.y);
	
	if(gestureDistance > maximumTapDist) notTapping = YES;
	
	if(holding)
	{
		[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputHoldUp sender:self]];
	} else if(!notTapping)
	{
		[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputTap sender:self]];
	} else {
		
		float vDist = location.y - startPos.y;
		float hDist = location.x - startPos.x;
		
		if(fabs(vDist) > fabs(hDist))
		{
			if(vDist >= 0)
			{
				if(hasMovedDown)
					[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeDownThenUp sender:self]];
				else 
					[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeUp sender:self]];
			} else {
				if(hasMovedUp)
					[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeUpThenDown sender:self]];
				else 
					[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeDown sender:self]];
			}
		} else {
			if(hDist >= 0)
			{
				if(hasMovedLeft)
					[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeLeftThenRight sender:self]];
				else
					[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeRight sender:self]];

			} else {
				if(hasMovedRight)
					[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeRightThenLeft sender:self]];
				else 
					[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeLeft sender:self]];
			}
		}
		
		
	}
	
	
	hasMovedDown = NO;
	hasMovedUp = NO;
	hasMovedLeft = NO;
	hasMovedRight = NO;
	notTapping = NO;
	ownedTouch = nil;
	holding = NO;
	[self cancelHold];
}


-(void)startHold:(ccTime)delta
{
	holding = YES;
	[self cancelHold];
	
	[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputHoldDown sender:self]];
}

-(void)cancelHold
{

	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(startHold:) forTarget:self];//unscheduleTimer:holdTimer];
}


-(void)enable
{
	[super enable];
	
}

-(void)disable
{
	[super disable];
	
	hasMovedDown = NO;
	hasMovedUp = NO;
	hasMovedLeft = NO;
	hasMovedRight = NO;
	notTapping = NO;
	ownedTouch = nil;
	holding = NO;
	[self cancelHold];
}

-(void)dealloc
{
	//[holdTimer release];
	[super dealloc];
}

@end
