//
//  SecurityGaurd2.m
//  BEUEngine
//
//  Created by Chris Mele on 8/6/10.
//  Copyright 2010 Invulse. All rights reserved.
//

#import "SecurityGaurd2.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "BEUAudioController.h"

@implementation SecurityGaurd2

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	life = 300.0f;
	totalLife = life;
	
	gaurdMovementSpeed = 80.0f;
	normalMovementSpeed = 115.0f;
	movementSpeed = normalMovementSpeed;
	
	
	//drawBoundingBoxes = YES;
	
	directionalWalking = YES;
	
	normalMoveArea = CGRectMake(-30.0f,0.0f,60.0f,20.0f);
	gaurdMoveArea = CGRectMake(-30.0f,0.0f,100.0f,20.0f);
	moveArea = normalMoveArea;
	hitArea = CGRectMake(-35.0f,0.0f,70.0f,140.0f);
	
	
	shadowSize = CGSizeMake(95.0f, 30.0f);
	shadowOffset = ccp(-5.0f,5.0f);
	
	securityGaurd = [[BEUSprite alloc] init];
	securityGaurd.anchorPoint = ccp(0.0f,0.0f);
	securityGaurd.position = ccp(34.0f,0.0f);
	
	gaurdOrigin = securityGaurd.position;
	
	minCoinDrop = 6;
	maxCoinDrop = 12;
	coinDropChance = .8;
	
	healthDropChance = .15;
	minHealthDrop = 20;
	maxHealthDrop = 40;
	
	gaurding = NO;
	minGaurdTime = 10.0f;
	maxGaurdTime = 20.0f;
	
	
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"SecurityGaurd2.plist"];
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-Body.png"]];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-LeftLeg.png"]];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-RightLeg.png"]];
	leftArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-LeftArm.png"]];
	rightArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-RightArm.png"]];
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-Head.png"]];
	
	
	[securityGaurd addChild:rightArm];
	[securityGaurd addChild:rightLeg];
	[securityGaurd addChild:leftLeg];
	[securityGaurd addChild:body];
	[securityGaurd addChild:head];
	[securityGaurd addChild:leftArm];
	[self addChild:securityGaurd];
	
	attack1Move = [[BEUMove moveWithName:@"attack1"
									   character:self
										   input:nil
										selector:@selector(attack1:)] retain];
	attack1Move.range = 145.0f;
	
	[movesController addMove:attack1Move];
	
	attack2Move = [[BEUMove moveWithName:@"attack2" 
									   character:self 
										   input:nil 
										selector:@selector(attack2:)] retain];
	attack2Move.range = 145.0f;
	
	[movesController addMove:attack2Move];
	
	gaurdAttack1Move = [[BEUMove moveWithName:@"gaurdAttack1"
									   character:self
										   input:nil
										selector:@selector(gaurdAttack1:)] retain];
	gaurdAttack1Move.range = 145.0f;
	
	//[movesController addMove:gaurdAttack1Move];
	
	gaurdAttack2Move = [[BEUMove moveWithName:@"gaurdAttack2" 
									   character:self 
										   input:nil 
										selector:@selector(gaurdAttack2:)] retain];
	gaurdAttack2Move.range = 145.0f;
	
	//[movesController addMove:gaurdAttack2Move];
	
	
	startGaurdMove = [[BEUMove moveWithName:@"startGaurd" 
									  character:self
										  input:nil
									   selector:@selector(startGaurd:)] retain];
	startGaurdMove.range = 400.0f;
	[movesController addMove:startGaurdMove];
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"SecurityGaurd2-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-Head.png"
							]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-LeftArm.png"
							]] target:leftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-Body.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-RightArm.png"
							]] target:rightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-LeftLeg.png"
							]] target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-RightLeg.png"
							]] target:rightLeg];
	
	BEUAnimation *gaurdInitFrames = [BEUAnimation animationWithName:@"gaurdInitFrames"];
	[self addCharacterAnimation:gaurdInitFrames];
	[gaurdInitFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-Head.png"
							]] target:head];
	[gaurdInitFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-LeftArm.png"
							]] target:leftArm];
	[gaurdInitFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-Body.png"
							]] target:body];
	[gaurdInitFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-RightArmGaurd.png"
							]] target:rightArm];
	[gaurdInitFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-LeftLeg.png"
							]] target:leftLeg];
	[gaurdInitFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"SecurityGaurd2-RightLeg.png"
							]] target:rightLeg];
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"] target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftArm"] target:leftArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightArm"] target:rightArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftLeg"] target:leftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightLeg"] target:rightLeg];
	
	
	
	BEUAnimation *gaurdInitPosition = [BEUAnimation animationWithName:@"gaurdInitPosition"];
	[self addCharacterAnimation:gaurdInitPosition];
	[gaurdInitPosition addAction:[animator getAnimationByName:@"GaurdInitPosition-Head"] target:head];
	[gaurdInitPosition addAction:[animator getAnimationByName:@"GaurdInitPosition-LeftArm"] target:leftArm];
	[gaurdInitPosition addAction:[animator getAnimationByName:@"GaurdInitPosition-Body"] target:body];
	[gaurdInitPosition addAction:[animator getAnimationByName:@"GaurdInitPosition-RightArm"] target:rightArm];
	[gaurdInitPosition addAction:[animator getAnimationByName:@"GaurdInitPosition-LeftLeg"] target:leftLeg];
	[gaurdInitPosition addAction:[animator getAnimationByName:@"GaurdInitPosition-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *idle = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idle];
	[idle addAction:[animator getAnimationByName:@"Idle-Head"] target:head];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftArm"] target:leftArm];
	[idle addAction:[animator getAnimationByName:@"Idle-Body"] target:body];
	[idle addAction:[animator getAnimationByName:@"Idle-RightArm"] target:rightArm];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftLeg"] target:leftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-RightLeg"] target:rightLeg];
	
	BEUAnimation *gaurdIdle = [BEUAnimation animationWithName:@"gaurdIdle"];
	[self addCharacterAnimation:gaurdIdle];
	[gaurdIdle addAction:[animator getAnimationByName:@"GaurdIdle-Head"] target:head];
	[gaurdIdle addAction:[animator getAnimationByName:@"GaurdIdle-LeftArm"] target:leftArm];
	[gaurdIdle addAction:[animator getAnimationByName:@"GaurdIdle-Body"] target:body];
	[gaurdIdle addAction:[animator getAnimationByName:@"GaurdIdle-RightArm"] target:rightArm];
	[gaurdIdle addAction:[animator getAnimationByName:@"GaurdIdle-LeftLeg"] target:leftLeg];
	[gaurdIdle addAction:[animator getAnimationByName:@"GaurdIdle-RightLeg"] target:rightLeg];
	
	
	/*BEUAnimation *walk = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walk];
	[walk addAction:[animator getAnimationByName:@"Walk-Head"] target:head];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftArm"] target:leftArm];
	[walk addAction:[animator getAnimationByName:@"Walk-Body"] target:body];
	[walk addAction:[animator getAnimationByName:@"Walk-RightArm"] target:rightArm];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftLeg"] target:leftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-RightLeg"] target:rightLeg];*/
	
	BEUAnimation *walkForwardStart = [BEUAnimation animationWithName:@"walkForwardStart"];
	[self addCharacterAnimation:walkForwardStart];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-Head"] target:head];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-LeftArm"] target:leftArm];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-Body"] target:body];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-RightArm"] target:rightArm];
	[walkForwardStart addAction:[animator getAnimationByName:@"WalkForwardStart-LeftLeg"] target:leftLeg];
	[walkForwardStart addAction:[CCSequence actions:
								 [animator getAnimationByName:@"WalkForwardStart-RightLeg"],
								 [CCCallFunc actionWithTarget:self selector:@selector(walkForwardStart)],
								 nil
								 ]
						 target:rightLeg];
	
	
	BEUAnimation *walkForward = [BEUAnimation animationWithName:@"walkForward"];
	[self addCharacterAnimation:walkForward];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Head"] target:head];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-LeftArm"] target:leftArm];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-Body"] target:body];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightArm"] target:rightArm];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-LeftLeg"] target:leftLeg];
	[walkForward addAction:[animator getAnimationByName:@"WalkForward-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *walkBackwardStart = [BEUAnimation animationWithName:@"walkBackwardStart"];
	[self addCharacterAnimation:walkBackwardStart];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-Head"] target:head];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-LeftArm"] target:leftArm];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-Body"] target:body];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-RightArm"] target:rightArm];
	[walkBackwardStart addAction:[animator getAnimationByName:@"WalkBackwardStart-LeftLeg"] target:leftLeg];
	[walkBackwardStart addAction:[CCSequence actions:
								  [animator getAnimationByName:@"WalkBackwardStart-RightLeg"],
								  [CCCallFunc actionWithTarget:self selector:@selector(walkBackwardStart)],
								  nil
								  ]
						  target:rightLeg];
	
	
	BEUAnimation *walkBackward = [BEUAnimation animationWithName:@"walkBackward"];
	[self addCharacterAnimation:walkBackward];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-Head"] target:head];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-LeftArm"] target:leftArm];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-Body"] target:body];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-RightArm"] target:rightArm];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-LeftLeg"] target:leftLeg];
	[walkBackward addAction:[animator getAnimationByName:@"WalkBackward-RightLeg"] target:rightLeg];
	
	BEUAnimation *gaurdWalkForwardStart = [BEUAnimation animationWithName:@"gaurdWalkForwardStart"];
	[self addCharacterAnimation:gaurdWalkForwardStart];
	[gaurdWalkForwardStart addAction:[animator getAnimationByName:@"GaurdWalkForwardStart-Head"] target:head];
	[gaurdWalkForwardStart addAction:[animator getAnimationByName:@"GaurdWalkForwardStart-LeftArm"] target:leftArm];
	[gaurdWalkForwardStart addAction:[animator getAnimationByName:@"GaurdWalkForwardStart-Body"] target:body];
	[gaurdWalkForwardStart addAction:[animator getAnimationByName:@"GaurdWalkForwardStart-RightArm"] target:rightArm];
	[gaurdWalkForwardStart addAction:[animator getAnimationByName:@"GaurdWalkForwardStart-LeftLeg"] target:leftLeg];
	[gaurdWalkForwardStart addAction:[CCSequence actions:
								 [animator getAnimationByName:@"GaurdWalkForwardStart-RightLeg"],
								 [CCCallFunc actionWithTarget:self selector:@selector(walkForwardStart)],
								 nil
								 ]
						 target:rightLeg];
	
	
	BEUAnimation *gaurdWalkForward = [BEUAnimation animationWithName:@"gaurdWalkForward"];
	[self addCharacterAnimation:gaurdWalkForward];
	[gaurdWalkForward addAction:[animator getAnimationByName:@"GaurdWalkForward-Head"] target:head];
	[gaurdWalkForward addAction:[animator getAnimationByName:@"GaurdWalkForward-LeftArm"] target:leftArm];
	[gaurdWalkForward addAction:[animator getAnimationByName:@"GaurdWalkForward-Body"] target:body];
	[gaurdWalkForward addAction:[animator getAnimationByName:@"GaurdWalkForward-RightArm"] target:rightArm];
	[gaurdWalkForward addAction:[animator getAnimationByName:@"GaurdWalkForward-LeftLeg"] target:leftLeg];
	[gaurdWalkForward addAction:[animator getAnimationByName:@"GaurdWalkForward-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *gaurdWalkBackwardStart = [BEUAnimation animationWithName:@"gaurdWalkBackwardStart"];
	[self addCharacterAnimation:gaurdWalkBackwardStart];
	[gaurdWalkBackwardStart addAction:[animator getAnimationByName:@"GaurdWalkBackwardStart-Head"] target:head];
	[gaurdWalkBackwardStart addAction:[animator getAnimationByName:@"GaurdWalkBackwardStart-LeftArm"] target:leftArm];
	[gaurdWalkBackwardStart addAction:[animator getAnimationByName:@"GaurdWalkBackwardStart-Body"] target:body];
	[gaurdWalkBackwardStart addAction:[animator getAnimationByName:@"GaurdWalkBackwardStart-RightArm"] target:rightArm];
	[gaurdWalkBackwardStart addAction:[animator getAnimationByName:@"GaurdWalkBackwardStart-LeftLeg"] target:leftLeg];
	[gaurdWalkBackwardStart addAction:[CCSequence actions:
								  [animator getAnimationByName:@"GaurdWalkBackwardStart-RightLeg"],
								  [CCCallFunc actionWithTarget:self selector:@selector(walkBackwardStart)],
								  nil
								  ]
						  target:rightLeg];
	
	
	BEUAnimation *gaurdWalkBackward = [BEUAnimation animationWithName:@"gaurdWalkBackward"];
	[self addCharacterAnimation:gaurdWalkBackward];
	[gaurdWalkBackward addAction:[animator getAnimationByName:@"GaurdWalkBackward-Head"] target:head];
	[gaurdWalkBackward addAction:[animator getAnimationByName:@"GaurdWalkBackward-LeftArm"] target:leftArm];
	[gaurdWalkBackward addAction:[animator getAnimationByName:@"GaurdWalkBackward-Body"] target:body];
	[gaurdWalkBackward addAction:[animator getAnimationByName:@"GaurdWalkBackward-RightArm"] target:rightArm];
	[gaurdWalkBackward addAction:[animator getAnimationByName:@"GaurdWalkBackward-LeftLeg"] target:leftLeg];
	[gaurdWalkBackward addAction:[animator getAnimationByName:@"GaurdWalkBackward-RightLeg"] target:rightLeg];
	
	
	/*BEUAnimation *gaurdWalk = [BEUAnimation animationWithName:@"gaurdWalk"];
	[self addCharacterAnimation:gaurdWalk];
	[gaurdWalk addAction:[animator getAnimationByName:@"GaurdWalk-Head"] target:head];
	[gaurdWalk addAction:[animator getAnimationByName:@"GaurdWalk-LeftArm"] target:leftArm];
	[gaurdWalk addAction:[animator getAnimationByName:@"GaurdWalk-Body"] target:body];
	[gaurdWalk addAction:[animator getAnimationByName:@"GaurdWalk-RightArm"] target:rightArm];
	[gaurdWalk addAction:[animator getAnimationByName:@"GaurdWalk-LeftLeg"] target:leftLeg];
	[gaurdWalk addAction:[animator getAnimationByName:@"GaurdWalk-RightLeg"] target:rightLeg];*/
	
	BEUAnimation *attack1 = [BEUAnimation animationWithName:@"attack1"];
	[self addCharacterAnimation:attack1];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Head"] target:head];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftArm"] target:leftArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Body"] target:body];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-RightArm"] target:rightArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftLeg"] target:leftLeg];
	[attack1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Attack1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(attack1Complete)],
	  nil
	  ]
				target:rightLeg];
	[attack1 addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.86f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-LeftArmSwing.png"]],
	  nil
	  ]
				target:leftArm];
	
	
	[attack1 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.86f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Send)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						nil
						]
				target:self];
	
	BEUAnimation *gaurdAttack1 = [BEUAnimation animationWithName:@"gaurdAttack1"];
	[self addCharacterAnimation:gaurdAttack1];
	[gaurdAttack1 addAction:[animator getAnimationByName:@"GaurdAttack1-Head"] target:head];
	[gaurdAttack1 addAction:[animator getAnimationByName:@"GaurdAttack1-LeftArm"] target:leftArm];
	[gaurdAttack1 addAction:[animator getAnimationByName:@"GaurdAttack1-Body"] target:body];
	[gaurdAttack1 addAction:[animator getAnimationByName:@"GaurdAttack1-RightArm"] target:rightArm];
	[gaurdAttack1 addAction:[animator getAnimationByName:@"GaurdAttack1-LeftLeg"] target:leftLeg];
	[gaurdAttack1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"GaurdAttack1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(gaurdAttack1Complete)],
	  nil
	  ]
				target:rightLeg];
	[gaurdAttack1 addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.9f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-LeftArmSwing.png"]],
	  nil
	  ]
				target:leftArm];
	
	
	[gaurdAttack1 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.9f],
						[CCCallFunc actionWithTarget:self selector:@selector(gaurdAttack1Send)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						nil
						]
				target:self];
	
	BEUAnimation *attack2 = [BEUAnimation animationWithName:@"attack2"];
	[self addCharacterAnimation:attack2];
	[attack2 addAction:[animator getAnimationByName:@"Attack2-Head"] target:head];
	[attack2 addAction:[animator getAnimationByName:@"Attack2-LeftArm"] target:leftArm];
	[attack2 addAction:[animator getAnimationByName:@"Attack2-Body"] target:body];
	[attack2 addAction:[animator getAnimationByName:@"Attack2-RightArm"] target:rightArm];
	[attack2 addAction:[animator getAnimationByName:@"Attack2-LeftLeg"] target:leftLeg];
	[attack2 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Attack2-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(attack2Complete)],
	  nil
	  ] target:rightLeg];
	[attack2 addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:0.7f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-LeftArmSwing.png"]],
	  [CCDelayTime actionWithDuration:0.2f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-LeftArm.png"]],
	  [CCDelayTime actionWithDuration:0.66f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-LeftArmSwing.png"]],
	  
	  nil
	  ]
				target:leftArm];
	
	[attack2 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.83f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack2Send)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						[CCDelayTime actionWithDuration:0.73f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack2Send)],
						[BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],						
						nil
						]
				target:self];
	
	BEUAnimation *gaurdAttack2 = [BEUAnimation animationWithName:@"gaurdAttack2"];
	[self addCharacterAnimation:gaurdAttack2];
	[gaurdAttack2 addAction:[animator getAnimationByName:@"GaurdAttack2-Head"] target:head];
	[gaurdAttack2 addAction:[animator getAnimationByName:@"GaurdAttack2-LeftArm"] target:leftArm];
	[gaurdAttack2 addAction:[animator getAnimationByName:@"GaurdAttack2-Body"] target:body];
	[gaurdAttack2 addAction:[animator getAnimationByName:@"GaurdAttack2-RightArm"] target:rightArm];
	[gaurdAttack2 addAction:[animator getAnimationByName:@"GaurdAttack2-LeftLeg"] target:leftLeg];
	[gaurdAttack2 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"GaurdAttack2-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(gaurdAttack2Complete)],
	  nil
	  ]
					 target:rightLeg];
	[gaurdAttack2 addAction:
	 [CCSequence actions:
	  [CCDelayTime actionWithDuration:.95f],
	  [BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"SecurityGaurd2-LeftArmSwing.png"]],
	  nil
	  ]
					 target:leftArm];
	
	
	[gaurdAttack2 addAction:[CCSequence actions:
							 [CCDelayTime actionWithDuration:1.0f],
							 [CCCallFunc actionWithTarget:self selector:@selector(gaurdAttack2Send)],
							 [BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
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
	[hit1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Hit1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
	  nil
	  ] target:rightLeg];
	
	
	
	BEUAnimation *hit2 = [BEUAnimation animationWithName:@"hit2"];
	[self addCharacterAnimation:hit2];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Head"] target:head];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftArm"] target:leftArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-Body"] target:body];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-RightArm"] target:rightArm];
	[hit2 addAction:[animator getAnimationByName:@"Hit2-LeftLeg"] target:leftLeg];
	[hit2 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Hit2-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
	  nil
	  ] target:rightLeg];
	
	
	BEUAnimation *fall1 = [BEUAnimation animationWithName:@"fall1"];
	[self addCharacterAnimation:fall1];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Head"] target:head];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftArm"] target:leftArm];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-Body"] target:body];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-RightArm"] target:rightArm];
	[fall1 addAction:[animator getAnimationByName:@"Fall1-LeftLeg"] target:leftLeg];
	[fall1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Fall1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(hitComplete)],
	  nil
	  ] target:rightLeg];
	
	
	
	
	BEUAnimation *death1 = [BEUAnimation animationWithName:@"death1"];
	[self addCharacterAnimation:death1];
	[death1 addAction:[animator getAnimationByName:@"Death1-Head"] target:head];
	[death1 addAction:[animator getAnimationByName:@"Death1-LeftArm"] target:leftArm];
	[death1 addAction:[animator getAnimationByName:@"Death1-Body"] target:body];
	[death1 addAction:[animator getAnimationByName:@"Death1-RightArm"] target:rightArm];
	[death1 addAction:[animator getAnimationByName:@"Death1-LeftLeg"] target:leftLeg];
	[death1 addAction:[animator getAnimationByName:@"Death1-RightLeg"] target:rightLeg];
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
	[super setUpAI];
	
	ai.difficultyMultiplier = 0.25f;
}

