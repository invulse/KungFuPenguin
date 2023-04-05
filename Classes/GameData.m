//
//  GameData.m
//  BEUEngine
//
//  Created by Chris Mele on 7/14/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "GameData.h"
#import "WeaponData.h"

@implementation GameData

@synthesize crystalSplashShown, controlsChosen, totalGameTime, totalStoryTime, totalEnemiesKilled, totalStoryEnemiesKilled, currentDifficulty,muteMusic,muteSFX,controlMethod,savedSurvivalGame,survivalGameInfo,savedStoryGame;

@synthesize coins, totalCoins, storyLevelData, purchasedMoves, purchasedWeapons, unlockedMoves, unlockedWeapons, equippedWeapons, pistolAmmo, maxPistolAmmo, shurikenAmmo, maxShurikenAmmo, completedInitialTraining, totalLife, powerPercent, movementSpeed, staminaReductionRate, minReplenishStaminaTime, maxReplenishStaminaTime, specialAdditionRate, jumpPercent, rampagePowerPercent, rampageModeTime;
@synthesize minLife, maxLife, minPower, maxPower, minMovementSpeed, maxMovementSpeed, minStaminaReductionRate, maxStaminaReductionRate, minSpecialAdditionRate, maxSpecialAdditionRate, minRampagePowerPercent, maxRampagePowerPercent, minRampageModeTime, maxRampageModetime;

@synthesize currentGameType;

static GameData *_sharedGameData = nil;

-(id)init
{
	self = [super init];
	
	
	
	minLife = 100.0f;
	maxLife = 300.0f;
	
	minPower = 1.0f;
	maxPower = 1.8f;
	
	minMovementSpeed = 180.0f;
	maxMovementSpeed = 230.0f;
	
	minStaminaReductionRate = 1.0f;
	maxStaminaReductionRate = .3f;
	
	minSpecialAdditionRate = 1.0f;
	maxSpecialAdditionRate = 2.0f;
	
	minRampagePowerPercent = 1.5f;
	maxRampagePowerPercent = 2.0f;
	
	minRampageModeTime = 10.0f;
	maxRampageModetime = 20.0f;
	
	maxPistolAmmo = 50;
	maxShurikenAmmo = 20;
	
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	
	if(![userDefaults boolForKey:@"hasRun"])
	{
		[self reset];
	}
	
	[self load];

	
	return self;
}

+(GameData *)sharedGameData
{
	if(!_sharedGameData)
	{
		_sharedGameData = [[self alloc] init];
	}
	
	return _sharedGameData;
}

-(void)reset
{
	[userDefaults setBool:YES forKey:@"hasRun"];
	[userDefaults setBool:NO forKey:@"crystalSplashShown"];
	[userDefaults setBool:NO forKey:@"controlsChosen"];	
	[userDefaults setInteger:0 forKey:@"coins"];
	[userDefaults setInteger:0 forKey:@"totalCoins"];
	[userDefaults setValue:[NSArray array] forKey:@"storyLevelData"];
	[userDefaults setValue:[NSArray array] forKey:@"purchasedMoves"];
	[userDefaults setValue:[NSArray arrayWithObjects:[NSNumber numberWithInt:PENGUIN_WEAPON_NONE],nil] forKey:@"purchasedWeapons"];
	[userDefaults setValue:[NSArray array] forKey:@"unlockedMoves"];
	[userDefaults setValue:[NSDictionary dictionary] forKey:@"unlockedWeapons"];
	
	[userDefaults setValue:
	 [NSMutableArray arrayWithObjects:
	  [NSNumber numberWithInt:PENGUIN_WEAPON_NONE],
	  [NSNumber numberWithInt:PENGUIN_WEAPON_EMPTY],
	  [NSNumber numberWithInt:PENGUIN_WEAPON_EMPTY],
	  nil
	  ] 
					forKey:@"equippedWeapons"];
	[userDefaults setInteger:20 forKey:@"pistolAmmo"];
	[userDefaults setInteger:0 forKey:@"shurkienAmmo"];
	[userDefaults setBool:NO forKey:@"completedInitialTraining"];
	[userDefaults setInteger:GAME_DIFFICULTY_NORMAL forKey:@"currentDifficulty"];
	[userDefaults setBool:NO forKey:@"muteMusic"];
	[userDefaults setBool:NO forKey:@"muteSFX"];
	[userDefaults setInteger:CONTROL_METHOD_GESTURES forKey:@"controlMethod"];
	[userDefaults setValue:nil forKey:@"savedSurvivalGame"];
	[userDefaults setValue:
	 [NSMutableDictionary dictionaryWithObjectsAndKeys:
	  [NSNumber numberWithBool:NO],@"villageUnlocked",
	  [NSNumber numberWithInt:0],@"villageHighScore",
	  [NSNumber numberWithBool:NO],@"caveUnlocked",
	  [NSNumber numberWithInt:0],@"caveHighScore",
	  [NSNumber numberWithBool:NO],@"dojoUnlocked",
	  [NSNumber numberWithInt:0],@"dojoHighScore",
	  [NSNumber numberWithBool:NO],@"hqUnlocked",
	  [NSNumber numberWithInt:0],@"hqHighScore",
	  nil] forKey:@"survivalGameInfo"];
	[userDefaults setValue:nil forKey:@"savedStoryGame"];
	
	[userDefaults setFloat:0 forKey:@"totalGameTime"];
	[userDefaults setFloat:0 forKey:@"totalStoryTime"];
	[userDefaults setInteger:0 forKey:@"totalEnemiesKilled"];
	[userDefaults setInteger:0 forKey:@"totalStoryEnemiesKilled"];
	
	[userDefaults setFloat:100.0f forKey:@"totalLife"];
	[userDefaults setFloat:minPower forKey:@"powerPercent"];
	[userDefaults setFloat:minMovementSpeed forKey:@"movementSpeed"];
	[userDefaults setFloat:minStaminaReductionRate forKey:@"staminaReductionRate"];
	[userDefaults setFloat:.6f forKey:@"minReplenishStaminaTime"];
	[userDefaults setFloat:1.6f forKey:@"maxReplenishStaminaTime"];
	[userDefaults setFloat:minSpecialAdditionRate forKey:@"specialAdditionRate"];
	[userDefaults setFloat:1.6f forKey:@"jumpPercent"];
	[userDefaults setFloat:minRampagePowerPercent	forKey:@"rampagePowerPercent"];
	[userDefaults setFloat:minRampageModeTime forKey:@"rampageModeTime"];
	[userDefaults synchronize];	
	
	[self load];
}

