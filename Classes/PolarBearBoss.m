//
//  PolarBearBoss.m
//  BEUEngine
//
//  Created by Chris Mele on 6/15/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "PolarBearBoss.h"
#import "BEUInstantAction.h"
#import "Animator.h"
#import "BEUCharacterAIIdleBehavior.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"
#import "BEUInstantAction.h"
#import "CannonBall1.h"
#import "BEUCharacterMoveAction.h"
#import "GameHUD.h"
#import "BEUAudioController.h"

@implementation PolarBearBoss

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"PolarBearBoss.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CannonBall.plist"];
	
	eskimoLeftArm = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoLeftArm.png"]
					 ];
	eskimoHead = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoHead.png"]
					 ];
	eskimoBody = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoBody.png"]
					 ];
	eskimoRightArm = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoRightArm.png"]
					 ];
	eskimoLeftLeg = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoLeftLeg.png"]
					 ];
	eskimoRightLeg = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoLeftLeg.png"]
					 ];
	frontLeftLeg = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-FrontLeftLeg.png"]
					 ];
	backLeftLeg = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-BackLeftLeg.png"]
					 ];
	head = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Head.png"]
					 ];
	body = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Body.png"]
					 ];
	backRightLeg = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-BackRightLeg.png"]
					 ];
	frontRightLeg = [CCSprite spriteWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-FrontRightLeg.png"]
					 ];
	
	
	
	
	muzzleFlash = [[CCSprite alloc] init];
	
	smoke = [[CCSprite alloc] init];
	
	wind = [[CCSprite alloc] init];
	
	
	[wind addAnimation:[CCAnimation animationWithName:@"windAnimation" 
												delay:0.06f 
											   frames:[NSArray arrayWithObjects:
													   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Wind1.png"],
													   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Wind2.png"],
													   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Wind3.png"],
													   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Wind4.png"],
													   nil
													   ]]];
	
	windAction = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[wind animationByName:@"windAnimation"]]] retain];
	
	polarBear = [[CCSprite alloc] init];
	polarBear.scale = 0.8f;
	polarBear.position = ccp(-70.0f,0.0f);
	
	
	
	[polarBear addChild:frontRightLeg];
	[polarBear addChild:backRightLeg];
	[polarBear addChild:eskimoRightLeg];
	[polarBear addChild:body];
	[polarBear addChild:head];
	[polarBear addChild:backLeftLeg];
	[polarBear addChild:frontLeftLeg];
	[polarBear addChild:eskimoLeftLeg];
	[polarBear addChild:eskimoRightArm];
	[polarBear addChild:eskimoBody];
	[polarBear addChild:eskimoHead];
	[polarBear addChild:eskimoLeftArm];
	[polarBear addChild:muzzleFlash];
	[polarBear addChild:smoke];
	[polarBear addChild:wind];
	[self addChild:polarBear];
	
	
	//Moves
	
	BEUMove *maul1Move = [BEUMove moveWithName:@"maul1"
									 character:self 
										 input:nil 
									  selector:@selector(maul1:)];
	maul1Move.range = 230.0f;
	[movesController addMove:maul1Move];
	
	
	BEUMove *shoot1Move = [BEUMove moveWithName:@"shoot1" 
									  character:self 
										  input:nil 
									   selector:@selector(shoot1:)];
	
	shoot1Move.range = 600.0f;
	shoot1Move.minRange = 200.0f;
	[movesController addMove:shoot1Move];
	
	
	BEUMove *shoot2Move = [BEUMove moveWithName:@"shoot2" 
									  character:self 
										  input:nil 
									   selector:@selector(shoot2:)];
	shoot2Move.range = 500.0f;
	[movesController addMove:shoot2Move];
	
	
	BEUMove *rawrMove = [BEUMove moveWithName:@"rawr" 
									  character:self 
										  input:nil 
									   selector:@selector(rawr:)];
	
	rawrMove.range = 150.0f;
	[movesController addMove:rawrMove];
	
	BEUMove *runMove = [BEUMove moveWithName:@"runMove" 
									character:self 
										input:nil 
									 selector:@selector(run:)];
	
	runMove.range = 700.0f;
	[movesController addMove:runMove];
	
	//Attributes
	
	shadowSize = CGSizeMake(270.0f, 60.0f);
	
	///drawBoundingBoxes = YES;
	hitArea = CGRectMake(-125.0f,0.0f,250.0f,265.0f);
	moveArea = CGRectMake(-100.0f,0.0f,200.0f,30.0f);
	canMoveThroughObjectWalls = NO;
	
	runSpeed = 220.0f;
	walkSpeed = 90.0f;
	
	movementSpeed = walkSpeed;
	autoOrient = NO;
	life = 3000.0f;
	totalLife = life;
	
	vulnerable = NO;
	hitAppliesMoveForces = NO;
	hitCancelsAIBehavior = NO;
	hitCancelsMovement = NO;
	hitCancelsMove = NO;
	damageToNextDown = 600.0f;
	hitMultiplier = 0.65f;
	
}

