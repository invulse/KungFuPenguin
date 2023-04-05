//
//  TestInstructions.m
//  BEUEngine
//
//  Created by Chris Mele on 6/4/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "TestInstructions.h"


@implementation TestInstructions

-(id)init
{
	if( (self = [super init]) )
	{
		instructions = [CCSprite spriteWithFile:@"TempInstructions.png"];
		instructions.anchorPoint = ccp(0,0);
		[self addChild:instructions];
		
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	}
	
	return self;
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[self.parent removeChild:self cleanup:YES];
}

@end
