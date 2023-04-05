//
//  NinjaRunning.h
//  BEUEngine
//
//  Created by Chris Mele on 11/5/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "cocos2d.h"
#import "Enemy.h"

@interface NinjaRunning : Enemy {
	
	CCNode *ninja;
	CCSprite *leftArm;
	CCSprite *head;
	CCSprite *body;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
	CCSprite *rightArm;
	
}

-(void)loop;

@end