-(void)setUpAI
{
	ai = [[BEUCharacterAI alloc] initWithParent:self];
	
	/*BEUCharacterAIBehavior *moveBranch = [BEUCharacterAIMove behavior];
	moveBranch.canRunMultipleTimesInARow = NO;
	
	BEUCharacterAIBehavior *moveTo = [BEUCharacterAIMoveToTarget behavior];
	moveTo.canRunMultipleTimesInARow = NO;
	[moveBranch addBehavior:moveTo];*/
	
	BEUCharacterAIBehavior *moveAway = [BEUCharacterAIMoveAwayToTargetZ behavior];
	moveAway.canRunMultipleTimesInARow = NO;
	[ai addBehavior:moveAway];
	
	//[ai addBehavior:moveBranch];
	
	
	ai.difficultyMultiplier = 0.4f;
	
	/*BEUCharacterAIBehavior *idleBranch = [BEUCharacterAIIdleBehavior behaviorWithMinTime:.6f maxTime:1.6f];
	idleBranch.canRunMultipleTimesInARow = NO;
	[ai addBehavior:idleBranch];
	*/
	
	
	
	//BEUCharacterAIAttackBehavior *attackBehavior = [BEUCharacterAIMoveToAndAttack behaviorWithMoves:[movesController moves]];
	BEUCharacterAIAttackBehavior *attackBehavior = [BEUCharacterAIAttackWithMoveInRange behaviorWithMoves:[movesController moves]];
	attackBehavior.canRunMultipleTimesInARow = YES;
	attackBehavior.idleAfterAttack = YES;
	attackBehavior.minIdleTime = 2.0f;
	attackBehavior.maxIdleTime = 4.0f;
	attackBehavior.canRunSameMoveAgain = NO;
	[ai addBehavior:attackBehavior];
}


