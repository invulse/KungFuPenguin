//
//  BEUInputJoystick.m
//  BEUEngine
//
//  Created by Chris Mele on 3/13/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUInputJoystick.h"


@implementation BEUInputJoystick

@synthesize percent, angle,canSwipe,swipeTime,hitArea;

-(id)initWithMinZone:(float)min maxZone:(float)max baseImage:(NSString *)baseImage stickImage:(NSString *)stickImage
{
	
	if( (self = [super init]) )
	{
		minZone = min;
		maxZone = max;
		
		//radius = radius_;
		
		canSwipe = NO;
		swipeTime = 0.3f;
		isSwipeOK = NO;
		
		self.anchorPoint = CGPointZero;
		
		joystickBase = [[CCSprite alloc] initWithFile:baseImage];
		//joystickBase.scaleX = joystickBase.scaleY = radius*2/joystickBase.contentSize.width;
		
		joystickStick = [[CCSprite alloc] initWithFile:stickImage];
		//joystickStick.scaleX = joystickStick.scaleY = (radius)/joystickStick.contentSize.width;
		
		radius = joystickBase.contentSize.width/2;
		
		stickOpacity = 255;
		baseOpacity = 255;
		
		hitArea = CGRectMake(-radius,-radius,radius*2,radius*2);
		
		[self addChild:joystickBase];
		[self addChild:joystickStick];
		
	}
	return self;
}

-(void)show
{
	[joystickBase runAction:[CCFadeIn actionWithDuration:0.3f]];
	[joystickStick runAction:[CCFadeIn actionWithDuration:0.3f]];
	//NSLog(@"SHOWING JOYSTICK");
}

-(void)hide
{
	//NSLog(@"HIDING JOYSTICK");
	
	//[joystickBase runAction:[CCHide action]];
	//[joystickStick runAction:[CCHide action]];
	[joystickBase runAction: [CCFadeTo actionWithDuration:0.3f opacity:0]];
	  
	[joystickStick runAction:[CCFadeTo actionWithDuration:0.3f opacity:0]];
	//[joystickBase runAction:[CCMoveBy actionWithDuration:1.5f position:ccp(100,100)]];
	
	
}

-(void)updateJoystickPosition:(CGPoint)point
{
	float distFromCenter = sqrtf(point.x*point.x + point.y*point.y);
	
	float actualPercent = distFromCenter/radius;
	if(actualPercent > 1) actualPercent = 1;
	
	percent = (distFromCenter - minZone)/(maxZone - minZone);
	
	if(percent > 1) percent = 1;
	else if(percent < 0) percent = 0;
	
	angle = [BEUMath angleFromPoint:CGPointZero toPoint:point];
	
	joystickStick.position = ccp(
								 cos(angle)*radius*actualPercent, 
								 sin(angle)*radius*actualPercent
								 );
	[inputLayer dispatchEvent: [BEUInputMovementEvent eventWithAngle:angle percent:percent sender:self]];
}

-(BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
	
	if(!CGRectContainsPoint(hitArea, location))
	{
			
		return NO;
	
	} else {
		ownedTouch = touch;
		[self updateJoystickPosition:location];
		
		if(canSwipe)
		{
			isSwipeOK = YES;
			[[CCScheduler sharedScheduler] scheduleSelector:@selector(cancelSwipes:) forTarget:self interval:swipeTime paused:NO];
			//[self schedule:@selector(cancelSwipes:) interval:swipeTime];
		}
		
		return YES;
	}
	
	/* else if(location.x > radius || 
	   location.x < -radius || 
	   location.y > radius || 
	   location.y < -radius)
	{
		return NO;
	} */ 
	
	
}

-(void)cancelSwipes:(ccTime)delta
{
	//[self unschedule:@selector(cancelSwipes:)];
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(cancelSwipes:) forTarget:self];
	isSwipeOK = NO;
}

-(void)setStickOpacity:(GLuint)stickOpacity_
{
	stickOpacity = stickOpacity_;
	
	joystickStick.opacity = stickOpacity;
	
}

-(void)setBaseOpacity:(GLuint)baseOpacity_
{
	baseOpacity = baseOpacity_;
	joystickBase.opacity = baseOpacity;
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
	[self updateJoystickPosition:location];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	location = [self convertToNodeSpace:location];
	
	
	if(isSwipeOK)
	{
		
		float distFromCenter = sqrtf(location.x*location.x + location.y*location.y);
		
		float actualPercent = distFromCenter/radius;
		
		if(actualPercent >= .3)
		{
			if(location.x > 0 && fabsf(location.x)>fabsf(location.y))
			{
				[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeRight sender:self]];
			} else if(location.x < 0 && fabsf(location.x)>fabsf(location.y))
			{
				[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeLeft sender:self]];
			} else if(location.y > 0 && fabsf(location.y)>fabsf(location.x))
			{
				[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeUp sender:self]];
			} else if(location.y < 0 && fabsf(location.y)>fabsf(location.x))
			{
				[inputLayer dispatchEvent:[BEUInputEvent eventWithType:BEUInputSwipeDown sender:self]];
			}
		}
		
	}
	
	
	[self updateJoystickPosition:CGPointZero];
	
	ownedTouch = nil;
}

-(void)enable
{
	[super enable];
}

-(void)disable
{
	[super disable];
	
	[self updateJoystickPosition:CGPointZero];
	
	ownedTouch = nil;
}

-(void)setOpacity:(GLubyte)o
{
	[super setOpacity:o];
	
	//NSLog(@"SET JOYSTICK OPACITY: %d",o);
	float percent = o/255;
	GLubyte newBaseOpacity = baseOpacity*percent;
	GLubyte newStickOpacity = stickOpacity*percent;
	[joystickBase setOpacity:newBaseOpacity];
	[joystickStick setOpacity:newStickOpacity];
}

-(void)setHitArea:(CGRect)hitArea_
{
	hitArea = CGRectMake(hitArea_.origin.x-self.position.x,hitArea_.origin.y-self.position.y,hitArea_.size.width,hitArea_.size.height);
}

-(void)dealloc
{
	[joystickBase release];
	[joystickStick release];
	inputLayer = nil;
	ownedTouch = nil;
	[super dealloc];
}



@end
