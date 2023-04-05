//
//  BonusGame.m
//  BEUEngine
//
//  Created by Chris Mele on 11/3/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUGameManager.h"
#import "BonusGame.h"
#import "PenguinSlideCharacter.h"
#import "Eskimo2Running.h"
#import "IcebergBonusTile.h"
#import "IcebergBonusBG.h"
#import "BEUAssetController.h"
#import "BEUInputJoystick.h"
#import "IcebergBonusRocks.h"
#import "BEUTriggerController.h"
#import "GameHUD.h"
#import "EndLevelBonus.h"
#import "CrystalSession.h"
#import "GameData.h"
#import "BuildingBonusTile.h"
#import "WarehouseBonusTile.h"
#import "NinjaRunning.h"
#import "SecurityGaurd1Running.h"
#import "BuildingBonusRocks.h"
#import "HQPole.h"

@implementation BonusGame

-(id)initGameWithType:(int)type_ nextLevel:(NSString *)nextLevel_
{
	nextLevel = [nextLevel_ copy];
	
	gameType = type_;
	
	
	NSString *file;
	switch (gameType) {
		case BONUS_GAME_ICEBERG:
			file = @"IcebergBonus.plist";
			break;
		case BONUS_GAME_BUILDING:
			file = @"BuildingBonus.plist";
			break;
		case BONUS_GAME_WAREHOUSE:
			file = @"WarehouseBonus.plist";
			break;
	}
	
	return [self initGameWithLevel:file];
}

-(id)initAsyncWithType:(int)type_ nextLevel:(NSString *)nextLevel_ callbackTarget:(id)callbackTarget_
{
	nextLevel = [nextLevel_ copy];
	
	gameType = type_;
	
	
	NSString *file;
	switch (gameType) {
		case BONUS_GAME_ICEBERG:
			file = @"IcebergBonus.plist";
			break;
		case BONUS_GAME_BUILDING:
			file = @"BuildingBonus.plist";
			break;
		case BONUS_GAME_WAREHOUSE:
			file = @"WarehouseBonus.plist";
			break;
	}
	
	return [self initAsyncWithLevel:file callbackTarget:callbackTarget_];
}

