//
//  SurvivalGame.m
//  BEUEngine
//
//  Created by Chris Mele on 10/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "SurvivalGame.h"
#import "BEUEnvironment.h"
#import "BEUArea.h"
#import "BEUGameManager.h"
#import "BEUTrigger.h"
#import "BEUGameAction.h"
#import "BEUAssetController.h"
#import "GameHUD.h"
#import "BEUObjectController.h"
#import "GameData.h"
#import "PenguinCharacter.h"
#import "SurvivalEnd.h"
#import "CrystalSession.h"

@implementation SurvivalGame

@synthesize gameType;

-(id)initGameWithType:(int)gameType_
{
	gameType = gameType_;
	
	NSString *file;
	switch (gameType) {
		case SURVIVAL_GAME_VILLAGE:
			file = @"SurvivalVillage.plist";
			break;
		case SURVIVAL_GAME_CAVE:
			file = @"SurvivalCave.plist";
			break;
		case SURVIVAL_GAME_DOJO:
			file = @"SurvivalDojo.plist";
			break;
		case SURVIVAL_GAME_HQ:
			file = @"SurvivalHQ.plist";
			break;
	}
	
	return [self initGameWithLevel:file];
}


-(id)initAsyncWithType:(int)gameType_ callbackTarget:(id)callbackTarget_
{
	
	
	gameType = gameType_;
	NSString *file;
	switch (gameType) {
		case SURVIVAL_GAME_VILLAGE:
			file = @"SurvivalVillage.plist";
			break;
		case SURVIVAL_GAME_CAVE:
			file = @"SurvivalCave.plist";
			break;
		case SURVIVAL_GAME_DOJO:
			file = @"SurvivalDojo.plist";
			break;
		case SURVIVAL_GAME_HQ:
			file = @"SurvivalHQ.plist";
			break;
	}
	
	return [self initAsyncWithLevel:file callbackTarget:callbackTarget_];

}

-(id)initGameWithSaveData:(NSDictionary *)saveData_
{
	loadedGame = YES;
	saveData = [saveData_ retain];
	[[GameData sharedGameData] setSavedSurvivalGame:nil];
	[[GameData sharedGameData] save];
	
	[[BEUGameManager sharedManager] setInitialMusic: [[NSArray arrayWithObjects:@"ninja2.mp3",@"arctic winds.mp3",@"straight ahead.mp3",nil] objectAtIndex:arc4random()%3] ];
	
	gameType = [[saveData valueForKey:@"gameType"] intValue];
	
	NSString *file;
	switch (gameType) {
		case SURVIVAL_GAME_VILLAGE:
			file = @"SurvivalVillage.plist";
			break;
		case SURVIVAL_GAME_CAVE:
			file = @"SurvivalCave.plist";
			break;
		case SURVIVAL_GAME_DOJO:
			file = @"SurvivalDojo.plist";
			break;
		case SURVIVAL_GAME_HQ:
			file = @"SurvivalHQ.plist";
			break;
	}
	
	return [self initGameWithLevel:file];
}

-(id)initAsyncWithSaveData:(NSDictionary *)saveData_ callbackTarget:(id)callbackTarget_
{
	loadedGame = YES;
	saveData = [saveData_ retain];
	
	gameType = [[saveData valueForKey:@"gameType"] intValue];
	
	[[GameData sharedGameData] setSavedSurvivalGame:nil];
	[[GameData sharedGameData] save];
	
	NSString *file;
	switch (gameType) {
		case SURVIVAL_GAME_VILLAGE:
			file = @"SurvivalVillage.plist";
			break;
		case SURVIVAL_GAME_CAVE:
			file = @"SurvivalCave.plist";
			break;
		case SURVIVAL_GAME_DOJO:
			file = @"SurvivalDojo.plist";
			break;
		case SURVIVAL_GAME_HQ:
			file = @"SurvivalHQ.plist";
			break;
	}
	
	return [self initAsyncWithLevel:file callbackTarget:callbackTarget_];
}

