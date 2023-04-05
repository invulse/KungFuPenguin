//
//  DebugMenu.m
//  BEUEngine
//
//  Created by Chris Mele on 6/3/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "DebugMenu.h"
#import "PenguinGameController.h"
#import "TestInstructions.h"
#import "GameData.h"
#import "DebugLevelData.h"
#import "SurvivalGame.h"
#import "BonusGame.h"
#import "FinalBossEndCutScene.h"

@implementation DebugMenu

-(id)init
{
	if( (self = [super init]) )
	{
		CCLabel *menuLabel = [CCLabel labelWithString:@"Level Select" fontName:@"Arial" fontSize:20];
		menuLabel.anchorPoint = ccp(0.0f,0.5f);
		menuLabel.position = ccp(30, [[CCDirector sharedDirector] winSize].height - 15);
		
		levelSelectMenu = [CCMenu menuWithItems:
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"Sandbox" fontName:@"Arial" fontSize:16] target:self selector:@selector(sandbox:)],
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"Game Map" fontName:@"Arial" fontSize:16] target:self selector:@selector(gameMap:)],
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"Shop" fontName:@"Arial" fontSize:16] target:self selector:@selector(shop:)],
						   
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"Bonus Game - Iceberg" fontName:@"Arial" fontSize:16] target:self selector:@selector(icebergBonus:)],
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"Bonus Game - Building" fontName:@"Arial" fontSize:16] target:self selector:@selector(buildingBonus:)],
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"Bonus Game - Warehouse" fontName:@"Arial" fontSize:16] target:self selector:@selector(warehouseBonus:)],
						   
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"CutScene" fontName:@"Arial" fontSize:16] target:self selector:@selector(cutScene:)],
						   
						   
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"Add 1000 Coins" fontName:@"Arial" fontSize:16] target:self	selector:@selector(addCoins:)],
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"Reset Game Data" fontName:@"Arial" fontSize:16] target:self selector:@selector(resetGameData:)],
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"Unlock All" fontName:@"Arial" fontSize:16] target:self selector:@selector(unlockAll:)],
						   [CCMenuItemLabel itemWithLabel:[CCLabel labelWithString:@"View Game Data" fontName:@"Arial" fontSize:16] target:self selector:@selector(viewGameData:)],
						   nil
						   ];
		[levelSelectMenu alignItemsVerticallyWithPadding:2.0f];
		levelSelectMenu.anchorPoint = ccp(0.5f,0.5f);
		levelSelectMenu.position = ccp([[CCDirector sharedDirector] winSize].width/2,[[CCDirector sharedDirector] winSize].height/2);
		
		
		[self addChild:menuLabel];
		[self addChild:levelSelectMenu];
	}
	
	return self;
}

-(void)gameMap:(id)sender
{
	[[PenguinGameController sharedController] gotoMap];
}


-(void)sandbox:(id)sender
{
	[[PenguinGameController sharedController] gotoSandbox];
}

-(void)shop:(id)sender
{
	[[PenguinGameController sharedController] gotoShop];
}

-(void)training:(id)sender
{
	[[PenguinGameController sharedController] gotoTraining];
}

-(void)survivalVillage:(id)sender
{
	[[PenguinGameController sharedController] gotoSurvivalGameWithType:SURVIVAL_GAME_VILLAGE];
}

-(void)survivalCave:(id)sender
{
	[[PenguinGameController sharedController] gotoSurvivalGameWithType:SURVIVAL_GAME_CAVE];
}

-(void)survivalDojo:(id)sender
{
	[[PenguinGameController sharedController] gotoSurvivalGameWithType:SURVIVAL_GAME_DOJO];
}

-(void)survivalHQ:(id)sender
{
	[[PenguinGameController sharedController] gotoSurvivalGameWithType:SURVIVAL_GAME_HQ];
}

-(void)icebergBonus:(id)sender
{
	[[PenguinGameController sharedController] gotoBonusGameWithType:BONUS_GAME_ICEBERG nextLevel:@"Level1C"];
}

-(void)buildingBonus:(id)sender
{
	[[PenguinGameController sharedController] gotoBonusGameWithType:BONUS_GAME_BUILDING nextLevel:@"Level1C"];
}

-(void)warehouseBonus:(id)sender
{
	[[PenguinGameController sharedController] gotoBonusGameWithType:BONUS_GAME_WAREHOUSE nextLevel:@"Level1C"];
}

-(void)instructions:(id)sender
{
	[self addChild:[[[TestInstructions alloc] init] autorelease]];
}

-(void)addCoins:(id)sender
{
	[[GameData sharedGameData] setCoins:[GameData sharedGameData].coins + 1000];
	[[GameData sharedGameData] save];
}

-(void)resetGameData:(id)sender
{
	[[GameData sharedGameData] reset];
}

-(void)unlockAll:(id)sender
{
	NSDictionary *levelsDict = [NSDictionary dictionaryWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"Levels.plist"]];
	
	NSArray *levelsArray = [levelsDict allKeys];
	
	
	for ( NSString *key in levelsArray )
	{
		NSDictionary *levelDict = [levelsDict valueForKey:key];
		
		[[[GameData sharedGameData] storyLevelData] setValue:[NSMutableDictionary dictionary] forKey:[levelDict valueForKey:@"levelID"]];
	}
	
	
	
	NSDictionary *weaponsArray = [NSArray arrayWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"Weapons.plist"]];
	
	
	
	for ( NSDictionary *weaponDict in weaponsArray )
	{
		
		if([weaponDict valueForKey:@"weaponID"]) [[[GameData sharedGameData] unlockedWeapons] addObject:[weaponDict valueForKey:@"weaponID"]];
	}
	
	
	NSMutableDictionary *survivalInfo = [[GameData sharedGameData] survivalGameInfo];
	[survivalInfo setValue:[NSNumber numberWithBool:YES] forKey:@"villageUnlocked"];
	[survivalInfo setValue:[NSNumber numberWithBool:YES] forKey:@"caveUnlocked"];
	[survivalInfo setValue:[NSNumber numberWithBool:YES] forKey:@"dojoUnlocked"];
	[survivalInfo setValue:[NSNumber numberWithBool:YES] forKey:@"hqUnlocked"];
	
	
	[[GameData sharedGameData] save];
	
}

-(void)loadSavedStory:(id)sender
{
	[[PenguinGameController sharedController] gotoStoryGameWithSavedData:[[GameData sharedGameData] savedStoryGame]];
}

-(void)cutScene:(id)sender
{
	FinalBossEndCutScene *cutscene = [[[FinalBossEndCutScene alloc] initWithTarget:nil selector:nil] autorelease];
	[[PenguinGameController sharedController] gotoScene:cutscene];
	
}

-(void)viewGameData:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:
	 [CCFadeTransition transitionWithDuration:1.0f scene:[[[DebugLevelData alloc] init] autorelease] withColor:ccc3(0,0,0)]
	 ];
}

@end
