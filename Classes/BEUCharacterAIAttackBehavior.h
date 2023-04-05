//
//  BEUCharacterAIAttackBehavior.h
//  BEUEngine
//
//  Created by Chris Mele on 3/8/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "BEUCharacterAIBehavior.h"
#import "BEUCharacterMoveAction.h"
#import "BEUMove.h"

@class BEUMove;
@class BEUCharacterAIBehavior;
@class BEUCharacterMoveToObject;

@interface BEUCharacterAIAttackBehavior : BEUCharacterAIBehavior 
{
	BOOL idleAfterAttack;
	float minIdleTime;
	float maxIdleTime;
	
	//should the attack behavior or branch require a cooldown after running before
	//it can be run again
	BOOL needsCooldown;
	float minCooldownTime;
	float maxCooldownTime;
	BOOL coolingDown;
	
	BOOL canRunSameMoveAgain;
	
	BEUMove *lastMove;
	
}

@property(nonatomic) BOOL idleAfterAttack;
@property(nonatomic) float minIdleTime;
@property(nonatomic) float maxIdleTime;
@property(nonatomic) BOOL needsCooldown;
@property(nonatomic) float minCooldownTime;
@property(nonatomic) float maxCooldownTime;
@property(nonatomic) BOOL canRunSameMoveAgain;

-(BOOL)hasMoveInRange;
-(void)attackComplete;
-(void)idleComplete:(ccTime)delta;
-(void)cooldownComplete:(ccTime)delta;

@end


@interface BEUCharacterAIAttackWithRandomMove : BEUCharacterAIAttackBehavior
{
	NSMutableArray *moves;
}

@property(nonatomic,retain) NSMutableArray *moves;

-(id)initWithMoves:(NSMutableArray *)moves;

+(id)behaviorWithMoves:(NSMutableArray *)moves;

-(BEUMove *)getRandomMove;
-(BEUMove *)getRandomMoveInRange;


@end

@interface BEUCharacterAIMoveToAndAttack : BEUCharacterAIAttackWithRandomMove
{
	BEUMove *attackMove;
	BEUCharacterMoveToObject *moveToAction;
	
	BOOL mustBeInViewPort;
}

@property(nonatomic,assign) BEUMove *attackMove;
@property(nonatomic) BOOL mustBeInViewPort;

-(void)moveToComplete;
-(void)moveToCanceled;

@end


@interface BEUCharacterAIAttackWithMoveInRange : BEUCharacterAIMoveToAndAttack
{
	
}

@end