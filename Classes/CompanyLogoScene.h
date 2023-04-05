//
//  CompanyLogoScene.h
//  BEUEngine
//
//  Created by Chris Mele on 11/11/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"

@class Animator;

@interface CompanyLogoScene : CCScene {
	CCSprite *screen;
	Animator *animator;
	
	CCSprite *invulse;
	CCSprite *games;
	CCSprite *arrowLeft;
	CCSprite *arrowRight;
	CCSprite *arrowRight2;
}

@end
