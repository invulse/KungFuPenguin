//
//  FullGamePromo.m
//  BEUEngine
//
//  Created by Chris Mele on 11/18/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "FullGamePromo.h"
#import "PenguinGameController.h"

@implementation FullGamePromo

-(id)init
{
	CCSprite *bg = [CCSprite spriteWithFile:@"FullGamePromoBG.png"];
	bg.anchorPoint = CGPointZero;
	bg.position = CGPointZero;
	
	CCMenuItemImage *buyButton = [CCMenuItemImage itemFromNormalImage:@"FullGamePromoBuyButton.png" selectedImage:@"FullGamePromoBuyButtonDown.png" target:self selector:@selector(buy:)];
	buyButton.anchorPoint = CGPointZero;
	buyButton.position = ccp(200,12);
	
	CCMenuItemImage *declineButton = [CCMenuItemImage itemFromNormalImage:@"FullGamePromoDeclineButton.png" selectedImage:@"FullGamePromoDeclineButton.png" target:self selector:@selector(decline:)];
	declineButton.anchorPoint = CGPointZero;
	declineButton.position = ccp(12,12);
	
	CCMenu *menu = [CCMenu menuWithItems:buyButton,declineButton,nil];
	menu.anchorPoint = CGPointZero;
	menu.position = CGPointZero;

	[self addChild:bg];
	[self addChild:menu];
	
	return self;
}

-(void)buy:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=400687288&mt=8"]];
}

-(void)decline:(id)sender
{
	[[PenguinGameController sharedController] gotoMap];
}

@end