-(void)createGame
{
	[[GameData sharedGameData] setCurrentGameType:GAME_TYPE_SURVIVAL];
	
	[super createGame];
	
	[SurvivalEnd preload];
	
	[[GameHUD sharedGameHUD] enableKillMeter];
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerKilled selector:@selector(killHandler:)];
	
	enemiesKilled = 0;
	areaBuffer = 1;
	completedAreas = 0;
	
	if(loadedGame)
	{
		enemiesKilled = [[saveData valueForKey:@"enemiesKilled"] intValue];
		completedAreas = [[saveData valueForKey:@"completedAreas"] intValue];
		[[[GameHUD sharedGameHUD] killMeter] setKills:enemiesKilled];
		
		[[[GameHUD sharedGameHUD] coins] setCoins:[[GameData sharedGameData] coins] + [[saveData valueForKey:@"coinsCollected"] intValue]];
		
		PenguinCharacter *penguin = (PenguinCharacter *)[[BEUObjectController sharedController] playerCharacter];
		
		[penguin applyHealth:[[saveData valueForKey:@"health"] floatValue]-penguin.totalLife];
		[penguin applySpecial:[[saveData valueForKey:@"rampage"] floatValue]];
	}
	
	
	float spawnerSizePadding = 0;//30;
	
	switch (gameType) {
		case SURVIVAL_GAME_VILLAGE:
			spawnerLimitTopY = 180 - spawnerSizePadding;
			spawnerLimitBottomY = 0 + spawnerSizePadding;
			
			spawnInfo = [[NSMutableArray arrayWithObjects:
						 
						 [SpawnInfo infoWithStart:0 
										maxAtOnce:4 
									numberToSpawn:8 
									   spawnTypes:[NSMutableArray arrayWithObjects:
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo2"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo3"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo4"].class,
												   nil
												   ]
						  ],
						 
						 [SpawnInfo infoWithStart:3 
										maxAtOnce:5 
									numberToSpawn:10 
									   spawnTypes:[NSMutableArray arrayWithObjects:
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo2"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo3"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo4"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"FatEskimo"].class,
												   nil
												   ]
						  ],
						 
						 [SpawnInfo infoWithStart:8 
										maxAtOnce:6 
									numberToSpawn:16 
									   spawnTypes:[NSMutableArray arrayWithObjects:
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo2"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo3"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo4"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"FatEskimo"].class,
												   nil
												   ]
						  ],
						 
						 [SpawnInfo infoWithStart:12
										maxAtOnce:8
									numberToSpawn:20 
									   spawnTypes:[NSMutableArray arrayWithObjects:
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo2"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo3"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"Eskimo4"].class,
												   [[BEUAssetController sharedController] getAssetWithName:@"FatEskimo"].class,
												   nil
												   ]
						  ],
						 nil
						 ] retain];
			
			
			break;
		case SURVIVAL_GAME_CAVE:
			spawnerLimitTopY = 230 - spawnerSizePadding;
			spawnerLimitBottomY = 0 + spawnerSizePadding;
			
			spawnInfo = [[NSMutableArray arrayWithObjects:
						  
						  [SpawnInfo infoWithStart:0 
										 maxAtOnce:4 
									 numberToSpawn:16 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo3"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo4"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"FatEskimo"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Wolf"].class,
													
													nil
													]
						   ],
						  
						  [SpawnInfo infoWithStart:3 
										 maxAtOnce:5 
									 numberToSpawn:20 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo3"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo4"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"FatEskimo"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Wolf"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Bat"].class,
													nil
													]
						   ],
						  
						  [SpawnInfo infoWithStart:8 
										 maxAtOnce:6 
									 numberToSpawn:25 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo3"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo4"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"FatEskimo"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Wolf"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Bat"].class,
													nil
													]
						   ],
						  
						  [SpawnInfo infoWithStart:12
										 maxAtOnce:8
									 numberToSpawn:30 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo3"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Eskimo4"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"FatEskimo"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Wolf"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Bat"].class,
													nil
													]
						   ],
						  nil
						  ] retain];
			break;
		case SURVIVAL_GAME_DOJO:
			spawnerLimitTopY = 185 - spawnerSizePadding;
			spawnerLimitBottomY = 0 + spawnerSizePadding;
			
			spawnInfo = [[NSMutableArray arrayWithObjects:
						  
						  [SpawnInfo infoWithStart:0 
										 maxAtOnce:4 
									 numberToSpawn:16 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo1"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo2"].class,
													nil
													]
						   ],
						  
						  [SpawnInfo infoWithStart:3 
										 maxAtOnce:5 
									 numberToSpawn:20 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo1"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo3"].class,
													nil
													]
						   ],
						  
						  [SpawnInfo infoWithStart:8 
										 maxAtOnce:6 
									 numberToSpawn:25 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo1"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo3"].class,
													nil
													]
						   ],
						  
						  [SpawnInfo infoWithStart:12
										 maxAtOnce:8
									 numberToSpawn:30 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo1"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"NinjaEskimo3"].class,
													nil
													]
						   ],
						  nil
						  ] retain];
			break;
		case SURVIVAL_GAME_HQ:
			spawnerLimitTopY = 240 - spawnerSizePadding;
			spawnerLimitBottomY = 0 + spawnerSizePadding;
			
			spawnInfo = [[NSMutableArray arrayWithObjects:
						  
						  [SpawnInfo infoWithStart:0 
										 maxAtOnce:4 
									 numberToSpawn:16 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd1"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd3"].class,
													nil
													]
						   ],
						  
						  [SpawnInfo infoWithStart:3 
										 maxAtOnce:5 
									 numberToSpawn:20 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd1"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd3"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Gman1"].class,
													nil
													]
						   ],
						  
						  [SpawnInfo infoWithStart:8 
										 maxAtOnce:6 
									 numberToSpawn:25 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd1"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd3"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Gman1"].class,
													nil
													]
						   ],
						  
						  [SpawnInfo infoWithStart:12
										 maxAtOnce:8
									 numberToSpawn:30 
										spawnTypes:[NSMutableArray arrayWithObjects:
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd1"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd2"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"SecurityGaurd3"].class,
													[[BEUAssetController sharedController] getAssetWithName:@"Gman1"].class,
													nil
													]
						   ],
						  nil
						  ] retain];
			break;
	}
	
	
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerEnteredArea selector:@selector(newAreaEnteredHandler:)];
	
	areaPool = [[NSMutableArray alloc] init];
	
	for ( int i=[[BEUEnvironment sharedEnvironment] areas].count-1; i>=0; i-- )
	{
		
		BEUArea *area = [[[BEUEnvironment sharedEnvironment] areas] objectAtIndex:i];
		[areaPool addObject:area];
		[[BEUEnvironment sharedEnvironment] removeArea:area];
		
		
	}
	
	
	
	
	for ( int i=0; i< areaBuffer*2+1; i++ )
	{
		[self makeNewArea];
		
	}
	
	BEUArea *secondArea = [[[BEUEnvironment sharedEnvironment] areas] objectAtIndex:1];
	[[BEUObjectController sharedController] playerCharacter].x = secondArea.position.x + secondArea.contentSize.width/3;
	[[BEUObjectController sharedController] playerCharacter].z = spawnerLimitBottomY + (spawnerLimitTopY - spawnerLimitBottomY)/2;
	
	[[BEUGameManager sharedManager] setInitialMusic: [[NSArray arrayWithObjects:@"ninja2.mp3",@"arctic winds.mp3",@"straight ahead.mp3",nil] objectAtIndex:arc4random()%3] ];
	
	
}