-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"PolarBearBoss-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoLeftArm.png"]
						   ]
				   target:eskimoLeftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoHead.png"]
						   ]
				   target:eskimoHead];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoBody.png"]
						   ]
				   target:eskimoBody];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoRightArm.png"]
						   ]
				   target:eskimoRightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoRightLeg.png"]
						   ]
				   target:eskimoRightLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-EskimoLeftLeg.png"]
						   ]
				   target:eskimoLeftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Head.png"]
						   ]
				   target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Body.png"]
						   ]
				   target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-FrontRightLeg.png"]
						   ]
				   target:frontRightLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-FrontLeftLeg.png"]
						   ]
				   target:frontLeftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-BackLeftLeg.png"]
						   ]
				   target:backLeftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-BackRightLeg.png"]
						   ]
				   target:backRightLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-MuzzleFlash.png"]
						   ]
				   target:muzzleFlash];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Smoke.png"]
						   ]
				   target:smoke];
	
	
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:smoke];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:muzzleFlash];
	
	
	
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-EskimoLeftArm"]
					 target:eskimoLeftArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-EskimoRightArm"]
					 target:eskimoRightArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-EskimoHead"]
					 target:eskimoHead];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-EskimoBody"]
					 target:eskimoBody];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-EskimoLeftLeg"]
					 target:eskimoLeftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-EskimoRightLeg"]
					 target:eskimoRightLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"]
					 target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-FrontLeftLeg"]
					 target:frontLeftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-BackLeftLeg"]
					 target:backLeftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"]
					 target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-FrontRightLeg"]
					 target:frontRightLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-BackRightLeg"]
					 target:backRightLeg];
	
	BEUAnimation *walk = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walk];
	[walk addAction:[animator getAnimationByName:@"Walk-EskimoLeftArm"]
					 target:eskimoLeftArm];
	[walk addAction:[animator getAnimationByName:@"Walk-EskimoRightArm"]
					 target:eskimoRightArm];
	[walk addAction:[animator getAnimationByName:@"Walk-EskimoHead"]
					 target:eskimoHead];
	[walk addAction:[animator getAnimationByName:@"Walk-EskimoBody"]
					 target:eskimoBody];
	[walk addAction:[animator getAnimationByName:@"Walk-EskimoLeftLeg"]
					 target:eskimoLeftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-EskimoRightLeg"]
					 target:eskimoRightLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-Head"]
					 target:head];
	[walk addAction:[animator getAnimationByName:@"Walk-FrontLeftLeg"]
					 target:frontLeftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-BackLeftLeg"]
					 target:backLeftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-Body"]
					 target:body];
	[walk addAction:[animator getAnimationByName:@"Walk-FrontRightLeg"]
					 target:frontRightLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-BackRightLeg"]
					 target:backRightLeg];
	
	BEUAnimation *idle = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idle];
	[idle addAction:[animator getAnimationByName:@"Idle-EskimoLeftArm"]
			 target:eskimoLeftArm];
	[idle addAction:[animator getAnimationByName:@"Idle-EskimoRightArm"]
			 target:eskimoRightArm];
	[idle addAction:[animator getAnimationByName:@"Idle-EskimoHead"]
			 target:eskimoHead];
	[idle addAction:[animator getAnimationByName:@"Idle-EskimoBody"]
			 target:eskimoBody];
	[idle addAction:[animator getAnimationByName:@"Idle-EskimoLeftLeg"]
			 target:eskimoLeftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-EskimoRightLeg"]
			 target:eskimoRightLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-Head"]
			 target:head];
	[idle addAction:[animator getAnimationByName:@"Idle-FrontLeftLeg"]
			 target:frontLeftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-BackLeftLeg"]
			 target:backLeftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-Body"]
			 target:body];
	[idle addAction:[animator getAnimationByName:@"Idle-FrontRightLeg"]
			 target:frontRightLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-BackRightLeg"]
			 target:backRightLeg];
	
	BEUAnimation *maul1 = [BEUAnimation animationWithName:@"maul1"];
	[self addCharacterAnimation:maul1];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-EskimoLeftArm"]
			 target:eskimoLeftArm];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-EskimoRightArm"]
			 target:eskimoRightArm];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-EskimoHead"]
			 target:eskimoHead];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-EskimoBody"]
			 target:eskimoBody];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-EskimoLeftLeg"]
			 target:eskimoLeftLeg];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-EskimoRightLeg"]
			 target:eskimoRightLeg];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-Head"]
			 target:head];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-FrontLeftLeg"]
			 target:frontLeftLeg];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-BackLeftLeg"]
			 target:backLeftLeg];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-Body"]
			 target:body];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-FrontRightLeg"]
			 target:frontRightLeg];
	[maul1 addAction:[animator getAnimationByName:@"Maul1-BackRightLeg"]
			 target:backRightLeg];
	[maul1 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.73f],
					  [CCCallFunc actionWithTarget:self selector:@selector(maul1Send)],
					  [CCDelayTime actionWithDuration:0.57f],
					  [CCCallFunc actionWithTarget:self selector:@selector(maul1Complete)],
					  nil
					  ] 
			  target:self];
	
	BEUAnimation *shoot1 = [BEUAnimation animationWithName:@"shoot1"];
	[self addCharacterAnimation:shoot1];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-EskimoLeftArm"]
			  target:eskimoLeftArm];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-EskimoRightArm"]
			  target:eskimoRightArm];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-EskimoHead"]
			  target:eskimoHead];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-EskimoBody"]
			  target:eskimoBody];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-EskimoLeftLeg"]
			  target:eskimoLeftLeg];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-EskimoRightLeg"]
			  target:eskimoRightLeg];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-Head"]
			  target:head];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-FrontLeftLeg"]
			  target:frontLeftLeg];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-BackLeftLeg"]
			  target:backLeftLeg];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-Body"]
			  target:body];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-FrontRightLeg"]
			  target:frontRightLeg];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-BackRightLeg"]
			  target:backRightLeg];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-MuzzleFlash"]
			   target:muzzleFlash];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-Smoke"]
			   target:smoke];
	[shoot1 addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.54f],
					   [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-MuzzleFlash.png"]],
					   [CCDelayTime actionWithDuration:0.66f],
					   [BEUSetFrame actionWithSpriteFrame:nil],
					   nil
					   ] 
			   target:muzzleFlash];
	[shoot1 addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.54f],
					   [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Smoke.png"]],
					   [CCDelayTime actionWithDuration:0.66f],
					   [BEUSetFrame actionWithSpriteFrame:nil],
					   nil
					   ] 
			   target:smoke];
	[shoot1 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.54f],
					  [CCCallFunc actionWithTarget:self selector:@selector(shoot1Send)],
					  [CCDelayTime actionWithDuration:0.66f],
					  [CCCallFunc actionWithTarget:self selector:@selector(shoot1Complete)],
					  nil
					  ] 
			  target:self];
	
	
	BEUAnimation *shoot2Start = [BEUAnimation animationWithName:@"shoot2Start"];
	[self addCharacterAnimation:shoot2Start];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-EskimoLeftArm"]
			   target:eskimoLeftArm];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-EskimoRightArm"]
			   target:eskimoRightArm];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-EskimoHead"]
			   target:eskimoHead];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-EskimoBody"]
			   target:eskimoBody];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-EskimoLeftLeg"]
			   target:eskimoLeftLeg];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-EskimoRightLeg"]
			   target:eskimoRightLeg];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-Head"]
			   target:head];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-FrontLeftLeg"]
			   target:frontLeftLeg];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-BackLeftLeg"]
			   target:backLeftLeg];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-Body"]
			   target:body];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-FrontRightLeg"]
			   target:frontRightLeg];
	[shoot2Start addAction:[animator getAnimationByName:@"Shoot2Start-BackRightLeg"]
			   target:backRightLeg];
	[shoot2Start addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.66f],
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot2Shoot)],
					   nil
					   ] 
			   target:self];
	
	BEUAnimation *shoot2Shoot = [BEUAnimation animationWithName:@"shoot2Shoot"];
	[self addCharacterAnimation:shoot2Shoot];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-EskimoLeftArm"]
					target:eskimoLeftArm];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-EskimoRightArm"]
					target:eskimoRightArm];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-EskimoHead"]
					target:eskimoHead];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-EskimoBody"]
					target:eskimoBody];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-EskimoLeftLeg"]
					target:eskimoLeftLeg];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-EskimoRightLeg"]
					target:eskimoRightLeg];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-Head"]
					target:head];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-FrontLeftLeg"]
					target:frontLeftLeg];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-BackLeftLeg"]
					target:backLeftLeg];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-Body"]
					target:body];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-FrontRightLeg"]
					target:frontRightLeg];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-BackRightLeg"]
					target:backRightLeg];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-MuzzleFlash"]
			   target:muzzleFlash];
	[shoot2Shoot addAction:[animator getAnimationByName:@"Shoot2Shoot-Smoke"]
			   target:smoke];
	[shoot2Shoot addAction:[CCSequence actions:
					   [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-MuzzleFlash.png"]],
					   [CCDelayTime actionWithDuration:0.3f],
					   [BEUSetFrame actionWithSpriteFrame:nil],
					   nil
					   ] 
			   target:muzzleFlash];
	[shoot2Shoot addAction:[CCSequence actions:
					   [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Smoke.png"]],
					   [CCDelayTime actionWithDuration:0.3f],
					   [BEUSetFrame actionWithSpriteFrame:nil],
					   nil
					   ] 
			   target:smoke];
	[shoot2Shoot addAction:[CCSequence actions:
							[CCDelayTime actionWithDuration:0.36f],
							[CCCallFunc actionWithTarget:self selector:@selector(shoot2ShootComplete)],
							nil
							] 
					target:self];
	
	BEUAnimation *shoot2End = [BEUAnimation animationWithName:@"shoot2End"];
	[self addCharacterAnimation:shoot2End];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-EskimoLeftArm"]
					target:eskimoLeftArm];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-EskimoRightArm"]
					target:eskimoRightArm];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-EskimoHead"]
					target:eskimoHead];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-EskimoBody"]
					target:eskimoBody];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-EskimoLeftLeg"]
					target:eskimoLeftLeg];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-EskimoRightLeg"]
					target:eskimoRightLeg];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-Head"]
					target:head];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-FrontLeftLeg"]
					target:frontLeftLeg];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-BackLeftLeg"]
					target:backLeftLeg];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-Body"]
					target:body];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-FrontRightLeg"]
					target:frontRightLeg];
	[shoot2End addAction:[animator getAnimationByName:@"Shoot2End-BackRightLeg"]
					target:backRightLeg];
	[shoot2End addAction:[CCSequence actions:
							[CCDelayTime actionWithDuration:0.46f],
							[CCCallFunc actionWithTarget:self selector:@selector(shoot2Complete)],
							nil
							] 
					target:self];
	
	BEUAnimation *down = [BEUAnimation animationWithName:@"down"];
	[self addCharacterAnimation:down];
	[down addAction:[animator getAnimationByName:@"Down-EskimoLeftArm"]
			 target:eskimoLeftArm];
	[down addAction:[animator getAnimationByName:@"Down-EskimoRightArm"]
			 target:eskimoRightArm];
	[down addAction:[animator getAnimationByName:@"Down-EskimoHead"]
			 target:eskimoHead];
	[down addAction:[animator getAnimationByName:@"Down-EskimoBody"]
			 target:eskimoBody];
	[down addAction:[animator getAnimationByName:@"Down-EskimoLeftLeg"]
			 target:eskimoLeftLeg];
	[down addAction:[animator getAnimationByName:@"Down-EskimoRightLeg"]
			 target:eskimoRightLeg];
	[down addAction:[animator getAnimationByName:@"Down-Head"]
			 target:head];
	[down addAction:[animator getAnimationByName:@"Down-FrontLeftLeg"]
			 target:frontLeftLeg];
	[down addAction:[animator getAnimationByName:@"Down-BackLeftLeg"]
			 target:backLeftLeg];
	[down addAction:[animator getAnimationByName:@"Down-Body"]
			 target:body];
	[down addAction:[animator getAnimationByName:@"Down-FrontRightLeg"]
			 target:frontRightLeg];
	[down addAction:[animator getAnimationByName:@"Down-BackRightLeg"]
			 target:backRightLeg];
	[down addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: @"PolarBear-HeadHurt.png"]]
			 target:head];
	[down addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.66f],
					  [CCCallFunc actionWithTarget:self selector:@selector(downComplete)],
					  nil
					  ] 
			  target:self];
	
	
	BEUAnimation *hit1 = [BEUAnimation animationWithName:@"hit1"];
	[self addCharacterAnimation:hit1];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-EskimoLeftArm"]
				  target:eskimoLeftArm];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-EskimoRightArm"]
				  target:eskimoRightArm];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-EskimoHead"]
				  target:eskimoHead];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-EskimoBody"]
				  target:eskimoBody];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-EskimoLeftLeg"]
				  target:eskimoLeftLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-EskimoRightLeg"]
				  target:eskimoRightLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Head"]
				  target:head];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-FrontLeftLeg"]
				  target:frontLeftLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-BackLeftLeg"]
				  target:backLeftLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Body"]
				  target:body];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-FrontRightLeg"]
				  target:frontRightLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-BackRightLeg"]
				  target:backRightLeg];
	
	
	BEUAnimation *hit2 = [BEUAnimation animationWithName:@"hit2"];
	[self addCharacterAnimation:hit2];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-EskimoLeftArm"]
			 target:eskimoLeftArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-EskimoRightArm"]
			 target:eskimoRightArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-EskimoHead"]
			 target:eskimoHead];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-EskimoBody"]
			 target:eskimoBody];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-EskimoLeftLeg"]
			 target:eskimoLeftLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-EskimoRightLeg"]
			 target:eskimoRightLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Head"]
			 target:head];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-FrontLeftLeg"]
			 target:frontLeftLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-BackLeftLeg"]
			 target:backLeftLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Body"]
			 target:body];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-FrontRightLeg"]
			 target:frontRightLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-BackRightLeg"]
			 target:backRightLeg];
	
	
	BEUAnimation *getUp = [BEUAnimation animationWithName:@"getUp"];
	[self addCharacterAnimation:getUp];
	[getUp addAction:[animator getAnimationByName:@"GetUp-EskimoLeftArm"]
			 target:eskimoLeftArm];
	[getUp addAction:[animator getAnimationByName:@"GetUp-EskimoRightArm"]
			 target:eskimoRightArm];
	[getUp addAction:[animator getAnimationByName:@"GetUp-EskimoHead"]
			 target:eskimoHead];
	[getUp addAction:[animator getAnimationByName:@"GetUp-EskimoBody"]
			 target:eskimoBody];
	[getUp addAction:[animator getAnimationByName:@"GetUp-EskimoLeftLeg"]
			 target:eskimoLeftLeg];
	[getUp addAction:[animator getAnimationByName:@"GetUp-EskimoRightLeg"]
			 target:eskimoRightLeg];
	[getUp addAction:[animator getAnimationByName:@"GetUp-Head"]
			 target:head];
	[getUp addAction:[animator getAnimationByName:@"GetUp-FrontLeftLeg"]
			 target:frontLeftLeg];
	[getUp addAction:[animator getAnimationByName:@"GetUp-BackLeftLeg"]
			 target:backLeftLeg];
	[getUp addAction:[animator getAnimationByName:@"GetUp-Body"]
			 target:body];
	[getUp addAction:[animator getAnimationByName:@"GetUp-FrontRightLeg"]
			 target:frontRightLeg];
	[getUp addAction:[animator getAnimationByName:@"GetUp-BackRightLeg"]
			 target:backRightLeg];
	[getUp addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: @"PolarBear-Head.png"]]
			 target:head];
	[getUp addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.36f],
					 [CCCallFunc actionWithTarget:self selector:@selector(getUpComplete)],
					 nil
					 ] 
			 target:self];
	
	BEUAnimation *death = [BEUAnimation animationWithName:@"death"];
	[self addCharacterAnimation:death];
	[death addAction:[animator getAnimationByName:@"Death-EskimoLeftArm"]
			 target:eskimoLeftArm];
	[death addAction:[animator getAnimationByName:@"Death-EskimoRightArm"]
			 target:eskimoRightArm];
	[death addAction:[animator getAnimationByName:@"Death-EskimoHead"]
			 target:eskimoHead];
	[death addAction:[animator getAnimationByName:@"Death-EskimoBody"]
			 target:eskimoBody];
	[death addAction:[animator getAnimationByName:@"Death-EskimoLeftLeg"]
			 target:eskimoLeftLeg];
	[death addAction:[animator getAnimationByName:@"Death-EskimoRightLeg"]
			 target:eskimoRightLeg];
	[death addAction:[animator getAnimationByName:@"Death-Head"]
			 target:head];
	[death addAction:[animator getAnimationByName:@"Death-FrontLeftLeg"]
			 target:frontLeftLeg];
	[death addAction:[animator getAnimationByName:@"Death-BackLeftLeg"]
			 target:backLeftLeg];
	[death addAction:[animator getAnimationByName:@"Death-Body"]
			 target:body];
	[death addAction:[animator getAnimationByName:@"Death-FrontRightLeg"]
			 target:frontRightLeg];
	[death addAction:[animator getAnimationByName:@"Death-BackRightLeg"]
			 target:backRightLeg];
	[death addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:3.5f],
					 [CCCallFunc actionWithTarget:self selector:@selector(kill)],
					 nil
					 ] 
			 target:self];
	
	BEUAnimation *death2 = [BEUAnimation animationWithName:@"death2"];
	[self addCharacterAnimation:death2];
	[death2 addAction:[animator getAnimationByName:@"Death2-EskimoLeftArm"]
			  target:eskimoLeftArm];
	[death2 addAction:[animator getAnimationByName:@"Death2-EskimoRightArm"]
			  target:eskimoRightArm];
	[death2 addAction:[animator getAnimationByName:@"Death2-EskimoHead"]
			  target:eskimoHead];
	[death2 addAction:[animator getAnimationByName:@"Death2-EskimoBody"]
			  target:eskimoBody];
	[death2 addAction:[animator getAnimationByName:@"Death2-EskimoLeftLeg"]
			  target:eskimoLeftLeg];
	[death2 addAction:[animator getAnimationByName:@"Death2-EskimoRightLeg"]
			  target:eskimoRightLeg];
	[death2 addAction:[animator getAnimationByName:@"Death2-Head"]
			  target:head];
	[death2 addAction:[animator getAnimationByName:@"Death2-FrontLeftLeg"]
			  target:frontLeftLeg];
	[death2 addAction:[animator getAnimationByName:@"Death2-BackLeftLeg"]
			  target:backLeftLeg];
	[death2 addAction:[animator getAnimationByName:@"Death2-Body"]
			  target:body];
	[death2 addAction:[animator getAnimationByName:@"Death2-FrontRightLeg"]
			  target:frontRightLeg];
	[death2 addAction:[animator getAnimationByName:@"Death2-BackRightLeg"]
			  target:backRightLeg];
	[death2 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:3.5f],
					  [CCCallFunc actionWithTarget:self selector:@selector(kill)],
					  nil
					  ] 
			  target:self];
	
	
	
	BEUAnimation *rawr = [BEUAnimation animationWithName:@"rawr"];
	[self addCharacterAnimation:rawr];
	[rawr addAction:[animator getAnimationByName:@"Rawr-EskimoLeftArm"]
			   target:eskimoLeftArm];
	[rawr addAction:[animator getAnimationByName:@"Rawr-EskimoRightArm"]
			   target:eskimoRightArm];
	[rawr addAction:[animator getAnimationByName:@"Rawr-EskimoHead"]
			   target:eskimoHead];
	[rawr addAction:[animator getAnimationByName:@"Rawr-EskimoBody"]
			   target:eskimoBody];
	[rawr addAction:[animator getAnimationByName:@"Rawr-EskimoLeftLeg"]
			   target:eskimoLeftLeg];
	[rawr addAction:[animator getAnimationByName:@"Rawr-EskimoRightLeg"]
			   target:eskimoRightLeg];
	[rawr addAction:[animator getAnimationByName:@"Rawr-Head"]
			   target:head];
	[rawr addAction:[animator getAnimationByName:@"Rawr-FrontLeftLeg"]
			   target:frontLeftLeg];
	[rawr addAction:[animator getAnimationByName:@"Rawr-BackLeftLeg"]
			   target:backLeftLeg];
	[rawr addAction:[animator getAnimationByName:@"Rawr-Body"]
			   target:body];
	[rawr addAction:[animator getAnimationByName:@"Rawr-FrontRightLeg"]
			   target:frontRightLeg];
	[rawr addAction:[animator getAnimationByName:@"Rawr-BackRightLeg"]
			   target:backRightLeg];
	[rawr addAction:[animator getAnimationByName:@"Rawr-Wind"]
			 target:wind];
	
	[rawr addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.5f],
					   [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-HeadBlow.png"]],
					   nil
					   ] 
			   target:head];
	
	[rawr addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.5f],
					   [CCCallFunc actionWithTarget:self selector:@selector(rawrSend)],
					   nil
					   ] 
			   target:self];
	
	
	
	BEUAnimation *rawrEnd = [BEUAnimation animationWithName:@"rawrEnd"];
	[self addCharacterAnimation:rawrEnd];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-EskimoLeftArm"]
			 target:eskimoLeftArm];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-EskimoRightArm"]
			 target:eskimoRightArm];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-EskimoHead"]
			 target:eskimoHead];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-EskimoBody"]
			 target:eskimoBody];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-EskimoLeftLeg"]
			 target:eskimoLeftLeg];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-EskimoRightLeg"]
			 target:eskimoRightLeg];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-Head"]
			 target:head];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-FrontLeftLeg"]
			 target:frontLeftLeg];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-BackLeftLeg"]
			 target:backLeftLeg];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-Body"]
			 target:body];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-FrontRightLeg"]
			 target:frontRightLeg];
	[rawrEnd addAction:[animator getAnimationByName:@"RawrEnd-BackRightLeg"]
			 target:backRightLeg];
	
	[rawrEnd addAction:
					 [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Head.png"]]
					 
			 target:head];
	
	[rawrEnd addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.47f],
					 [CCCallFunc actionWithTarget:self selector:@selector(rawrComplete)],
					 nil
					 ] 
			 target:self];
	
	
	BEUAnimation *runStart = [BEUAnimation animationWithName:@"runStart"];
	[self addCharacterAnimation:runStart];
	[runStart addAction:[animator getAnimationByName:@"RunStart-EskimoLeftArm"]
			  target:eskimoLeftArm];
	[runStart addAction:[animator getAnimationByName:@"RunStart-EskimoRightArm"]
			  target:eskimoRightArm];
	[runStart addAction:[animator getAnimationByName:@"RunStart-EskimoHead"]
			  target:eskimoHead];
	[runStart addAction:[animator getAnimationByName:@"RunStart-EskimoBody"]
			  target:eskimoBody];
	[runStart addAction:[animator getAnimationByName:@"RunStart-EskimoLeftLeg"]
			  target:eskimoLeftLeg];
	[runStart addAction:[animator getAnimationByName:@"RunStart-EskimoRightLeg"]
			  target:eskimoRightLeg];
	[runStart addAction:[animator getAnimationByName:@"RunStart-Head"]
			  target:head];
	[runStart addAction:[animator getAnimationByName:@"RunStart-FrontLeftLeg"]
			  target:frontLeftLeg];
	[runStart addAction:[animator getAnimationByName:@"RunStart-BackLeftLeg"]
			  target:backLeftLeg];
	[runStart addAction:[animator getAnimationByName:@"RunStart-Body"]
			  target:body];
	[runStart addAction:[animator getAnimationByName:@"RunStart-FrontRightLeg"]
			  target:frontRightLeg];
	[runStart addAction:[animator getAnimationByName:@"RunStart-BackRightLeg"]
			  target:backRightLeg];
	[runStart addAction:
	 [CCSequence actions:
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-HeadBite.png"]],
	  [CCDelayTime actionWithDuration:1.0f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"PolarBear-Head.png"]],
	  nil
	  ]
				 target:head];
	
	[runStart addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:1.0f],
					  	 [CCCallFunc actionWithTarget:self selector:@selector(runMove)],
					  [CCDelayTime actionWithDuration:0.4f],
					  [CCCallFunc actionWithTarget:self selector:@selector(runLoop)],
					  nil
					  ] 
			  target:self];
	
	BEUAnimation *runLoop = [BEUAnimation animationWithName:@"runLoop"];
	[self addCharacterAnimation:runLoop];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-EskimoLeftArm"]
				 target:eskimoLeftArm];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-EskimoRightArm"]
				 target:eskimoRightArm];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-EskimoHead"]
				 target:eskimoHead];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-EskimoBody"]
				 target:eskimoBody];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-EskimoLeftLeg"]
				 target:eskimoLeftLeg];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-EskimoRightLeg"]
				 target:eskimoRightLeg];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-Head"]
				 target:head];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-FrontLeftLeg"]
				 target:frontLeftLeg];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-BackLeftLeg"]
				 target:backLeftLeg];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-Body"]
				 target:body];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-FrontRightLeg"]
				 target:frontRightLeg];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-BackRightLeg"]
				 target:backRightLeg];
	
	
	BEUAnimation *runEnd = [BEUAnimation animationWithName:@"runEnd"];
	[self addCharacterAnimation:runEnd];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-EskimoLeftArm"]
				 target:eskimoLeftArm];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-EskimoRightArm"]
				 target:eskimoRightArm];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-EskimoHead"]
				 target:eskimoHead];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-EskimoBody"]
				 target:eskimoBody];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-EskimoLeftLeg"]
				 target:eskimoLeftLeg];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-EskimoRightLeg"]
				 target:eskimoRightLeg];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-Head"]
				 target:head];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-FrontLeftLeg"]
				 target:frontLeftLeg];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-BackLeftLeg"]
				 target:backLeftLeg];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-Body"]
				 target:body];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-FrontRightLeg"]
				 target:frontRightLeg];
	[runEnd addAction:[animator getAnimationByName:@"RunEnd-BackRightLeg"]
				 target:backRightLeg];
	[runEnd addAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:0.86f],
						 [CCCallFunc actionWithTarget:self selector:@selector(runComplete)],
						 nil
						 ] 
				 target:self];
	
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"initPosition"];
	
}


