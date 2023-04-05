//
//  Chapter1StartCutScene.m
//  BEUEngine
//
//  Created by Chris Mele on 11/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Chapter1StartCutScene.h"
#import "Animator.h"

@implementation Chapter1StartCutScene

-(id)initWithTarget:(id)target_ selector:(SEL)selector_
{
	[super initWithTarget:target_ selector:selector_];
	
	animator = [[Animator alloc] initAnimationsFromFile:@"StoryPanels0.plist"];
	
	panel01BG = [CCSprite spriteWithFile:@"StoryPanel0-1-BG.png"];
	panel01Penguins = [CCSprite spriteWithFile:@"StoryPanel0-1-Penguins.png"];
	panel01Eskimos = [CCSprite spriteWithFile:@"StoryPanel0-1-Eskimos.png"];
	panel01Penguin = [CCSprite spriteWithFile:@"StoryPanel0-1-Penguin.png"];
	
	panel02BG = [CCSprite spriteWithFile:@"StoryPanel0-2-BG.png"];
	panel02Eskimo = [CCSprite spriteWithFile:@"StoryPanel0-2-Eskimo.png"];
	
	panel03BG = [CCSprite spriteWithFile:@"BlackScreen.png"];
	panel03Penguin = [CCSprite spriteWithFile:@"StoryPanel0-3.png"];
	
	blackScreen = [CCSprite spriteWithFile:@"BlackScreen.png"];
	blackScreen.opacity = 0;
	whiteScreen = [CCSprite spriteWithFile:@"WhiteScreen.png"];
	whiteScreen.anchorPoint = CGPointZero;
	
	panel01BG.visible = panel01Penguin.visible = panel01Eskimos.visible = panel01Penguin.visible = panel02BG.visible = panel02Eskimo.visible = panel03BG.visible = panel03Penguin.visible = NO;
	
	[self addChild:panel01BG];
	[self addChild:panel01Penguins];
	[self addChild:panel01Eskimos];
	[self addChild:panel01Penguin];
	[self addChild:panel02BG];
	[self addChild:panel02Eskimo];
	[self addChild:panel03BG];
	[self addChild:panel03Penguin];
	[self addChild:blackScreen];
	[self addChild:whiteScreen];
	
	return self;	
}

-(void)start
{
	[super start];
	
	panel01BG.visible = panel01Penguins.visible = panel01Eskimos.visible = panel01Penguin.visible = YES;
	
	[panel01BG runAction:[animator getAnimationByName:@"0-1-BG"]];
	[panel01Penguins runAction:[animator getAnimationByName:@"0-1-Penguins"]];
	[panel01Eskimos runAction:[animator getAnimationByName:@"0-1-Eskimos"]];
	[panel01Penguin runAction:[animator getAnimationByName:@"0-1-Penguin"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"0-1-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel2)],
							nil
							]];
}


-(void)panel2
{
	panel01BG.visible = panel01Penguins.visible = panel01Eskimos.visible = panel01Penguin.visible = NO;
	panel02BG.visible = panel02Eskimo.visible = YES;
	
	[panel02BG runAction:[animator getAnimationByName:@"0-2-BG"]];
	[panel02Eskimo runAction:[animator getAnimationByName:@"0-2-Eskimo"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"0-2-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel3)],
							nil
							]];
}

-(void)panel3
{
	panel02BG.visible = panel02Eskimo.visible = NO;
	panel03BG.visible = panel03Penguin.visible = YES;
	
	[panel03BG runAction:[animator getAnimationByName:@"0-3-BG"]];
	[panel03Penguin runAction:[animator getAnimationByName:@"0-3-Penguin"]];
	[whiteScreen runAction:[animator getAnimationByName:@"0-3-Screen"]];
	[blackScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"0-3-BlackScreen"],
							[CCCallFunc actionWithTarget:self selector:@selector(complete)],
							nil
							]];
}

-(void)dealloc
{
	[animator release];
	[super dealloc];
}

@end
