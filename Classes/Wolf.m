//
//  Eskimo2.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Wolf.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"
#import "BEUCharacterAIIdleBehavior.h"

@implementation Wolf

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	life = 120.0f;
	totalLife = life;
	
	movementSpeed = 200.0f;
	
	moveArea = CGRectMake(-20.0f,0.0f,60.0f,20.0f);
	hitArea = CGRectMake(-70.0f,0.0f,140.0f,100.0f);
	
	
	shadowSize = CGSizeMake(95.0f, 30.0f);
	shadowOffset = ccp(-5.0f,5.0f);
	
	wolf = [[BEUSprite alloc] init];
	wolf.anchorPoint = ccp(0.0f,0.0f);
	wolf.position = ccp(0.0f,0.0f);
	
	autoOrient = NO;
	//drawBoundingBoxes = YES;
	
	minCoinDrop = 2;
	maxCoinDrop = 4;
	coinDropChance = .7;
	
	healthDropChance = .2;
	minHealthDrop = 10;
	maxHealthDrop = 20;
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Wolf.plist"];
	
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfHead.png"]];
	frontLeftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfFrontLeftLeg.png"]];
	backLeftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfBackLeftLeg.png"]];
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfBody.png"]];
	frontRightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfFrontRightLeg.png"]];
	backRightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfBackRightLeg.png"]];
	tail = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfTail.png"]];
	
	[wolf addChild:tail];
	[wolf addChild:backRightLeg];
	[wolf addChild:frontRightLeg];
	[wolf addChild:body];
	[wolf addChild:backLeftLeg];
	[wolf addChild:frontLeftLeg];
	[wolf addChild:head];
	[self addChild:wolf];
	
	BEUMove *attackMove = [BEUMove moveWithName:@"attack1"
									  character:self
										  input:nil
									   selector:@selector(attack1:)];
	attackMove.range = 140.0f;
	[movesController addMove:attackMove];
	
}

