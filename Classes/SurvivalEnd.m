//
//  SurvivalEnd.m
//  BEUEngine
//
//  Created by Chris Mele on 10/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "SurvivalEnd.h"
#import "PenguinGameController.h"
#import "CrystalSession.h"


@implementation SurvivalEnd

-(id)initWithScore:(int)score_
{
	[super initWithFile:@"SurvivalEnd-BG.png"];
	
	self.anchorPoint = CGPointZero;
	
	CCLabel *scoreText = [CCLabel labelWithString:[NSString stringWithFormat:@"%d Kills",score_] fontName:@"Marker Felt" fontSize:28];
	scoreText.anchorPoint = CGPointZero;
	scoreText.position = ccp(154,148);
	[scoreText setColor:ccc3(255, 197, 141)];
	
	
	CCMenuItemImage *mainMenuButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-MainMenuButton.png" selectedImage:@"EndLevel-MainMenuButton-On.png" target:self selector:@selector(mainMenuHandler:)];
	
	CCMenuItemImage *shopButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-ShopButton.png" selectedImage:@"EndLevel-ShopButton-On.png" target:self selector:@selector(shopHandler:)];
	
	CCMenuItemImage *retryButton = [CCMenuItemImage itemFromNormalImage:@"SurvivalEnd-RetryButton.png" selectedImage:@"SurvivalEnd-RetryButtonDown.png" target:self selector:@selector(retryHandler:)];
	
	
	CCMenu *menu = [[CCMenu menuWithItems:mainMenuButton,shopButton,retryButton,nil] retain];
	[menu alignItemsHorizontallyWithPadding:15];
	menu.position = ccp(241,107);
	
	
	CCMenuItemImage *leaderboardButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-LeaderboardsButton.png" selectedImage:@"EndLevel-LeaderboardsButton-On.png" target:self selector:@selector(leaderboards:)];
	leaderboardButton.anchorPoint = CGPointZero;
	leaderboardButton.position = ccp(273,143);
	
	CCMenu *leaderboards = [CCMenu menuWithItems:leaderboardButton,nil];
	leaderboards.position = CGPointZero;
	leaderboards.anchorPoint = CGPointZero;
	
	scoreText.opacity = 0;
	mainMenuButton.opacity = 0;
	shopButton.opacity = 0;
	retryButton.opacity = 0;	
	leaderboardButton.opacity = 0;
	self.opacity = 0;
	
	
	[self addChild:scoreText];
	[self addChild:menu];
	[self addChild:leaderboards];
	
	float fadeTime = 0.5f;
	
	[mainMenuButton runAction:[CCFadeIn actionWithDuration:fadeTime]];
	[shopButton runAction:[CCFadeIn actionWithDuration:fadeTime]];
	[retryButton runAction:[CCFadeIn actionWithDuration:fadeTime]];
	[scoreText runAction:[CCFadeIn actionWithDuration:fadeTime]];
	[leaderboardButton runAction:[CCFadeIn actionWithDuration:fadeTime]];
	[self runAction:[CCFadeIn actionWithDuration:fadeTime]];
	
	
	return self;
}

+(void)preload
{
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-LeaderboardsButton.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-LeaderboardsButton-On.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"SurvivalEnd-RetryButton.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"SurvivalEnd-RetryButtonDown.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-ShopButton.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-ShopButton-On.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-MainMenuButton.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"EndLevel-MainMenuButton-On.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"SurvivalEnd-BG.png"];
	
}

+(id)endWithScore:(int)score_
{
	return [[[self alloc] initWithScore:score_] autorelease];
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

-(void)retryHandler:(id)sender
{
	[[PenguinGameController sharedController] restartSurvivalGame];
}

-(void)newRecord
{
	CCSprite *record = [CCSprite spriteWithFile:@"SurvivalEnd-NewRecord.png"];
	record.anchorPoint = CGPointZero;
	record.position = ccp(28,165);
	[self addChild:record];
}

-(void)leaderboards:(id)sender
{
	[CrystalSession activateCrystalUIAtLeaderboards];
}

@end
