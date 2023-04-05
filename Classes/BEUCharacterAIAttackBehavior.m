//
//  BEUCharacterAIAttackBehavior.m
//  BEUEngine
//
//  Created by Chris Mele on 3/8/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCharacterAIAttackBehavior.h"


@implementation BEUCharacterAIAttackBehavior

@synthesize idleAfterAttack, minIdleTime, maxIdleTime, needsCooldown, minCooldownTime, maxCooldownTime,canRunSameMoveAgain;

-(id)init
{
	if( (self = [super initWithName:@"attack"]) )
	{
		//Attack behaviors in generally should not be run multiple times in a row, which should help avoid endlessly attacking 
		//enemies
		canRunMultipleTimesInARow = NO;
		idleAfterAttack = NO;
		minIdleTime = 0.2f;
		maxIdleTime = 0.6f;
		
		needsCooldown = NO;
		minCooldownTime = 2.0f;
		maxCooldownTime = 4.0f;
		coolingDown = NO;
		
		canRunSameMoveAgain = YES;
		
	}
	
	return self;
}

+(id)behavior
{
	return [[[BEUCharacterAIAttackBehavior alloc] init] autorelease];
}

-(BOOL)hasMoveInRange
{
	return NO;
}

-(float)value
{
	lastValue = (coolingDown) ? 0 : (1 - ai.difficultyMultiplier)*CCRANDOM_0_1();
	//NSLog(@"GETTING VALUE FOR ATTACK BEHAVIOR: %1.2f",lastValue);
	return lastValue;
	
}

