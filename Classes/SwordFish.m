//
//  SwordFish.m
//  BEUEngine
//
//  Created by Chris Mele on 3/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "SwordFish.h"


@implementation SwordFish

-(id)init
{
	if( (self = [super init]) )
	{
		sword = [CCSprite spriteWithFile:@"SwordFish.png"];
		sword.anchorPoint = ccp(0.0f, 0.0f);
		sword.position = ccp(10,8);
		sword.rotation = 90;
		moveArea = CGRectMake(-10, -10, 90, 20);
		drawBoundingBoxes = YES;
		[self addChild:sword];
	}
	
	return self;
}

-(void)dealloc
{
	[sword release];
	[super dealloc];
}

@end
