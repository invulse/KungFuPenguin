//
//  Enemy.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"
#import "Animator.h"
#import "BEUCharacterAIIdleBehavior.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"
#import "BEUInstantAction.h"
#import "Coins.h"
#import "HealthPack1.h"
#import "GameData.h"

@implementation Enemy

-(void)createObject
{
	[super createObject];
	
	[self setUpAI];
	[self setUpDrops];
	
}


-(void)setUpCharacter
{
	[super setUpCharacter];
	
	enemy = YES;
	autoOrient = YES;
	//drawBoundingBoxes = YES;
	isWall = NO;
	
	life = 100.0f;
	totalLife = 100.0f;
	
	minCoinDrop = 0;
	maxCoinDrop = 0;
	coinDropChance = 0.0f;
	
	minHealthDrop = 0;
	maxHealthDrop = 0;
	healthDropChance = 0.0f;
	
	if([[GameData sharedGameData] currentGameType] == GAME_TYPE_STORY)
	{
		switch ([GameData sharedGameData].currentDifficulty)
		{
			case GAME_DIFFICULTY_EASY:
				hitMultiplier = 1.4f;
				break;
			case GAME_DIFFICULTY_NORMAL:
				//coinsToDrop = coinsToDrop;
				hitMultiplier = 1.2f;
				break;
			case GAME_DIFFICULTY_HARD:
				hitMultiplier = 1.0f;
				break;
			case GAME_DIFFICULTY_INSANE:
				hitMultiplier = .8f;
				break;
				
		}
	}
	

}


-(void)setUpDrops
{
	
	/// SET UP DROPS
	itemsToDrop = [[NSMutableArray array] retain];
	
	if(CCRANDOM_0_1() <= coinDropChance || [GameData sharedGameData].currentGameType == GAME_TYPE_SURVIVAL)
	{
		
		int coinsToDrop = minCoinDrop + (maxCoinDrop-minCoinDrop)*CCRANDOM_0_1();
		
		if([GameData sharedGameData].currentGameType == GAME_TYPE_SURVIVAL)
		{
			
			coinsToDrop = coinsToDrop*3.0f;
		} else {
		
			switch ([GameData sharedGameData].currentDifficulty)
			{
				case GAME_DIFFICULTY_EASY:
					coinsToDrop = coinsToDrop*.8f;
					break;
				case GAME_DIFFICULTY_NORMAL:
					//coinsToDrop = coinsToDrop;
					break;
				case GAME_DIFFICULTY_HARD:
					coinsToDrop = coinsToDrop*1.3f;
					break;
				case GAME_DIFFICULTY_INSANE:
					coinsToDrop = coinsToDrop*1.8f;
					break;
		
			}
			
		}
		
		
		//find out how many 25c coins should drop
		int type25Coins = coinsToDrop/25;
		
		for ( int i=0; i<type25Coins; i++ )
		{
			Coin *coin;
			
			if([[BEUObjectController sharedController] doesObjectPoolContainType:[Coin25 class]])
			{
				coin = [((Coin *)[[BEUObjectController sharedController] getObjectFromPoolWithClass:[Coin25 class]]) retain];
			} else {
				coin = [[Coin25 coin] retain];
			}
			coin.visible = NO;
			[itemsToDrop addObject:coin];
			[coin release];
		}
		coinsToDrop = coinsToDrop%25;
		
		//find out how many 5c coins should drop
		int type5Coins = coinsToDrop/5;
		
		for ( int i=0; i<type5Coins; i++ )
		{
			Coin *coin;
			
			if([[BEUObjectController sharedController] doesObjectPoolContainType:[Coin5 class]])
			{
				coin = [((Coin *)[[BEUObjectController sharedController] getObjectFromPoolWithClass:[Coin5 class]]) retain];
			} else {
				coin = [[Coin5 coin] retain];
			}
			
			coin.visible = NO;
			[itemsToDrop addObject:coin];
			[coin release];
			
		}
		
		coinsToDrop = coinsToDrop%5;
		
		//find out how many 1c coins should drop
		int type1Coins = coinsToDrop/1;
		
		for ( int i=0; i<type1Coins; i++ )
		{
			Coin *coin;
			
			if([[BEUObjectController sharedController] doesObjectPoolContainType:[Coin1 class]])
			{
				coin = [((Coin *)[[BEUObjectController sharedController] getObjectFromPoolWithClass:[Coin1 class]]) retain];
			} else {
				coin = [[Coin1 coin] retain];
			}
			coin.visible = NO;
			[itemsToDrop addObject:coin];
			[coin release];
		}
		
		//coinsToDrop = coinsToDrop%1;
		
		
	}
	
	if(CCRANDOM_0_1() <= healthDropChance && [[GameData sharedGameData] currentGameType] != GAME_TYPE_SURVIVAL)
	{
		
		float healthToDrop = minHealthDrop + (maxHealthDrop-minHealthDrop)*CCRANDOM_0_1();
		
		HealthPack1 *pack = [HealthPack1 healthPack];
		pack.health = healthToDrop;
		pack.visible = NO;
		[itemsToDrop addObject:pack];
		
	}

}

