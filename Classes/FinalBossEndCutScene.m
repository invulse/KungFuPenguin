//
//  FinalBossEndCutScene.m
//  BEUEngine
//
//  Created by Chris Mele on 11/17/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "FinalBossEndCutScene.h"
#import "PenguinGameController.h"
#import "Animator.h"

@implementation FinalBossEndCutScene

-(id)initWithTarget:(id)target_ selector:(SEL)selector_
{
	[super initWithTarget:target_ selector:selector_];
	
	animator = [[Animator alloc] initAnimationsFromFile:@"StoryPanels5.plist"];
	
	panel51BG = [CCSprite spriteWithFile:@"StoryPanel5-1-BG.png"];
	panel51Penguin = [CCSprite spriteWithFile:@"StoryPanel5-1-Penguin.png"];
	panel51Sword = [CCSprite spriteWithFile:@"StoryPanel5-1-Sword.png"];
	panel52BG = [CCSprite spriteWithFile:@"StoryPanel5-2-BG.png"];
	panel52Penguin = [CCSprite spriteWithFile:@"StoryPanel5-2-Penguin.png"];
	panel53BG = [CCSprite spriteWithFile:@"StoryPanel5-3-BG.png"];
	panel53Penguin1 = [CCSprite spriteWithFile:@"StoryPanel5-3-Penguin1.png"];
	panel53Penguin2 = [CCSprite spriteWithFile:@"StoryPanel5-3-Penguin2.png"];
	panel53Penguin3 = [CCSprite spriteWithFile:@"StoryPanel5-3-Penguin3.png"];
	panel53Penguin4 = [CCSprite spriteWithFile:@"StoryPanel5-3-Penguin4.png"];
	panel54BG = [CCSprite spriteWithFile:@"StoryPanel5-4-BG.png"];
	panel54FG = [CCSprite spriteWithFile:@"StoryPanel5-4-FG.png"];
	panel54Bandana = [CCSprite spriteWithFile:@"StoryPanel5-4-Bandana.png"];

	blackScreen = [CCSprite spriteWithFile:@"BlackScreen.png"];
	blackScreen.opacity = 0;
	whiteScreen = [CCSprite spriteWithFile:@"WhiteScreen.png"];
	whiteScreen.anchorPoint = CGPointZero;
	
	panel51BG.visible = panel51Penguin.visible = panel51Sword.visible = panel52BG.visible = panel52Penguin.visible = panel53BG.visible = panel53Penguin1.visible = panel53Penguin2.visible = panel53Penguin3.visible = panel53Penguin4.visible = panel54BG.visible = panel54FG.visible = panel54Bandana.visible = NO;
	
	[self addChild:panel51BG];
	[self addChild:panel51Penguin];
	[self addChild:panel51Sword];
	[self addChild:panel52BG];
	[self addChild:panel52Penguin];
	[self addChild:panel53BG];
	[self addChild:panel53Penguin1];
	[self addChild:panel53Penguin2];
	[self addChild:panel53Penguin3];
	[self addChild:panel53Penguin4];
	[self addChild:panel54BG];
	[self addChild:panel54FG];
	[self addChild:panel54Bandana];
	
	[self addChild:blackScreen];
	[self addChild:whiteScreen];
	
	return self;
}

+(void)preload
{
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-1-BG.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-1-Penguin.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-1-Sword.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-2-BG.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-2-Penguin.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-3-BG.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-3-Penguin1.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-3-Penguin2.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-3-Penguin3.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-3-Penguin4.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-4-BG.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-4-FG.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-4-Bandana.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"StoryPanel5-1.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"BlackScreen.png"];
	[[CCTextureCache sharedTextureCache] addImage:@"WhiteScreen.png"];
}

-(void)onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	[self start];
}

-(void)start
{
	[super start];
	
	panel51BG.visible = panel51Penguin.visible = panel51Sword.visible = YES;
	
	[panel51BG runAction:[animator getAnimationByName:@"5-1-BG"]];
	[panel51Penguin runAction:[animator getAnimationByName:@"5-1-Penguin"]];
	[panel51Sword runAction:[animator getAnimationByName:@"5-1-Sword"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"5-1-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel2)],
							nil
							]];
}

-(void)panel2
{
	panel51BG.visible = panel51Penguin.visible = panel51Sword.visible = NO;
	panel52BG.visible = panel52Penguin.visible = YES;
	
	[panel52BG runAction:[animator getAnimationByName:@"5-2-BG"]];
	[panel52Penguin runAction:[animator getAnimationByName:@"5-2-Penguin"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"5-2-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel3)],
							nil
							]];	
}

-(void)panel3
{
	panel52BG.visible = panel52Penguin.visible = NO;
	panel53BG.visible = panel53Penguin1.visible = panel53Penguin2.visible = panel53Penguin3.visible = panel53Penguin4.visible = YES;
	
	[panel53BG runAction:[animator getAnimationByName:@"5-3-BG"]];
	[panel53Penguin1 runAction:[animator getAnimationByName:@"5-3-Penguin1"]];
	[panel53Penguin2 runAction:[animator getAnimationByName:@"5-3-Penguin2"]];
	[panel53Penguin3 runAction:[animator getAnimationByName:@"5-3-Penguin3"]];
	[panel53Penguin4 runAction:[animator getAnimationByName:@"5-3-Penguin4"]];
	[whiteScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"5-3-Screen"],
							[CCCallFunc actionWithTarget:self selector:@selector(panel4)],
							nil
							]];	
}

-(void)panel4
{
	panel53BG.visible = panel53Penguin1.visible = panel53Penguin2.visible = panel53Penguin3.visible = panel53Penguin4.visible = NO;
	panel54BG.visible = panel54FG.visible = panel54Bandana.visible = YES;
	
	[panel54BG runAction:[animator getAnimationByName:@"5-4-BG"]];
	[panel54FG runAction:[animator getAnimationByName:@"5-4-FG"]];
	[panel54Bandana runAction:[animator getAnimationByName:@"5-4-Bandana"]];
	[whiteScreen runAction:[animator getAnimationByName:@"5-4-Screen"]];
	[blackScreen runAction:[CCSequence actions:
							[animator getAnimationByName:@"5-4-BlackScreen"],
							[CCCallFunc actionWithTarget:self selector:@selector(complete)],
							nil
							]];
}

-(void)complete
{
	[[PenguinGameController sharedController] gotoMap];
}

-(void)dealloc
{
	[animator release];
	[super dealloc];
}

@end
