//
//  BEUCharacterAIIdleBehavior.m
//  BEUEngine
//
//  Created by Chris on 3/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUCharacterAIIdleBehavior.h"


@implementation BEUCharacterAIIdleBehavior

@synthesize minTime,maxTime;

-(id)initWithMinTime:(float)min maxTime:(float)max
{
	if( (self = [super initWithName:@"idle"]) ){
		minTime = min;
		maxTime = max;
		
		//We probably dont want idle actions to be run multiple times in a row
		canRunMultipleTimesInARow = NO;
	}
	
	return self;
}

+(id)behaviorWithMinTime:(float)min maxTime:(float)max
{
	return [[[self alloc] initWithMinTime:min maxTime:max] autorelease];
}

-(float)value
{
	return lastValue = (ai.difficultyMultiplier)*CCRANDOM_0_1();
}

-(void)run
{
	[super run];
	float randTime = minTime + (maxTime - minTime)*CCRANDOM_0_1();
	idleAction = [CCSequence actions:
				  [CCDelayTime actionWithDuration:randTime],
				  [CCCallFunc actionWithTarget:self selector:@selector(complete)],
				  nil
				  ];
	[ai.parent runAction:idleAction];
	
}

-(void)cancel
{
	[super cancel];
	[ai.parent stopAction:idleAction];
	idleAction = nil;
	
}

-(void)complete
{
	[super complete];
	idleAction = nil;
}

-(void)dealloc
{
	if(idleAction)
	{
		[ai.parent stopAction:idleAction];
		//[idleAction release];
	}
	
	[super dealloc];
}

@end