-(void)setUpAI
{
	ai = [[BEUCharacterAI alloc] initWithParent:self];
	
	BEUCharacterAIBehavior *moveBranch = [BEUCharacterAIMove behavior];
	//[moveBranch setCanRunMultipleTimesInARow:NO];
	//[moveBranch addBehavior:[BEUCharacterAIMoveToTarget behavior]];
	BEUCharacterAIBehavior *moveAway = [BEUCharacterAIMoveAwayFromTarget behavior];
	moveAway.canRunMultipleTimesInARow = NO;
	
	BEUCharacterAIBehavior *moveAwayToZ = [BEUCharacterAIMoveAwayToTargetZ behavior];
	moveAwayToZ.canRunMultipleTimesInARow = NO;
	
	[moveBranch addBehavior:moveAway];
	[moveBranch addBehavior:moveAwayToZ];
	[ai addBehavior:moveBranch];
	
	BEUCharacterAIBehavior *idleBranch = [BEUCharacterAIIdleBehavior behaviorWithMinTime:0.6f maxTime:1.4f];
	//[idleBranch setCanRunMultipleTimesInARow:NO];
	[ai addBehavior:idleBranch];
	
	BEUCharacterAIAttackBehavior *attackBehavior = [BEUCharacterAIMoveToAndAttack behaviorWithMoves:[movesController moves]];
	attackBehavior.name = @"attack";
	attackBehavior.needsCooldown = YES;
	[ai addBehavior:attackBehavior];
	
	//BEUCharacterAIBehavior *attackBranch = [BEUCharacterAIAttackBehavior behavior];
	//[attackBranch addBehavior:];
	//[ai addBehavior:attackBranch];
}

-(void)reset
{
	[super reset];
	
	canMoveThroughObjectWalls = NO;
	canMoveThroughWalls = NO;
	
	[self setUpDrops];
	
}

-(void)death:(BEUAction *)action
{
	
	[super death:action];
	
	for ( BEUItem *obj in itemsToDrop )
	{
		CGRect globalRect = [self globalMoveArea];
		
		obj.x = globalRect.origin.x + globalRect.size.width/2;
		obj.z = globalRect.origin.y + globalRect.size.height/2;
		obj.y = 0;
		
		
		[obj applyForceX:-150 + 300*CCRANDOM_0_1()];
		[obj applyForceZ:-120 + 240*CCRANDOM_0_1()];
		[obj applyForceY: 200];
		
		obj.visible = YES;
		
		[[BEUObjectController sharedController] addItem:obj];		
	}	
	
	[itemsToDrop removeAllObjects];
	
	
}

-(void)dealloc
{
	[itemsToDrop release];
	
	[super dealloc];
}


@end
