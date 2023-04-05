//
//  EskimoCharacter.h
//  BEUEngine
//
//  Created by Chris on 3/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUInstantAction.h"
#import "BEUAnimatedCharacter.h"
#import "BEUSprite.h"
#import "BEUCharacterAIIdleBehavior.h"
#import "BEUHitAction.h"
#import "cocos2d.h"
#import "BEUCharacterAIMoveBehavior.h"

#import "BEUCharacterAIAttackBehavior.h"

@interface EskimoCharacter : BEUAnimatedCharacter {
	BEUSprite *eskimo;
	CCSprite *body;
	CCSprite *head;
	CCSprite *leftArm;
	CCSprite *rightArm;
	CCSprite *leftLeg;
	CCSprite *rightLeg;
	
}

-(void)setUpEskimo;
-(void)setUpAnimations;
-(void)setUpAI;

-(BOOL)attack:(BEUMove *)move;
-(void)attackSend;
-(void)attackComplete;

-(void)block;

@end