-(void)walk
{
	if(![currentCharacterAnimation.name isEqualToString:@"walk"])
	{
		state = BEUCharacterStateMoving;
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walk"];
	}
}

-(void)idle
{
	if(![currentCharacterAnimation.name isEqualToString:@"idle"])
	{
		state = BEUCharacterStateIdle;
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"idle"];
	}
}

-(BOOL)maul1:(BEUMove *)move
{
	state = BEUCharacterStateAttacking;
	canMove = NO;
	[movesController setCurrentMove:move];
	[self faceObject:orientToObject];
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"maul1"];
	
	return YES;
}

-(void)maul1Send
{
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self 
													selector:@selector(receiveHit:) 
													duration:0.3f 
													 hitArea:CGRectMake(0,0,235,160) 
													  zRange:ccp(-30.0f,30.0f)
													   power:20 
													  xForce:directionMultiplier*270.0f 
													  yForce:0
													  zForce:0 
													relative:YES];
	hitAction.type = BEUHitTypeKnockdown;
	[[BEUActionsController sharedController] addAction:hitAction];
}

-(void)maul1Complete
{
	[movesController completeCurrentMove];
	canMove = YES;
	[self idle];
}

-(BOOL)shoot1:(BEUMove *)move
{
	state = BEUCharacterStateAttacking;
	canMove = NO;
	[movesController setCurrentMove:move];
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"shoot1"];
	[self faceObject:orientToObject];
	
	
	
	return YES;
}

