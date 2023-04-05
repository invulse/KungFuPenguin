//
//  PenguinGameController.m
//  BEUEngine
//
//  Created by Chris on 3/29/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "PenguinGameController.h"
#import "PenguinGame.h"
#import "PenguinMainMenu.h"
#import "PenguinPauseMenu.h"
#import "DebugMenu.h"
#import "SandboxGame.h"
#import "Shop.h"
#import "TrainingGame.h"
#import "BEUAudioController.h"
#import "GameMap.h"
#import "LoadingScreen.h"
#import "GameData.h"
#import "StoryGame.h"
#import "SettingsMainMenu.h"
#import "TrainingLevelGame.h"
#import "SurvivalGame.h"
#import "SurvivalMenu.h"
#import "CrystalSession.h"
#import "BonusGame.h"
#import "FullGamePromo.h"
#import "CreditsMenu.h"
#import "SimpleAudioEngine.h"

@implementation PenguinGameController

@synthesize currentGame,levelToLoad;

static PenguinGameController *_sharedController;



-(id)init
{
	if( (self = [super init]) )
	{
		[self initSounds];
		
		loadingTransitionInComplete = NO;
		gameLoaded = NO;
		
	}
	
	return self;
}

+(PenguinGameController *)sharedController
{
	if(!_sharedController)
	{
		_sharedController = [[PenguinGameController alloc] init];
	}
	
	return _sharedController;
}