-(void)createGame
{
	[super createGame];
	
	[EndLevelBonus preload];
	
	[[GameHUD sharedGameHUD] enableKillMeter];
	[[BEUTriggerController sharedController] addListener:self type:BEUTriggerKilled selector:@selector(killHandler:)];
	
	enemiesKilled = 0;
	
	charatersSpawning = [[NSMutableArray alloc] init];
	minSpawnTime = 5.0f;
	maxSpawnTime = 8.0f;
	timeTillNextCharacterSpawn = minSpawnTime + (maxSpawnTime-minSpawnTime)*CCRANDOM_0_1();
	timeTillNextRockSpawn = minSpawnTime + (maxSpawnTime-minSpawnTime)*CCRANDOM_0_1();
	
	[[BEUEnvironment sharedEnvironment] removeArea:[[[BEUEnvironment sharedEnvironment] areas] objectAtIndex:0]];
	
	BEUArea *area;
	BEUEnvironmentImage *bg;
	BEUEnvironmentImage *fg;
	
	switch (gameType) {
		case BONUS_GAME_ICEBERG:
			area = [[[BEUArea alloc] init] autorelease];
			
			[area addTile:[[[IcebergBonusTile alloc] initTile] autorelease]];
			
			[[BEUEnvironment sharedEnvironment] addArea:area];
			
			
			BEUEnvironmentImage *bg = [[[IcebergBonusBG alloc] init] autorelease];
			
			[[BEUEnvironment sharedEnvironment] addBG:bg];
			
			characterSpawnInfos = [[NSMutableArray arrayWithObjects:
									[BonusSpawnInfo infoWithStartTime:0.0f spawnTypes:[NSMutableArray arrayWithObject:[Eskimo2Running class]] minTime:2.5f maxTime:5.0f],
									[BonusSpawnInfo infoWithStartTime:15.0f spawnTypes:[NSMutableArray arrayWithObject:[Eskimo2Running class]] minTime:2.0f maxTime:4.8f],
									[BonusSpawnInfo infoWithStartTime:35.0f spawnTypes:[NSMutableArray arrayWithObject:[Eskimo2Running class]] minTime:1.5f maxTime:4.0f],
									[BonusSpawnInfo infoWithStartTime:60.0f spawnTypes:[NSMutableArray arrayWithObject:[Eskimo2Running class]] minTime:1.5f maxTime:3.5f],
									
									nil
									] retain];
			rockSpawnInfos = [[NSMutableArray arrayWithObjects:
							   [BonusSpawnInfo infoWithStartTime:0.0f spawnTypes:[NSMutableArray arrayWithObjects:[IcebergBonusRock3 class],nil] minTime:3.0f maxTime:6.0f],
							   [BonusSpawnInfo infoWithStartTime:20.0f spawnTypes:[NSMutableArray arrayWithObjects:[IcebergBonusRock3 class],[IcebergBonusRock2 class],nil] minTime:2.5f maxTime:5.0f],
							   [BonusSpawnInfo infoWithStartTime:60.0f spawnTypes:[NSMutableArray arrayWithObjects:[IcebergBonusRock3 class],[IcebergBonusRock2 class],[IcebergBonusRock1 class],nil] minTime:1.7f maxTime:4.0f],
							   [BonusSpawnInfo infoWithStartTime:120.0f spawnTypes:[NSMutableArray arrayWithObjects:[IcebergBonusRock2 class],[IcebergBonusRock1 class],nil] minTime:1.0f maxTime:3.6f],
							   [BonusSpawnInfo infoWithStartTime:180.0f spawnTypes:[NSMutableArray arrayWithObjects:[IcebergBonusRock1 class],nil] minTime:1.0f maxTime: 3.0f],
							   nil
							   ] retain];
			minSpawnY = 65;
			maxSpawnY = 205;
			break;
		case BONUS_GAME_BUILDING:
			area = [[[BEUArea alloc] init] autorelease];
			
			[area addTile:[[[BuildingBonusTile alloc] initTile] autorelease]];
			
			[[BEUEnvironment sharedEnvironment] addArea:area];
			
			
			bg = [[[BuildingBonusBG alloc] init] autorelease];
			
			[[BEUEnvironment sharedEnvironment] addBG:bg];
			fg = [[[BuildingBonusFG alloc] init] autorelease];
			
			[[BEUEnvironment sharedEnvironment] addFG:fg];
			
			characterSpawnInfos = [[NSMutableArray arrayWithObjects:
									[BonusSpawnInfo infoWithStartTime:0.0f spawnTypes:[NSMutableArray arrayWithObject:[NinjaRunning class]] minTime:2.5f maxTime:5.0f],
									[BonusSpawnInfo infoWithStartTime:15.0f spawnTypes:[NSMutableArray arrayWithObject:[NinjaRunning class]] minTime:2.0f maxTime:4.8f],
									[BonusSpawnInfo infoWithStartTime:35.0f spawnTypes:[NSMutableArray arrayWithObject:[NinjaRunning class]] minTime:1.5f maxTime:4.0f],
									[BonusSpawnInfo infoWithStartTime:60.0f spawnTypes:[NSMutableArray arrayWithObject:[NinjaRunning class]] minTime:1.5f maxTime:3.5f],
									
									nil
									] retain];
			rockSpawnInfos = [[NSMutableArray arrayWithObjects:
							   [BonusSpawnInfo infoWithStartTime:0.0f spawnTypes:[NSMutableArray arrayWithObjects:[BuildingBonusRock1 class],nil] minTime:3.0f maxTime:6.0f],
							   [BonusSpawnInfo infoWithStartTime:20.0f spawnTypes:[NSMutableArray arrayWithObjects:[BuildingBonusRock1 class],[BuildingBonusRock2 class],nil] minTime:2.5f maxTime:5.0f],
							   [BonusSpawnInfo infoWithStartTime:60.0f spawnTypes:[NSMutableArray arrayWithObjects:[BuildingBonusRock1 class],[BuildingBonusRock2 class],[BuildingBonusRock3 class],nil] minTime:1.7f maxTime:4.0f],
							   [BonusSpawnInfo infoWithStartTime:120.0f spawnTypes:[NSMutableArray arrayWithObjects:[BuildingBonusRock2 class],[BuildingBonusRock3 class],nil] minTime:1.0f maxTime:3.6f],
							   [BonusSpawnInfo infoWithStartTime:180.0f spawnTypes:[NSMutableArray arrayWithObjects:[BuildingBonusRock3 class],nil] minTime:1.0f maxTime: 3.0f],
							   nil
							   ] retain];
			
			minSpawnY = 75;
			maxSpawnY = 215;
			break;
		case BONUS_GAME_WAREHOUSE:
			area = [[[BEUArea alloc] init] autorelease];
			
			[area addTile:[[[WarehouseBonusTile alloc] initTile] autorelease]];
			
			[[BEUEnvironment sharedEnvironment] addArea:area];
			
			characterSpawnInfos = [[NSMutableArray arrayWithObjects:
									[BonusSpawnInfo infoWithStartTime:0.0f spawnTypes:[NSMutableArray arrayWithObject:[SecurityGaurd1Running class]] minTime:2.5f maxTime:5.0f],
									[BonusSpawnInfo infoWithStartTime:15.0f spawnTypes:[NSMutableArray arrayWithObject:[SecurityGaurd1Running class]] minTime:1.5f maxTime:4.2f],
									[BonusSpawnInfo infoWithStartTime:35.0f spawnTypes:[NSMutableArray arrayWithObject:[SecurityGaurd1Running class]] minTime:1.2f maxTime:3.5f],
									[BonusSpawnInfo infoWithStartTime:60.0f spawnTypes:[NSMutableArray arrayWithObject:[SecurityGaurd1Running class]] minTime:1.0f maxTime:3.0f],
									
									nil
									] retain];
			rockSpawnInfos = [[NSMutableArray arrayWithObjects:
							   [BonusSpawnInfo infoWithStartTime:0.0f spawnTypes:[NSMutableArray arrayWithObjects:[HQPole class],nil] minTime:1.7f maxTime:3.0f],
							   [BonusSpawnInfo infoWithStartTime:15.0f spawnTypes:[NSMutableArray arrayWithObjects:[HQPole class],nil] minTime:1.2f maxTime:2.4f],
							   [BonusSpawnInfo infoWithStartTime:25.0f spawnTypes:[NSMutableArray arrayWithObjects:[HQPole class],nil] minTime:.5f maxTime:1.7f],
							   [BonusSpawnInfo infoWithStartTime:35.0f spawnTypes:[NSMutableArray arrayWithObjects:[HQPole class],nil] minTime:.3f maxTime:1.2f],
							   nil
							   ] retain];
			minSpawnY = 0;
			maxSpawnY = 240;
			break;
	}
	
	
	
	
	
	
	
	
	
	
	CCSprite *bonusLevel = [CCSprite spriteWithFile:@"BonusTitle-BonusLevel.png"];
	bonusLevel.opacity = 0;
	bonusLevel.scale = 3.0f;
	bonusLevel.position = ccp(480/2,320/2);
	[bonusLevel runAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration: 2.0f],
	  [CCEaseExponentialOut actionWithAction:
		  [CCSpawn actions:
		   [CCFadeIn actionWithDuration:0.2f],
		   [CCScaleTo actionWithDuration:0.4f scale:1.0f],
		   nil
		   ]
	   ],
	  [CCDelayTime actionWithDuration:.5f],
	  [CCEaseExponentialOut actionWithAction:
	   [CCSpawn actions:
		[CCFadeOut actionWithDuration:0.4f],
		[CCScaleTo actionWithDuration:0.4f scale:.3f],
		nil
		]
	   ],
	  [CCCallFuncND actionWithTarget:self selector:@selector(removeChild:cleanup:) data:(void*)YES],
	  nil
	  ]	 
	 ];
	
	CCSprite *ready = [CCSprite spriteWithFile:@"BonusTitle-Ready.png"];
	ready.opacity = 0;
	ready.scale = 3.0f;
	ready.position = ccp(480/2,320/2);
	[ready runAction:
	 [CCSequence actions:
	  
	  [CCDelayTime actionWithDuration: 2.9f],
	  [CCEaseExponentialOut actionWithAction:
	   [CCSpawn actions:
		[CCFadeIn actionWithDuration:0.2f],
		[CCScaleTo actionWithDuration:0.4f scale:1.0f],
		nil
		]
	   ],
	  [CCDelayTime actionWithDuration:.5f],
	  [CCEaseExponentialOut actionWithAction:
	   [CCSpawn actions:
		[CCFadeOut actionWithDuration:0.4f],
		[CCScaleTo actionWithDuration:0.4f scale:.3f],
		nil
		]
	   ],
	  [CCCallFuncND actionWithTarget:self selector:@selector(removeChild:cleanup:) data:(void*)YES],
	  nil
	  ]	 
	 ];
	
	CCSprite *go = [CCSprite spriteWithFile:@"BonusTitle-Go.png"];
	go.opacity = 0;
	go.scale = 3.0f;
	go.position = ccp(480/2,320/2);
	[go runAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration: 3.8f],
	  [CCEaseExponentialOut actionWithAction:
	   [CCSpawn actions:
		[CCFadeIn actionWithDuration:0.2f],
		[CCScaleTo actionWithDuration:0.4f scale:1.0f],
		nil
		]
	   ],
	  
	  [CCEaseExponentialIn actionWithAction:
	   [CCSpawn actions:
		[CCFadeOut actionWithDuration:0.4f],
		[CCScaleTo actionWithDuration:0.4f scale:.3f],
		nil
		]
	   ],
	  [CCCallFuncND actionWithTarget:self selector:@selector(removeChild:cleanup:) data:(void*)YES],
	  nil
	  ]	 
	 ];
	
	
	[self addChild:bonusLevel];
	[self addChild:ready];
	[self addChild:go];
	
	[[BEUGameManager sharedManager] setInitialMusic: [[NSArray arrayWithObjects:@"ninja2.mp3",@"arctic winds.mp3",@"straight ahead.mp3",nil] objectAtIndex:arc4random()%3] ];
	
	
}

