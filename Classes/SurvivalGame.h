//
//  SurvivalGame.h
//  BEUEngine
//
//  Created by Chris Mele on 10/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinGame.h"

#define SURVIVAL_GAME_VILLAGE 1
#define SURVIVAL_GAME_CAVE 2
#define SURVIVAL_GAME_DOJO 3
#define SURVIVAL_GAME_HQ 4

@class BEUArea;
@class SpawnInfo;

@interface SurvivalGame : PenguinGame {
	
	int gameType;
	int enemiesKilled;
	
	int completedAreas;
	int enemiesKilledAtLastArea;
	int coinsCollectedAtLastArea;
	float healthAtLastArea;
	float rampageAtLastArea;
	
	//amount of areas to buffer in front of and in back of the currentArea
	int areaBuffer;
	
	//Pool of areas to clone from for upcoming areas needed
	NSMutableArray *areaPool;
	
	NSMutableArray *spawnInfo;
	
	float spawnerLimitBottomY;
	float spawnerLimitTopY;
	
	BOOL loadedGame;
	//NSDictionary *saveData;
	
	
}

@property(nonatomic) int gameType;

-(id)initGameWithType:(int)gameType_;
-(id)initAsyncWithType:(int)gameType_ callbackTarget:(id)callbackTarget_;

-(id)initGameWithSaveData:(NSDictionary *)saveData_;
-(id)initAsyncWithSaveData:(NSDictionary *)saveData_ callbackTarget:(id)callbackTarget_;


-(BEUArea *)makeNewArea;
-(SpawnInfo *)getCurrentSpawnInfo;

-(NSDictionary *)saveGame;

@end

@interface SpawnInfo : NSObject
{
	int areaStart;
	int maxAtOnce;
	int numberToSpawn;
	
	NSMutableArray *spawnTypes;
}

@property(assign) int areaStart;
@property(assign) int maxAtOnce;
@property(assign) int numberToSpawn;
@property(retain) NSMutableArray *spawnTypes;

-(id)initWithStart:(int)start_ maxAtOnce:(int)max_ numberToSpawn:(int)number_ spawnTypes:(NSMutableArray *)types_;
+(id)infoWithStart:(int)start_ maxAtOnce:(int)max_ numberToSpawn:(int)number_ spawnTypes:(NSMutableArray *)types_;

@end

