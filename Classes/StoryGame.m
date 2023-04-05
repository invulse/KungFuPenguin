//
//  StoryGame.m
//  BEUEngine
//
//  Created by Chris Mele on 9/21/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "StoryGame.h"
#import "BEUInputLayer.h"
#import "GameHUD.h"
#import "GameData.h"
#import "BEUObjectController.h"
#import "EndLevel.h"
#import "MessagePopup.h"
#import "CrystalSession.h"
#import "WeaponData.h"
#import "BEUCutScene.h"

@implementation StoryGame

@synthesize levelDict;

-(void)createGame
{
	[[GameData sharedGameData] setCurrentGameType:GAME_TYPE_STORY];
	
	[super createGame];
	
	[EndLevel preload];
	
	if([levelDict valueForKey:@"endCutscene"])
	{
		[NSClassFromString([levelDict valueForKey:@"endCutscene"]) preload];
	}
	
	if(loadFromSave)
	{
		[super startGame];
	} else {
		
		if([levelDict valueForKey:@"cutscene"])
		{
			[self startCutScene];
		}
		
		[self startTitles];
		
	}
	
}

-(void)startTitles
{
	titles = [[[StoryTitles alloc] initWithTitle:[levelDict valueForKey:@"levelTitle"] subTitle:[levelDict valueForKey:@"levelSubTitle"] target:self selector:@selector(titlesComplete)] autorelease];
	
	[self addChild:titles];
}

-(void)startCutScene
{
	cutScene = [NSClassFromString([levelDict valueForKey:@"cutscene"]) cutSceneWithTarget:self selector:@selector(completeCutScene)];
	
	[self addChild:cutScene];
	
}

-(void)completeCutScene
{
	[self removeChild:cutScene cleanup:YES];
	[super startGame];
}

-(void)endCutsceneComplete
{
	[[PenguinGameController sharedController] gotoMap];
}

-(id)initGameWithLevelInfo:(NSDictionary *)levelDict_
{
	levelDict = [levelDict_ retain];
	
	[self initGameWithLevel:[levelDict valueForKey:@"levelFile"]];
	
	return self;
	
}

-(id)initAsyncWithLevelInfo:(NSDictionary *)levelDict_ callbackTarget:(id)callbackTarget_
{
	levelDict = [levelDict_ retain];
	
	[self initAsyncWithLevel:[levelDict valueForKey:@"levelFile"] callbackTarget:callbackTarget_];
	
	return self;
}

-(id)initAsyncWithSaveData:(NSDictionary *)saveData_ callbackTarget:(id)callbackTarget_
{
	levelDict = [[NSMutableDictionary dictionaryWithDictionary:[saveData_ valueForKey:@"levelDict"]] retain];
	
	[super initAsyncWithSaveData:saveData_ callbackTarget:callbackTarget_];
	
	return self;
}

/*-(void)endGameHandler:(BEUTrigger *)trigger
{
	[super endGameHandler:trigger];
}*/

