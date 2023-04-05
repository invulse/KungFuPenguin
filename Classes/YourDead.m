//
//  YourDead.m
//  BEUEngine
//
//  Created by Chris Mele on 9/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "YourDead.h"
#import "PenguinGameController.h"
#import "BEUGameManager.h"
#import "PenguinGame.h"

@implementation YourDead

-(id)initYourDead
{
	self = [super initWithFile:@"YourDead-BG.png"];
	self.anchorPoint = CGPointZero;
	
	CCMenuItemImage *mainMenuButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-MainMenuButton.png" selectedImage:@"EndLevel-MainMenuButton-On.png" target:self selector:@selector(mainMenuHandler:)];
	
	CCMenuItemImage *shopButton = [CCMenuItemImage itemFromNormalImage:@"EndLevel-ShopButton.png" selectedImage:@"EndLevel-ShopButton-On.png" target:self selector:@selector(shopHandler:)];
	
	CCMenuItemImage *retryButton = [CCMenuItemImage itemFromNormalImage:@"YourDead-RetryButton.png" selectedImage:@"YourDead-RetryButton-On.png" target:self selector:@selector(retryHandler:)];
	
	
	menu = [CCMenu menuWithItems:mainMenuButton,shopButton,retryButton,nil];
	[menu alignItemsHorizontallyWithPadding:15];
	menu.position = ccp(240,127);
	[self addChild:menu];
	
	
	mainMenuButton.opacity = 0;
	shopButton.opacity = 0;
	retryButton.opacity = 0;
	self.opacity = 0;
	
	[mainMenuButton runAction:[CCFadeIn actionWithDuration:0.5f]];
	[shopButton runAction:[CCFadeIn actionWithDuration:0.5f]];
	[retryButton runAction:[CCFadeIn actionWithDuration:0.5f]];
	[self runAction:[CCFadeIn actionWithDuration:0.5f]];
	
	return self;
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
	
	[[PenguinGameController sharedController] restartStoryGame];
	//NSString *file = [currentGame.levelFile copy];
	
	//[[PenguinGameController sharedController] endGame];
	
	//[[PenguinGameController sharedController] gotoGameWithLevel:file];
}

@end
