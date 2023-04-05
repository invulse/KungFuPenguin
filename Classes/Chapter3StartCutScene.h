//
//  Chapter3StartCutScene.h
//  BEUEngine
//
//  Created by Chris Mele on 11/15/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCutScene.h"

@class Animator;

@interface Chapter3StartCutScene : BEUCutScene {
	Animator *animator;
	
	CCSprite *panel21BG;
	CCSprite *panel22BG;
	CCSprite *panel22Girl;
	CCSprite *panel22FG;
	CCSprite *panel23BG;
	CCSprite *panel23Penguin;
	CCSprite *panel24BG;
	CCSprite *panel24Ninjas;
	
	CCSprite *whiteScreen;
	CCSprite *blackScreen;
}

@end
