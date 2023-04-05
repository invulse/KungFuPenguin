//
//  EndLevel.m
//  BEUEngine
//
//  Created by Chris Mele on 6/1/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "EndLevel.h"
#import "PenguinGameController.h"
#import "Animator.h"
#import "GameData.h"
#import "StoryGame.h"
#import "BEUGameManager.h"
#import "CrystalSession.h"
#import "BonusGame.h"

@implementation EndLevel

+(id)endLevelWithTimeBonus:(int)timeBonus_ lifeBonus:(int)lifeBonus_ collected:(int)collected_ leaderboard:(NSString *)leaderboard_
{
	return [[[self alloc] initWithTimeBonus:timeBonus_ lifeBonus:lifeBonus_ collected:collected_ leaderboard:leaderboard_] autorelease];
}

-(id)initWithTimeBonus:(int)timeBonus_ lifeBonus:(int)lifeBonus_ collected:(int)collected_ leaderboard:(NSString *)leaderboard_
{
	self = [super initWithFile:@"EndLevel-BG.png"];
	
	self.anchorPoint = CGPointZero;
	
	collected = collected_;
	timeBonus = timeBonus_;
	lifeBonus = lifeBonus_;
	leaderboardID = leaderboard_;
	
	collectedCoins = [[HUDCoins alloc] initWithCoins:collected];
	collectedCoins.position = ccp(190,190);
	[self addChild:collectedCoins];
	
	timeBonusCoins = [[HUDCoins alloc] initWithCoins:timeBonus];
	timeBonusCoins.position = ccp(190,148);
	[self addChild:timeBonusCoins];
	
	lifeBonusCoins = [[HUDCoins alloc] initWithCoins:lifeBonus];
	lifeBonusCoins.position = ccp(190,106);
	[self addChild:lifeBonusCoins];
	
	
	
	totalBonusCoins = [[HUDCoins alloc] initWithCoins:timeBonus+lifeBonus+collected];
	totalBonusCoins.position = ccp(306,164);
	[self addChild:totalBonusCoins];
	
	if(leaderboardID)
	{
		CCMenuItemImage *leaderboardsButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-LeaderboardsButton.png" selectedImage:@"EndLevel-LeaderboardsButton-On.png" target:self selector:@selector(leaderboards:)];
		leaderboardsButton.anchorPoint = CGPointZero;
		CCMenu *leaderboardsMenu = [CCMenu menuWithItems:leaderboardsButton,nil];
		[self addChild:leaderboardsMenu];
		leaderboardsMenu.position = ccp(263,109);
		leaderboardsMenu.opacity = 0;
		[leaderboardsMenu runAction:[CCFadeIn actionWithDuration:0.5f]];
		
	}
	
	
	StoryGame *game = ((StoryGame *)[[BEUGameManager sharedManager] game]);
	
	
	CCMenuItemImage *mainMenuButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-MainMenuButton.png" selectedImage:@"EndLevel-MainMenuButton-On.png" target:self selector:@selector(mainMenuHandler:)];
	
	CCMenuItemImage *shopButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-ShopButton.png" selectedImage:@"EndLevel-ShopButton-On.png" target:self selector:@selector(shopHandler:)];
	
	CCMenuItemImage *continueButton;
	
#if LITE==1
	continueButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-ContinueButton.png" selectedImage:@"EndLevel-ContinueButton-On.png" target:self selector:@selector(continueHandler:)];
		
	if([[[game levelDict] valueForKey:@"levelID"] isEqualToString:@"Level1B"])
	{
		mainMenuButton.visible = NO;
		shopButton.visible = NO;
	}
	
#else 
	
	if([[[game levelDict] valueForKey:@"levelID"] isEqualToString:@"Level1B"] ||
	   [[[game levelDict] valueForKey:@"levelID"] isEqualToString:@"Level4B"] ||
	   [[[game levelDict] valueForKey:@"levelID"] isEqualToString:@"Level6A"] 
	   )
	{
		mainMenuButton.visible = NO;
		shopButton.visible = NO;
		continueButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-BonusButton.png" selectedImage:@"EndLevel-BonusButton-On.png" target:self selector:@selector(continueHandler:)];
	} else {
		continueButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-ContinueButton.png" selectedImage:@"EndLevel-ContinueButton-On.png" target:self selector:@selector(continueHandler:)];		
	}
	
#endif
	
	menu = [[CCMenu menuWithItems:mainMenuButton,shopButton,continueButton,nil] retain];
	[menu alignItemsHorizontallyWithPadding:15];
	menu.position = ccp(241,64);
	
	[self addChild:menu];
	
	timeBonusCoins.opacity = 0;
	lifeBonusCoins.opacity = 0;
	totalBonusCoins.opacity = 0;
	mainMenuButton.opacity = 0;
	shopButton.opacity = 0;
	continueButton.opacity = 0;	
	self.opacity = 0;
	
	[collectedCoins runAction:[CCFadeIn actionWithDuration:0.5f]];
	[timeBonusCoins runAction:[CCFadeIn actionWithDuration:0.5f]];
	[lifeBonusCoins runAction:[CCFadeIn actionWithDuration:0.5f]];
	[totalBonusCoins runAction:[CCFadeIn actionWithDuration:0.5f]];
	[mainMenuButton runAction:[CCFadeIn actionWithDuration:0.5f]];
	[shopButton runAction:[CCFadeIn actionWithDuration:0.5f]];
	[continueButton runAction:[CCFadeIn actionWithDuration:0.5f]];
	[self runAction:[CCFadeIn actionWithDuration:0.5f]];
	
	return self;
	
}

