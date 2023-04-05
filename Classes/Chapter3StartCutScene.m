//
//  Chapter3StartCutScene.m
//  BEUEngine
//
//  Created by Chris Mele on 11/15/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "Chapter3StartCutScene.h"
#import "Animator.h"

@implementation Chapter3StartCutScene

-(id)initWithTarget:(id)target_ selector:(SEL)selector_
{
	[super initWithTarget:target_ selector:selector_];
	
	animator = [[Animator alloc] initAnimationsFromFile:@"StoryPanels2.plist"];

	panel21BG = [CCSprite spriteWithFile:@"StoryPanel2-1.png"];
	
	panel22BG = [CCSprite spriteWithFile:@"StoryPanel2-2-BG.png"];
	panel22Girl = [CCSprite spriteWithFile:@"StoryPanel2-2-Girl.png"];
	panel22FG = [CCSprite spriteWithFile:@"StoryPanel2-2-FG.png"];
	
	panel23BG = [CCSprite spriteWithFile:@"StoryPanel2-3-BG.png"];
	panel23Penguin = [CCSprite spriteWithFile:@"StoryPanel2-3-Penguin.png"];
	
	panel24BG = [CCSprite spriteWithFile:@"StoryPanel2-4-BG.png"];
	panel24Ninjas = [CCSprite spriteWithFile:@"StoryPanel2-4-Ninjas.png"];
	
	
	panel21BG.visible = panel22BG.visible = panel22Girl.visible = panel22FG.visible = panel23BG.visible = panel23Penguin.visible = panel24BG.visible = panel24Ninjas.visible = NO;
	
	whiteScreen = [CCSprite spriteWithFile:@"WhiteScreen.png"];
	whiteScreen.anchorPoint = CGPointZero;
	//whiteScreen.opacity = 0;
	
	blackScreen = [CCSprite spriteWithFile:@"BlackScreen.png"];
	blackScreen.opacity = 0;
	
	[self addChild:panel21BG];
	[self addChild:panel22BG];
	[self addChild:panel22Girl];
	[self addChild:panel22FG];
	[self addChild:panel23BG];
	[self addChild:panel23Penguin];
	[self addChild:panel24BG];
	[self addChild:panel24Ninjas];
	[self addChild:whiteScreen];
	[self addChild:blackScreen];
	
	return self;
}

-(void)start
{
	[super start];
	
	panel21BG.visible = YES;
	[panel21BG runAction:[animator getAnimationByName:@"2-1-BG"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"2-1-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel2)],
							nil
							]];
	
	
}

-(void)panel2
{
	panel21BG.visible = NO;
	
	panel22BG.visible = panel22Girl.visible = panel22FG.visible = YES;
	panel22BG.anchorPoint = CGPointZero;
	panel22FG.anchorPoint = CGPointZero;
	[panel22Girl runAction:[animator getAnimationByName:@"2-2-Girl"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"2-2-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel3)],
							nil
							]];
}

-(void)panel3
{
	
	panel22BG.visible = panel22Girl.visible = panel22FG.visible = NO;
	panel23BG.visible = panel23Penguin.visible = YES;
	
	[panel23BG runAction:[animator getAnimationByName:@"2-3-BG"]];
	[panel23Penguin runAction:[animator getAnimationByName:@"2-3-Penguin"]];
	[whiteScreen runAction:[animator getAnimationByName:@"2-3-Screen"]];
	[blackScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"2-3-BlackScreen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel4)],
							nil
							]];
}

-(void)panel4
{
	panel23BG.visible = panel23Penguin.visible = NO;
	panel24BG.visible = panel24Ninjas.visible = YES;
	
	[panel24BG runAction:[animator getAnimationByName:@"2-4-BG"]];
	[panel24Ninjas runAction:[animator getAnimationByName:@"2-4-Ninjas"]];
	[blackScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"2-4-BlackScreen"],
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
