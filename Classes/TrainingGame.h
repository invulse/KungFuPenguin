//
//  TrainingGame.h
//  BEUEngine
//
//  Created by Chris Mele on 8/10/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PenguinGame.h"

@interface TrainingGame : PenguinGame {
	
	float firstMovementNeededTime;
	float firstMovementTime;
	
	int dashes;
	int dashesNeeded;
	
	int firstAttacks;
	int firstAttacksNeeded;
	
	int secondAttacks;
	int secondAttacksNeeded;
	
	CCSprite *instruction;
}

-(void)startTraining;
-(void)firstTimeWelcomeComplete:(NSNumber *)accepted;
-(void)completeBasicTraining;

-(void)rampageStart:(BEUTrigger *)trigger;
-(void)rampageComplete:(BEUTrigger *)trigger;

@end
