//
//  Eskimo3Spear.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Ninja3Arrow.h"


@implementation Ninja3Arrow

-(id)initWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	
	[super initWithPower:power_ weight:weight_ fromCharacter:character];
	[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaEskimo-Arrow.png"]];
	self.anchorPoint = ccp(.5f,.5f);
	[self makeActionWithHitArea:CGRectMake(-60.0f,-6.0f,120.0f,13.0f)];
	//drawBoundingBoxes = YES;
	canMoveThroughObjectWalls = YES;
	return self;
}

+(id)projectileWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	return [[[self alloc] initWithPower:power_ weight:weight_ fromCharacter:character] autorelease];
}


@end
