//
//  Chapter4StartCutScene.m
//  BEUEngine
//
//  Created by Chris Mele on 11/15/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Chapter4StartCutScene.h"
#import "Animator.h"

@implementation Chapter4StartCutScene

-(id)initWithTarget:(id)target_ selector:(SEL)selector_
{
	[super initWithTarget:target_ selector:selector_];
	
	
	animator = [[Animator alloc] initAnimationsFromFile:@"StoryPanels3.plist"];
	
	panel31BG = [CCSprite spriteWithFile:@"StoryPanel3-1-BG.png"];
	panel31Enemy = [CCSprite spriteWithFile:@"StoryPanel3-1-Enemy.png"];
	panel31Penguin = [CCSprite spriteWithFile:@"StoryPanel3-1-Penguin.png"];
	
	panel32BG = [CCSprite spriteWithFile:@"StoryPanel3-2-BG.png"];
	panel32Penguin = [CCSprite spriteWithFile:@"StoryPanel3-2-Penguin.png"];
	
	panel33BG = [CCSprite spriteWithFile:@"StoryPanel3-3-BG.png"];
	panel33Gaurd = [CCSprite spriteWithFile:@"StoryPanel3-3-Gaurd.png"];
	
	whiteScreen = [CCSprite spriteWithFile:@"WhiteScreen.png"];
	whiteScreen.anchorPoint = CGPointZero;
	//whiteScreen.opacity = 0;
	
	blackScreen = [CCSprite spriteWithFile:@"BlackScreen.png"];
	blackScreen.opacity = 0;
	
	panel31BG.visible = panel31Enemy.visible = panel31Penguin.visible = panel32BG.visible = panel32Penguin.visible = panel33BG.visible = panel33Gaurd.visible = NO;
	
	[self addChild:panel31BG];
	[self addChild:panel31Enemy];
	[self addChild:panel31Penguin];
	[self addChild:panel32BG];
	[self addChild:panel32Penguin];
	[self addChild:panel33BG];
	[self addChild:panel33Gaurd];
	[self addChild:blackScreen];
	[self addChild:whiteScreen];
	
	return self;
}


-(void)start
{
	[super start];
	
	panel31BG.visible = panel31Enemy.visible = panel31Penguin.visible = YES;
	
	[panel31BG runAction:[animator getAnimationByName:@"3-1-BG"]];
	[panel31Enemy runAction:[animator getAnimationByName:@"3-1-Enemy"]];
	[panel31Penguin runAction:[animator getAnimationByName:@"3-1-Penguin"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"3-1-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel2)],
							nil
							]];
}

-(void)panel2
{
	
	panel31BG.visible = panel31Enemy.visible = panel31Penguin.visible = NO;
	panel32BG.visible = panel32Penguin.visible = YES;
	
	[panel32BG runAction:[animator getAnimationByName:@"3-2-BG"]];
	[panel32Penguin runAction:[animator getAnimationByName:@"3-2-Penguin"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"3-2-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel3)],
							nil
							]];
}

-(void)panel3
{
	panel32BG.visible = panel32Penguin.visible = NO;
	panel33BG.visible = panel33Gaurd.visible = YES;
	
	[panel33BG runAction:[animator getAnimationByName:@"3-3-BG"]];
	[panel33Gaurd runAction:[animator getAnimationByName:@"3-3-Gaurd"]];
	[whiteScreen runAction:[animator getAnimationByName:@"3-3-Screen"]];
	[blackScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"3-3-BlackScreen"],
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
