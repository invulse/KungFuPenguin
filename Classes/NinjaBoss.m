//
//  Eskimo2.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NinjaBoss.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "Effects.h"
#import "BEUAudioController.h"
#import "GameHUD.h"

@implementation NinjaBoss

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	
	movementSpeed = 175.0f;
	
	autoOrient = NO;
	life = 6000.0f;
	totalLife = life;
	vulnerable = NO;
	hitAppliesMoveForces = NO;
	hitCancelsAIBehavior = NO;
	hitCancelsMove = NO;
	hitCancelsMovement = NO;
	damageTillNextDown = 800.0f;
	hitMultiplier = 0.6f;
	
	//drawBoundingBoxes = YES;
	moveArea = CGRectMake(-10.0f,0.0f,20.0f,20.0f);
	hitArea = CGRectMake(-35.0f,0.0f,70.0f,140.0f);
	
	shadowSize = CGSizeMake(95.0f, 30.0f);
	shadowOffset = ccp(-5.0f,5.0f);
	
	ninja = [[BEUSprite alloc] init];
	ninja.anchorPoint = ccp(0.0f,0.0f);
	ninja.position = ccp(20.0f,0.0f);
	
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"NinjaBoss.plist"];
	leftHand = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-LeftHand.png"]];
	rightHand = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-LeftHand.png"]];
	weapon = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-Weapon.png"]];
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-Body.png"]];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-LeftLeg.png"]];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-RightLeg.png"]];
	leftArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-LeftArm.png"]];
	rightArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-RightArm.png"]];
	head = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-Head.png"]];
	
	
	[ninja addChild:rightArm];
	[ninja addChild:rightLeg];
	[ninja addChild:leftLeg];
	[ninja addChild:body];
	[ninja addChild:head];
	[ninja addChild:leftArm];
	[ninja addChild:weapon];
	[ninja addChild:rightHand];
	[ninja addChild:leftHand];
	[self addChild:ninja];
	
	BEUMove *attack1Move = [BEUMove moveWithName:@"attack1"
									   character:self
										   input:nil
										selector:@selector(attack1:)];
	attack1Move.range = 250.0f;
	
	[movesController addMove:attack1Move];
	
	BEUMove *attack2Move = [BEUMove moveWithName:@"attack2" 
									   character:self 
										   input:nil 
										selector:@selector(attack2:)];
	attack2Move.range = 250.0f;
	
	[movesController addMove:attack2Move];
	
	
	BEUMove *slideAttack1Move = [BEUMove moveWithName:@"slideAttack1" 
									   character:self 
										   input:nil 
										selector:@selector(slideAttack1:)];
	slideAttack1Move.range = 300.0f;
	
	[movesController addMove:slideAttack1Move];
	
	BEUMove *slideAttack2Move = [BEUMove moveWithName:@"slideAttack2" 
									   character:self 
										   input:nil 
										selector:@selector(slideAttack2:)];
	slideAttack2Move.range = 400.0f;
	
	[movesController addMove:slideAttack2Move];
	
	
	BEUMove *jumpMove = [BEUMove moveWithName:@"jump" 
									   character:self 
										   input:nil 
										selector:@selector(jump:)];
	jumpMove.range = 400.0f;
	
	[movesController addMove:jumpMove];
	
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"NinjaBoss-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaBoss-LeftHand.png"
							]] target:leftHand];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaBoss-LeftHand.png"
							]] target:rightHand];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaBoss-Weapon.png"
							]] target:weapon];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaBoss-Head.png"
							]] target:head];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaBoss-LeftArm.png"
							]] target:leftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaBoss-Body.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaBoss-RightArm.png"
							]] target:rightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaBoss-LeftLeg.png"
							]] target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"NinjaBoss-RightLeg.png"
							]] target:rightLeg];
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftHand"] target:leftHand];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightHand"] target:rightHand];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Weapon"] target:weapon];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Head"] target:head];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftArm"] target:leftArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightArm"] target:rightArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftLeg"] target:leftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightLeg"] target:rightLeg];
	
	BEUAnimation *idle = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idle];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftHand"] target:leftHand];
	[idle addAction:[animator getAnimationByName:@"Idle-RightHand"] target:rightHand];
	[idle addAction:[animator getAnimationByName:@"Idle-Weapon"] target:weapon];
	[idle addAction:[animator getAnimationByName:@"Idle-Head"] target:head];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftArm"] target:leftArm];
	[idle addAction:[animator getAnimationByName:@"Idle-Body"] target:body];
	[idle addAction:[animator getAnimationByName:@"Idle-RightArm"] target:rightArm];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftLeg"] target:leftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-RightLeg"] target:rightLeg];
	
	
	BEUAnimation *walk = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walk];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftHand"] target:leftHand];
	[walk addAction:[animator getAnimationByName:@"Walk-RightHand"] target:rightHand];
	[walk addAction:[animator getAnimationByName:@"Walk-Weapon"] target:weapon];
	[walk addAction:[animator getAnimationByName:@"Walk-Head"] target:head];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftArm"] target:leftArm];
	[walk addAction:[animator getAnimationByName:@"Walk-Body"] target:body];
	[walk addAction:[animator getAnimationByName:@"Walk-RightArm"] target:rightArm];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftLeg"] target:leftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-RightLeg"] target:rightLeg];
	[walk addAction:[BEUSetFrame actionWithSpriteFrame:
					 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-LeftLegRun.png"]]
												target:leftLeg];
	
	BEUAnimation *attack1 = [BEUAnimation animationWithName:@"attack1"];
	[self addCharacterAnimation:attack1];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftHand"] target:leftHand];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-RightHand"] target:rightHand];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Weapon"] target:weapon];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Head"] target:head];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftArm"] target:leftArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Body"] target:body];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-RightArm"] target:rightArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftLeg"] target:leftLeg];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-RightLeg"] target:rightLeg];
	[attack1 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.33f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Move)],
						[BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES],
						[CCDelayTime actionWithDuration:0.8f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Send)],
						[BEUPlayEffect actionWithSfxName:@"SwordSwing" onlyOne:YES],
						[CCDelayTime actionWithDuration:0.7f],
						[CCCallFunc actionWithTarget:self selector:@selector(attack1Complete)],
						nil
						]
				target:self];
	 
	 BEUAnimation *attack2 = [BEUAnimation animationWithName:@"attack2"];
	 [self addCharacterAnimation:attack2];
	 [attack2 addAction:[animator getAnimationByName:@"Attack2-LeftHand"] target:leftHand];
	 [attack2 addAction:[animator getAnimationByName:@"Attack2-RightHand"] target:rightHand];
	 [attack2 addAction:[animator getAnimationByName:@"Attack2-Weapon"] target:weapon];
	 [attack2 addAction:[animator getAnimationByName:@"Attack2-Head"] target:head];
	 [attack2 addAction:[animator getAnimationByName:@"Attack2-LeftArm"] target:leftArm];
	 [attack2 addAction:[animator getAnimationByName:@"Attack2-Body"] target:body];
	 [attack2 addAction:[animator getAnimationByName:@"Attack2-RightArm"] target:rightArm];
	 [attack2 addAction:[animator getAnimationByName:@"Attack2-LeftLeg"] target:leftLeg];
	 [attack2 addAction:[animator getAnimationByName:@"Attack2-RightLeg"] target:rightLeg];
	 [attack2 addAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:0.4f],
						 [CCCallFunc actionWithTarget:self selector:@selector(attack2Move)],
						 [BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES],
						 [CCDelayTime actionWithDuration:0.6f],
						 [CCCallFunc actionWithTarget:self selector:@selector(attack2Send)],
						 [BEUPlayEffect actionWithSfxName:@"SwordSwing" onlyOne:YES],
						 [CCDelayTime actionWithDuration:0.83f],
						 [CCCallFunc actionWithTarget:self selector:@selector(attack2Complete)],
						 nil
						 ]
				 target:self];
	 
	 
	 BEUAnimation *slideAttack1 = [BEUAnimation animationWithName:@"slideAttack1"];
	 [self addCharacterAnimation:slideAttack1];
	 [slideAttack1 addAction:[animator getAnimationByName:@"SlideAttack1-LeftHand"] target:leftHand];
	 [slideAttack1 addAction:[animator getAnimationByName:@"SlideAttack1-RightHand"] target:rightHand];
	 [slideAttack1 addAction:[animator getAnimationByName:@"SlideAttack1-Weapon"] target:weapon];
	 [slideAttack1 addAction:[animator getAnimationByName:@"SlideAttack1-Head"] target:head];
	 [slideAttack1 addAction:[animator getAnimationByName:@"SlideAttack1-LeftArm"] target:leftArm];
	 [slideAttack1 addAction:[animator getAnimationByName:@"SlideAttack1-Body"] target:body];
	 [slideAttack1 addAction:[animator getAnimationByName:@"SlideAttack1-RightArm"] target:rightArm];
	 [slideAttack1 addAction:[animator getAnimationByName:@"SlideAttack1-LeftLeg"] target:leftLeg];
	 [slideAttack1 addAction:[animator getAnimationByName:@"SlideAttack1-RightLeg"] target:rightLeg];
	 [slideAttack1 addAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:0.7f],
						 [CCCallFunc actionWithTarget:self selector:@selector(slideAttack1Move)],
						 [BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES],
						 [CCDelayTime actionWithDuration:0.066f],
						 [CCCallFunc actionWithTarget:self selector:@selector(slideAttack1Send)],
						 [BEUPlayEffect actionWithSfxName:@"PunchSwing" onlyOne:YES],
						 [CCDelayTime actionWithDuration:0.8f],
						 [CCCallFunc actionWithTarget:self selector:@selector(slideAttack1Complete)],
						 nil
						 ]
				 target:self];
	 
	 BEUAnimation *slideAttack2 = [BEUAnimation animationWithName:@"slideAttack2"];
	 [self addCharacterAnimation:slideAttack2];
	 [slideAttack2 addAction:[animator getAnimationByName:@"SlideAttack2-LeftHand"] target:leftHand];
	 [slideAttack2 addAction:[animator getAnimationByName:@"SlideAttack2-RightHand"] target:rightHand];
	 [slideAttack2 addAction:[animator getAnimationByName:@"SlideAttack2-Weapon"] target:weapon];
	 [slideAttack2 addAction:[animator getAnimationByName:@"SlideAttack2-Head"] target:head];
	 [slideAttack2 addAction:[animator getAnimationByName:@"SlideAttack2-LeftArm"] target:leftArm];
	 [slideAttack2 addAction:[animator getAnimationByName:@"SlideAttack2-Body"] target:body];
	 [slideAttack2 addAction:[animator getAnimationByName:@"SlideAttack2-RightArm"] target:rightArm];
	 [slideAttack2 addAction:[animator getAnimationByName:@"SlideAttack2-LeftLeg"] target:leftLeg];
	 [slideAttack2 addAction:[animator getAnimationByName:@"SlideAttack2-RightLeg"] target:rightLeg];
	 [slideAttack2 addAction:[CCSequence actions:
							  [CCDelayTime actionWithDuration:0.33f],
							  [CCCallFunc actionWithTarget:self selector:@selector(slideAttack2Move)],
							  [BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES],
							  [CCDelayTime actionWithDuration:1.7f],
							  [CCCallFunc actionWithTarget:self selector:@selector(slideAttack2StopMove)],
							  [CCDelayTime actionWithDuration:0.2f],
							  [CCCallFunc actionWithTarget:self selector:@selector(slideAttack2Complete)],
							  nil
							  ]
					  target:self];
	
	
	 BEUAnimation *jumpStart = [BEUAnimation animationWithName:@"jumpStart"];
	 [self addCharacterAnimation:jumpStart];
	 [jumpStart addAction:[animator getAnimationByName:@"JumpStart-LeftHand"] target:leftHand];
	 [jumpStart addAction:[animator getAnimationByName:@"JumpStart-RightHand"] target:rightHand];
	 [jumpStart addAction:[animator getAnimationByName:@"JumpStart-Weapon"] target:weapon];
	 [jumpStart addAction:[animator getAnimationByName:@"JumpStart-Head"] target:head];
	 [jumpStart addAction:[animator getAnimationByName:@"JumpStart-LeftArm"] target:leftArm];
	 [jumpStart addAction:[animator getAnimationByName:@"JumpStart-Body"] target:body];
	 [jumpStart addAction:[animator getAnimationByName:@"JumpStart-RightArm"] target:rightArm];
	 [jumpStart addAction:[animator getAnimationByName:@"JumpStart-LeftLeg"] target:leftLeg];
	 [jumpStart addAction:[animator getAnimationByName:@"JumpStart-RightLeg"] target:rightLeg];
	 [jumpStart addAction:[CCSequence actions:
							  [CCDelayTime actionWithDuration:0.233f],
							  [CCCallFunc actionWithTarget:self selector:@selector(jumpMove)],
							  [BEUPlayEffect actionWithSfxName:@"GenericJump" onlyOne:YES],
							  
							  [CCDelayTime actionWithDuration:0.4f],
						      [CCCallFunc actionWithTarget:self selector:@selector(jumpSmoke)],
							  
								[CCDelayTime actionWithDuration:0.1f],
								[CCCallFunc actionWithTarget:self selector:@selector(jumpWarp)],
								nil
							  ]
					  target:self];
	 
	 BEUAnimation *jumpAttack = [BEUAnimation animationWithName:@"jumpAttack"];
	 [self addCharacterAnimation:jumpAttack];
	 [jumpAttack addAction:[animator getAnimationByName:@"JumpAttack-LeftHand"] target:leftHand];
	 [jumpAttack addAction:[animator getAnimationByName:@"JumpAttack-RightHand"] target:rightHand];
	 [jumpAttack addAction:[animator getAnimationByName:@"JumpAttack-Weapon"] target:weapon];
	 [jumpAttack addAction:[animator getAnimationByName:@"JumpAttack-Head"] target:head];
	 [jumpAttack addAction:[animator getAnimationByName:@"JumpAttack-LeftArm"] target:leftArm];
	 [jumpAttack addAction:[animator getAnimationByName:@"JumpAttack-Body"] target:body];
	 [jumpAttack addAction:[animator getAnimationByName:@"JumpAttack-RightArm"] target:rightArm];
	 [jumpAttack addAction:[animator getAnimationByName:@"JumpAttack-LeftLeg"] target:leftLeg];
	 [jumpAttack addAction:[animator getAnimationByName:@"JumpAttack-RightLeg"] target:rightLeg];
	 [jumpAttack addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.3f],
						   [CCCallFunc actionWithTarget:self selector:@selector(jumpSend)],
						   [BEUPlayEffect actionWithSfxName:@"SwordSwing" onlyOne:YES],
						   [CCDelayTime actionWithDuration:0.6f],
						   [CCCallFunc actionWithTarget:self selector:@selector(jumpComplete)],
						   nil
						   ]
				   target:self];
	 
	 
	 BEUAnimation *downStart = [BEUAnimation animationWithName:@"downStart"];
	 [self addCharacterAnimation:downStart];
	 [downStart addAction:[animator getAnimationByName:@"DownStart-LeftHand"] target:leftHand];
	 [downStart addAction:[animator getAnimationByName:@"DownStart-RightHand"] target:rightHand];
	 [downStart addAction:[animator getAnimationByName:@"DownStart-Weapon"] target:weapon];
	 [downStart addAction:[animator getAnimationByName:@"DownStart-Head"] target:head];
	 [downStart addAction:[animator getAnimationByName:@"DownStart-LeftArm"] target:leftArm];
	 [downStart addAction:[animator getAnimationByName:@"DownStart-Body"] target:body];
	 [downStart addAction:[animator getAnimationByName:@"DownStart-RightArm"] target:rightArm];
	 [downStart addAction:[animator getAnimationByName:@"DownStart-LeftLeg"] target:leftLeg];
	 [downStart addAction:[animator getAnimationByName:@"DownStart-RightLeg"] target:rightLeg];
	 [downStart addAction:[BEUSetFrame actionWithSpriteFrame:
					  [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-HeadHurt.png"]]
												 target:head];
	 [downStart addAction:[CCSequence actions:
							[CCDelayTime actionWithDuration:0.36f],
							[CCCallFunc actionWithTarget:self selector:@selector(downLoop)],
							nil
							]
					target:self];
	 
	 BEUAnimation *downLoop = [BEUAnimation animationWithName:@"downLoop"];
	 [self addCharacterAnimation:downLoop];
	 [downLoop addAction:[animator getAnimationByName:@"DownLoop-LeftHand"] target:leftHand];
	 [downLoop addAction:[animator getAnimationByName:@"DownLoop-RightHand"] target:rightHand];
	 [downLoop addAction:[animator getAnimationByName:@"DownLoop-Weapon"] target:weapon];
	 [downLoop addAction:[animator getAnimationByName:@"DownLoop-Head"] target:head];
	 [downLoop addAction:[animator getAnimationByName:@"DownLoop-LeftArm"] target:leftArm];
	 [downLoop addAction:[animator getAnimationByName:@"DownLoop-Body"] target:body];
	 [downLoop addAction:[animator getAnimationByName:@"DownLoop-RightArm"] target:rightArm];
	 [downLoop addAction:[animator getAnimationByName:@"DownLoop-LeftLeg"] target:leftLeg];
	 [downLoop addAction:[animator getAnimationByName:@"DownLoop-RightLeg"] target:rightLeg];
	 
	 
	 BEUAnimation *downHit1 = [BEUAnimation animationWithName:@"downHit1"];
	 [self addCharacterAnimation:downHit1];
	 [downHit1 addAction:[animator getAnimationByName:@"DownHit1-LeftHand"] target:leftHand];
	 [downHit1 addAction:[animator getAnimationByName:@"DownHit1-RightHand"] target:rightHand];
	 [downHit1 addAction:[animator getAnimationByName:@"DownHit1-Weapon"] target:weapon];
	 [downHit1 addAction:[animator getAnimationByName:@"DownHit1-Head"] target:head];
	 [downHit1 addAction:[animator getAnimationByName:@"DownHit1-LeftArm"] target:leftArm];
	 [downHit1 addAction:[animator getAnimationByName:@"DownHit1-Body"] target:body];
	 [downHit1 addAction:[animator getAnimationByName:@"DownHit1-RightArm"] target:rightArm];
	 [downHit1 addAction:[animator getAnimationByName:@"DownHit1-LeftLeg"] target:leftLeg];
	 [downHit1 addAction:[animator getAnimationByName:@"DownHit1-RightLeg"] target:rightLeg];
	 [downHit1 addAction:[CCSequence actions:
						   [CCDelayTime actionWithDuration:0.3f],
						   [CCCallFunc actionWithTarget:self selector:@selector(downLoop)],
						   nil
						   ]
				   target:self];
	 
	 BEUAnimation *downComplete = [BEUAnimation animationWithName:@"downComplete"];
	 [self addCharacterAnimation:downComplete];
	 [downComplete addAction:[animator getAnimationByName:@"DownComplete-LeftHand"] target:leftHand];
	 [downComplete addAction:[animator getAnimationByName:@"DownComplete-RightHand"] target:rightHand];
	 [downComplete addAction:[animator getAnimationByName:@"DownComplete-Weapon"] target:weapon];
	 [downComplete addAction:[animator getAnimationByName:@"DownComplete-Head"] target:head];
	 [downComplete addAction:[animator getAnimationByName:@"DownComplete-LeftArm"] target:leftArm];
	 [downComplete addAction:[animator getAnimationByName:@"DownComplete-Body"] target:body];
	 [downComplete addAction:[animator getAnimationByName:@"DownComplete-RightArm"] target:rightArm];
	 [downComplete addAction:[animator getAnimationByName:@"DownComplete-LeftLeg"] target:leftLeg];
	 [downComplete addAction:[animator getAnimationByName:@"DownComplete-RightLeg"] target:rightLeg];
	 [downComplete addAction:[BEUSetFrame actionWithSpriteFrame:
							[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-Head.png"]]
													   target:head];
	 [downComplete addAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(downComplete)],
						  nil
						  ]
				  target:self];
	  
	  
	  BEUAnimation *death = [BEUAnimation animationWithName:@"death"];
	  [self addCharacterAnimation:death];
	  [death addAction:[animator getAnimationByName:@"Death-LeftHand"] target:leftHand];
	  [death addAction:[animator getAnimationByName:@"Death-RightHand"] target:rightHand];
	  [death addAction:[animator getAnimationByName:@"Death-Weapon"] target:weapon];
	  [death addAction:[animator getAnimationByName:@"Death-Head"] target:head];
	  [death addAction:[animator getAnimationByName:@"Death-LeftArm"] target:leftArm];
	  [death addAction:[animator getAnimationByName:@"Death-Body"] target:body];
	  [death addAction:[animator getAnimationByName:@"Death-RightArm"] target:rightArm];
	  [death addAction:[animator getAnimationByName:@"Death-LeftLeg"] target:leftLeg];
	  [death addAction:[animator getAnimationByName:@"Death-RightLeg"] target:rightLeg];
	  [death addAction:[BEUSetFrame actionWithSpriteFrame:
							   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"NinjaBoss-HeadDead.png"]]
														  target:head];
	   [death addAction:[CCSequence actions:
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
	
	ai.difficultyMultiplier = 0.35f;
}

-(void)idle
{
	if(![currentCharacterAnimation.name isEqualToString:@"idle"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"idle"];
	}
}

-(void)walk
{
	if(![currentCharacterAnimation.name isEqualToString:@"walk"])
	{
		[self playCharacterAnimationWithName:@"initFrames"];
		[self playCharacterAnimationWithName:@"walk"];
	}
}


-(BOOL)attack1:(BEUMove *)move
{
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"attack1"];
	[self faceObject:orientToObject];
	[movesController setCurrentMove:move];
	return YES;
}

-(void)attack1Move
{
	float maxMoveX = 200.0f;
	float toMoveX = (fabsf(orientToObject.x - x) > maxMoveX) ? maxMoveX : fabsf(orientToObject.x - x);
	[self applyAdjForceX:toMoveX];
	
	[self applyForceY:350.0f];
}

-(void)attack1Send
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.1f
											   hitArea:CGRectMake(0, 0, 90, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:35.0f
												xForce:directionMultiplier*160.0f
												yForce:0.0f
												zForce:0.0f
											  relative: YES
						 ];
	
	hit.type = BEUHitTypeKnockdown;
	
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
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"attack2"];
	[self faceObject:orientToObject];
	[movesController setCurrentMove:move];
	return YES;
}

