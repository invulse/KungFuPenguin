//
//  FinalBossStartCutScene.h
//  BEUEngine
//
//  Created by Chris Mele on 11/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCutScene.h"

@class Animator;

@interface FinalBossStartCutScene : BEUCutScene {
	
	Animator *animator;
	
	CCSprite *panel41BG;
	CCSprite *panel41Penguin;
	CCSprite *panel42;
	
	CCSprite *whiteScreen;
	CCSprite *blackScreen;
}

@end