-(void)idle
{
	if(!gaurding && ![currentCharacterAnimation.name isEqualToString:@"idle"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"idle"];
	} else if(gaurding && ![currentCharacterAnimation.name isEqualToString:@"gaurdIdle"])
	{
		[self playCharacterAnimationWithName:@"gaurdInitFrames"];
		[self playCharacterAnimationWithName:@"gaurdIdle"];
	}
}

-(void)walk
{
	if(!gaurding && ![currentCharacterAnimation.name isEqualToString:@"walk"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walk"];
	} else if(gaurding && ![currentCharacterAnimation.name isEqualToString:@"gaurdWalk"])
	{
		[self playCharacterAnimationWithName:@"gaurdInitFrames"];
		[self playCharacterAnimationWithName:@"gaurdWalk"];
	}
}

-(void)walkForward
{
	if(!gaurding && ![currentCharacterAnimation.name isEqualToString:@"walkForward"] && ![currentCharacterAnimation.name isEqualToString:@"walkForwardStart"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walkForwardStart"];
	} else if(gaurding && ![currentCharacterAnimation.name isEqualToString:@"gaurdWalkForward"] && ![currentCharacterAnimation.name isEqualToString:@"gaurdWalkForwardStart"])
	{
		[self playCharacterAnimationWithName:@"gaurdInitFrames"];
		[self playCharacterAnimationWithName:@"gaurdWalkForwardStart"];
	}
}

-(void)walkForwardStart
{
	if(!gaurding)
	{
		[self playCharacterAnimationWithName:@"walkForward"];
	} else {
		[self playCharacterAnimationWithName:@"gaurdWalkForward"];
	}
}

-(void)walkBackward
{
	if(!gaurding && ![currentCharacterAnimation.name isEqualToString:@"walkBackward"] && ![currentCharacterAnimation.name isEqualToString:@"walkBackwardStart"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walkBackwardStart"];
	} else if(gaurding && ![currentCharacterAnimation.name isEqualToString:@"gaurdWalkBackward"] && ![currentCharacterAnimation.name isEqualToString:@"gaurdWalkBackwardStart"])
	{
		[self playCharacterAnimationWithName:@"gaurdInitFrames"];
		[self playCharacterAnimationWithName:@"gaurdWalkBackwardStart"];
	}
}

-(void)walkBackwardStart
{
	if(!gaurding)
	{
		[self playCharacterAnimationWithName:@"walkBackward"];
	} else {
		[self playCharacterAnimationWithName:@"gaurdWalkBackward"];
	}
}


-(BOOL)attack1:(BEUMove *)move
{
	if(gaurding) return NO;
	
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"attack1"];
	[movesController setCurrentMove:move];
	return YES;
}


-(void)attack1Send
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.1f
											   hitArea:CGRectMake(77, 0, 120, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:37
												xForce:directionMultiplier*160.0f
												yForce:0.0f
												zForce:0.0f
											  relative: YES
						 ];
	
	hit.type = BEUHitTypeBlunt;
	
	
	[[BEUActionsController sharedController] addAction:hit];
}

-(void)attack1Complete
{
	canMove = YES;
	
	[self idle];
	[movesController completeCurrentMove];
}

-(BOOL)attack2:(BEUMove *)move
{
	if(gaurding) return NO;
	
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"attack2"];
	[movesController setCurrentMove:move];
	return YES;
}

