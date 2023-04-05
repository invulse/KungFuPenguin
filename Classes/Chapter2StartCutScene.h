//
//  Chapter2StartCutScene.h
//  BEUEngine
//
//  Created by Chris Mele on 11/8/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCutScene.h"

@class Animator;

@interface Chapter2StartCutScene : BEUCutScene {
	Animator *animator;
	
	CCSprite *panel11BG;
	CCSprite *panel11Eskimo;
	CCSprite *panel11Penguin;
	CCSprite *panel12BG;
	CCSprite *panel12Eskimo;
	CCSprite *panel12Penguin;
	CCSprite *panel13BG;
	CCSprite *panel13Penguin;
	
	CCSprite *whiteScreen;
	CCSprite *blackScreen;
	
	
}

-(void)frame2Start;
-(void)frame3Start;

@end