-(void)attack2Move
{
	float maxMoveX = 200.0f;
	
	float toMoveX = (fabsf(orientToObject.x - x) > maxMoveX) ? maxMoveX : fabsf(orientToObject.x - x);
	
	[self applyAdjForceX:toMoveX];
	[self applyForceY:250.0f];
	
}

-(void)attack2Send
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.1f
											   hitArea:CGRectMake(0, 0, 90, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:32.0f
												xForce:directionMultiplier*130.0f
												yForce:0.0f
												zForce:0.0f
											  relative: YES
						 ];
	hit.type = BEUHitTypeKnockdown;
	
	[[BEUActionsController sharedController] addAction:hit];
}

-(void)attack2Complete
{
	canMove = YES;
	
	[self idle];
	[movesController completeCurrentMove];
}

-(BOOL)slideAttack1:(BEUMove *)move
{
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"slideAttack1"];
	[self faceObject:orientToObject];
	[movesController setCurrentMove:move];
	return YES;
}
   
-(void)slideAttack1Move
{
	
	[self applyAdjForceX:400.0f];
	
}
   
-(void)slideAttack1Send
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.1f
											   hitArea:CGRectMake(0, 0, 90, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:32.0f
												xForce:directionMultiplier*230.0f
												yForce:0.0f
												zForce:0.0f
											  relative: YES
						 ];
	hit.type = BEUHitTypeBlunt;
	
	[[BEUActionsController sharedController] addAction:hit];
}
   