-(void)attack2Send
{
	[self applyAdjForceX:140.0f];
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.1f
											   hitArea:CGRectMake(0, 0, 160, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:30
												xForce:directionMultiplier*50.0f
												yForce:0.0f
												zForce:0.0f
											  relative: YES
						 ];
	hit.type = BEUHitTypeBlunt;
	
	
	[[BEUActionsController sharedController] addAction:hit];
}

-(void)attack2Complete
{
	canMove = YES;
	
	[self idle];
	[movesController completeCurrentMove];
}

-(BOOL)gaurdAttack1:(BEUMove *)move
{
	if(!gaurding) return NO;
	
	canMove = NO;
	[self playCharacterAnimationWithName:@"gaurdInitFrames"];
	[self playCharacterAnimationWithName:@"gaurdAttack1"];
	[movesController setCurrentMove:move];
	return YES;
}

-(void)gaurdAttack1Send
{
	[self applyAdjForceX:140.0f];
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.1f
											   hitArea:CGRectMake(0, 0, 160, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:20
												xForce:directionMultiplier*50.0f
												yForce:0.0f
												zForce:0.0f
											  relative: YES
						 ];
	hit.type = BEUHitTypeBlunt;
	
	
	[[BEUActionsController sharedController] addAction:hit];
}

-(void)gaurdAttack1Complete
{
	canMove = YES;
	
	[self idle];
	[movesController completeCurrentMove];
}