-(void)load
{
	crystalSplashShown = [userDefaults boolForKey:@"crystalSplashShown"];
	controlsChosen = [userDefaults boolForKey:@"controlsChosen"];
	
	coins = [userDefaults integerForKey:@"coins"];
	totalCoins = [userDefaults integerForKey:@"totalCoins"];
	
	storyLevelData = [[NSMutableDictionary dictionaryWithDictionary:[userDefaults dictionaryForKey:@"storyLevelData"]] retain];
	
	purchasedMoves = [[NSMutableArray arrayWithArray:[userDefaults arrayForKey:@"purchasedMoves"]] retain];
	purchasedWeapons = [[NSMutableArray arrayWithArray:[userDefaults arrayForKey:@"purchasedWeapons"]] retain];
	equippedWeapons = [[NSMutableArray arrayWithArray:[userDefaults arrayForKey:@"equippedWeapons"]] retain];
	unlockedMoves = [[NSMutableArray arrayWithArray:[userDefaults arrayForKey:@"unlockedMoves"]] retain];
	unlockedWeapons = [[NSMutableArray arrayWithArray:[userDefaults arrayForKey:@"unlockedWeapons"]] retain];
	
	
	pistolAmmo = [userDefaults integerForKey:@"pistolAmmo"];
	shurikenAmmo = [userDefaults integerForKey:@"bowAmmo"];
	
	completedInitialTraining = [userDefaults boolForKey:@"completedInitialTraining"];
	
	totalGameTime = [userDefaults floatForKey:@"totalGameTime"];
	totalStoryTime = [userDefaults floatForKey:@"totalStoryTime"];
	totalEnemiesKilled = [userDefaults integerForKey:@"totalEnemiesKilled"];
	totalStoryEnemiesKilled = [userDefaults integerForKey:@"totalStoryEnemiesKilled"];
	currentDifficulty = [userDefaults integerForKey:@"currentDifficulty"];
	muteMusic = [userDefaults boolForKey:@"muteMusic"];
	muteSFX = [userDefaults boolForKey:@"muteSFX"];
	controlMethod = [userDefaults integerForKey:@"controlMethod"];
	savedSurvivalGame = [userDefaults dictionaryForKey:@"savedSurvivalGame"];
	survivalGameInfo = [[NSMutableDictionary dictionaryWithDictionary:[userDefaults dictionaryForKey:@"survivalGameInfo"]] retain];
	
	savedStoryGame = [userDefaults dictionaryForKey:@"savedStoryGame"];
	
	totalLife = [userDefaults floatForKey:@"totalLife"];
	powerPercent = [userDefaults floatForKey:@"powerPercent"];
	movementSpeed = [userDefaults floatForKey:@"movementSpeed"];
	staminaReductionRate = [userDefaults floatForKey:@"staminaReductionRate"];
	minReplenishStaminaTime = [userDefaults floatForKey:@"minReplenishStaminaTime"];
	maxReplenishStaminaTime = [userDefaults floatForKey:@"maxReplenishStaminaTime"];
	specialAdditionRate = [userDefaults floatForKey:@"specialAdditionRate"];
	jumpPercent = [userDefaults floatForKey:@"jumpPercent"];
	rampagePowerPercent = [userDefaults floatForKey:@"rampagePowerPercent"];
	rampageModeTime = [userDefaults floatForKey:@"rampageModeTime"];
}