-(void)addInputs
{
	BEUInputJoystick *joystick = [[[BEUInputJoystick alloc] initWithMinZone:0 maxZone:30 baseImage:@"Input-JoystickBase.png" stickImage:@"Input-JoystickStick.png"] autorelease];
	joystick.position = ccp(85,60);
	joystick.tag = 0;
	joystick.canSwipe = YES;
	[joystick setStickOpacity:125];
	[joystick setBaseOpacity:125];
	
	[[BEUInputLayer sharedInputLayer] addInput:joystick];
}

-(void)addAssets
{
	[super addAssets];
	
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"IcebergBonusTile"
						type:BEUAssetEnvironmentTile
					   class:[IcebergBonusTile class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"PenguinSlideCharacter"
						type:BEUAssetEnvironmentTile
					   class:[PenguinSlideCharacter class]
	  ]
	 ];
	
	[[BEUAssetController sharedController] addAsset:
	 [BEUAsset assetWithName:@"Eskimo2Running"
						type:BEUAssetEnvironmentTile
					   class:[Eskimo2Running class]
	  ]
	 ];
}

-(void)mainCharacterKilled:(BEUTrigger *)trigger
{
	[self runAction:
	 [CCSequence actions:
	  [CCCallFunc actionWithTarget:self selector:@selector(slowMotion)],
	  [CCDelayTime actionWithDuration:2.0f],
	  [CCCallFunc actionWithTarget:self selector:@selector(stopSlowMotion)],
	  [CCCallFunc actionWithTarget:self selector:@selector(showEndGameScreen)],
	  nil
	  ]	 
	 ];
}

