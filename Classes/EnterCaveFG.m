//
//  EnterCaveFG.m
//  BEUEngine
//
//  Created by Chris Mele on 9/22/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "EnterCaveFG.h"

@implementation EnterCaveFG

-(void)createObject
{
	[super createObject];
	
	canMoveThroughObjectWalls = YES;
	canMoveThroughWalls = YES;
	
	CCSprite *sprite = [CCSprite spriteWithFile:@"EnterCaveFG.png"];
	sprite.anchorPoint = CGPointZero;
	sprite.position = ccp(219,0);
	[self addChild:sprite];
	
	//drawBoundingBoxes = YES;
}

@end
