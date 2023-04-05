//
//  Chapter4StartCutScene.h
//  BEUEngine
//
//  Created by Chris Mele on 11/15/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCutScene.h"

@class Animator;


@interface Chapter4StartCutScene : BEUCutScene {
	Animator *animator;
	
	CCSprite *panel31BG;
	CCSprite *panel31Enemy;
	CCSprite *panel31Penguin;
	CCSprite *panel32BG;
	CCSprite *panel32Penguin;
	CCSprite *panel33BG;
	CCSprite *panel33Gaurd;
	
	CCSprite *whiteScreen;
	CCSprite *blackScreen;
	
}

@end