-(void)setUpAI
{
	ai = [[BEUCharacterAI alloc] initWithParent:self];
	
	BEUCharacterAIBehavior *moveBranch = [BEUCharacterAIMove behavior];
	
	BEUCharacterAIMoveAwayFromTarget *moveAway = [BEUCharacterAIMoveAwayFromTarget behavior];
	moveAway.minMovePercent = 0.3f;
	
	BEUCharacterAIMoveAwayToTargetZ *moveToZ = [BEUCharacterAIMoveAwayToTargetZ behavior];
	moveToZ.minMovePercent = 0.3f;
	
	[moveBranch addBehavior:moveAway];
	[moveBranch addBehavior:moveToZ];
	[ai addBehavior:moveBranch];
	
	BEUCharacterAIBehavior *idleBranch = [BEUCharacterAIIdleBehavior behaviorWithMinTime:0.8f maxTime:1.6f];
	[ai addBehavior:idleBranch];
	
	BEUCharacterAIBehavior *attackBranch = [BEUCharacterAIAttackBehavior behavior];
	[attackBranch addBehavior:[BEUCharacterAIMoveToAndAttack behaviorWithMoves:[movesController moves]]];
	[ai addBehavior:attackBranch];
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"Wolf-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"WolfHead.png"
							]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"WolfFrontLeftLeg.png"
							]] target:frontLeftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"WolfBackLeftLeg.png"
							]] target:backLeftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"WolfBody.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"WolfFrontRightLeg.png"
							]] target:frontRightLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"WolfBackRightLeg.png"
							]] target:backRightLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"WolfTail.png"
							]] target:tail];
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"] target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-FrontLeftLeg"] target:frontLeftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-BackLeftLeg"] target:backLeftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-BackLeftLeg"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-FrontRightLeg"] target:frontRightLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-BackRightLeg"] target:backRightLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Tail"] target:tail];
	
	BEUAnimation *idle = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idle];
	[idle addAction:[animator getAnimationByName:@"Idle-Head"] target:head];
	[idle addAction:[animator getAnimationByName:@"Idle-FrontLeftLeg"] target:frontLeftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-BackLeftLeg"] target:backLeftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-Body"] target:body];
	[idle addAction:[animator getAnimationByName:@"Idle-FrontRightLeg"] target:frontRightLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-BackRightLeg"] target:backRightLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-Tail"] target:tail];
	
	
	BEUAnimation *walk = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walk];
	[walk addAction:[animator getAnimationByName:@"Walk-Head"] target:head];
	[walk addAction:[animator getAnimationByName:@"Walk-FrontLeftLeg"] target:frontLeftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-BackLeftLeg"] target:backLeftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-Body"] target:body];
	[walk addAction:[animator getAnimationByName:@"Walk-FrontRightLeg"] target:frontRightLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-BackRightLeg"] target:backRightLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-Tail"] target:tail];
	
	BEUAnimation *run = [BEUAnimation animationWithName:@"run"];
	[self addCharacterAnimation:run];
	[run addAction:[animator getAnimationByName:@"Run-Head"] target:head];
	[run addAction:[animator getAnimationByName:@"Run-FrontLeftLeg"] target:frontLeftLeg];
	[run addAction:[animator getAnimationByName:@"Run-BackLeftLeg"] target:backLeftLeg];
	[run addAction:[animator getAnimationByName:@"Run-Body"] target:body];
	[run addAction:[animator getAnimationByName:@"Run-FrontRightLeg"] target:frontRightLeg];
	[run addAction:[animator getAnimationByName:@"Run-BackRightLeg"] target:backRightLeg];
	[run addAction:[animator getAnimationByName:@"Run-Tail"] target:tail];
	
	BEUAnimation *attack1 = [BEUAnimation animationWithName:@"attack1"];
	[self addCharacterAnimation:attack1];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Head"] target:head];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-FrontLeftLeg"] target:frontLeftLeg];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-BackLeftLeg"] target:backLeftLeg];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Body"] target:body];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-FrontRightLeg"] target:frontRightLeg];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-BackRightLeg"] target:backRightLeg];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Tail"] target:tail];
	[attack1 addAction:[CCSequence actions:
						[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfHead-Bite.png"]],
						[CCDelayTime actionWithDuration:0.56f],
						[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfHead.png"]],
						nil
						]
			 target:head];
	[attack1 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.56f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Send)],
						[CCDelayTime actionWithDuration:0.67],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Complete)],
						nil
						]
				target:self];
	
	
	
	BEUAnimation *hit1 = [BEUAnimation animationWithName:@"hit1"];
	[self addCharacterAnimation:hit1];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Head"] target:head];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-FrontLeftLeg"] target:frontLeftLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-BackLeftLeg"] target:backLeftLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Body"] target:body];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-FrontRightLeg"] target:frontRightLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-BackRightLeg"] target:backRightLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Tail"] target:tail];
	[hit1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfHead-Hurt.png"]]
			 target:head];
	[hit1 addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.5f],
					 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					 nil
					 ]
			 target:self];
	
	BEUAnimation *hit2 = [BEUAnimation animationWithName:@"hit2"];
	[self addCharacterAnimation:hit2];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Head"] target:head];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-FrontLeftLeg"] target:frontLeftLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-BackLeftLeg"] target:backLeftLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Body"] target:body];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-FrontRightLeg"] target:frontRightLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-BackRightLeg"] target:backRightLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Tail"] target:tail];
	[hit2 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfHead-Hurt.png"]]
			 target:head];
	[hit2 addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.63f],
					 [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					 nil
					 ]
			 target:self];
	
	BEUAnimation *fall1 = [BEUAnimation animationWithName:@"fall1"];
	[self addCharacterAnimation:fall1];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Head"] target:head];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-FrontLeftLeg"] target:frontLeftLeg];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-BackLeftLeg"] target:backLeftLeg];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Body"] target:body];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-FrontRightLeg"] target:frontRightLeg];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-BackRightLeg"] target:backRightLeg];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Tail"] target:tail];
	[fall1 addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfHead-Hurt.png"]],
	  [CCDelayTime actionWithDuration:1.9f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfHead-Hurt.png"]],
	  nil
	  ]
			  target:head];
	[fall1 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:2.2f],
					  [CCCallFunc actionWithTarget:self selector:@selector(idle)],
					  nil
					  ]
			  target:self];
	
	BEUAnimation *death1 = [BEUAnimation animationWithName:@"death1"];
	[self addCharacterAnimation:death1];
	[death1 addAction:[animator getAnimationByName:@"Death1-Head"] target:head];
	[death1 addAction:[animator getAnimationByName:@"Death1-FrontLeftLeg"] target:frontLeftLeg];
	[death1 addAction:[animator getAnimationByName:@"Death1-BackLeftLeg"] target:backLeftLeg];
	[death1 addAction:[animator getAnimationByName:@"Death1-Body"] target:body];
	[death1 addAction:[animator getAnimationByName:@"Death1-FrontRightLeg"] target:frontRightLeg];
	[death1 addAction:[animator getAnimationByName:@"Death1-BackRightLeg"] target:backRightLeg];
	[death1 addAction:[animator getAnimationByName:@"Death1-Tail"] target:tail];
	[death1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"WolfHead-Hurt.png"]]
			   target:head];
	[death1 addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:3.0f],
					   [CCCallFunc actionWithTarget:self selector:@selector(kill)],
					   nil
					   ]
			   target:self];
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"initPosition"];
	
}

