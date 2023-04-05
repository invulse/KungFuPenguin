//
//  Eskimo3Spear.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Eskimo3Spear.h"


@implementation Eskimo3Spear

-(id)initWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	
	[super initWithPower:power_ weight:weight_ fromCharacter:character];
	[self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Eskimo3Spear.png"]];
	[self makeActionWithHitArea:CGRectMake(-30.0f,10.0f,85.0f,30.0f)];
	//drawBoundingBoxes = YES;
	canMoveThroughObjectWalls = YES;
	return self;
}

+(id)projectileWithPower:(float)power_ weight:(float)weight_ fromCharacter:(BEUCharacter *)character
{
	return [[[self alloc] initWithPower:power_ weight:weight_ fromCharacter:character] autorelease];
}


@end