-(void)endGame
{
	[super endGame];
	
	[[BEUInputLayer sharedInputLayer] hide];
	[[BEUInputLayer sharedInputLayer] disable];
	[[GameHUD sharedGameHUD] hide];
	
	
	
	
	int collectedCoins = [[[GameHUD sharedGameHUD] coins]  coins] - gameStartCoins;
	
	int minTimeBonus = [[levelDict valueForKey:@"minTimeBonus"] intValue];
	int maxTimeBonus = [[levelDict valueForKey:@"maxTimeBonus"] intValue];
	float bestTime = [[levelDict valueForKey:@"bestTime"] floatValue];
	float worstTime = [[levelDict valueForKey:@"worstTime"] floatValue];
	
	int timeBonus = ((gameTime-worstTime)/(bestTime-worstTime))*(maxTimeBonus-minTimeBonus) + minTimeBonus;
	
	int minLifeBonus = [[levelDict valueForKey:@"minLifeBonus"] intValue];
	int maxLifeBonus = [[levelDict valueForKey:@"maxLifeBonus"] intValue];
	
	int lifeBonus = ([[BEUObjectController sharedController] playerCharacter].life/[[BEUObjectController sharedController] playerCharacter].totalLife)*(maxLifeBonus-minLifeBonus) + minLifeBonus;
	
	int totalCoins = timeBonus + lifeBonus + collectedCoins;
	
	
	if(![levelDict valueForKey:@"endCutscene"]){
		
		EndLevel *endLevel = [EndLevel endLevelWithTimeBonus:timeBonus lifeBonus:lifeBonus collected:collectedCoins leaderboard:[levelDict valueForKey:@"leaderboardID"]];
	
		[self addChild:endLevel z:999];
	}
	
	if([[GameData sharedGameData].storyLevelData valueForKey:[levelDict valueForKey:@"levelID"]])
	{
		//check if there is already a highscore since a score already exists
		NSMutableDictionary *levelData = [NSMutableDictionary dictionaryWithDictionary:[[GameData sharedGameData].storyLevelData valueForKey:[levelDict valueForKey:@"levelID"]]];
		
		NSNumber *currentTotalCoins = [levelData valueForKey:@"totalCoins"];
		
		if([currentTotalCoins intValue] < totalCoins)
		{
			[levelData setValue:[NSNumber numberWithInt:totalCoins] forKey:@"totalCoins"];
		}
		
		NSNumber *currentBestTime = [levelData valueForKey:@"bestTime"];
		
		if([currentBestTime floatValue] > gameTime)
		{
			[levelData setValue:[NSNumber numberWithFloat:gameTime] forKey:@"bestTime"];
		}		
		
		NSNumber *currentBestDifficuluty = [levelData valueForKey:@"bestDifficulty"];
		
		if([currentBestDifficuluty intValue] < [[GameData sharedGameData] currentDifficulty])
		{
			[levelData setValue:[NSNumber numberWithInt:[[GameData sharedGameData] currentDifficulty]] forKey:@"bestDifficulty"];
		}
		
		[[GameData sharedGameData].storyLevelData setValue:levelData forKey:[levelDict valueForKey:@"levelID"]];
	} else {
		//no high score exists for this level so make one
		NSMutableDictionary *levelData = [NSMutableDictionary dictionary];
		
		[levelData setValue:[NSNumber numberWithInt:totalCoins] forKey:@"totalCoins"];
		[levelData setValue:[NSNumber numberWithFloat:gameTime] forKey:@"bestTime"];
		[levelData setValue:[NSNumber numberWithInt:[[GameData sharedGameData] currentDifficulty]] forKey:@"bestDifficulty"];
		
		[[GameData sharedGameData].storyLevelData setValue:levelData forKey:[levelDict valueForKey:@"levelID"]];
		
		[self checkUnlocks];
		
	}
	
	
	if([levelDict valueForKey:@"leaderboardID"])
	{
		int chapterScore = 0;
		
		for ( NSString *levelID in [levelDict valueForKey:@"leaderboardLevels"] )
		{
			NSDictionary *levelData = [[GameData sharedGameData].storyLevelData valueForKey:levelID];
			
			NSNumber *levelScore = [levelData valueForKey:@"totalCoins"];
			chapterScore += [levelScore intValue]; 
		}
		
		[CrystalSession postLeaderboardResult:chapterScore forLeaderboardId:[levelDict valueForKey:@"leaderboardID"] lowestValFirst:NO];
		//[PenguinGameController setHighScore:chapterScore forLeaderboard:[levelDict valueForKey:@"leaderboardID"]];
	}
	
	[self checkAchievements];
	
	
	
	[[GameData sharedGameData] setTotalGameTime:[GameData sharedGameData].totalGameTime+gameTime];
	[[GameData sharedGameData] setTotalStoryTime:[GameData sharedGameData].totalStoryTime+gameTime];
	[[GameData sharedGameData] setCoins:[GameData sharedGameData].coins+totalCoins];
	[[GameData sharedGameData] setTotalCoins:[GameData sharedGameData].totalCoins+totalCoins];
	[[GameData sharedGameData] setSavedStoryGame:nil];
	
	
	//post total coins 
	[CrystalSession postLeaderboardResult:[GameData sharedGameData].totalCoins forLeaderboardId:@"988456026" lowestValFirst:NO];
	
	
	[[GameData sharedGameData] save];
	
	
	if([levelDict valueForKey:@"endCutscene"])
	{
		BEUCutScene *endCutscene = [NSClassFromString([levelDict valueForKey:@"endCutscene"]) cutSceneWithTarget:nil selector:nil];
		//[self addChild:endCutscene];
		//[endCutscene start];
		CCScene *scene = [CCScene node];
		[scene addChild:endCutscene];
		
		[[PenguinGameController sharedController] endGame];
		[[PenguinGameController sharedController] gotoScene:scene];
	}
}

-(void)startGame
{
	
	[titles transitionIn];
	
}