-(void)showEndGameScreen
{
	[self unschedule:@selector(step:)];
	
	[[BEUTriggerController sharedController] removeAllListenersFor:self];
	
	[[BEUInputLayer sharedInputLayer] hide];
	[[BEUInputLayer sharedInputLayer] disable];
	[[GameHUD sharedGameHUD] hide];
	
	int bonusCoins = enemiesKilled*25;
		
	
	EndLevelBonus *endLevel = [EndLevelBonus endWithScore:enemiesKilled bonus:bonusCoins nextLevel:nextLevel];
	[self addChild:endLevel];
	
	[[GameData sharedGameData] setTotalCoins:[GameData sharedGameData].totalCoins+bonusCoins];
	[[GameData sharedGameData] setCoins:[GameData sharedGameData].coins+bonusCoins];
	[[GameData sharedGameData] setTotalGameTime:[GameData sharedGameData].totalGameTime+gameTime];
	[[GameData sharedGameData] setTotalStoryTime:[GameData sharedGameData].totalStoryTime+gameTime];
	
	//post total coins 
	[CrystalSession postLeaderboardResult:[GameData sharedGameData].totalCoins forLeaderboardId:@"988456026" lowestValFirst:NO];
	
	
	[[GameData sharedGameData] save];
}

-(void)step:(ccTime)delta
{
	[super step:delta];
	
	
	if(timeTillNextCharacterSpawn <= 0)
	{
		
		
		BonusSpawnInfo *spawnInfo;
		
		for ( BonusSpawnInfo *info in characterSpawnInfos )
		{
			if(gameTime >= info.startTime) spawnInfo = info;
			else break;
		}
		BOOL foundInPool = NO;
		BEUCharacter *newCharacter;
		Class spawnClass = [[spawnInfo spawnTypes] objectAtIndex:arc4random()%spawnInfo.spawnTypes.count];
		
		if([[BEUObjectController sharedController] doesObjectPoolContainType:spawnClass])
		{
			newCharacter = ((BEUCharacter *)[[BEUObjectController sharedController] getObjectFromPoolWithClass:spawnClass]);
			foundInPool = YES;
		} else {
			newCharacter = [[[spawnClass alloc] initAsync:self] autorelease];
		}
		
		newCharacter.enemy = YES;
		[newCharacter setVisible:NO];
		[newCharacter disable];
		[charatersSpawning addObject:newCharacter];
		timeTillNextCharacterSpawn = spawnInfo.minTimeBetweenSpawns + (spawnInfo.maxTimeBetweenSpawns-spawnInfo.minTimeBetweenSpawns)*CCRANDOM_0_1();
		
		if(foundInPool) [self creationComplete:newCharacter];
	} else {
		timeTillNextCharacterSpawn -= delta;
	}
	
	if(timeTillNextRockSpawn <= 0)
	{
	
		BonusSpawnInfo *spawnInfo;
		
		for ( BonusSpawnInfo *info in rockSpawnInfos )
		{
			if(gameTime >= info.startTime) spawnInfo = info;
			else break;
		}
		BOOL foundInPool = NO;
		BEUCharacter *newCharacter;
		Class spawnClass = [[spawnInfo spawnTypes] objectAtIndex:arc4random()%spawnInfo.spawnTypes.count];
		
		if([[BEUObjectController sharedController] doesObjectPoolContainType:spawnClass])
		{
			newCharacter = ((BEUCharacter *)[[BEUObjectController sharedController] getObjectFromPoolWithClass:spawnClass]);
			foundInPool = YES;
		} else {
			newCharacter = [[[spawnClass alloc] initAsync:self] autorelease];
		}
		
		newCharacter.enemy = YES;
		[newCharacter setVisible:NO];
		[newCharacter disable];
		[charatersSpawning addObject:newCharacter];
		timeTillNextRockSpawn = spawnInfo.minTimeBetweenSpawns + (spawnInfo.maxTimeBetweenSpawns-spawnInfo.minTimeBetweenSpawns)*CCRANDOM_0_1();
		
		if(foundInPool) [self creationComplete:newCharacter];
	} else {
		timeTillNextRockSpawn -= delta;
	}
	
}