+(void)preload
{
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-LeaderboardsButton.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-LeaderboardsButton-On.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-ContinueButton.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-ContinueButton-On.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-ShopButton.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-ShopButton-On.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-MainMenuButton.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-MainMenuButton-On.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-BG.png"];
}

-(void)mainMenuHandler:(id)sender
{
	[[PenguinGameController sharedController] endGame];
	[[PenguinGameController sharedController] gotoMainMenu];
}

-(void)shopHandler:(id)sender
{
	[[PenguinGameController sharedController] endGame];
	[[PenguinGameController sharedController] gotoShop];
}

-(void)continueHandler:(id)sender
{
	
	NSArray *levelIDs = [NSArray arrayWithObjects:@"Level1A",@"Level1B",@"Level1C",@"Level2A",@"Level2B",@"Level3A",@"Level3B",@"Level4A",@"Level4B",@"Level5A",@"Level5B",@"Level5C",@"Level6A",@"Level6B",@"Level6C",@"FinalBossLevel",nil];
	
	int levelIndex;
	int count = 0;
	StoryGame *game = ((StoryGame *)[[BEUGameManager sharedManager] game]);
	
#if LITE==1
	
	if([[[game levelDict] valueForKey:@"levelID"] isEqualToString:@"Level1B"])
	{
		
		[[PenguinGameController sharedController] endGame];
		[[PenguinGameController sharedController] gotoFullGamePromo];
		return;
	}
#endif
	
	
	if([[[game levelDict] valueForKey:@"levelID"] isEqualToString:@"Level1B"])
	{
		
		[[PenguinGameController sharedController] endGame];
		[[PenguinGameController sharedController] gotoBonusGameWithType:BONUS_GAME_ICEBERG nextLevel:@"Level1C"];
		return;
	} else if([[[game levelDict] valueForKey:@"levelID"] isEqualToString:@"Level4B"])
	{
		
		[[PenguinGameController sharedController] endGame];
		[[PenguinGameController sharedController] gotoBonusGameWithType:BONUS_GAME_BUILDING nextLevel:@"Level5A"];
		return;
	} else if([[[game levelDict] valueForKey:@"levelID"] isEqualToString:@"Level6A"])
	{
		
		[[PenguinGameController sharedController] endGame];
		[[PenguinGameController sharedController] gotoBonusGameWithType:BONUS_GAME_WAREHOUSE nextLevel:@"Level6B"];
		return;
	}
	
	
	//NSLog(@"CURRENT LEVEL DICT: %@",[game levelDict]);
	
	
	for ( NSString *levelID in levelIDs )
	{
		
		
		if([levelID isEqualToString:[[game levelDict] valueForKey:@"levelID"] ])
		{
			levelIndex = count;
			break;
		}
		count++;
	}
	
	//check if there is a next level id, if there is lets go to that level
	if(levelIDs.count > (levelIndex+1))
	{
		NSString *nextLevelID = [levelIDs objectAtIndex:(levelIndex+1)];
		NSDictionary *nextLevelDict = [[NSDictionary dictionaryWithContentsOfFile:[CCFileUtils fullPathFromRelativePath:@"Levels.plist"]] valueForKey:nextLevelID];
		[[PenguinGameController sharedController] endGame];
		[[PenguinGameController sharedController] gotoStoryGameWithLevel:nextLevelDict];
	} else {	
		[[PenguinGameController sharedController] endGame];		
		[[PenguinGameController sharedController] gotoMap];
	}
}

-(void)leaderboards:(id)sender
{
	//[PenguinGameController showLeaderboard:leaderboardID];
	[CrystalSession activateCrystalUIAtLeaderboards];
}
									  
-(void)dealloc
{
	[timeBonusCoins release];
	[lifeBonusCoins release];
	[collectedCoins release];
	[totalBonusCoins release];
	[menu release];
	[super dealloc];
}



@end
