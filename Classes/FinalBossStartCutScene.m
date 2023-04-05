//
//  FinalBossStartCutScene.m
//  BEUEngine
//
//  Created by Chris Mele on 11/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "FinalBossStartCutScene.h"
#import "Animator.h"

@implementation FinalBossStartCutScene

-(id)initWithTarget:(id)target_ selector:(SEL)selector_
{
	[super initWithTarget:target_ selector:selector_];
	
	animator = [[Animator alloc] initAnimationsFromFile:@"StoryPanels4.plist"];
	
	panel41BG = [CCSprite spriteWithFile:@"StoryPanels4-1-BG.png"];
	panel41Penguin = [CCSprite spriteWithFile:@"StoryPanels4-1-Penguin.png"];
	panel42 = [CCSprite spriteWithFile:@"StoryPanels4-2.png"];
	
	blackScreen = [CCSprite spriteWithFile:@"BlackScreen.png"];
	blackScreen.opacity = 0;
	whiteScreen = [CCSprite spriteWithFile:@"WhiteScreen.png"];
	whiteScreen.anchorPoint = CGPointZero;
	
	panel41BG.visible = panel41Penguin.visible = panel42.visible = NO;
	
	[self addChild:panel41BG];
	[self addChild:panel41Penguin];
	[self addChild:panel42];
	[self addChild:blackScreen];
	[self addChild:whiteScreen];
	
	return self;
	
}

-(void)start
{
	[super start];
	
	panel41BG.visible = panel41Penguin.visible = YES;
	
	[panel41BG runAction:[animator getAnimationByName:@"4-1-BG"]];
	[panel41Penguin runAction:[animator getAnimationByName:@"4-1-Penguin"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"4-1-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel2)],
							nil]
	 ];
	
	
}

-(void)panel2
{
	panel41BG.visible = panel41Penguin.visible = NO;
	panel42.visible = YES;
	
	[panel42 runAction:[animator getAnimationByName:@"4-2-Image"]];
	[whiteScreen runAction:[animator getAnimationByName:@"4-2-Screen"]];
	[blackScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"4-2-BlackScreen"],
							[CCCallFunc actionWithTarget:self selector:@selector(complete)],
							nil]
	 ];
}


-(void)dealloc
{
	[animator release];
	[super dealloc];
}



@end
