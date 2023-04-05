//
//  BEUProjectile.m
//  BEUEngine
//
//  Created by Chris on 3/16/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUProjectile.h"


@implementation BEUProjectile

@synthesize power,fromCharacter;

-(id)init
{
	if( (self = [super init]) )
	{
		isWall = NO;
		affectedByGravity = NO;
		canMoveThroughObjectWalls = YES;
		weight = 20;
		power = 20;
		startX = -99999999;
		maxXDistance = 1000;
		lastX = -9999999;
		airFriction = 0;
	}
	return self;
	
}

-(id)initWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	[self init];
	power = power_;
	weight = weight_;
	fromCharacter = character;
	
	
	
	
	
	
	return self;
}

-(void)makeActionWithHitArea:(CGRect)area
{
	hitArea = area;
	hitAction = [BEUHitAction actionWithSender:fromCharacter
											selector:@selector(receiveHit:)
											duration:-1
											 hitArea:hitArea
										zRange:ccp(-20.0f,20.0f)
											   power:power
											  xForce:(moveX + weight)
											  yForce:0 
											  zForce:0
											relative: YES];
	hitAction.relativePositionTo = self;
	hitAction.completeTarget = self;
	hitAction.completeSelector = @selector(removeProjectile);
	hitAction.sendsLeft = 1;
	[[BEUActionsController sharedController] addAction:hitAction];
}

+(id)projectileWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	return [[[self alloc] initWithPower:power_ weight:weight_ fromCharacter:character] autorelease];
}

-(void)removeProjectile
{
	if(hitAction)
	{
		[[BEUActionsController sharedController] removeAction:hitAction];
	}
	[[BEUObjectController sharedController] removeObject: self];
}

-(void)moveWithAngle:(float)angle magnitude:(float)mag_
{
	[self applyForceX: cos(angle)*mag_];
	[self applyForceY: sin(angle)*mag_];	
}


-(void)step:(ccTime)delta
{	
	[super step:delta];
	
	if(startX == -99999999)
	{
		startX = x;
	}
	 
	 if(fabsf(startX - x) > maxXDistance)
	{
		[self removeProjectile];
		return;
	}
	
	if(moveX > 0)
	{
		[self setFacingRight:YES];
	} else if(moveX < 0) {
		[self setFacingRight:NO];
	}
	
	
	if(x == lastX) [self removeProjectile];
	
	lastX = x;

}

-(void)dealloc
{
	
	hitAction = nil;
	fromCharacter = nil;
	
	[super dealloc];
}

@end
