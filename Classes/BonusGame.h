//
//  BonusGame.h
//  BEUEngine
//
//  Created by Chris Mele on 11/3/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinGame.h"

#define BONUS_GAME_ICEBERG 1
#define BONUS_GAME_BUILDING 2
#define BONUS_GAME_WAREHOUSE 3

@interface BonusGame : PenguinGame {
	
	NSString *nextLevel;
	
	int gameType;
	
	float timeTillNextCharacterSpawn;
	float timeTillNextRockSpawn;
	float minSpawnTime;
	float maxSpawnTime;
	int enemiesKilled;
	
	NSMutableArray *charatersSpawning;
	NSMutableArray *rockSpawnInfos;
	NSMutableArray *characterSpawnInfos;
	
	float minSpawnY;
	float maxSpawnY;
}

-(id)initGameWithType:(int)type_ nextLevel:(NSString *)nextLevel_;
-(id)initAsyncWithType:(int)type_ nextLevel:(NSString *)nextLevel_ callbackTarget:(id)callbackTarget_;
-(void)creationComplete:(id)sender;
@end

@interface BonusSpawnInfo : NSObject {
	NSMutableArray *spawnTypes;
	float startTime;
	float minTimeBetweenSpawns;
	float maxTimeBetweenSpawns;
} 

@property(retain) NSMutableArray *spawnTypes;
@property(assign) float startTime;
@property(assign) float minTimeBetweenSpawns;
@property(assign) float maxTimeBetweenSpawns;

-(id)initWithStartTime:(float)startTime_ spawnTypes:(NSMutableArray *)spawnTypes_ minTime:(float)minTime_ maxTime:(float)maxTime_;
+(id)infoWithStartTime:(float)startTime_ spawnTypes:(NSMutableArray *)spawnTypes_ minTime:(float)minTime_ maxTime:(float)maxTime_;;

@end