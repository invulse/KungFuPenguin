//
//  CreditsMenu.m
//  BEUEngine
//
//  Created by Chris Mele on 11/19/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "CreditsMenu.h"
#import "PenguinGameController.h"

@implementation CreditsMenu

-(id)init
{
	[super init];
	
	CCSprite *bg = [CCSprite spriteWithFile:@"SettingsMenu-BG.png"];
	bg.anchorPoint = CGPointZero;
	bg.position = CGPointZero;
	
	CCSprite *title = [CCSprite spriteWithFile:@"CreditsTitle.png"];
	title.anchorPoint = ccp(.5f,0);
	title.position = ccp(bg.contentSize.width/2,283);
	
	CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalImage:@"Shop-BackButton.png" selectedImage:@"Shop-BackButtonDown.png" target:self selector:@selector(back:)];
	
	CCMenu *backMenu = [CCMenu menuWithItems:backButton,nil];
	backMenu.position = ccp(55,298);
	
	CCSprite *credits = [CCSprite spriteWithFile:@"Credits.png"];
	credits.position = ccp(73,19);
	credits.anchorPoint = CGPointZero;
	
	[self addChild:bg];
	[self addChild:title];
	[self addChild:backMenu];
	[self addChild:credits];
	
	return self;
}

-(void)back:(id)sender
{
	
	[[PenguinGameController sharedController] gotoMainMenu];
}

@end
