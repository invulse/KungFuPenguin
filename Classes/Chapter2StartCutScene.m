//
//  Chapter2StartCutScene.m
//  BEUEngine
//
//  Created by Chris Mele on 11/8/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Chapter2StartCutScene.h"
#import "PenguinGameController.h"
#import "Animator.h"

@implementation Chapter2StartCutScene

-(id)initWithTarget:(id)target_ selector:(SEL)selector_
{
	[super initWithTarget:target_ selector:selector_];
	
	animator = [[Animator alloc] initAnimationsFromFile:@"StoryPanels1.plist"];
	
	panel11BG = [[CCSprite alloc] initWithFile:@"StoryPanel1-1-BG.png"];
	panel11Eskimo = [[CCSprite alloc] initWithFile:@"StoryPanel1-1-Eskimo.png"];
	panel11Penguin = [[CCSprite alloc] initWithFile:@"StoryPanel1-1-Penguin.png"];
	panel11BG.visible = panel11Eskimo.visible = panel11Penguin.visible = NO;
	
	panel12BG = [[CCSprite alloc] initWithFile:@"StoryPanel1-2-BG.png"];
	panel12Eskimo = [[CCSprite alloc] initWithFile:@"StoryPanel1-2-Eskimo.png"];
	panel12Penguin = [[CCSprite alloc] initWithFile:@"StoryPanel1-2-Penguin.png"];
	panel12BG.visible = panel12Eskimo.visible = panel12Penguin.visible = NO;
	
	panel13BG = [[CCSprite alloc] initWithFile:@"StoryPanel1-3-BG.png"];
	panel13Penguin = [[CCSprite alloc] initWithFile:@"StoryPanel1-3-Penguin.png"];
	panel13BG.visible = panel13Penguin.visible = NO;
	
	
	whiteScreen = [CCSprite spriteWithFile:@"WhiteScreen.png"];
	whiteScreen.anchorPoint = CGPointZero;
	//whiteScreen.opacity = 0;
	
	blackScreen = [CCSprite spriteWithFile:@"BlackScreen.png"];
	blackScreen.opacity = 0;
	
	[self addChild:panel11BG];
	[self addChild:panel11Eskimo];
	[self addChild:panel11Penguin];
	[self addChild:panel12BG];
	[self addChild:panel12Eskimo];
	[self addChild:panel12Penguin];
	[self addChild:panel13BG];
	[self addChild:panel13Penguin];
	[self addChild:blackScreen];
	[self addChild:whiteScreen];
	
	return self;
}

-(void)start
{
	[super start];
	panel11BG.visible = panel11Eskimo.visible = panel11Penguin.visible = YES;
	[panel11BG runAction:[animator getAnimationByName:@"1-1-BG"]];
	[panel11Eskimo runAction:[animator getAnimationByName:@"1-1-Eskimo"]];
	[panel11Penguin runAction:[animator getAnimationByName:@"1-1-Penguin"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"1-1-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(frame2Start)],
							nil
							]
	 ];	
	
}

-(void)frame2Start
{
	panel11BG.visible = panel11Eskimo.visible = panel11Penguin.visible = NO;
	
	panel12BG.visible = panel12Eskimo.visible = panel12Penguin.visible = YES;
	[panel12BG runAction:[animator getAnimationByName:@"1-2-BG"]];
	[panel12Eskimo runAction:[animator getAnimationByName:@"1-2-Eskimo"]];
	[panel12Penguin runAction:[animator getAnimationByName:@"1-2-Penguin"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"1-2-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(frame3Start)],
							nil
							]
	 ];
}

-(void)frame3Start
{
	panel12BG.visible = panel12Eskimo.visible = panel12Penguin.visible = NO;
	
	panel13BG.visible = panel13Penguin.visible = YES;
	[panel13BG runAction:[animator getAnimationByName:@"1-3-BG"]];
	[panel13Penguin runAction:[animator getAnimationByName:@"1-3-Penguin"]];
	[whiteScreen runAction:[animator getAnimationByName:@"1-3-Screen"]];
	[blackScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"1-3-BlackScreen"],
							[CCCallFunc actionWithTarget:self selector:@selector(complete)],
							nil
							]
	 ];
}

-(void)dealloc
{
	[panel11BG release];
	[panel11Eskimo release];
	[panel11Penguin release];
	[panel12BG release];
	[panel12Eskimo release];
	[panel12Penguin release];
	[panel13BG release];
	[panel13Penguin release];
	[super dealloc];
}

@end
