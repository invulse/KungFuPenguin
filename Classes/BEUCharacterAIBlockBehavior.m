//
//  BEUCharacterAIBlockBehavior.m
//  BEUEngine
//
//  Created by Chris on 3/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUCharacterAIBlockBehavior.h"


@implementation BEUCharacterAIBlockBehavior

-(id)initBlock
{
	if( (self = [super initWithName:@"block"]) )
	{
		canInteruptOthers = YES;
	}
	
	return self;
}

+(id)behavior
{
	return [[[self alloc] initBlock] autorelease];
}

-(float)value
{
	if(ai.targetCharacter.state == BEUCharacterStateAttacking)
	{
		return lastValue = (1 - ai.difficultyMultiplier/4)*CCRANDOM_0_1();
	}
	
	return lastValue = 0;
}

-(void)run
{
	[super run];
	[ai.parent runAction:
	 [CCSequence actions:
	  [CCCallFunc actionWithTarget:ai.parent selector:@selector(block)],
	  [CCDelayTime actionWithDuration:.5],
	  [CCCallFunc actionWithTarget:ai.parent selector:@selector(blockComplete)],
	  [CCCallFunc actionWithTarget:self selector:@selector(complete)],
	  nil]
	 ];
}

-(void)complete
{
	[super complete];
}

@end
