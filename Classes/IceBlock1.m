//
//  IceBlock1.m
//  BEUEngine
//
//  Created by Chris Mele on 8/26/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "IceBlock1.h"
#import "Coins.h"
#import "HealthPack1.h"
#import "BEUCharacter.h"

@implementation IceBlock1

-(id)init
{
	self = [super init];
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"IceBlock1.plist"];
	
	block = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"IceBlock1.png"]];
	block.anchorPoint = ccp(0,0);
	block.position = ccp(85,-10);
	blockStart = block.position;
	[self addChild:block];
	
	//drawBoundingBoxes = YES;
	
	moveArea = CGRectMake(-15, 0, 106, 50);
	hitArea = CGRectMake(-15, 0, 106, 90);
	
	return self;
}

-(void)createDrops
{
	
	int minCoinDrop = 0;
	int maxCoinDrop = 50;
	
	
		
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
	
	
	
	float healthDropChance = .7;
	float minHealthDrop = 10;
	float maxHealthDrop = 50;
	
	
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
	
	[block stopAllActions];
	
	[block runAction:
	 [CCSequence actions:
	  [CCMoveTo actionWithDuration:0.08f position:ccp(blockStart.x+2.0f*sender.directionMultiplier,blockStart.y+0.0f)],
	  [CCMoveTo actionWithDuration:0.08f position:blockStart],
	  nil
	  ]
	 ];
}	

-(void)destroyed:(BEUHitAction *)hit
{
	[super destroyed:hit];
	
	BEUCharacter *sender = ((BEUCharacter *)hit.sender);
	
	[block setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"IceBlock1-Broken.png"]];
	
	[block runAction:
	 [CCSequence actions:
	  [CCJumpBy actionWithDuration:0.6f position:ccp(30.0f*sender.directionMultiplier,0) height:15.0f jumps:1],
	  [CCFadeOut actionWithDuration:0.8f],
	  [CCCallFunc actionWithTarget:self selector:@selector(remove)],
	  nil
	  ]
	 ];
}

@end