-(void)shoot1Send
{
	CannonBall1 *cannonBall = [CannonBall1 projectileWithPower:20.0f weight:30.0f fromCharacter:self];
	cannonBall.x = x + directionMultiplier*140;
	cannonBall.y = 208*.8;
	cannonBall.z = z;
	cannonBall.affectedByGravity = YES;
	//[cannonBall moveWithAngle:0.0f magnitude:directionMultiplier*280.0f];
	
	float g = [BEUObjectController sharedController].gravity;
	float t = .5f;
	
	CGRect targetArea;
	
	float minDist = 200;
	float maxDist = 500;
	if(directionMultiplier < 0)
	{
		targetArea = CGRectMake(x - maxDist,z-300,maxDist-minDist,600);
	} else {
		targetArea = CGRectMake(x + minDist,z-300,maxDist-minDist,600);
	}
	
	
	float toX = orientToObject.x;
	if(!CGRectContainsPoint(targetArea, ccp(toX,z)))
	{
		toX = targetArea.origin.x + targetArea.size.width*CCRANDOM_0_1();
		
	}
	
	//NSLog(@"SHOOTING TARGET AREA: %@ TOX: %1.2f",NSStringFromCGRect(targetArea),toX);
	[[BEUAudioController sharedController] playSfx:@"GrenadeLaunch" onlyOne:YES];
	
	float toMoveX = ((toX-cannonBall.x)-20 + 40*CCRANDOM_0_1())/t;
	
	
	cannonBall.moveX = toMoveX;
	cannonBall.moveY = ((orientToObject.y-cannonBall.y) + .5*g*powf(t, 2))/t;	
	
	
	[[BEUObjectController sharedController] addObject:cannonBall];
}

