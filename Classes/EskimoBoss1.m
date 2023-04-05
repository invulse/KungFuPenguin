//
//  EskimoBoss1.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EskimoBoss1.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"
#import "BEUCharacterAIIdleBehavior.h"
#import "BEUAudioController.h"
#import "GameHUD.h"

@implementation EskimoBoss1

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	running = NO;
	jumping = NO;
	checkJump = NO;
	
	hitCancelsMove = NO;
	hitCancelsAIBehavior = NO;
	hitAppliesMoveForces = NO;
	hitCancelsMovement = NO;
	//drawBoundingBoxes = YES;
	
	concurrentHits = 0;
	maxConcurrentHits = maxConcurrentHits = arc4random()%3 + 2;
	
	life = 1400.0f;
	totalLife = life;
	
	moveArea = CGRectMake(-40.0f,0.0f,80.0f,40.0f);
	hitArea = CGRectMake(-65.0f,0.0f,130.0f,220.0f);
	
	
	shadowSize = CGSizeMake(125.0f, 40.0f);
	shadowOffset = ccp(0.0f,10.0f);
	
	eskimo = [[BEUSprite alloc] init];
	eskimo.anchorPoint = ccp(0.0f,0.0f);
	eskimo.position = ccp(150.0f,36.0f);
	
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"EskimoBoss1.plist"];
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1Body.png"]];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1Leg.png"]];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1Leg.png"]];
	leftArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1LeftArm.png"]];
	rightArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1RightArm.png"]];
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1Head.png"]];
	
	
	[eskimo addChild:rightArm];
	[eskimo addChild:rightLeg];
	[eskimo addChild:leftLeg];
	[eskimo addChild:body];
	[eskimo addChild:head];
	[eskimo addChild:leftArm];
	[self addChild:eskimo];
	
	walkSpeed = 70.0f;
	runSpeed = 200.0f;
	movementSpeed = walkSpeed;
	
	[movesController addMove:
	 [BEUMove moveWithName:@"attack1"
				 character:self
					 input:BEUInputTap
				  selector:@selector(attack1:)]
	 ];
	
	BEUMove *jumpMove = [BEUMove moveWithName:@"jump"
									character:self
										input:BEUInputTap
									 selector:@selector(jump:)];
	jumpMove.range = 200.0f;
	
	[movesController addMove:jumpMove];
	
	
	BEUMove *runMove = [BEUMove moveWithName:@"run"
								   character:self
									   input:BEUInputTap
									selector:@selector(run:)];
	runMove.range = 200.0f;
	runMove.interruptible = NO;
	[movesController addMove:runMove];
	
	canMoveThroughObjectWalls = NO;
	
	
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"EskimoBoss1-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"EskimoBoss1Head.png"
							]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"EskimoBoss1LeftArm.png"
							]] target:leftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"EskimoBoss1Body.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"EskimoBoss1RightArm.png"
							]] target:rightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"EskimoBoss1Leg.png"
							]] target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"EskimoBoss1Leg.png"
							]] target:rightLeg];
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"] target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftArm"] target:leftArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightArm"] target:rightArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftLeg"] target:leftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightLeg"] target:rightLeg];
	
	BEUAnimation *idle = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idle];
	[idle addAction:[animator getAnimationByName:@"Idle-Head"] target:head];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftArm"] target:leftArm];
	[idle addAction:[animator getAnimationByName:@"Idle-Body"] target:body];
	[idle addAction:[animator getAnimationByName:@"Idle-RightArm"] target:rightArm];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftLeg"] target:leftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *walkForward = [BEUAnimation animationWithName:@"walkForward"];
	[self addCharacterAnimation:walkForward];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Head"] target:head];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-LeftArm"] target:leftArm];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Body"] target:body];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightArm"] target:rightArm];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-LeftLeg"] target:leftLeg];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightLeg"] target:rightLeg];
	/*[walkForward addAction:[CCRepeatForever actionWithAction:[CCSequence actions:
							[CCDelayTime actionWithDuration:0.633f],
							[CCCallFunc actionWithTarget:self selector:@selector(walkShake)],
							[CCDelayTime actionWithDuration:0.733f],
							[CCCallFunc actionWithTarget:self selector:@selector(walkShake)],
							nil
							]]
					target:self];*/
	
	
	BEUAnimation *walkBackward = [BEUAnimation animationWithName:@"walkBackward"];
	[self addCharacterAnimation:walkBackward];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-Head"] target:head];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-LeftArm"] target:leftArm];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-Body"] target:body];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-RightArm"] target:rightArm];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-LeftLeg"] target:leftLeg];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-RightLeg"] target:rightLeg];
	/*[walkBackward addAction:[CCRepeatForever actionWithAction:[CCSequence actions:
							[CCDelayTime actionWithDuration:0.7f],
							[CCCallFunc actionWithTarget:self selector:@selector(walkShake)],
							[CCDelayTime actionWithDuration:0.633f],
							[CCCallFunc actionWithTarget:self selector:@selector(walkShake)],
							nil
							]]
					target:self];*/
	
	BEUAnimation *attack1 = [BEUAnimation animationWithName:@"attack1"];
	[self addCharacterAnimation:attack1];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Head"] target:head];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftArm"] target:leftArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Body"] target:body];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-RightArm"] target:rightArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftLeg"] target:leftLeg];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-RightLeg"] target:rightLeg];
	[attack1 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.76f],
						[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1LeftArmSwing.png"]],
						[CCDelayTime actionWithDuration:0.5f],
						[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1LeftArm.png"]],
						nil
									]
				target:leftArm];
	[attack1 addAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.93f],
						  [CCCallFunc actionWithTarget:self selector:@selector(attack1Send)],
						  [BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						  [CCDelayTime actionWithDuration:0.47f],
						  [CCCallFunc actionWithTarget:self selector:@selector(attack1Complete)],
						  nil
						  ]
				  target:self];
	
	
	BEUAnimation *jumpStart = [BEUAnimation animationWithName:@"jumpStart"];
	[self addCharacterAnimation:jumpStart];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-Head"] target:head];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-LeftArm"] target:leftArm];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-Body"] target:body];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-RightArm"] target:rightArm];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-LeftLeg"] target:leftLeg];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-RightLeg"] target:rightLeg];
	[jumpStart addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.8f],
						[CCCallFunc actionWithTarget:self selector:@selector(jumpStart)],
						[BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES],
						nil
						]
				target:self];
	
	
	BEUAnimation *jumpLand = [BEUAnimation animationWithName:@"jumpLand"];
	[self addCharacterAnimation:jumpLand];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-Head"] target:head];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-LeftArm"] target:leftArm];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-Body"] target:body];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-RightArm"] target:rightArm];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-LeftLeg"] target:leftLeg];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-RightLeg"] target:rightLeg];
	[jumpLand addAction:[CCSequence actions:
						  [BEUPlayEffect actionWithSfxName:@"HitHeavy" onlyOne:YES],
						  [CCDelayTime actionWithDuration:0.7f],
						  [CCCallFunc actionWithTarget:self selector:@selector(jumpComplete)],
						  nil
						  ]
				  target:self];
	
	
	
	
	
	BEUAnimation *runStart = [BEUAnimation animationWithName:@"runStart"];
	[self addCharacterAnimation:runStart];
	[runStart addAction:[animator getAnimationByName:@"RunStart-Head"] target:head];
	[runStart addAction:[animator getAnimationByName:@"RunStart-LeftArm"] target:leftArm];
	[runStart addAction:[animator getAnimationByName:@"RunStart-Body"] target:body];
	[runStart addAction:[animator getAnimationByName:@"RunStart-RightArm"] target:rightArm];
	[runStart addAction:[animator getAnimationByName:@"RunStart-LeftLeg"] target:leftLeg];
	[runStart addAction:[CCSequence actions:
						 [animator getAnimationByName:@"RunStart-RightLeg"],
						 [CCCallFunc actionWithTarget:self selector:@selector(runSend)],
						 nil
						 ] target:rightLeg];
	/*[runStart addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.36f],
					   
					   nil
					   ]
			   target:self];*/
	
	BEUAnimation *runLoop = [BEUAnimation animationWithName:@"runLoop"];
	[self addCharacterAnimation:runLoop];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-Head"] target:head];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-LeftArm"] target:leftArm];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-Body"] target:body];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-RightArm"] target:rightArm];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-LeftLeg"] target:leftLeg];
	[runLoop addAction:[animator getAnimationByName:@"RunLoop-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *runStop = [BEUAnimation animationWithName:@"runStop"];
	[self addCharacterAnimation:runStop];
	[runStop addAction:[animator getAnimationByName:@"RunStop-Head"] target:head];
	[runStop addAction:[animator getAnimationByName:@"RunStop-LeftArm"] target:leftArm];
	[runStop addAction:[animator getAnimationByName:@"RunStop-Body"] target:body];
	[runStop addAction:[animator getAnimationByName:@"RunStop-RightArm"] target:rightArm];
	[runStop addAction:[animator getAnimationByName:@"RunStop-LeftLeg"] target:leftLeg];
	[runStop addAction:[animator getAnimationByName:@"RunStop-RightLeg"] target:rightLeg];
	[runStop addAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:1.03f],
						 [CCCallFunc actionWithTarget:self selector:@selector(runComplete)],
						 nil
						 ]
				 target:self];
	
		
	BEUAnimation *hit1 = [BEUAnimation animationWithName:@"hit1"];
	[self addCharacterAnimation:hit1];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Head"] target:head];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftArm"] target:leftArm];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-Body"] target:body];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightArm"] target:rightArm];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-LeftLeg"] target:leftLeg];
	[hit1 addAction:[animator getAnimationByName:@"Hit1-RightLeg"] target:rightLeg];
	[hit1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1HeadHurt.png"]]
			 target:head];
	[hit1 addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.66f],
					 [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
					 nil
					 ]
			 target:self];
	
	BEUAnimation *hit2 = [BEUAnimation animationWithName:@"hit2"];
	[self addCharacterAnimation:hit2];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Head"] target:head];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftArm"] target:leftArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Body"] target:body];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightArm"] target:rightArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftLeg"] target:leftLeg];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightLeg"] target:rightLeg];
	[hit2 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1HeadHurt.png"]]
			 target:head];
	[hit2 addAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:0.8f],
					 [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
					 nil
					 ]
			 target:self];
	
	
	
	
	BEUAnimation *death1 = [BEUAnimation animationWithName:@"death1"];
	[self addCharacterAnimation:death1];
	[death1 addAction:[animator getAnimationByName:@"Death-Head"] target:head];
	[death1 addAction:[animator getAnimationByName:@"Death-LeftArm"] target:leftArm];
	[death1 addAction:[animator getAnimationByName:@"Death-Body"] target:body];
	[death1 addAction:[animator getAnimationByName:@"Death-RightArm"] target:rightArm];
	[death1 addAction:[animator getAnimationByName:@"Death-LeftLeg"] target:leftLeg];
	[death1 addAction:[animator getAnimationByName:@"Death-RightLeg"] target:rightLeg];
	[death1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"EskimoBoss1Dead.png"]]
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