-(void)slideAttack1Complete
{
	canMove = YES;
	
	[self idle];
	[movesController completeCurrentMove];
}

-(BOOL)slideAttack2:(BEUMove *)move
{
	autoAnimate = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"slideAttack2"];
	[self faceObject:orientToObject];
	[movesController setCurrentMove:move];
	return YES;
}

-(void)slideAttack2Move
{
	if(x < orientToObject.x)
	{
		movingAngle = 0.0f;
		movingPercent = 0.8f;
	} else {
		movingAngle = M_PI;
		movingPercent = 0.8f;
	}
	
	[self schedule:@selector(slideAttack2Send) interval:0.26f];
	
}


-(void)slideAttack2Send
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.0f
											   hitArea:CGRectMake(0, 0, 90, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:14.0f
												xForce:directionMultiplier*230.0f
												yForce:0.0f
												zForce:0.0f
											  relative: YES
						 ];
	hit.type = BEUHitTypeImpale;
	[[BEUAudioController sharedController] playSfx:@"SwordSwing" onlyOne:YES];
	[[BEUActionsController sharedController] addAction:hit];
	
	
}

-(void)slideAttack2StopMove
{
	[self unschedule:@selector(slideAttack2Send)];
	movingAngle = 0.0f;
	movingPercent = 0.0f;
}

