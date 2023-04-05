//
//  BEUCharacterAIMoveBehavior.m
//  BEUEngine
//
//  Created by Chris Mele on 3/6/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCharacterAIMoveBehavior.h"

@implementation BEUCharacterAIMove

@synthesize nearTargetDistance,currentAction,minMovePercent,maxMovePercent;

-(id)init
{
	if( (self = [super init]) )
	{
		name = @"move";
		nearTargetDistance = 50;
		
		minMovePercent = 1.0f;
		maxMovePercent = 1.0f;
		
		//Since moving is generally ok to do all the time for enemies allow this to happen more than once in a row
		canRunMultipleTimesInARow = YES;
	}
	
	return self;
}

+(id)behavior
{
	return [[[self alloc] init] autorelease];
}

-(void)cancel
{
	[super cancel];
	
	if(currentAction) [ai.parent stopAction:currentAction];
	currentAction = nil;
}

-(void)canceling
{
	currentAction = nil;
	
	[self cancel];
}

-(void)complete
{
	[super complete];
	
	[ai.parent stopAction:currentAction];
	currentAction = nil;
}

-(float)value
{
	return lastValue = (ai.difficultyMultiplier)*CCRANDOM_0_1();
}

-(void)dealloc
{
	if(currentAction)
	{
		[ai.parent stopAction:currentAction];
		//[currentAction release];
		currentAction = nil;
	}
	[super dealloc];
}

@end


@implementation BEUCharacterAIMoveToTarget

-(id)init
{
	
	if( (self = [super init]) )
	{
		name = @"moveToTarget";
	}
	
	return self;
}

+(id)behavior
{
	return [[[self alloc] init] autorelease];
}
			  
-(void)run
{
	[super run];
	currentAction = [BEUCharacterMoveToObject actionWithObject:ai.targetCharacter 
													  distance:ai.targetCharacter.moveArea.size.width/2 + ai.parent.moveArea.size.width/2 + 10 ]; //(30 + (10 % arc4random()))]; 
	((BEUCharacterMoveTo *)currentAction).movePercent = minMovePercent + (maxMovePercent-minMovePercent)*CCRANDOM_0_1();
	currentAction.onCompleteTarget = self;
	currentAction.onCompleteSelector = @selector(complete);
	currentAction.cancelTarget = self;
	currentAction.cancelSelector = @selector(canceling);
	[ai.parent runAction: currentAction];
}

-(float) value
{
	/*float dist = ccpDistance(ccp(ai.parent.x,ai.parent.z), 
							 ccp(ai.targetCharacter.x,ai.targetCharacter.z));
	if( dist > nearTargetDistance + 30 )
	{
		return (nearTargetDistance/dist);
		
	}
	
	return 0;*/
	return lastValue = (1 - ai.difficultyMultiplier)*CCRANDOM_0_1();
}

@end



@implementation BEUCharacterAIMoveAwayFromTarget

-(id)init
{
	if( (self = [super init]) )
	{
		name = @"moveAwayFromTarget";
	}
	
	return self;
}

+(id)behavior
{
	return [[[BEUCharacterAIMoveAwayFromTarget alloc] init] autorelease];
}


-(void)run
{
	[super run];
	
	CGRect targetMoveArea = [ai.targetCharacter globalMoveArea];
	
	CGRect withinRect = (ai.targetCharacter.x < ai.parent.x) ? 
						CGRectMake(targetMoveArea.origin.x + targetMoveArea.size.width, ai.targetCharacter.z - 100, 200, 200)
					  : CGRectMake(targetMoveArea.origin.x - 200, ai.targetCharacter.z - 100, 200, 200); 
	
	
	CGPoint toPoint = [[BEUEnvironment sharedEnvironment] getValidRandomPointWithinRect:withinRect forObject:ai.parent];
	
	if(toPoint.x == -9999.0f && toPoint.y == -9999.0f)
	{
		[self cancel];
	} else {
	
		currentAction = [BEUCharacterMoveTo actionWithPoint:toPoint];
		((BEUCharacterMoveTo *)currentAction).movePercent = minMovePercent + (maxMovePercent-minMovePercent)*CCRANDOM_0_1();
		currentAction.onCompleteSelector = @selector(complete);
		currentAction.onCompleteTarget = self;
		currentAction.cancelTarget = self;
		currentAction.cancelSelector = @selector(canceling);
		[ai.parent runAction: currentAction];
	 
	}
}

-(float)value
{
	
	/*float dist = ccpDistance(ccp(ai.parent.x,ai.parent.z), 
							 ccp(ai.targetCharacter.x,ai.targetCharacter.z));
	
	if( dist <= self.nearTargetDistance + 30 )
	{
		return (1 - (nearTargetDistance/dist));
	}
	
	return 0;*/
	
	return lastValue = CCRANDOM_0_1() * ai.difficultyMultiplier;
}

@end



@implementation BEUCharacterAIMoveAwayToTargetZ

-(id)init
{
	if( (self = [super init]) )
	{
		name = @"moveAwayToTargetZ";
	}
	
	return self;
}

+(id)behavior
{
	return [[[BEUCharacterAIMoveAwayToTargetZ alloc] init] autorelease];
}

-(void)run
{
	[super run];
	
	CGRect targetMoveArea = [ai.targetCharacter globalMoveArea];
	
	CGRect withinRect = (ai.targetCharacter.x < ai.parent.x) ? 
	CGRectMake(targetMoveArea.origin.x + targetMoveArea.size.width, targetMoveArea.origin.y, 200, targetMoveArea.size.height)
	: CGRectMake(targetMoveArea.origin.x - 200, targetMoveArea.origin.y, 200, targetMoveArea.size.height); 
	
	
	CGPoint toPoint = [[BEUEnvironment sharedEnvironment] getValidRandomPointWithinRect:withinRect forObject:ai.parent];
	
	
	
	
	if(toPoint.x == -9999.0f && toPoint.y == -9999.0f)
	{
		[self cancel];
	} else {
	
	
		currentAction = [BEUCharacterMoveTo actionWithPoint:toPoint];
		((BEUCharacterMoveTo *)currentAction).movePercent = minMovePercent + (maxMovePercent-minMovePercent)*CCRANDOM_0_1();

		currentAction.onCompleteSelector = @selector(complete);
		currentAction.onCompleteTarget = self;
		currentAction.cancelTarget = self;
		currentAction.cancelSelector = @selector(canceling);
		
		[ai.parent runAction: currentAction];
	
	}
}

-(float)value
{

	return lastValue = CCRANDOM_0_1()*ai.difficultyMultiplier;
	
}

@end