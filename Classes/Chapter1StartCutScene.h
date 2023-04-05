//
//  Chapter1StartCutScene.h
//  BEUEngine
//
//  Created by Chris Mele on 11/16/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCutScene.h"

@class Animator;

@interface Chapter1StartCutScene : BEUCutScene {
	Animator *animator;
	
	CCSprite *panel01BG;
	CCSprite *panel01Penguins;
	CCSprite *panel01Eskimos;
	CCSprite *panel01Penguin;
	CCSprite *panel01Screen;
	
	CCSprite *panel02BG;
	CCSprite *panel02Eskimo;
	CCSprite *panel02Screen;
	
	CCSprite *panel03BG;
	CCSprite *panel03Penguin;
	CCSprite *panel03Screen;
	CCSprite *panel03BlackScreen;
	
	CCSprite *whiteScreen;
	CCSprite *blackScreen;
}

@end