-(void)initSounds
{
	[[BEUAudioController sharedController] addSfxFile:@"Whoos_1.wav" toSfx:@"PunchSwing"];
	[[BEUAudioController sharedController] addSfxFile:@"Whoos_2.wav" toSfx:@"PunchSwing"];
	[[BEUAudioController sharedController] addSfxFile:@"Whoos_3.wav" toSfx:@"PunchSwing"];
	[[BEUAudioController sharedController] addSfxFile:@"Whoos_4.wav" toSfx:@"PunchSwing"];
	//[[BEUAudioController sharedController] addSfxFile:@"Whoos_5.wav" toSfx:@"PunchSwing"];
	
	[[BEUAudioController sharedController] addSfxFile:@"Whoosh_1.wav" toSfx:@"WhooshFast"];
	[[BEUAudioController sharedController] addSfxFile:@"Whoosh_2.wav" toSfx:@"WhooshFaster"];
	[[BEUAudioController sharedController] addSfxFile:@"Whoosh_3.wav" toSfx:@"WhooshFastest"];
	
	[[BEUAudioController sharedController] addSfxFile:@"Hit_1.wav" toSfx:@"BluntHit"];
	[[BEUAudioController sharedController] addSfxFile:@"Hit_2.wav" toSfx:@"BluntHit"];
	[[BEUAudioController sharedController] addSfxFile:@"Hit_3.wav" toSfx:@"BluntHit"];
	
	[[BEUAudioController sharedController] addSfxFile:@"Jump_1.wav" toSfx:@"GenericJump"];
	[[BEUAudioController sharedController] addSfxFile:@"Jump_2.wav" toSfx:@"GenericJump"];
	[[BEUAudioController sharedController] addSfxFile:@"Jump_3.wav" toSfx:@"GenericJump"];
	//[[BEUAudioController sharedController] addSfxFile:@"Jump_4.wav" toSfx:@"GenericJump"];
	
	[[BEUAudioController sharedController] addSfxFile:@"SwordSwing_1.wav" toSfx:@"SwordSwing"];
	[[BEUAudioController sharedController] addSfxFile:@"SwordSwing_2.wav" toSfx:@"SwordSwing"];
	[[BEUAudioController sharedController] addSfxFile:@"SwordSwing_3.wav" toSfx:@"SwordSwing"];
	//[[BEUAudioController sharedController] addSfxFile:@"SwordSwing_4.wav" toSfx:@"SwordSwing"];
	//[[BEUAudioController sharedController] addSfxFile:@"SwordSwing_5.wav" toSfx:@"SwordSwing"];
	
	[[BEUAudioController sharedController] addSfxFile:@"Sword_Shing_1.wav" toSfx:@"SwordShing"];
	[[BEUAudioController sharedController] addSfxFile:@"Sword_Shing_2.wav" toSfx:@"SwordShing"];
	[[BEUAudioController sharedController] addSfxFile:@"Sword_Shing_3.wav" toSfx:@"SwordShing"];
	
	[[BEUAudioController sharedController] addSfxFile:@"ButtonTap_2.wav" toSfx:@"MenuTap1"];
	[[BEUAudioController sharedController] addSfxFile:@"ButtonTap_1.wav" toSfx:@"MenuTap2"];
	
	[[BEUAudioController sharedController] addSfxFile:@"Coin_1.wav" toSfx:@"CoinPickUp"];
	[[BEUAudioController sharedController] addSfxFile:@"Coins_2.wav" toSfx:@"CoinPickUp"];
	
	[[BEUAudioController sharedController] addSfxFile:@"Health_Pack_2.wav" toSfx:@"HealthPackPickUp"];
	
	[[BEUAudioController sharedController] addSfxFile:@"SwordHit_1_Update.wav" toSfx:@"CutHit"];
	[[BEUAudioController sharedController] addSfxFile:@"SwordHit_1_Juicy.wav" toSfx:@"CutHit"];
	[[BEUAudioController sharedController] addSfxFile:@"Cut_1.wav" toSfx:@"CutHit"];
	[[BEUAudioController sharedController] addSfxFile:@"Cut_2.wav" toSfx:@"CutHit"];
	//[[BEUAudioController sharedController] addSfxFile:@"Cut_3.wav" toSfx:@"CutHit"];
	
	[[BEUAudioController sharedController] addSfxFile:@"BowShoot_1.wav" toSfx:@"BowShoot"];
	
	[[BEUAudioController sharedController] addSfxFile:@"Death_1.wav" toSfx:@"DeathHuman"];
	[[BEUAudioController sharedController] addSfxFile:@"Death_2.wav" toSfx:@"DeathHuman"];
	[[BEUAudioController sharedController] addSfxFile:@"Death_3.wav" toSfx:@"DeathHuman"];
	[[BEUAudioController sharedController] addSfxFile:@"Death_4.wav" toSfx:@"DeathHuman"];
	[[BEUAudioController sharedController] addSfxFile:@"Death_5.wav" toSfx:@"DeathHuman"];
	[[BEUAudioController sharedController] addSfxFile:@"Death_6.wav" toSfx:@"DeathHuman"];
	//[[BEUAudioController sharedController] addSfxFile:@"Death_7.wav" toSfx:@"DeathHuman"];
	//[[BEUAudioController sharedController] addSfxFile:@"Death_8.wav" toSfx:@"DeathHuman"];
	//[[BEUAudioController sharedController] addSfxFile:@"Death_9.wav" toSfx:@"DeathHuman"];
	
	[[BEUAudioController sharedController] addSfxFile:@"HitHeavy.wav" toSfx:@"HitHeavy"];
	
	[[BEUAudioController sharedController] addSfxFile:@"Explosion1.wav" toSfx:@"Explosion"];
	
	[[BEUAudioController sharedController] addSfxFile:@"GrenadeLaunch1.wav" toSfx:@"GrenadeLaunch"];
	
	[[BEUAudioController sharedController] addSfxFile:@"GunShot1.wav" toSfx:@"GunShot"];
	
	[[BEUAudioController sharedController] addSfxFile:@"HitPlastic1.wav" toSfx:@"HitPlastic"];
	
	[[BEUAudioController sharedController] addSfxFile:@"Purchase.wav" toSfx:@"Purchase"];
	
	[[BEUAudioController sharedController] addSfxFile:@"Laser.wav" toSfx:@"Laser"];
	
	[[BEUAudioController sharedController] addSfxFile:@"HitMetal.wav" toSfx:@"HitMetal"];
	
	[[BEUAudioController sharedController] addSfxFile:@"ChainsawSwing1.wav" toSfx:@"ChainsawSwing"];
	[[BEUAudioController sharedController] addSfxFile:@"ChainsawSwing2.wav" toSfx:@"ChainsawSwing"];
	
	[[BEUAudioController sharedController] addSfxFile:@"WoodBreak.wav" toSfx:@"WoodBreak"];
	
	[[BEUAudioController sharedController] initializeSounds];
}

-(PenguinMainMenu *)mainMenu
{
	return [[[PenguinMainMenu alloc] init] autorelease];
}

-(void)gotoMainMenu
{
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] replaceScene: 
	 [CCFadeTransition transitionWithDuration:1.0f scene:[self mainMenu] withColor: ccc3(0, 0, 0)]
	];
}