-(void)idle
{
	if(![currentCharacterAnimation.name isEqualToString:@"idle"])
	{
		ai.enabled = YES;
		canMove = YES;
		canReceiveHit = YES;
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"idle"];
	}
}

-(void)walk
{
	
	if(moveX < movementSpeed*0.55f)
	{
		if(![currentCharacterAnimation.name isEqualToString:@"walk"])
		{
			[self playCharacterAnimationWithName:@"initFrames"];
			[self playCharacterAnimationWithName:@"walk"];
		}
		
	} else {
	
		if(![currentCharacterAnimation.name isEqualToString:@"run"])
		{
			[self playCharacterAnimationWithName:@"initFrames"];
			[self playCharacterAnimationWithName:@"run"];
		}
	}
}


-(BOOL)attack1:(BEUMove *)move
{
	canMove = NO;
	
	[self setFacingRight:(orientToObject.x > self.x)];
	
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"attack1"];
	currentMove = move;
	
	[self applyForceX:directionMultiplier*150.0f];
	[self applyForceY:100.0f];
	
	
	
	
	
	return YES;
}

-(void)attack1Send
{
	
	[[BEUActionsController sharedController] addAction:
	 [[[BEUHitAction alloc] initWithSender:self
								 selector:@selector(receiveHit:)
								 duration:0.05f
								  hitArea:CGRectMake(0, 0, 130, 100)
								   zRange:ccp(-20.0f,20.0f)
								 	power:15.0f
								   xForce:directionMultiplier*100.0f
								   yForce:0.0f
								   zForce:0.0f
								 relative: YES
	  ] autorelease]
	 ];
}

-(void)attack1Complete
{
	[self idle];
	[currentMove completeMove];
}


-(void)hit:(BEUAction *)action
{
	[super hit:action];
	
	canMove = NO;
	ai.enabled = NO;
	BEUHitAction *hit = (BEUHitAction *)action;
	if([hit.type isEqualToString:BEUHitTypeKnockdown])
	{
		[self fall1];
	} else {
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:[NSString stringWithFormat:@"hit%d", (arc4random()%2 +1)]];
	}
	
}

-(void)fall1
{
	canMove = NO;
	canReceiveHit = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"fall1"];
}

-(void)death:(BEUAction *)action
{
	[super death:action];
	
	canMove = NO;
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"death1"];
}

-(void)dealloc
{
	[head release];
	[frontLeftLeg release];
	[backLeftLeg release];
	[body release];
	[frontRightLeg release];
	[backRightLeg release];
	[tail release];
	[wolf release];
	
	[super dealloc];
}

@end