-(void)slideAttack2Complete
{
	autoAnimate = YES;
	
	[self idle];
	[movesController completeCurrentMove];
}


-(BOOL)jump:(BEUMove *)move
{
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"jumpStart"];
	[self faceObject:orientToObject];
	[movesController setCurrentMove:move];
	return YES;
}

-(void)jumpMove
{
	[self applyForceY:300.0f];
	
}

-(void)jumpSmoke
{
	SmokeExplosion1 *explosion = [[[SmokeExplosion1 alloc] init] autorelease];
	
	explosion.x = x;	
	explosion.y = y+ 60;
	explosion.z = z;
	
	
	[explosion startEffect];
}

-(void)jumpWarp
{
	
	
	if(orientToObject.x < x)
	{
		x = orientToObject.x - 60.0f;
	} else {
		x = orientToObject.x + 60.0f;
	}
	
	[self faceObject:orientToObject];
	
	
	[self playCharacterAnimationWithName:@"jumpAttack"];
	[self applyForceY:-200.0f];
	
	
	
}

-(void)jumpSend
{
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0.1f
											   hitArea:CGRectMake(0, 0, 90, 100)
												zRange:ccp(-30.0f,30.0f)
												 power:38.0f
												xForce:directionMultiplier*100.0f
												yForce:-200.0f
												zForce:0.0f
											  relative: YES
						 ];
	hit.type = BEUHitTypeKnockdown;
	
	[[BEUActionsController sharedController] addAction:hit];
}

