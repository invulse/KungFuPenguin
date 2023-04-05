//
//  PenguinGestureArea.m
//  BEUEngine
//
//  Created by Chris Mele on 5/19/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinGestureArea.h"


@implementation PenguinGestureArea

-(id)initWithArea:(CGRect)area
{
	[super initWithArea:area];
	touchesToRemove = [[NSMutableArray alloc] init];
	touchTime = 0.5f;
	//updateTimer = [CCTimer timerWithTarget:self selector:@selector(update:)];
	
	[[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:0 paused:NO];//scheduleTimer:updateTimer];
	return self;
}

-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	
	BOOL owned = [super touchBegan:touch withEvent:event];
	if(owned)
	{
		CGPoint location = [self getLocalTouchPoint:touch];
		
		[touches release];
		
		touches = [[NSMutableArray alloc] init];
		
		
		[touches addObject:[[[GestureTouch alloc] initWithPoint:location timeLeft:touchTime] autorelease]];
	}
	
	return owned;
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self getLocalTouchPoint:touch];
	[touches addObject:[[[GestureTouch alloc] initWithPoint:location timeLeft:touchTime] autorelease]];
	[super touchMoved:touch withEvent:event];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self getLocalTouchPoint:touch];
	[touches addObject:[[[GestureTouch alloc] initWithPoint:location timeLeft:touchTime] autorelease]];
	[super touchEnded:touch withEvent:event];
}

-(void)draw
{
	[super draw];
	
	GestureTouch *lastTouch = nil;
	float total = touches.count;
	float count = 0;
	float toMax = total*0.5f;
	
	for ( GestureTouch *touch in touches )
	{
		
		if(!lastTouch)
		{
			lastTouch = touch;
			continue;
		}
		
		
		float percent = count / total;
		float touchPercent = touch.timeLeft/touchTime;
		
		//GLubyte a = 255*touchPercent;
		
		
		
		float lineWidth = 0.001f;
		
		if(count > total - toMax)
		{
			
			lineWidth = ((total-count)/toMax)*16.0f*touchPercent;
		} else {
			lineWidth = percent*16.0f*touchPercent;
		}
		
		if(lineWidth <= 0.0f) lineWidth = 0.01f;
		
		/*if(lineWidth < 1)
		{
			lastTouch = touch;
			continue;
		}*/
		
		glLineWidth(lineWidth);
		glColor4ub(255, 0, 0, 255);		
		ccDrawLine(lastTouch.point, touch.point);
		
		
		
		
		if(count > total - toMax)
		{
			lineWidth = ((total-count)/toMax)*5.0f*touchPercent;
			
			
		} else {
			lineWidth = percent*5.0f*touchPercent;
		}
		if(lineWidth <= 0.0f) lineWidth = 0.01f;
		glLineWidth(lineWidth);
		glColor4ub(10, 0, 0, 255);
		ccDrawLine(lastTouch.point, touch.point);
		lastTouch = touch;
		count++;
	}
	
}

-(void)update:(ccTime)delta
{

	
	for ( GestureTouch *touch in touches )
	{
		touch.timeLeft -= delta;
		if(touch.timeLeft <= 0.0f) [touchesToRemove addObject:touch];
	}
	
	[touches removeObjectsInArray:touchesToRemove];
	[touchesToRemove removeAllObjects];
}

-(void)dealloc
{
	[[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];//unscheduleTimer:updateTimer];
	[touches release];
	[touchesToRemove release];
	[super dealloc];
}



@end

@implementation GestureTouch

@synthesize point,timeLeft;

-(id)initWithPoint:(CGPoint)point_ timeLeft:(float)timeLeft_
{
	[super init];
	point = point_;
	timeLeft = timeLeft_;
	return self;
}

@end