-(void)killHandler:(BEUTrigger *)trigger
{
	if( ((BEUCharacter *)trigger.sender).enemy )
	{
		enemiesKilled++;
		
		[[[GameHUD sharedGameHUD] killMeter] setKills:enemiesKilled];
		
	}
}

-(void)startGameHandler:(BEUTrigger *)trigger
{
	[super startGameHandler:trigger];
	
	
	//[[[[BEUEnvironment sharedEnvironment] areas] objectAtIndex:0] unlock];
}

-(void)newAreaEnteredHandler:(id)trigger
{
	
	int currentAreaIndex = [[[BEUEnvironment sharedEnvironment] areas] indexOfObject:[[BEUEnvironment sharedEnvironment] currentArea]];
	int totalAreas = [[[BEUEnvironment sharedEnvironment] areas] count];
	BEUArea *currentArea = [[BEUEnvironment sharedEnvironment] currentArea];
	if(currentAreaIndex > areaBuffer)
	{
		[[BEUEnvironment sharedEnvironment] removeArea:
		 [[[BEUEnvironment sharedEnvironment] areas] objectAtIndex:0]
		 ];
	}
	
	if(currentAreaIndex == totalAreas-areaBuffer)
	{
		[self makeNewArea];
	}
	
	
	if(currentAreaIndex > 0)
	{
		float spawnerPadding = 80;
		//float spawnerWidth = 30;
		//float spawnerHeight = spawnerLimitTopY-spawnerLimitBottomY;
		
		SpawnInfo *info = [self getCurrentSpawnInfo];
		
		
		//float timeBetweenSpawns = 1.0f;
		
				
		BEUSpawner *spawner = [BEUSpawner spawnerWithArea:CGRectMake(currentArea.position.x - spawnerPadding, spawnerLimitBottomY + spawnerPadding,currentArea.contentSize.width + spawnerPadding*2,spawnerLimitTopY - spawnerLimitBottomY - spawnerPadding) types:info.spawnTypes numberToSpawn:info.numberToSpawn ordered:NO async:YES];
		spawner.maximumSpawnableAtOnce = info.maxAtOnce;
		spawner.timeBetweenSpawns = 1.0f;
		spawner.mustBeOutOfViewport = YES;
		[[BEUObjectController sharedController] addSpawner:spawner];
		[spawner start];
		
		[[BEUGameManager sharedManager] addGameAction:
		 [BEUGameAction actionWithListeners:
		  [NSMutableArray arrayWithObjects:
		   [BEUGameActionListener listenerWithListenType:BEUTriggerAllEnemiesKilled listenTarget:spawner],
		   nil
		   ]
								  selectors:
		  [NSMutableArray arrayWithObjects:
		   [BEUGameActionSelector selectorWithType:@selector(unlock) target:currentArea],
		   nil
		   ]
		  ]		 
		 ];
		
		completedAreas++;
		enemiesKilledAtLastArea = enemiesKilled;
		coinsCollectedAtLastArea = [[[GameHUD sharedGameHUD] coins] coins] - [[GameData sharedGameData] coins];
		healthAtLastArea = [[[BEUObjectController sharedController] playerCharacter] life];
		rampageAtLastArea = [((PenguinCharacter *)[[BEUObjectController sharedController] playerCharacter]) special]; 
		
		[[GameData sharedGameData] setSavedSurvivalGame:[self saveGame]];
		[[GameData sharedGameData] save];
		
		
	}
	
}

