//
//  BEUEffect.m
//  BEUEngine
//
//  Created by Chris Mele on 5/28/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUEffect.h"
#import "BEUObjectController.h"
#import "BEUEnvironment.h"

@implementation BEUEffect

@synthesize effectRunning,isOnTopOfObjects,isBelowObjects;

-(id)init
{
	if( (self = [super init]) )
	{
		effectRunning = NO;
		isOnTopOfObjects = YES;
		isBelowObjects = NO;
		affectedByGravity = NO;
	}
	
	return self;
}

-(void)resetEffect
{
	//Override me with your intial position and settings for the effect
}

-(void)startEffect
{
	if(effectRunning) [self resetEffect];
	self.position = ccp(x,z+y);
	if(!parent_)
	{
		if(isOnTopOfObjects)
		{
			[[[BEUEnvironment sharedEnvironment] effectsLayer] addChild:self];
			
		} else if(isBelowObjects)
		{
			[[[BEUEnvironment sharedEnvironment] floorLayer] addChild:self];
		} else {
			[[BEUObjectController sharedController] addObject:self];
		}
	}
	
	
	effectRunning = YES;
}

-(void)completeEffect
{
	//if(parent_) [parent_ removeChild:self cleanup:YES];
	if(isOnTopOfObjects || isBelowObjects)
	{
		[self removeFromParentAndCleanup:YES];
	} else {
		[[BEUObjectController sharedController] removeObject:self];
	}
	
	
	effectRunning = NO;
	[self resetEffect];
}

@end
