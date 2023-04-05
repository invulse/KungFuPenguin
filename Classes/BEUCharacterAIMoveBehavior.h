//
//  BEUCharacterAIMoveBehavior.h
//  BEUEngine
//
//  Created by Chris Mele on 3/6/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCharacterAIBehavior.h"
#import "BEUCharacterAction.h"
#import "BEUCharacterMoveAction.h"
#import "BEUCharacterAI.h"

#import "BEUEnvironment.h"

@class BEUCharacterAIBehavior;
@class BEUCharacterMoveTo;
@class BEUCharacterMoveToObject;
@class BEUCharacterAction;

@interface BEUCharacterAIMove : BEUCharacterAIBehavior
{
	//Distance to be considered 'near target'
	float nearTargetDistance;
	
	
	//minimum move percent 0-1
	float minMovePercent;
	//maximum move percent 0-1
	float maxMovePercent;
	
	//
	BEUCharacterAction *currentAction;
}

@property(nonatomic,assign) float nearTargetDistance;
@property(nonatomic,assign) BEUCharacterAction *currentAction;
@property(nonatomic) float minMovePercent;
@property(nonatomic) float maxMovePercent;

-(void)canceling;

@end


@interface BEUCharacterAIMoveToTarget : BEUCharacterAIMove 
{
	
}

@end

@interface BEUCharacterAIMoveAwayFromTarget : BEUCharacterAIMove
{
	
}

@end

@interface BEUCharacterAIMoveAwayToTargetZ : BEUCharacterAIMove
{

}

@end