-(SpawnInfo *)getCurrentSpawnInfo
{
	SpawnInfo *lastInfo = nil;
	
	for ( SpawnInfo *info in spawnInfo )
	{
		if(!lastInfo) lastInfo = info;
		else if(info.areaStart > completedAreas) {
			break;
		} else {
			lastInfo = info;
		}
	}
	
	return lastInfo;
	
}

-(BEUArea *)makeNewArea
{
	BEUArea *newArea = [(BEUArea *)[areaPool objectAtIndex: (arc4random()%areaPool.count)] clone];
	newArea.autoLock = YES;
	newArea.transition = BEUAreaTransitionSnap;
	[[BEUEnvironment sharedEnvironment] addArea:newArea];
	
	return newArea;
}

-(NSDictionary *)saveGame
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:gameType],
			@"gameType",
			[NSNumber numberWithInt:completedAreas],
			@"completedAreas",
			[NSNumber numberWithInt:enemiesKilledAtLastArea],
			@"enemiesKilled",
			[NSNumber numberWithInt:coinsCollectedAtLastArea],
			@"coinsCollected",
			[NSNumber numberWithFloat:healthAtLastArea],
			@"health",
			[NSNumber numberWithFloat:rampageAtLastArea],
			@"rampage",
			nil		
			];
}