-(BOOL)gaurdAttack2:(BEUMove *)move
{
	if(!gaurding) return NO;
	
	canMove = NO;
	[self playCharacterAnimationWithName:@"gaurdInitFrames"];
	[self playCharacterAnimationWithName:@"gaurdAttack2"];
	[movesController setCurrentMove:move];
	return YES;
}

-(void)gaurdAttack2Send
{
	[self applyAdjForceX:140.0f];
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.1f
											   hitArea:CGRectMake(0, 0, 160, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:20
												xForce:directionMultiplier*50.0f
												yForce:0.0f
												zForce:0.0f
											  relative: YES
						 ];
	hit.type = BEUHitTypeBlunt;
	
	
	[[BEUActionsController sharedController] addAction:hit];
}

-(void)gaurdAttack2Complete
{
	canMove = YES;
	
	[self idle];
	[movesController completeCurrentMove];
}


-(BOOL)startGaurd:(BEUMove *)move
{
	if(gaurding) return NO;
	
	movementSpeed = gaurdMovementSpeed;
	moveArea = gaurdMoveArea;
	gaurding = YES;
	
	//hitMultiplier = 0.0f;
	[movesController setCurrentMove:move];
	
	//add gaurd moves
	[movesController addMove:gaurdAttack1Move];
	[movesController addMove:gaurdAttack2Move];
	
	//remove nongaurd moves
	[movesController removeMove:attack1Move];
	[movesController removeMove:attack2Move];
	[movesController removeMove:startGaurdMove];
	
	
	[self schedule:@selector(endGaurd:) interval:(minGaurdTime + (maxGaurdTime-minGaurdTime)*CCRANDOM_0_1())];
	[self schedule:@selector(completeGaurd:)];
	//return NO;
	return YES;
}