-(void)cancel
{
	[[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
	[super cancel];
}

-(void)attackComplete
{
	
	if(idleAfterAttack)
	{
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(idleComplete:) 
											  forTarget:self 
											   interval:(minIdleTime + (maxIdleTime-minIdleTime)*CCRANDOM_0_1()) 
												 paused:NO];
	} else {
		[self complete];
	}
}

-(void)idleComplete:(ccTime)delta
{
	[[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
	[self complete];
}

-(void)complete
{
	if(needsCooldown)
	{
		
		float cooldownTime = minCooldownTime + (maxCooldownTime-minCooldownTime)*CCRANDOM_0_1();
		NSLog(@"AI ATTACK BEHAVIOR IS COOLINGDOWN FOR %1.2f SECONDS  MIN: %1.2f, MAX: %1.2f",cooldownTime,minCooldownTime,maxCooldownTime);
		coolingDown = YES;
		[[CCScheduler sharedScheduler] scheduleSelector:@selector(cooldownComplete:)
											  forTarget:self 
											   interval:cooldownTime
												 paused:NO];
	}
	[super complete];
}

-(void)cooldownComplete:(ccTime)delta
{
	NSLog(@"AI ATTACK BEHAVIOR COOLDOWN COMPLETE");
	coolingDown = NO;
	[[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
}

@end


@implementation BEUCharacterAIAttackWithRandomMove

@synthesize moves;

-(id)initWithMoves:(NSMutableArray *)moves_
{
	if( (self = [super init]) )
	{
		name = @"attackWithRandomMove";
		moves = moves_;
	}
	
	return self;
}

+(id)behaviorWithMoves:(NSMutableArray *)moves_
{
	return [[[self alloc] initWithMoves:moves_] autorelease];
}

-(BOOL)hasMoveInRange
{
	float dist = ccpDistance(ccp(ai.parent.x,ai.parent.z), 
							 ccp(ai.targetCharacter.x,ai.targetCharacter.z));
	for ( BEUMove *move in moves )
	{
		if(move.range >= dist
		   && (canRunSameMoveAgain || move != lastMove)
		   ) return YES;
	}
	
	return NO;
}

-(BEUMove *)getRandomMove
{
	BEUMove *move = nil;
	
	if(canRunSameMoveAgain || moves.count == 1)
	{
	 move = [moves objectAtIndex:arc4random()%moves.count];
	} else {
		while ( move == lastMove && move == nil )
		{
			move = [moves objectAtIndex:arc4random()%moves.count];
		}
	}
	
	
	return move;
}

-(BEUMove *)getRandomMoveInRange
{
	NSMutableArray *inRangeMoves = [NSMutableArray array];
	float dist = ccpDistance(ccp(ai.parent.x,ai.parent.z), 
							 ccp(ai.targetCharacter.x,ai.targetCharacter.z));
	for ( BEUMove *move in moves )
	{
		if(move.range >= dist && move.minRange <= dist
		   && (canRunSameMoveAgain || lastMove != move || moves.count <= 1)
		   ) [inRangeMoves addObject:move];
	}
		
	return (inRangeMoves.count > 0) ? [inRangeMoves objectAtIndex:arc4random()%inRangeMoves.count] : nil;	
}

/*-(float)value
{
	if([self hasMoveInRange])
	{
		return [super value];//lastValue = (1 - ai.difficultyMultiplier)*CCRANDOM_0_1();
	} else {
		return lastValue = 0;
	}
}*/

-(void)run
{
	[super run];
	
	BEUMove *moveToRun;
	
	
	moveToRun = [self getRandomMoveInRange];
	
	
	[moveToRun startMove];
	moveToRun.completeTarget = self;
	moveToRun.completeSelector = @selector(attackComplete);
	
	lastMove = moveToRun;
	
}

-(void)dealloc
{
	moves = nil;
	[super dealloc];
}

@end


@implementation BEUCharacterAIMoveToAndAttack

@synthesize attackMove,mustBeInViewPort;

/*-(float)value
{
	return lastValue = (1 - ai.difficultyMultiplier)*CCRANDOM_0_1();
}*/
-(id)initWithMoves:(NSMutableArray *)moves_
{
	[super initWithMoves:moves_];
	mustBeInViewPort = YES;
	
	return self;
}

-(void)cancel
{
	if(moveToAction) [ai.parent stopAction:moveToAction];
	if(attackMove) [ai.parent.movesController cancelCurrentMove];
	
	moveToAction = nil;
	attackMove = nil;
	
	[super cancel];
}

-(void)moveToCanceled
{
	moveToAction = nil;
	[self cancel];
}

-(void)run
{
	//[super run];
	running = YES;
	
	attackMove = [self getRandomMove];
	
	
	float dist = fabsf(ai.parent.x-ai.targetCharacter.x);
	
	
	//check if the current distance from the target is less than minRange of move, if it is lets try to find a move with a better range
	if(dist < attackMove.minRange)
	{
		NSMutableArray *movesArray = [NSMutableArray array];
		for(BEUMove *move in moves)
		{
			if(dist > move.minRange)
			{
				[movesArray addObject:move];
			}
		}
		
		if(movesArray.count > 0)
		{
			attackMove  = [movesArray objectAtIndex:arc4random()%movesArray.count]; 
			
			
		}
		
	}
	
	
	moveToAction = [BEUCharacterMoveToObject 
											  actionWithObject:ai.targetCharacter 
											  distance:attackMove.range
											  zRange: ai.parent.moveArea.size.height];
	moveToAction.mustBeInViewPort = mustBeInViewPort;
	moveToAction.minDistance = attackMove.minRange;
	
	moveToAction.cancelTarget = self;
	moveToAction.cancelSelector = @selector(moveToCanceled);
	
	moveToAction.onCompleteTarget = self;
	moveToAction.onCompleteSelector = @selector(moveToComplete);
	
	[ai.parent runAction: moveToAction];
}

-(void)moveToComplete
{
	[attackMove startMove];
	attackMove.completeTarget = self;
	attackMove.completeSelector = @selector(attackComplete);
	moveToAction = nil;
	
}



-(void)dealloc
{
	attackMove = nil;
	[super dealloc];
}

@end


@implementation BEUCharacterAIAttackWithMoveInRange

-(void)run
{
	running = YES;
	
	attackMove = [self getRandomMoveInRange];
	
	
	
	if(attackMove)
	{
		[attackMove startMove];
		attackMove.completeTarget = self;
		attackMove.completeSelector = @selector(attackComplete);
		
		
		lastMove = attackMove;
		
	} else {
		attackMove = [self getRandomMove];
		
		lastMove = attackMove;
		
		moveToAction = [BEUCharacterMoveToObject 
						actionWithObject:ai.targetCharacter 
						distance:attackMove.range
						zRange: ai.parent.moveArea.size.height];



		moveToAction.onCompleteTarget = self;
		moveToAction.onCompleteSelector = @selector(moveToComplete);
		
		moveToAction.cancelTarget = self;
		moveToAction.cancelSelector = @selector(moveToCanceled);

		[ai.parent runAction: moveToAction];
	}
	
	
	
}

@end