-(PenguinGame *)newGame
{
	return [[[PenguinGame alloc] init] autorelease];
}

-(void)gotoNewGame
{
	[[CCDirector sharedDirector] replaceScene: 
	 [CCFadeTransition transitionWithDuration:1.0f scene:[self newGame] withColor: ccc3(0, 0, 0)]
	 ];
	
}

-(void)gotoGameWithLevel:(NSString *)level
{
	/*currentGame = [[PenguinGame alloc] initGameWithLevel:level];
	[[CCDirector sharedDirector] replaceScene: 
	 [CCFadeTransition transitionWithDuration:1.0f scene:currentGame withColor: ccc3(0, 0, 0)]
	 ];*/
	
	[self gotoLoadingScreen];
	
	currentGame = [[PenguinGame alloc] initAsyncWithLevel:level callbackTarget:self];
}

-(void)gotoStoryGameWithLevel:(NSDictionary *)level
{
	[self gotoLoadingScreen];
	
	
	if([[level valueForKey:@"trainingLevel"] boolValue])
	{
		currentGame = [[TrainingLevelGame alloc] initAsyncWithLevelInfo:level callbackTarget:self];
	} else {
		currentGame = [[StoryGame alloc] initAsyncWithLevelInfo:level callbackTarget:self];
	}
}

-(void)gotoStoryGameWithSavedData:(NSDictionary *)savedData
{
	[self gotoLoadingScreen];
	
	currentGame = [[StoryGame alloc] initAsyncWithSaveData:savedData callbackTarget:self];
	
}

-(void)gotoSurvivalGameWithType:(int)gameType
{
	[self gotoLoadingScreen];
	
	currentGame = [[SurvivalGame alloc] initAsyncWithType:gameType callbackTarget:self];

}

-(void)gotoSurvivalGameWithSavedData:(NSDictionary *)savedData
{
	[self gotoLoadingScreen];
	
	currentGame = [[SurvivalGame alloc] initAsyncWithSaveData:savedData callbackTarget:self];
	
}

-(void)gotoBonusGameWithType:(int)gameType nextLevel:(NSString *)nextLevel
{
	[self gotoLoadingScreen];
	
	currentGame = [[BonusGame alloc] initAsyncWithType:gameType nextLevel:nextLevel callbackTarget:self];
}

-(void)restartGame
{
	self.levelToLoad = [currentGame levelFile];
	
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration: 1.0f scene:[[[LoadingScreen alloc] initWithTarget:self selector:@selector(loadingTransitionRestartGameComplete)] autorelease] withColor:ccc3(0,0,0)]
	 ];
}

-(void)restartStoryGame
{
	levelInfoToLoad = ((StoryGame *)currentGame).levelDict;
	
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration: 1.0f scene:[[[LoadingScreen alloc] initWithTarget:self selector:@selector(loadingTransitionRestartStoryGameComplete)] autorelease] withColor:ccc3(0,0,0)]
	 ];
}

-(void)restartSurvivalGame
{
	survivalTypeToLoad = ((SurvivalGame *)currentGame).gameType;
	
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration: 1.0f scene:[[[LoadingScreen alloc] initWithTarget:self selector:@selector(loadingTransitionRestartSurvivalGameComplete)] autorelease] withColor:ccc3(0,0,0)]
	 ];
	
}



-(void)gotoSandbox
{
	[self gotoLoadingScreen];
	
	currentGame = [[SandboxGame alloc] initAsync:self];
	
}

-(void)gotoTraining
{
	currentGame = [[TrainingGame alloc] init];
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:1.0f scene:currentGame withColor:ccc3(0, 0, 0)]
	 ];
}

-(void)gotoShop
{
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:1.0f scene:[[[Shop alloc] init] autorelease] withColor:ccc3(0, 0, 0)]
	 ];
}

-(void)gotoMap
{
	
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:1.0f scene:[GameMap map] withColor:ccc3(0, 0, 0)]
	 ];

}

-(void)gotoDebugMenu
{
	DebugMenu *debugMenu = [[[DebugMenu alloc] init] autorelease];
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:1.0f scene:debugMenu withColor:ccc3(0,0,0)]
	 ];
}

-(void)pauseGame
{
	
	[currentGame pauseGame];
	
}
		  
-(void)resumeGame
{
	
	[currentGame resumeGame];
	//[[CCDirector sharedDirector] popScene];
	//[[CCDirector sharedDirector] resume];
}