-(void)setUpAI
{
	ai = [[BEUCharacterAI alloc] initWithParent:self];
	
	BEUCharacterAIBehavior *moveBranch = [BEUCharacterAIMove behavior];
	//[moveBranch addBehavior:[BEUCharacterAIMoveToTarget behavior]];
	//[moveBranch addBehavior:[BEUCharacterAIMoveAwayFromTarget behavior]];
	[moveBranch addBehavior:[BEUCharacterAIMoveAwayToTargetZ behavior]];
	[ai addBehavior:moveBranch];
	
	BEUCharacterAIBehavior *idleBranch = [BEUCharacterAIIdleBehavior behaviorWithMinTime:0.7f maxTime:1.8f];
	[ai addBehavior:idleBranch];
	
	attackBehavior = [BEUCharacterAIMoveToAndAttack behaviorWithMoves:[movesController moves]];
	attackBehavior.canRunSameMoveAgain = NO;
	attackBehavior.idleAfterAttack = YES;
	attackBehavior.minIdleTime = 0.7f;
	attackBehavior.maxIdleTime = 2.0f;
	BEUCharacterAIBehavior *attackBranch = [BEUCharacterAIAttackBehavior behavior];
	
	[attackBranch addBehavior:attackBehavior];
	[ai addBehavior:attackBranch];
}

