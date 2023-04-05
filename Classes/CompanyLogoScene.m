//
//  CompanyLogoScene.m
//  BEUEngine
//
//  Created by Chris Mele on 11/11/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "CompanyLogoScene.h"
#import "Animator.h"
#import "PenguinGameController.h"

@implementation CompanyLogoScene

-(id)init
{
	[super init];
	
	screen = [CCSprite spriteWithFile:@"WhiteScreen.png"];
	screen.anchorPoint = CGPointZero;
	
	invulse = [CCSprite spriteWithFile:@"CompanyLogo-Invulse.png"];
	games = [CCSprite spriteWithFile:@"CompanyLogo-Games.png"];
	arrowLeft = [CCSprite spriteWithFile:@"CompanyLogo-ArrowLeft.png"];
	arrowRight = [CCSprite spriteWithFile:@"CompanyLogo-ArrowRight.png"];
	arrowRight2 = [CCSprite spriteWithFile:@"CompanyLogo-ArrowRight2.png"];
	invulse.opacity = games.opacity = arrowLeft.opacity = arrowRight.opacity = arrowRight2.opacity = 0;
	
	
	[self addChild:screen];
	[self addChild:invulse];
	[self addChild:games];
	[self addChild:arrowLeft];
	[self addChild:arrowRight];
	[self addChild:arrowRight2];
	
	animator = [[Animator alloc] initAnimationsFromFile:@"CompanyLogoAnimations.plist"];
	
	
	
	
	return self;
}

-(void)onEnterTransitionDidFinish
{
	
	[invulse runAction:[animator getAnimationByName:@"Invulse"]];
	[games runAction:[animator getAnimationByName:@"Games"]];
	[arrowLeft runAction:[animator getAnimationByName:@"ArrowLeft"]];
	[arrowRight runAction:[animator getAnimationByName:@"ArrowRight"]];
	[arrowRight2 runAction:[CCSequence actions:
							[animator getAnimationByName:@"ArrowRight2"],
							[CCCallFunc actionWithTarget:self selector:@selector(complete)],
							nil
							]
	 ];
	
}

-(void)complete
{
	[[PenguinGameController sharedController] gotoMainMenu];
}

-(void)dealloc
{
	[animator release];
	[super dealloc];
}

@end
