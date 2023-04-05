//
//  BEUInputButton.m
//  BEUEngine
//
//  Created by Chris on 3/15/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUInputButton.h"


@implementation BEUInputButton

@synthesize shortHoldTime, useShortHolds, longHoldTime, useLongHolds,sendDownEvents,hitArea;

-(id)initWithUpSprite:(CCSprite *)up downSprite:(CCSprite *)down
{
	if( (self = [super init]) )
	{
		upSprite = [up retain]; 
		downSprite = [down retain];
		
		[self addChild:upSprite];
		[self addChild:downSprite];
		
		downSprite.visible = NO;
		
		useLongHolds = YES;
		longHoldTime = 0.45f;
		
		useShortHolds = YES;
		shortHoldTime = 0.25f;
		
		sendDownEvents = YES;
		
		upOpacity = upSprite.opacity;
		downOpacity = downSprite.opacity;
			
		self.anchorPoint = CGPointZero;
		
		hitArea = CGRectMake(-self.contentSize.width/2,-self.contentSize.height/2,self.contentSize.width,self.contentSize.height);
	}
	
	return self;
	
}

-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self getLocalTouchPoint:touch];
	/*if(location.x > -self.contentSize.width/2 &&
	   location.x < self.contentSize.width/2 &&
	   location.y > -self.contentSize.height/2 &&
	   location.y < self.contentSize.height/2)*/
	if(CGRectContainsPoint(hitArea, location))
	{
		upSprite.visible = NO;
		downSprite.visible = YES;
		
		
		if(sendDownEvents) [inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputButtonDown sender:self]];
		
		ownedTouch = touch;
		
		startDate = [[NSDate date] retain];
		
		return YES;
	}
	
	return NO;
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	upSprite.visible = YES;
	downSprite.visible = NO;
	
	ownedTouch = nil;
	
	float downTime = -[startDate timeIntervalSinceNow];	
	
	//NSLog(@"BUTTON UP WITH DOWN TIME: %1.2f",downTime);
	
	if(downTime < shortHoldTime || (!useShortHolds && !useLongHolds))
	{
		[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputButtonUp sender:self]];
		//NSLog(@"DISPATCHING TAP");
	} else if( (downTime >= shortHoldTime && downTime < longHoldTime) || !useLongHolds )
	{
		[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputButtonUpShort sender:self]];
		//NSLog(@"DISPATCHING SHORT");
	} else {
		[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputButtonUpLong sender:self]];
		//NSLog(@"DISPATCHING LONG");
	}
		
}

-(void)setOpacity:(GLubyte)o
{
	[super setOpacity:o];
	
	float percent = o/255;
	GLubyte newUp = upOpacity*percent;
	GLubyte newDown = downOpacity*percent;
	upSprite.opacity = newUp;
	downSprite.opacity = newDown;
	
	
}

-(void)setHitArea:(CGRect)hitArea_
{
	hitArea = CGRectMake(hitArea_.origin.x-self.position.x,hitArea_.origin.y-self.position.y,hitArea_.size.width,hitArea_.size.height);
}

-(void)dealloc
{
	ownedTouch = nil;
	[upSprite release];
	[downSprite release];
	
	[super dealloc];
}

@end