-(void)shoot1Complete
{
	canMove = YES;
	[movesController completeCurrentMove];
	[self idle];
}

-(BOOL)shoot2:(BEUMove *)move
{
	state = BEUCharacterStateAttacking;
	toShoot = 5 + arc4random()%5;
	
	canMove = NO;
	
	[movesController setCurrentMove:move];
	[self faceObject:orientToObject];
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"shoot2Start"];
	return YES;
}

-(void)shoot2Shoot
{
	CannonBall1 *cannonBall = [CannonBall1 projectileWithPower:20.0f weight:30.0f fromCharacter:self];
	cannonBall.x = x;
	cannonBall.y = 220;
	cannonBall.z = z;
	
	float g = [BEUObjectController sharedController].gravity;
	float t = 2.0f;
	
	float toX = orientToObject.x - 50 + 100*CCRANDOM_0_1();
	float toZ = orientToObject.z - 50 + 100*CCRANDOM_0_1();
	cannonBall.moveX = (toX-cannonBall.x)/t;
	cannonBall.moveZ = (toZ-cannonBall.z)/t;
	cannonBall.moveY = ((orientToObject.y-cannonBall.y) + .5*g*powf(t, 2))/t;	
	
	[[BEUObjectController sharedController] addObject:cannonBall];
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"shoot2Shoot"];
	
	[[BEUAudioController sharedController] playSfx:@"GrenadeLaunch" onlyOne:YES];
}