-(void)idle
{
	if(![currentCharacterAnimation.name isEqualToString:@"idle"] && !running && !jumping)
	{
		//ai.enabled = YES;
		canMove = YES;
		canReceiveHit = YES;
		
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"idle"];
	}
}

-(void)walk
{
	if(running || jumping) return;
	
	if((moveX > 0.0f && directionMultiplier == 1) || (moveX < 0.0f && directionMultiplier == -1) )
	{
		if(![currentCharacterAnimation.name isEqualToString:@"walkForward"])
		{
			[self playCharacterAnimationWithName:@"initFrames"];
			[self playCharacterAnimationWithName:@"walkForward"];
		}
	} else if( (moveX > 0.0f && directionMultiplier == -1) || (moveX < 0.0f && directionMultiplier == 1) )
	{
		if(![currentCharacterAnimation.name isEqualToString:@"walkBackward"])
		{
			[self playCharacterAnimationWithName:@"initFrames"];
			[self playCharacterAnimationWithName:@"walkBackward"];
		}
	}
}


-(BOOL)attack1:(BEUMove *)move
{
	canMove = NO;
	//canReceiveHit = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"attack1"];
	currentMove = move;
	return YES;
}

-(void)attack1Send
{
	
	[[BEUActionsController sharedController] addAction:
	 [[[BEUHitAction alloc] initWithSender:self
								 selector:@selector(receiveHit:)
								 duration:0.05f
								  hitArea:CGRectMake(0, 0, 100, 100)
								   zRange:ccp(-20.0f,20.0f)
								 	power:18.0f
								   xForce:directionMultiplier*100.0f
								   yForce:0.0f
								   zForce:0.0f
								 relative: YES
	  ] autorelease]
	 ];
}

