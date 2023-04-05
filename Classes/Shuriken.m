//
//  Shuriken.m
//  BEUEngine
//
//  Created by Chris Mele on 9/13/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Shuriken.h"


@implementation Shuriken

-(id)initWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	
	[super initWithPower:power_ weight:weight_ fromCharacter:character];
	[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PenguinWeapons-Shuriken.png"]];
	
	self.anchorPoint = ccp(.5f,.5f);
	self.rotation = 90;
	
	[self makeActionWithHitArea:CGRectMake(-12,-3,24,6)];
	
	//drawBoundingBoxes = YES;
	
	return self;
}

+(id)projectileWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	return [[[self alloc] initWithPower:power_ weight:weight_ fromCharacter:character] autorelease];
}


@end