-(void)shoot2ShootComplete
{
	toShoot--;
	if(toShoot == 0)
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"shoot2End"];
	} else {
		[self shoot2Shoot];
	}
}

-(void)shoot2Complete
{
	canMove = YES;
	[movesController completeCurrentMove];
	[self idle];
}

-(void)down
{
	//stop wind if its going
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(rawrEnd:) forTarget:self];
	[wind stopAction:windAction];
	[wind setDisplayFrame:nil];
	
	[ai cancelCurrentBehavior];
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"down"];
	canMove = NO;
	ai.enabled = NO;
	vulnerable = YES;
	hitMultiplier = 1.4f;
	canReceiveHit = NO;
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(getUp:) forTarget:self interval:4.0f + CCRANDOM_0_1()*3.0f paused:NO];
	
}

-(void)downComplete
{
	canReceiveHit = YES;
}

-(void)getUp:(ccTime)delta
{
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(getUp:) forTarget:self];
	vulnerable = NO;
	hitMultiplier = .6f;
	damageToNextDown = 600.0f;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"getUp"];
}

-(void)getUpComplete
{
	ai.enabled = YES;
	canMove = YES;
	[self idle];
}


-(BOOL)rawr:(BEUMove *)move
{
	state = BEUCharacterStateAttacking;
	
	canMove = NO;
	
	[movesController setCurrentMove:move];
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"rawr"];
	[self faceObject:orientToObject];
	
	return YES;
}

-(void)rawrSend
{
	[wind runAction:windAction];
	float time = (1.5f + (1.5f)*CCRANDOM_0_1());
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(rawrEnd:) forTarget:self interval:time paused:NO];
	
	BEUHitAction *hitAction = [BEUHitAction actionWithSender:self 
													selector:@selector(receiveHit:) 
													duration:time 
													 hitArea:CGRectMake(0,0,500,160) 
													  zRange:ccp(-40.0f,40.0f)
													   power:0 
													  xForce:directionMultiplier*300.0f 
													  yForce:0
													  zForce:0 
													relative:YES];
	hitAction.type = BEUHitTypeForce;
	hitAction.oncePerObject = NO;
	[[BEUActionsController sharedController] addAction:hitAction];
	
}

-(void)rawrEnd:(ccTime)delta
{
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(rawrEnd:) forTarget:self];
	[wind stopAction:windAction];
	[wind setDisplayFrame:nil];
	[self playCharacterAnimationWithName:@"rawrEnd"];
	
}

-(void)rawrComplete
{
	[movesController completeCurrentMove];
	
	canMove = YES;
	
	[self idle];
}

