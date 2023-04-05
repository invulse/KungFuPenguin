//
//  SealCharacter.h
//  BEUEngine
//
//  Created by Chris on 4/2/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BEUAnimatedCharacter.h"
#import "BEUInstantAction.h"
#import "BEUCharacterAIBehavior.h"
#import "BEUCharacterAIIdleBehavior.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"

@interface SealCharacter : BEUAnimatedCharacter {
	BEUSprite *seal;
	CCSprite *body;
	CCSprite *head;
	CCSprite *frontLeftFlipper;
	CCSprite *frontRightFlipper;
	CCSprite *backLeftFlipper;
}

-(void)setUpSeal;
-(void)setUpAnimations;
-(void)setUpAI;


-(BOOL)ram:(BEUMove *)move;
-(void)ramSlide;
-(void)ramComplete;

@end
