//
//  PolarBearCharacter.h
//  BEUEngine
//
//  Created by Chris on 3/30/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUAnimatedCharacter.h"
#import "BEUSprite.h"
#import "BEUInstantAction.h"
#import "BEUCharacterAIIdleBehavior.h"
#import "BEUHitAction.h"
#import "cocos2d.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"

@interface PolarBearCharacter : BEUAnimatedCharacter {
	BEUSprite *bear;
	
	CCSprite *frontLeftLeg;
	CCSprite *frontRightLeg;
	
	CCSprite *backLeftLeg;
	CCSprite *backRightLeg;
	
	CCSprite *body;
	CCSprite *head;
	
	NSString *currentAnimation;
}

-(void)createBear;
-(void)setUpAI;
-(void)setUpAnimations;
-(void)setOrigPositions;
-(void)stopAllAnimations;

-(BOOL)bite:(BEUMove *)move;
-(void)biteSend;
-(void)biteComplete;

@end