-(void)creationComplete:(id)sender
{
	BEUCharacter *newCharacter = sender;
	
		
	newCharacter.visible = YES;
	[newCharacter enable];
	//[newCharacter enableAI];
	
	newCharacter.x = 530;
	newCharacter.z = minSpawnY + (  (maxSpawnY-[newCharacter moveArea].size.height) -minSpawnY)*CCRANDOM_0_1();
	
	newCharacter.position = ccp(newCharacter.x, newCharacter.z + newCharacter.y);
	
	[[BEUObjectController sharedController] addCharacter:newCharacter];
	[charatersSpawning removeObject:sender];
	
}

-(void)killHandler:(BEUTrigger *)trigger
{
	if( ((BEUCharacter *)trigger.sender).enemy )
	{
		enemiesKilled++;
		
		[[[GameHUD sharedGameHUD] killMeter] setKills:enemiesKilled];
		
	}
}

@end

@implementation BonusSpawnInfo

@synthesize startTime,spawnTypes,minTimeBetweenSpawns,maxTimeBetweenSpawns;

-(id)initWithStartTime:(float)startTime_ spawnTypes:(NSMutableArray *)spawnTypes_ minTime:(float)minTime_ maxTime:(float)maxTime_
{
	[self init];
	
	startTime = startTime_;
	spawnTypes = [spawnTypes_ retain];
	minTimeBetweenSpawns = minTime_;
	maxTimeBetweenSpawns = maxTime_;
	
	return self;
}

+(id)infoWithStartTime:(float)startTime_ spawnTypes:(NSMutableArray *)spawnTypes_ minTime:(float)minTime_ maxTime:(float)maxTime_
{
	return [[[self alloc] initWithStartTime:startTime_ spawnTypes:spawnTypes_ minTime:minTime_ maxTime:maxTime_] autorelease];
}

-(void)dealloc
{
	[spawnTypes release];
	[super dealloc];
}

@end