-(void)attack1Complete
{
	canReceiveHit = YES;
	[self idle];
	[currentMove completeMove];
	currentMove = nil;
}

-(void)hit:(BEUAction *)action
{
	[super hit:action];
	
	[leftLeg runAction:[CCSequence actions:
						[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						nil]];
	[rightLeg runAction:[CCSequence actions:
						[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						nil]];
	[body runAction:[CCSequence actions:
						[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						nil]];
	[leftArm runAction:[CCSequence actions:
						[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						nil]];
	[rightArm runAction:[CCSequence actions:
						[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						nil]];
	[head runAction:[CCSequence actions:
						[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						nil]];
	
	
	[self updateHealthBar];
	
}

-(void)hitComplete
{
	ai.enabled = YES;
	canMove = YES;
	concurrentHits = 0;
	maxConcurrentHits = arc4random()%4 + 4;
	
	[self idle];
}

-(void)death:(BEUAction *)action
{
	[super death:action];
	canMove = NO;
	canReceiveHit = NO;
	
	[[BEUAudioController sharedController] playSfx:@"DeathHuman" onlyOne:NO];
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"death1"];
}

-(BOOL)run:(BEUMove *)move
{
	//NSLog(@"\n---------RUN-----------");
	autoOrient = NO;
	canReceiveHit = YES;
	canMoveThroughObjectWalls = YES;
	running = YES;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"runStart"];
	currentMove = move;
	
	
	runTime = 1.5f + 1.5f*CCRANDOM_0_1();
	runAngle = [BEUMath angleFromPoint:ccp(x,z) toPoint:ccp(orientToObject.x,orientToObject.z)];
	
	return YES;
}

-(void)runSend
{
	
	
	movementSpeed = runSpeed;
	
	movingAngle = runAngle;
	movingPercent = 1.0f;
	
	
	//NSLog(@"\n------ RUN SEND-------\n\nCAN MOVE:%d MOVING ANGLE: %1.2f, MOVING PERCENT: %1.2f \n - AUTO: %@, X: %1.2f, Y: %1.2f \n\n--------",canMove,movingAngle,movingPercent,orientToObject,orientToObject.x,orientToObject.z);
	
	
	
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:runTime],
					 [CCCallFunc actionWithTarget:self selector:@selector(runStop)],
					 nil
					 ]];
	
	[self playCharacterAnimationWithName:@"runLoop"];
	
	BEUHitAction *runAction = [BEUHitAction actionWithSender:self
													selector:@selector(receiveHit:)
													duration:runTime
													 hitArea:hitArea
													  zRange:ccp(-30.0f,30.0f)
													   power:25.0f
													  xForce:200.0f*directionMultiplier
													  yForce:0.0f
													  zForce:0.0f
													relative:YES];
	runAction.type = BEUHitTypeKnockdown;
	//runAction.unblockable = YES;
	[[BEUActionsController sharedController] addAction:runAction];
	
}

-(void)runStop
{
	//NSLog(@"\n-------RUN STOP-------");
	movingAngle = 0.0f;
	movingPercent = 0.0f;
	friction = 100.0f;
	movementSpeed = walkSpeed;
	[self playCharacterAnimationWithName:@"runStop"];
	
	
}

-(void)runComplete
{
	
	
	friction = 500.0f;
	
	
	running = NO;
	canMove = YES;
	autoOrient = YES;
	canMoveThroughObjectWalls = NO;
	//NSLog(@"-----------RUN COMPLETE: %d", autoOrient);
	[self idle];
	
	[currentMove completeMove];
	currentMove = nil;
}

-(BOOL)jump:(BEUMove *)move
{
	//NSLog(@"\n-------JUMP-------");
	//canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	jumping = YES;
	canMove = NO;
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"jumpStart"];
	
	currentMove = move;
	
	return YES;
}