-(BOOL)run:(BEUMove *)move
{
	state = BEUCharacterStateAttacking;
	
	autoAnimate = NO;
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	[movesController setCurrentMove:move];
	
	[self faceObject:orientToObject];
	
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"runStart"];
	
	
	
	
	
	angleToCharacter = [BEUMath angleFromPoint:ccp(x,z) toPoint:ccp(orientToObject.x,orientToObject.z)];
	
	
	float maxAngle = CC_DEGREES_TO_RADIANS(30);
	
	if(angleToCharacter > maxAngle && angleToCharacter < CC_DEGREES_TO_RADIANS(90))
	{
		angleToCharacter = maxAngle;
	} else if(angleToCharacter > CC_DEGREES_TO_RADIANS(180)-maxAngle && angleToCharacter < CC_DEGREES_TO_RADIANS(180))
	{
		angleToCharacter = CC_DEGREES_TO_RADIANS(180)-maxAngle;
	} else if(angleToCharacter < CC_DEGREES_TO_RADIANS(360)-maxAngle && angleToCharacter > CC_DEGREES_TO_RADIANS(270))
	{
		angleToCharacter = CC_DEGREES_TO_RADIANS(360)-maxAngle;
	} else if(angleToCharacter > CC_DEGREES_TO_RADIANS(180)+maxAngle && angleToCharacter < CC_DEGREES_TO_RADIANS(270))
	{
		angleToCharacter = CC_DEGREES_TO_RADIANS(180)+maxAngle;
	}
	
	return YES;
}

-(void)runMove
{
	movementSpeed = runSpeed;
	
	
	
	movingAngle = angleToCharacter;
	movingPercent = 1.0f;
	
	float minRunTime = (ccpDistance(ccp(x,z), ccp(orientToObject.x,orientToObject.z)) + 100)/movementSpeed ;
	
	float runTime = minRunTime + 1.0f + 1.5f*CCRANDOM_0_1();
	
	//runTime = (runTime<minRunTime) ? minRunTime : runTime;
	
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:runTime],
					 [CCCallFunc actionWithTarget:self selector:@selector(runEnd)],
					 nil
					 ]];
	
	
	BEUHitAction *runAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:runTime
													 hitArea:hitArea
													  zRange:ccp(-30.0f,30.0f)
													   power:20.0f
													  xForce:0
													  yForce:0.0f
													  zForce:0.0f
													relative:YES];
	runAction.oncePerObject = NO;
	runAction.type = BEUHitTypeKnockdown;
	//runAction.unblockable = YES;
	
	[[BEUActionsController sharedController] addAction:runAction];
}

-(void)runLoop
{
	[self playCharacterAnimationWithName:@"runLoop"];
}

-(void)runEnd
{
	movingPercent = 0.0f;
	[self playCharacterAnimationWithName:@"runEnd"];
}

-(void)runComplete
{
	canMoveThroughObjectWalls = NO;
	movementSpeed = walkSpeed;
	autoAnimate = YES;
	canReceiveHit = YES;
	[movesController completeCurrentMove];
	[self idle];
}

-(void)hit:(BEUAction *)action
{
	[super hit:action];
	
	
	if(vulnerable)
	{
		
		[frontLeftLeg runAction:[CCSequence actions:
							[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
							[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
							nil]];
		[frontRightLeg runAction:[CCSequence actions:
							 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
							 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
							 nil]];
		[body runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		[backLeftLeg runAction:[CCSequence actions:
							[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
							[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
							nil]];
		[backRightLeg runAction:[CCSequence actions:
							 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
							 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
							 nil]];
		[head runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		
		
		[eskimoHead runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		[eskimoBody runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		[eskimoLeftArm runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		[eskimoRightArm runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		[eskimoLeftLeg runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		[eskimoRightLeg runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		
		
		[self playCharacterAnimationWithName:[NSString stringWithFormat:@"hit%d", (arc4random()%2 +1)]];
	} else {
		BEUHitAction *hit = (BEUHitAction *)action;
		BEUCharacter *sender = (BEUCharacter *)action.sender;
		damageToNextDown -= hit.power;
		if(damageToNextDown <= 0)
		{
			damageToNextDown = 600.0f;
			[self down];
			
		} else {
		
			[polarBear runAction:[CCSequence actions:
								   [CCMoveBy actionWithDuration:0.07f position:ccp(sender.directionMultiplier*3.0f,0)],
								   [CCMoveBy actionWithDuration:0.07f position:ccp(sender.directionMultiplier*(-3.0f),0)],							   
								  nil
								  ]];		
		}
	}
	
	[self updateHealthBar];
	
}

-(void)death:(BEUAction *)action
{
	[super death:action];
	
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(getUp:) forTarget:self];
	
	ai.enabled = NO;
	autoAnimate = NO;
	canMove = NO;
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	[self playCharacterAnimationWithName:@"initFrames"];
	if(vulnerable)
	{
		[self playCharacterAnimationWithName:@"death2"];
	} else {
		[self playCharacterAnimationWithName:@"death"];
	}
}

-(void)step:(ccTime)delta
{
	[super step:delta];
	
	
}

-(void)enableAI
{
	[super enableAI];
	
	healthBar = [[GameHUD sharedGameHUD] addBossBar:@"BossBar-PolarBear.png"];
	[self updateHealthBar];
}

-(void)updateHealthBar
{
	[healthBar.bar setPercent:(life/totalLife)];
}

-(void)dealloc
{
	[eskimoHead release];
	[eskimoBody release];
	[eskimoLeftArm release];
	[eskimoRightArm release];
	[eskimoLeftLeg release];
	[eskimoRightLeg release];
	[head release];
	[body release];
	[frontLeftLeg release];
	[backLeftLeg release];
	[frontRightLeg release];
	[backRightLeg release];
	[super dealloc];
}


@end
