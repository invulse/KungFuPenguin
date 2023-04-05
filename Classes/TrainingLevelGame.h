//
//  TrainingLevelGame.h
//  BEUEngine
//
//  Created by Chris Mele on 10/14/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinGame.h"
#import "StoryGame.h"
#import "MessagePrompt.h"

@interface TrainingLevelGame : StoryGame {

	CCSprite *movementTip;
	CCSprite *attackTip;
	CCSprite *strongAttackTip;
	CCSprite *powerAttackTip;
	CCSprite *jumpTip;
	CCSprite *dashTip;
	CCSprite *blockTip;
	CCSprite *rampageTip;
	
	MessagePrompt *prompt;
	
}

-(void)addMovementTip;
-(void)removeMovementTip;

-(void)addAttackTip;
-(void)removeAttackTip;

-(void)addStrongAttackTip;
-(void)removeStrongAttackTip;

-(void)addPowerAttackTip;
-(void)removePowerAttackTip;

-(void)addJumpTip;
-(void)removeJumpTip;

-(void)addDashTip;
-(void)removeDashTip;

-(void)addBlockTip;
-(void)removeBlockTip;

-(void)addRampageTip:(BEUTrigger *)trigger;
-(void)removeRampageTip:(BEUTrigger *)trigger;

-(void)tipIn:(CCSprite *)tip;
-(void)tipOut:(CCSprite *)tip;

@end