-(void)save
{
	[userDefaults setBool:crystalSplashShown forKey:@"crystalSplashShown"];
	[userDefaults setBool:controlsChosen forKey:@"controlsChosen"];
	[userDefaults setInteger:coins forKey:@"coins"];
	[userDefaults setInteger:totalCoins forKey:@"totalCoins"];
	[userDefaults setValue:storyLevelData forKey:@"storyLevelData"];
	[userDefaults setValue:purchasedMoves forKey:@"purchasedMoves"];
	[userDefaults setValue:purchasedWeapons forKey:@"purchasedWeapons"];
	[userDefaults setValue:equippedWeapons forKey:@"equippedWeapons"];
	[userDefaults setValue:unlockedMoves forKey:@"unlockedMoves"];
	[userDefaults setValue:unlockedWeapons forKey:@"unlockedWeapons"];
	[userDefaults setInteger:pistolAmmo forKey:@"pistolAmmo"];
	[userDefaults setInteger:shurikenAmmo forKey:@"bowAmmo"];
	[userDefaults setBool:completedInitialTraining forKey:@"completedInitialTraining"];
	[userDefaults setFloat:totalGameTime forKey:@"totalGameTime"];
	[userDefaults setFloat:totalStoryTime forKey:@"totalStoryTime"];
	[userDefaults setInteger:totalEnemiesKilled forKey:@"totalEnemiesKilled"];
	[userDefaults setInteger:totalStoryEnemiesKilled forKey:@"totalStoryEnemiesKilled"];
	[userDefaults setInteger:currentDifficulty forKey:@"currentDifficulty"];
	[userDefaults setBool:muteMusic forKey:@"muteMusic"];
	[userDefaults setBool:muteSFX forKey:@"muteSFX"];
	[userDefaults setInteger:controlMethod forKey:@"controlMethod"];
	[userDefaults setValue:savedSurvivalGame forKey:@"savedSurvivalGame"];
	[userDefaults setValue:savedStoryGame forKey:@"savedStoryGame"];
	[userDefaults setValue:survivalGameInfo forKey:@"survivalGameInfo"];
	[userDefaults setBool:YES forKey:@"hasRun"];
	[userDefaults setFloat:totalLife forKey:@"totalLife"];
	[userDefaults setFloat:powerPercent forKey:@"powerPercent"];
	[userDefaults setFloat:movementSpeed forKey:@"movementSpeed"];
	[userDefaults setFloat:staminaReductionRate forKey:@"staminaReductionRate"];
	[userDefaults setFloat:minReplenishStaminaTime forKey:@"minReplenishStaminaTime"];
	[userDefaults setFloat:maxReplenishStaminaTime forKey:@"maxReplenishStaminaTime"];
	[userDefaults setFloat:specialAdditionRate forKey:@"specialAdditionRate"];
	[userDefaults setFloat:jumpPercent forKey:@"jumpPercent"];
	[userDefaults setFloat:rampagePowerPercent	forKey:@"rampagePowerPercent"];
	[userDefaults setFloat:rampageModeTime forKey:@"rampageModeTime"];
	[userDefaults synchronize];	
}

-(BOOL)isMoveOwned:(NSString *)moveName
{
	for ( NSString *purchasedName in purchasedMoves )
	{
		if([purchasedName isEqualToString:moveName]) return YES;
	}
	
	return NO;
}


-(BOOL)isWeaponOwned:(int)weaponID
{
	for ( NSNumber *purchasedID in purchasedWeapons )
	{
		if([purchasedID intValue] == weaponID) return YES;
	}
	
	return NO;
}

-(BOOL)isMoveUnlocked:(NSString *)moveName
{
	for ( NSString *unlockedName in unlockedMoves )
	{
		if([unlockedName isEqualToString:moveName]) return YES;
	}
	
	return NO;
}

-(BOOL)isWeaponUnlocked:(int)weaponID
{
	for ( NSNumber *unlockedID in unlockedWeapons )
	{
		if([unlockedID intValue] == weaponID) return YES;
	}
	
	return NO;
}

@end
