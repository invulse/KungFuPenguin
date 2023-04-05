//
//  Enemy.h
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "Character.h"

@class Animator;

@interface Enemy : Character {
	
	//minimum number of coins to be dropped on the enemies death
	int minCoinDrop;
	//maximum number of coins to be dropped on the enemies death
	int maxCoinDrop;
	//percentage of time that coins are dropped by enemy, 0 for never, 1 for always 
	float coinDropChance;
	
	
	//minimum amount of health to drop
	float maxHealthDrop;
	//maxmimum amount of health to drop
	float minHealthDrop;
	//percentage of time that health is dropped
	float healthDropChance;
	
	
	//Array of items that will drop when character dies
	NSMutableArray *itemsToDrop;
	
}

-(void)setUpAI;
-(void)setUpDrops;

@end