-(void)completeGaurd:(ccTime)delta
{
	[self unschedule:@selector(completeGaurd:)];
	[movesController completeCurrentMove];
}

-(void)endGaurd:(ccTime)delta
{
	
	
	//remove gaurd moves
	[movesController removeMove:gaurdAttack1Move];
	[movesController removeMove:gaurdAttack2Move];
	
	//add nongaurd moves
	[movesController addMove:attack1Move];
	[movesController addMove:attack2Move];
	[movesController addMove:startGaurdMove];
	
	[self unschedule:@selector(endGaurd:)];
	movementSpeed = normalMovementSpeed;
	moveArea = normalMoveArea;
	gaurding = NO;
}

-(BOOL)receiveHit:(BEUAction *)action
{
	if(!gaurding || ( gaurding && (
								   (orientToObject.x < x && facingRight_)
								   || (orientToObject.x > x && !facingRight_)
								   ))
	   )
	{
		return [super receiveHit:action];
	} else if( !((BEUCharacter *)action.sender).enemy ){
		[securityGaurd runAction:
		 [CCSequence actions:
		  [CCMoveTo actionWithDuration:0.07f position:ccp(gaurdOrigin.x+(((BEUCharacter *)action.sender).directionMultiplier*3.0f),gaurdOrigin.y)],
		  [CCMoveTo actionWithDuration:0.07f position:gaurdOrigin],
		  nil
		  ]
		 ];
		[[BEUAudioController sharedController] playSfx:@"HitPlastic" onlyOne:NO];
		
		return NO;
	}
	
	
	return NO;
}

-(void)hit:(BEUAction *)action
{
	
	[super hit:action];
	
	[ai cancelCurrentBehavior];
	[movesController cancelCurrentMove];
	
	if(gaurding)
	{
		[self endGaurd:0];
	}
	
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
	[[BEUAudioController sharedController] playSfx:@"DeathHuman" onlyOne:NO];
	[ai cancelCurrentBehavior];
	[movesController cancelCurrentMove];
	canMove = NO;
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"death1"];
}

-(void)dealloc
{
	[head release];
	[leftArm release];
	[rightArm release];
	[leftLeg release];
	[rightLeg release];
	[body release];
	[securityGaurd release];
	
	[attack1Move release];
	[attack2Move release];
	[gaurdAttack1Move release];
	[gaurdAttack2Move release];
	[startGaurdMove release];
	
	[super dealloc];
}

@end