-(void)quitGame
{
	[self endGame];
}

-(void)endGame
{	
	[currentGame killGame];
	[currentGame release];
	//[self gotoMainMenu];
}

-(void)gotoSettingsMenu
{
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:1.0f scene:[[[SettingsMainMenu alloc] init] autorelease] withColor:ccc3(0,0,0)]
	 ];
}

-(void)gotoSurvivalMenu
{
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:1.0f scene:[[[SurvivalMenu alloc] init] autorelease] withColor:ccc3(0,0,0)]
	 ];
}

-(void)gotoCredits
{
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:1.0f scene:[[[CreditsMenu alloc] init] autorelease] withColor:ccc3(0,0,0)]
	 ];
}

-(void)creationComplete:(id)game
{
	//currentGame = [game retain];
	
	//NSLog(@"GAME CREATION COMPLETE");
	gameLoaded = YES;	
	
	[self transitionFromLoadingScreenToGame];
}

-(void)gotoLoadingScreen
{
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration: 1.0f scene:[[[LoadingScreen alloc] initWithTarget:self selector:@selector(loadingTransitionComplete)] autorelease] withColor:ccc3(0,0,0)]
	 ];
}

-(void)loadingTransitionComplete
{
	//NSLog(@"LOADING TRANSITION COMPLETE");
	loadingTransitionInComplete = YES;
	
	[self transitionFromLoadingScreenToGame];
}

-(void)transitionFromLoadingScreenToGame
{
	if(loadingTransitionInComplete && gameLoaded)
	{
		[[CCDirector sharedDirector] replaceScene:
		 [CCFadeTransition transitionWithDuration:1.0f scene:currentGame withColor:ccc3(0,0,0)]
		 ];
		
		loadingTransitionInComplete = NO;
		gameLoaded = NO;
	}
}

-(void)loadingTransitionRestartGameComplete
{
	loadingTransitionInComplete = YES;
	[currentGame killGame];
	[currentGame release];
	
	currentGame = [[PenguinGame alloc] initAsyncWithLevel:levelToLoad callbackTarget:self];
}


-(void)loadingTransitionRestartStoryGameComplete
{
	loadingTransitionInComplete = YES;
	[currentGame killGame];
	[currentGame release];
	
	if([[GameData sharedGameData] savedStoryGame])
	{
		currentGame = [[StoryGame alloc] initAsyncWithSaveData:[[GameData sharedGameData] savedStoryGame] callbackTarget:self];
	} else {
		currentGame = [[StoryGame alloc] initAsyncWithLevelInfo:levelInfoToLoad callbackTarget:self];
	}
}

-(void)loadingTransitionRestartSurvivalGameComplete
{
	loadingTransitionInComplete = YES;
	[currentGame killGame];
	[currentGame release];
	
	currentGame = [[SurvivalGame alloc] initAsyncWithType:survivalTypeToLoad callbackTarget:self];
}

-(void)gotoScene:(CCScene *)scene
{
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:1.0f scene:scene withColor:ccc3(0,0,0)]
	 ];
}

-(void)gotoFullGamePromo
{
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:1.0f scene:[[[FullGamePromo alloc] init] autorelease] withColor:ccc3(0,0,0)]
	 ];	
}

-(void)dashboardWillAppear
{
	
}

-(void)dashboardDidAppear
{
	[[CCDirector sharedDirector] pause];
	[[CCDirector sharedDirector] stopAnimation];
}

-(void)dashboardWillDisappear
{
	
}

-(void)dashboardDidDisappear
{
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
}

+(void)updateAchievement:(NSString *)achievementId andPercentComplete:(float)percentComplete andShowNotification:(BOOL)show
{
		
}

+(void)setHighScore:(int64_t)score forLeaderboard:(NSString *)leaderboardID
{
	
}

+(void)showLeaderboard:(NSString *)leaderboardID
{
	
}

+(void)showDashboard
{
	[CrystalSession activateCrystalUI];
	
	
	[[SimpleAudioEngine sharedEngine] setMuted:YES];
}

+(void)dashboardClosed
{
	[[SimpleAudioEngine sharedEngine] setMuted:NO];
}

-(void)dealloc
{
	/*[currentGame release];
	[mainMenu release];
	[pauseMenu release];*/
	[levelToLoad release];
	[super dealloc];
}

@end