-(void)checkUnlocks
{
	NSString *levelID = [levelDict valueForKey:@"levelID"];
	
	if([levelID isEqualToString:@"Level1A"])
	{
		/*[[[GameData sharedGameData] unlockedMoves] addObject:@"groundPound"];
		[[[GameData sharedGameData] unlockedMoves] addObject:@"powerSlide"];*/
		/*MessagePopup *popup = [MessagePopup popupWithMessage:@"New moves are available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		[popup start];*/
		
	} else if([levelID isEqualToString:@"Level1B"])
	{
		//[[[GameData sharedGameData] unlockedMoves] addObject:@"combo4"];
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_BASEBALLBAT]];
		
		MessagePopup *popup = [MessagePopup popupWithMessage:@"A new weapon is available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"Level1C"])
	{
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_SWORDFISH]];
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_PIPEWRENCH]];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"New weapons are available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"Level2A"])
	{
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_MEATCLEAVER]];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"A new weapon is available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"Level2B"])
	{
		//[[[GameData sharedGameData] unlockedMoves] addObject:@"swingCombo1"];
		
		[[[GameData sharedGameData] survivalGameInfo] setValue:[NSNumber numberWithBool:YES] forKey:@"villageUnlocked"];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"Survival Mode has been unlocked!" time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"Level3A"])
	{
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_SLEDGEHAMMER]];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"A new weapon is available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"Level3B"])
	{
		// [[[GameData sharedGameData] unlockedMoves] addObject:@"swingCombo2"];
		[[[GameData sharedGameData] survivalGameInfo] setValue:[NSNumber numberWithBool:YES] forKey:@"caveUnlocked"];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"A new survival level has been unlocked!" time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"Level4A"])
	{
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_MACHETE]];
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_SHORTSWORD]];
		 MessagePopup *popup = [MessagePopup popupWithMessage:@"New weapons are available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		 [popup start];
	} else if([levelID isEqualToString:@"Level4B"])
	{
		
	} else if([levelID isEqualToString:@"Level5A"])
	{
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_KATANA]];
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_SCIMITAR]];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"A new weapon is available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"Level5B"])
	{
		//[[[GameData sharedGameData] unlockedMoves] addObject:@"swingCombo3"];
		/*MessagePopup *popup = [MessagePopup popupWithMessage:@"A new move is available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		[popup start];*/
		
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_BIGSWORD]];
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_AXE]];
		//[[[GameData sharedGameData] unlockedMoves] addObject:@"swingCombo4"];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"New weapons are available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"Level5C"])
	{
		[[[GameData sharedGameData] survivalGameInfo] setValue:[NSNumber numberWithBool:YES] forKey:@"dojoUnlocked"];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"A new survival level has been unlocked!" time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"Level6A"])
	{
	} else if([levelID isEqualToString:@"Level6B"])
	{
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_SABER]];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"A new weapon is available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"Level6C"])
	{
		[[[GameData sharedGameData] survivalGameInfo] setValue:[NSNumber numberWithBool:YES] forKey:@"hqUnlocked"];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"A new survival level has been unlocked!" time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	} else if([levelID isEqualToString:@"FinalBossLevel"])
	{
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_LASERSWORD]];
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_CHAINSAW]];
		[[[GameData sharedGameData] unlockedWeapons] addObject:[NSNumber numberWithInt:PENGUIN_WEAPON_DIVINEBLADE]];
		MessagePopup *popup = [MessagePopup popupWithMessage:@"New weapons are available in the shop." time:3.0f];
		[self addChild:popup z:1000];
		[popup start];
	}  
	
	
	
}