-(void)jumpStart
{
	//NSLog(@"\n-----JUMP START------");
	y = 1.0f;
	moveY = 400.0f + 400.0f*CCRANDOM_0_1();
	moveX = directionMultiplier * 200.0f * CCRANDOM_0_1();
	
	float zMultiplier = (orientToObject.z > z) ? 1.0f : -1.0f;
	
	moveZ = 100.0f * zMultiplier * CCRANDOM_0_1();
	
	checkJump = YES;
}

-(void)jumpCheck
{
	if(y <= 0.0f)[self jumpLand];
}

-(void)jumpLand
{
	//NSLog(@"\n------JUMP LAND------");
	checkJump = NO;
	
	[self playCharacterAnimationWithName:@"jumpLand"];
	
	BEUHitAction *landAction =  [BEUHitAction actionWithSender:self
													  selector:@selector(receiveGroundHit:)
													  duration:0.0f
													   hitArea:CGRectMake(-150.0f, -100.0f, 300.0f, 200.0f)
														zRange:ccp(-100.0f,100.0f)
														 power:28.0f
														xForce:50.0f*directionMultiplier 
														yForce:100.0f 
														zForce:0.0f
													  relative:YES];
	landAction.type = BEUHitTypeKnockdown;
	
	[[BEUActionsController sharedController] addAction:landAction];
	
	[[BEUEnvironment sharedEnvironment] shakeScreenWithRange:5 duration:.5f];
}

-(void)jumpComplete
{
	//NSLog(@"\n------JUMP COMPLETE------");
	canReceiveHit = YES;
	jumping = NO;
	canMove = YES;
	canMoveThroughObjectWalls = NO;
	
	[self idle];
	
	[currentMove completeMove];
	currentMove = nil;
}


-(void)walkShake
{
	[[BEUEnvironment sharedEnvironment] shakeScreenWithRange:1 duration:0.3f];
}

-(void)step:(ccTime)delta
{
	[super step:delta];
	
	if(checkJump)
	{
		[self jumpCheck];
	}
}

-(void)enableAI
{
	[super enableAI];
	
	healthBar = [[GameHUD sharedGameHUD] addBossBar:@"BossBar-Eskimo.png"];
	[self updateHealthBar];
}

-(void)updateHealthBar
{
	[healthBar.bar setPercent:(life/totalLife)];
}

-(void)dealloc
{
	[head release];
	[leftArm release];
	[rightArm release];
	[leftLeg release];
	[rightLeg release];
	[body release];
	[eskimo release];
	
	[super dealloc];
}

@end