-(void)mainCharacterKilled:(BEUTrigger *)trigger
{
	SurvivalEnd *end = [SurvivalEnd endWithScore:enemiesKilled];
	[self addChild:end];
	
	[[GameData sharedGameData] setSavedSurvivalGame:nil];
	
	int coinsCollected = [[[GameHUD sharedGameHUD] coins] coins] - [[GameData sharedGameData] coins];
	[[GameData sharedGameData] setTotalGameTime:[GameData sharedGameData].totalGameTime+gameTime];
	[[GameData sharedGameData] setCoins:[[[GameHUD sharedGameHUD] coins] coins]];
	[[GameData sharedGameData] setTotalCoins:[GameData sharedGameData].totalCoins+coinsCollected];
	
	
	
	NSString *scoreKey;
	NSString *leaderboardID;
	
	switch (gameType) {
		case SURVIVAL_GAME_VILLAGE:
			scoreKey = @"villageHighScore";
			leaderboardID = @"988409436";
			break;
		case SURVIVAL_GAME_CAVE:
			scoreKey = @"caveHighScore";
			leaderboardID = @"988377755";
			break;
		case SURVIVAL_GAME_DOJO:
			scoreKey = @"dojoHighScore";
			leaderboardID = @"988431394";
			break;
		case SURVIVAL_GAME_HQ:
			scoreKey = @"hqHighScore";
			leaderboardID = @"988471063";
			break;
	}
	
	int bestScore = [[[[GameData sharedGameData] survivalGameInfo] valueForKey:scoreKey] intValue];
	
	if(bestScore < enemiesKilled)
	{
		[[[GameData sharedGameData] survivalGameInfo] setValue:[NSNumber numberWithInt:enemiesKilled] forKey:scoreKey];
		[end newRecord];
	}
	
	[CrystalSession postLeaderboardResult:enemiesKilled forLeaderboardId:leaderboardID lowestValFirst:NO];
	//post total coins 
	[CrystalSession postLeaderboardResult:[GameData sharedGameData].totalCoins forLeaderboardId:@"988456026" lowestValFirst:NO];
	
	[[GameData sharedGameData] save];
}

-(void)killGame
{
	/*[[GameData sharedGameData] setSavedSurvivalGame:nil];
	[[GameData sharedGameData] save];*/
	[super killGame];
}

-(void)dealloc
{
	[areaPool release];
	[spawnInfo release];
	[super dealloc];
}


@end

@implementation SpawnInfo

@synthesize areaStart, maxAtOnce, numberToSpawn, spawnTypes;

-(id)initWithStart:(int)start_ maxAtOnce:(int)max_ numberToSpawn:(int)number_ spawnTypes:(NSMutableArray *)types_
{
	[super init];
	
	areaStart = start_;
	maxAtOnce = max_;
	numberToSpawn = number_;
	spawnTypes = [types_ retain];
	
	return self;
}

+(id)infoWithStart:(int)start_ maxAtOnce:(int)max_ numberToSpawn:(int)number_ spawnTypes:(NSMutableArray *)types_
{
	return [[[self alloc] initWithStart:start_ maxAtOnce:max_ numberToSpawn:number_ spawnTypes:types_] autorelease];
}

-(void)dealloc
{

	[spawnTypes release];
	[super dealloc];
}

@end

