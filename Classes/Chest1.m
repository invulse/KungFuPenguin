//
//  IceBlock1.m
//  BEUEngine
//
//  Created by Chris Mele on 8/26/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Chest1.h"
#import "Coins.h"
#import "HealthPack1.h"
#import "BEUCharacter.h"

@implementation Chest1

-(id)init
{
	self = [super init];
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Chest1.plist"];
	
	chest = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Chest1.png"]];
	chest.anchorPoint = ccp(0,0);
	chest.position = ccp(90,0);
	chestStart = chest.position;
	[self addChild:chest];
	
	//drawBoundingBoxes = YES;
	
	moveArea = CGRectMake(0, 0, 110, 30);
	hitArea = CGRectMake(0, 0, 110, 90);
	
	return self;
}

-(void)createDrops
{
	
	int minCoinDrop = 20;
	int maxCoinDrop = 70;
	
	
	
	int coinsToDrop = minCoinDrop + (maxCoinDrop-minCoinDrop)*CCRANDOM_0_1();
	
	//find out how many 25c coins should drop
	int type25Coins = coinsToDrop/25;
	
	for ( int i=0; i<type25Coins; i++ )
	{
		Coin *coin = [Coin coinWithValue:25];
		coin.visible = NO;
		[drops addObject:coin];
	}
	coinsToDrop = coinsToDrop%25;
	
	//find out how many 5c coins should drop
	int type5Coins = coinsToDrop/5;
	
	for ( int i=0; i<type5Coins; i++ )
	{
		Coin *coin = [Coin coinWithValue:5];
		coin.visible = NO;
		[drops addObject:coin];
	}
	
	coinsToDrop = coinsToDrop%5;
	
	//find out how many 1c coins should drop
	int type1Coins = coinsToDrop/1;
	
	for ( int i=0; i<type1Coins; i++ )
	{
		Coin *coin = [Coin coinWithValue:1];
		coin.visible = NO;
		[drops addObject:coin];
	}
	
	coinsToDrop = coinsToDrop%1;
	
	
	
	float healthDropChance = 1.0;
	float minHealthDrop = 30;
	float maxHealthDrop = 80;
	
	
	if(CCRANDOM_0_1() <= healthDropChance)
	{
		
		float healthToDrop = minHealthDrop + (maxHealthDrop-minHealthDrop)*CCRANDOM_0_1();
		
		HealthPack1 *pack = [HealthPack1 healthPack];
		pack.health = healthToDrop;
		pack.visible = NO;
		[drops addObject:pack];
		
	}
	
	
}

-(void)hit:(BEUHitAction *)hit
{
	
	BEUCharacter *sender = ((BEUCharacter *)hit.sender);
	
	[chest stopAllActions];
	
	[chest runAction:
	 [CCSequence actions:
	  [CCMoveTo actionWithDuration:0.08f position:ccp(chestStart.x+2.0f*sender.directionMultiplier,chestStart.y+0.0f)],
	  [CCMoveTo actionWithDuration:0.08f position:chestStart],
	  nil
	  ]
	 ];
}	

-(void)destroyed:(BEUHitAction *)hit
{
	[super destroyed:hit];
	
	BEUCharacter *sender = ((BEUCharacter *)hit.sender);
	
	[chest setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Chest1-Open.png"]];
	
	[chest runAction:
	 [CCSequence actions:
	  [CCJumpBy actionWithDuration:0.6f position:ccp(30.0f*sender.directionMultiplier,0) height:15.0f jumps:1],
	  [CCFadeOut actionWithDuration:0.8f],
	  [CCCallFunc actionWithTarget:self selector:@selector(remove)],
	  nil
	  ]
	 ];
}

@end