-(void)checkAchievements
{
	NSString *levelID = [levelDict valueForKey:@"levelID"];
	
	if([levelID isEqualToString:@"Level1A"])
	{
		[CrystalSession postAchievement:@"988348536" wasObtained:YES withDescription:@"Grasshoppah!" alwaysPopup:NO];
	}
	
	if([levelID isEqualToString:@"Level1C"])
	{
		[CrystalSession postAchievement:@"988332807" wasObtained:YES withDescription:@"Eskimo Kisses with a Fist!" alwaysPopup:NO];
	}
	
	
	if([levelID isEqualToString:@"Level3B"])
	{
		[CrystalSession postAchievement:@"988343722" wasObtained:YES withDescription:@"Village Pillager" alwaysPopup:NO];
	}
	
	if([levelID isEqualToString:@"Level5C"])
	{
		[CrystalSession postAchievement:@"988402228" wasObtained:YES withDescription:@"Ninja Exterminator!" alwaysPopup:NO];
	}
	
	if([levelID isEqualToString:@"FinalBossLevel"])
	{
		[CrystalSession postAchievement:@"988349599" wasObtained:YES withDescription:@"Our Savior!" alwaysPopup:NO];
		
		if([[GameData sharedGameData] currentDifficulty] == GAME_DIFFICULTY_HARD)
		{
			[CrystalSession postAchievement:@"988415185" wasObtained:YES withDescription:@"Masterful!" alwaysPopup:NO];
		} else if([[GameData sharedGameData] currentDifficulty] == GAME_DIFFICULTY_INSANE)
		{
			[CrystalSession postAchievement:@"988383468" wasObtained:YES withDescription:@"Good Luck With That..." alwaysPopup:NO];
		}
	}
	
	
	
}

-(void)titlesComplete
{
	[self removeChild:titles cleanup:YES];
	
	if(cutScene)
	{ 
		[cutScene start];
	} else {
		[super startGame];
	}
}

-(void)dealloc
{
	
	[levelDict release];
	[super dealloc];
}



-(NSDictionary *)save
{
	NSMutableDictionary *saveData_ = [NSMutableDictionary dictionaryWithDictionary:[super save]];
	[saveData_ setObject:levelDict forKey:@"levelDict"];
	[saveData_ setObject:[NSNumber numberWithInt:[[[GameHUD sharedGameHUD] coins]  coins] - gameStartCoins] forKey:@"collectedCoins"];
	[saveData_ setObject:[NSNumber numberWithFloat:gameTime] forKey:@"gameTime"];
	[[GameData sharedGameData] setSavedStoryGame:saveData_];
	[[GameData sharedGameData] save];
	return saveData_;
}

-(void)load:(NSDictionary *)options
{
	[super load:options];
	gameTime = [[options valueForKey:@"gameTime"] floatValue];
	[[[GameHUD sharedGameHUD] coins] setCoins:([[GameData sharedGameData] coins] + [[options valueForKey:@"collectedCoins"] intValue])];
}

@end

@implementation StoryTitles

-(id)initWithTitle:(NSString *)title_ subTitle:(NSString *)subTitle_ target:(id)target_ selector:(SEL)selector_
{
	[self initWithFile:@"BlackScreen.png"];
	self.anchorPoint = CGPointZero;
	
	target = target_;
	selector = selector_;
	
	
	title = [CCBitmapFontAtlas bitmapFontAtlasWithString:title_ fntFile:@"LevelIntro-TitleText.fnt"];
	title.anchorPoint = ccp(0,0);
	title.position = ccp(-title.contentSize.width-5,160);
	
	
	subTitle = [CCBitmapFontAtlas bitmapFontAtlasWithString:subTitle_ fntFile:@"LevelIntro-SubTitleText.fnt"];
	subTitle.anchorPoint = ccp(0,1);
	subTitle.position = ccp(480 + subTitle.contentSize.width+5,160);
	
	line = [CCSprite spriteWithFile:@"LevelIntro-Line.png"];
	line.anchorPoint = CGPointZero;
	line.position = ccp(0,321);
	
	[self addChild:line];
	[self addChild:title];
	[self addChild:subTitle];
	
	return self;
}

-(void)transitionIn
{
	
	[line runAction:
	 [CCSequence actions:
	  [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:0.5f position:ccp(0,160)]],
	  [CCDelayTime actionWithDuration:2.0f],
	  [CCEaseBackIn actionWithAction:[CCMoveTo actionWithDuration:0.6f position:ccp(0,-1)]],
	  nil
	  ]
	 ];
	
	[title runAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:.8f position:ccp(140,160)]],
	  [CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:1.2f position:ccp(481,160)]],
	  nil
	  ]
	 ];
	
	[subTitle runAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.5f],
	  [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:.8f position:ccp(480 - subTitle.contentSize.width - 60,160)]],
	  [CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:1.2f position:ccp(-subTitle.contentSize.width-5,160)]],
	  nil
	  ]
	 ];
	
	[self runAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:3.1f],
	  [CCFadeOut actionWithDuration:0.4f],
	  [CCCallFunc actionWithTarget:self selector:@selector(transitionOutComplete)],
	  nil
	  ]
	 ];
	
}

-(void)transitionOutComplete
{
	[target performSelector:selector];
}


@end