-(void)jumpComplete
{
	canMove = YES;
	
	[self idle];
	[movesController completeCurrentMove];
}

-(void)down
{
	[ai cancelCurrentBehavior];
	
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"downStart"];
	canMove = NO;
	ai.enabled = NO;
	vulnerable = YES;
	hitMultiplier = 1.0f;
	//canReceiveHit = NO;
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(downGetUp:) forTarget:self interval:4.0f + CCRANDOM_0_1()*3.0f paused:NO];
	
}

-(void)downLoop
{
	[self playCharacterAnimationWithName:@"downLoop"];
}

-(void)downGetUp:(ccTime)delta
{
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(downGetUp:) forTarget:self];
	vulnerable = NO;
	hitMultiplier = .6f;
	damageTillNextDown = 800;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"downComplete"];
	
}

-(void)downComplete
{
	ai.enabled = YES;
	canMove = YES;
	[self idle];
}
	 
-(void)hit:(BEUAction *)action
{
	[super hit:action];
	
	if(vulnerable)
	{
		
		[head runAction:[CCSequence actions:
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
		[weapon runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		[leftHand runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		[rightHand runAction:[CCSequence actions:
						 [CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
						 [CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
						 nil]];
		
		[self playCharacterAnimationWithName:@"downHit1"];
	} else {
		BEUHitAction *hit = (BEUHitAction *)action;
		BEUCharacter *sender = (BEUCharacter *)action.sender;
		damageTillNextDown -= hit.power;
		if(damageTillNextDown <= 0)
		{
			[self down];
			
		} else {
			
			[ninja runAction:[CCSequence actions:
								  [CCMoveBy actionWithDuration:0.07f position:ccp(sender.directionMultiplier*3.0f,0)],
								  [CCMoveBy actionWithDuration:0.07f position:ccp(sender.directionMultiplier*(-3.0f),0)],							   
								  nil
								  ]];		
		}
	}
	
	[self updateHealthBar];
}

-(void)enableAI
{
	[super enableAI];
	
	healthBar = [[GameHUD sharedGameHUD] addBossBar:@"BossBar-Ninja.png"];
	[self updateHealthBar];
}

-(void)updateHealthBar
{
	[healthBar.bar setPercent:(life/totalLife)];
}

-(void)death:(BEUAction *)action
{
	[super death:action];
	[[BEUAudioController sharedController] playSfx:@"DeathHuman" onlyOne:NO];
	
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(downGetUp:) forTarget:self];
	canMove = NO;
	autoAnimate = NO;
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	[ai cancelCurrentBehavior];
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"death"];
}

-(void)dealloc
{
	[head release];
	[leftArm release];
	[rightArm release];
	[leftLeg release];
	[rightLeg release];
	[body release];
	[ninja release];
	
	[super dealloc];
}

@end
