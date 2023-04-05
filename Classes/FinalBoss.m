//
//  Eskimo2.m
//  BEUEngine
//
//  Created by Chris on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"
#import "Animator.h"
#import "BEUInstantAction.h"
#import "BEUAudioController.h"

#import "BEUCharacterAIIdleBehavior.h"
#import "BEUCharacterAIMoveBehavior.h"
#import "BEUCharacterAIAttackBehavior.h"

#import "FinalBoss.h"
#import "Effects.h"
#import "BEUGameManager.h"
#import "GameHUD.h"

@implementation FinalBoss

@synthesize legsDestroyed;

-(void)setUpCharacter
{
	[super setUpCharacter];
	
	shotCount = 0;
	
	floatSpeed = 150.0f;
	walkSpeed = 60.0f;
	
	totalLife = life = 9000.0f;
	neededLegsDamage = 4500.0;

	movementSpeed = walkSpeed;
	//drawBoundingBoxes = YES;
	moveArea = CGRectMake(-70.0f,-10.0f,165.0f,60.0f);
	hitArea = CGRectMake(-70.0f,-10.0f,165.0f,375.0f);
	hitCancelsMove = NO;
	hitAppliesMoveForces = NO;
	hitCancelsAIBehavior = NO;
	hitCancelsMovement = NO;
	autoOrient = NO;
	
	
	shadowSize = CGSizeMake(180.0f, 60.0f);
	shadowOffset = ccp(-5.0f,5.0f);
	
	boss = [[BEUSprite alloc] init];
	boss.anchorPoint = ccp(0.0f,0.0f);
	boss.position = ccp(105.0f,-20.0f);
	
	minCoinDrop = 100;
	maxCoinDrop = 300;
	coinDropChance = 1;
	
	healthDropChance = 0;
	
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"FinalBoss.plist"];
	
	body = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Body.png"]];
	leftLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Leg.png"]];
	rightLeg = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Leg.png"]];
	leftArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LeftArm1.png"]];
	rightArm = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-RightArm1.png"]];
	
	gun = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Gun1.png"]];
	
	laserStart = [[CCSprite alloc] init];
	laser = [[CCSprite alloc] init];
	laserHit = [[CCSprite alloc] init];
	laserCharge = [[CCSprite alloc] init];
	
	
	[boss addChild:rightArm];
	[boss addChild:rightLeg];
	[boss addChild:body];
	[boss addChild:leftLeg];
	[boss addChild:laserCharge];
	[boss addChild:leftArm];
	[boss addChild:gun];
	[boss addChild:laserStart];
	[boss addChild:laser];
	[boss addChild:laserHit];
	
	[self addChild:boss];
	
	CCAnimation *gunAnimation = [CCAnimation animationWithName:@"gun"
															  delay:0.056f
															 frames:[NSArray arrayWithObjects:
																	 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Gun1.png"],
																	 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Gun2.png"],
																	 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Gun3.png"],
																	 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Gun4.png"],
																	 nil
																	 ]];
	[self addAnimation:gunAnimation];
	
	CCAnimation *laserStartAnimation = [CCAnimation animationWithName:@"laserStart"
															  delay:0.056f
															 frames:[NSArray arrayWithObjects:
																	 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LaserStart1.png"],
																	 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LaserStart2.png"],
																	 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LaserStart3.png"],
																	 nil
																	 ]];
	[self addAnimation:laserStartAnimation];
	
	CCAnimation *laserHitAnimation = [CCAnimation animationWithName:@"laserHit"
																delay:0.056f
															   frames:[NSArray arrayWithObjects:
																	   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LaserHit1.png"],
																	   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LaserHit2.png"],
																	   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LaserHit3.png"],
																	   nil
																	   ]];
	[self addAnimation:laserHitAnimation];
	
	
	
	shoot1Move = [[BEUMove moveWithName:@"shoot1"
									  character:self
										  input:nil
									   selector:@selector(shoot1:)] retain];
	shoot1Move.range = 800.0f;
	shoot1Move.minRange = 400.0f;
	
	[movesController addMove:shoot1Move];
	
	shoot2Move = [[BEUMove moveWithName:@"shoot2"
								character:self
									input:nil
								 selector:@selector(shoot2:)] retain];
	shoot2Move.range = 600.0f;
	shoot2Move.minRange = 150.0f;
	
	[movesController addMove:shoot2Move];
	
	kick1Move = [[BEUMove moveWithName:@"kick1"
								character:self
									input:nil
								 selector:@selector(kick1:)] retain];
	kick1Move.range = 200.0f;
	kick1Move.minRange = 0.0f;
	
	[movesController addMove:kick1Move];
	
	jumpMove = [[BEUMove moveWithName:@"jump"
								character:self
									input:nil
								 selector:@selector(jump:)] retain];
	jumpMove.range = 800.0f;
	jumpMove.minRange = 0.0f;
	
	[movesController addMove:jumpMove];
	
	attack1Move = [[BEUMove moveWithName:@"attack1"
								character:self
									input:nil
								 selector:@selector(attack1:)] retain];
	attack1Move.range = 300.0f;
	attack1Move.minRange = 0.0f;
	
	//[movesController addMove:attack1Move];
	
	laser1Move = [[BEUMove moveWithName:@"laser1"
								character:self
									input:nil
								 selector:@selector(laser1:)] retain];
	laser1Move.range = 400.0f;
	laser1Move.minRange = 150.0f;
	
	//[movesController addMove:laser1Move];
	
	laser2Move = [[BEUMove moveWithName:@"laser2"
								character:self
									input:nil
								 selector:@selector(laser2:)] retain];
	laser2Move.range = 400.0f;
	laser2Move.minRange = 150.0f;
	
	//[movesController addMove:laser2Move];
	
	laser3Move = [[BEUMove moveWithName:@"laser3"
								character:self
									input:nil
								 selector:@selector(laser3:)] retain];
	laser3Move.range = 700.0f;
	laser3Move.minRange = 0.0f;
	
	//[movesController addMove:laser3Move];
	
	laser4Move = [[BEUMove moveWithName:@"laser4"
								character:self
									input:nil
								 selector:@selector(laser4:)] retain];
	laser4Move.range = 1000.0f;
	laser4Move.minRange = 0.0f;
	
	//[movesController addMove:laser4Move];
	
	
}

-(void)setUpAnimations
{
	Animator *animator = [Animator animatorFromFile:@"FinalBoss-Animations.plist"];
	
	BEUAnimation *initFrames = [BEUAnimation animationWithName:@"initFrames"];
	[self addCharacterAnimation:initFrames];
	
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FinalBoss-LeftArm1.png"
							]] target:leftArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FinalBoss-Body.png"
							]] target:body];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FinalBoss-RightArm1.png"
							]] target:rightArm];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FinalBoss-Leg.png"
							]] target:leftLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FinalBoss-Leg.png"
							]] target:rightLeg];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FinalBoss-Gun1.png"
							]] target:gun];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:laserStart];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:laser];	
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:laserHit];
	[initFrames addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:laserCharge];
	
	BEUAnimation *initFramesFloat = [BEUAnimation animationWithName:@"initFramesFloat"];
	[self addCharacterAnimation:initFramesFloat];
	
	[initFramesFloat addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FinalBoss-LeftArm2.png"
							]] target:leftArm];
	[initFramesFloat addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FinalBoss-Body.png"
							]] target:body];
	[initFramesFloat addAction:[BEUSetFrame actionWithSpriteFrame:
						   [[CCSpriteFrameCache sharedSpriteFrameCache] 
							spriteFrameByName:@"FinalBoss-RightArm2.png"
							]] target:rightArm];
	[initFramesFloat addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:leftLeg];
	[initFramesFloat addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:rightLeg];
	[initFramesFloat addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:gun];
	[initFramesFloat addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:laserStart];
	[initFramesFloat addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:laser];	
	[initFramesFloat addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:laserHit];
	[initFramesFloat addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:laserCharge];
	
	
	BEUAnimation *initPosition = [BEUAnimation animationWithName:@"initPosition"];
	[self addCharacterAnimation:initPosition];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftArm"] target:leftArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Body"] target:body];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightArm"] target:rightArm];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-LeftLeg"] target:leftLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-RightLeg"] target:rightLeg];
	[initPosition addAction:[animator getAnimationByName:@"InitPosition-Gun"] target:gun];
	
	BEUAnimation *idle = [BEUAnimation animationWithName:@"idle"];
	[self addCharacterAnimation:idle];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftArm"] target:leftArm];
	[idle addAction:[animator getAnimationByName:@"Idle-Body"] target:body];
	[idle addAction:[animator getAnimationByName:@"Idle-RightArm"] target:rightArm];
	[idle addAction:[animator getAnimationByName:@"Idle-LeftLeg"] target:leftLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-RightLeg"] target:rightLeg];
	[idle addAction:[animator getAnimationByName:@"Idle-Gun"] target:gun];
	
	
	BEUAnimation *walk = [BEUAnimation animationWithName:@"walk"];
	[self addCharacterAnimation:walk];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftArm"] target:leftArm];
	[walk addAction:[animator getAnimationByName:@"Walk-Body"] target:body];
	[walk addAction:[animator getAnimationByName:@"Walk-RightArm"] target:rightArm];
	[walk addAction:[animator getAnimationByName:@"Walk-LeftLeg"] target:leftLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-RightLeg"] target:rightLeg];
	[walk addAction:[animator getAnimationByName:@"Walk-Gun"] target:gun];
	
	BEUAnimation *floatIdle = [BEUAnimation animationWithName:@"floatIdle"];
	[self addCharacterAnimation:floatIdle];
	[floatIdle addAction:[animator getAnimationByName:@"FloatIdle-LeftArm"] target:leftArm];
	[floatIdle addAction:[animator getAnimationByName:@"FloatIdle-Body"] target:body];
	[floatIdle addAction:[animator getAnimationByName:@"FloatIdle-RightArm"] target:rightArm];
	
	BEUAnimation *floatMoveForwardStart = [BEUAnimation animationWithName:@"floatMoveForwardStart"];
	[self addCharacterAnimation:floatMoveForwardStart];
	[floatMoveForwardStart addAction:[animator getAnimationByName:@"FloatMoveForwardStart-LeftArm"] target:leftArm];
	[floatMoveForwardStart addAction:[animator getAnimationByName:@"FloatMoveForwardStart-Body"] target:body];
	[floatMoveForwardStart addAction:[CCSequence actions:
									  [animator getAnimationByName:@"FloatMoveForwardStart-RightArm"],
									  [CCCallFunc actionWithTarget:self selector:@selector(floatMoveForwardStartComplete)],
									  nil
									  ] target:rightArm];
	
	BEUAnimation *floatMoveForwardIdle = [BEUAnimation animationWithName:@"floatMoveForwardLoop"];
	[self addCharacterAnimation:floatMoveForwardIdle];
	[floatMoveForwardIdle addAction:[animator getAnimationByName:@"FloatMoveForwardLoop-LeftArm"] target:leftArm];
	[floatMoveForwardIdle addAction:[animator getAnimationByName:@"FloatMoveForwardLoop-Body"] target:body];
	[floatMoveForwardIdle addAction:[animator getAnimationByName:@"FloatMoveForwardLoop-RightArm"] target:rightArm];
	
	BEUAnimation *floatMoveForwardStop = [BEUAnimation animationWithName:@"floatMoveForwardStop"];
	[self addCharacterAnimation:floatMoveForwardStop];
	[floatMoveForwardStop addAction:[animator getAnimationByName:@"FloatMoveForwardStop-LeftArm"] target:leftArm];
	[floatMoveForwardStop addAction:[animator getAnimationByName:@"FloatMoveForwardStop-Body"] target:body];
	[floatMoveForwardStop addAction:[CCSequence actions:
									  [animator getAnimationByName:@"FloatMoveForwardStop-RightArm"],
									  [CCCallFunc actionWithTarget:self selector:@selector(floatMoveForwardStopComplete)],
									  nil
									  ] target:rightArm];
	
	
	BEUAnimation *shoot1 = [BEUAnimation animationWithName:@"shoot1"];
	[self addCharacterAnimation:shoot1];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-LeftArm"] target:leftArm];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-Body"] target:body];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-RightArm"] target:rightArm];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-LeftLeg"] target:leftLeg];
	[shoot1 addAction:[animator getAnimationByName:@"Shoot1-Gun"] target:gun];
	[shoot1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Shoot1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeMove)],
	  nil
	  ]
			   target:rightLeg];
	
	
	
	[shoot1 addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:1.43f],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot1Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot1Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot1Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot1Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot1Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot1Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot1Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot1Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:YES], 
					   
					   nil
					   ]
			   target:gun];
	
	
	BEUAnimation *shoot2 = [BEUAnimation animationWithName:@"shoot2"];
	[self addCharacterAnimation:shoot2];
	[shoot2 addAction:[animator getAnimationByName:@"Shoot2-LeftArm"] target:leftArm];
	[shoot2 addAction:[animator getAnimationByName:@"Shoot2-Body"] target:body];
	[shoot2 addAction:[animator getAnimationByName:@"Shoot2-RightArm"] target:rightArm];
	[shoot2 addAction:[animator getAnimationByName:@"Shoot2-LeftLeg"] target:leftLeg];
	[shoot2 addAction:[animator getAnimationByName:@"Shoot2-Gun"] target:gun];
	[shoot2 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Shoot2-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeMove)],
	  nil
	  ]
			   target:rightLeg];
	
	
	
	[shoot2 addAction:[CCSequence actions:
					   [CCDelayTime actionWithDuration:0.93f],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot2Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot2Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot2Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot2Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot2Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:NO],
					   
					   [CCCallFunc actionWithTarget:self selector:@selector(shoot2Send)],
					   [BEUPlayEffect actionWithSfxName:@"GunShot" onlyOne:YES],
					   [CCAnimate actionWithAnimation:[self animationByName:@"gun"] restoreOriginalFrame:YES],
					   
					   
					   nil
					   ]
			   target:gun];
	
	BEUAnimation *kick1 = [BEUAnimation animationWithName:@"kick1"];
	[self addCharacterAnimation:kick1];
	[kick1 addAction:[animator getAnimationByName:@"Kick1-LeftArm"] target:leftArm];
	[kick1 addAction:[animator getAnimationByName:@"Kick1-Body"] target:body];
	[kick1 addAction:[animator getAnimationByName:@"Kick1-RightArm"] target:rightArm];
	[kick1 addAction:[animator getAnimationByName:@"Kick1-LeftLeg"] target:leftLeg];
	[kick1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Kick1-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeMove)],
	  nil
	  ]
			  target:rightLeg];	
	[kick1 addAction:[animator getAnimationByName:@"Kick1-Gun"] target:gun];
	[kick1 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.63f],
					  [CCCallFunc actionWithTarget:self selector:@selector(kick1Send)],					  
					  nil
					  ]
			  target:self];
	
	
	BEUAnimation *jumpStart = [BEUAnimation animationWithName:@"jumpStart"];
	[self addCharacterAnimation:jumpStart];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-LeftArm"] target:leftArm];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-Body"] target:body];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-RightArm"] target:rightArm];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-LeftLeg"] target:leftLeg];
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-RightLeg"] target:rightLeg];	
	[jumpStart addAction:[animator getAnimationByName:@"JumpStart-Gun"] target:gun];
	[jumpStart addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.56f],
					  [CCCallFunc actionWithTarget:self selector:@selector(jumpMove)],					  
					  nil
					  ]
			  target:self];
	
	BEUAnimation *jumpLand = [BEUAnimation animationWithName:@"jumpLand"];
	[self addCharacterAnimation:jumpLand];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-LeftArm"] target:leftArm];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-Body"] target:body];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-RightArm"] target:rightArm];
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-LeftLeg"] target:leftLeg];
	[jumpLand addAction:
	 [CCSequence actions:
	  [BEUPlayEffect actionWithSfxName:@"HitHeavy" onlyOne:YES],
	  [animator getAnimationByName:@"JumpLand-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeMove)],
	  nil
	  ]
				  target:rightLeg];	
	[jumpLand addAction:[animator getAnimationByName:@"JumpLand-Gun"] target:gun];
	
	
	BEUAnimation *legsBreak = [BEUAnimation animationWithName:@"legsBreak"];
	[self addCharacterAnimation:legsBreak];
	[legsBreak addAction:[animator getAnimationByName:@"LegsBreak-LeftArm"] target:leftArm];
	[legsBreak addAction:[animator getAnimationByName:@"LegsBreak-Body"] target:body];
	[legsBreak addAction:[animator getAnimationByName:@"LegsBreak-RightArm"] target:rightArm];
	[legsBreak addAction:[animator getAnimationByName:@"LegsBreak-LeftLeg"] target:leftLeg];
	[legsBreak addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"LegsBreak-RightLeg"],
	  [CCCallFunc actionWithTarget:self selector:@selector(legsBreakComplete)],
	  nil
	  ]
				 target:rightLeg];	
	[legsBreak addAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(legsBreakExplosion)],
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(legsBreakExplosion)],
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(legsBreakExplosion)],
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(legsBreakExplosion)],
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(legsBreakExplosion)],
						  nil
						  ]
				  target:self];
	[legsBreak addAction:[BEUSetFrame actionWithSpriteFrame:nil] target:gun];	
	[legsBreak addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LeftArm2.png"]] target:leftArm];	
	[legsBreak addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-RightArm2.png"]] target:rightArm];	
	
	


	BEUAnimation *laser1 = [BEUAnimation animationWithName:@"laser1"];
	[self addCharacterAnimation:laser1];
	[laser1 addAction:[animator getAnimationByName:@"Laser1-LeftArm"] target:leftArm];
	[laser1 addAction:[animator getAnimationByName:@"Laser1-Body"] target:body];
	[laser1 addAction:[animator getAnimationByName:@"Laser1-RightArm"] target:rightArm];
	[laser1 addAction:[animator getAnimationByName:@"Laser1-Laser"] target:laser];
	[laser1 addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Laser1.png"]] target:laser];	
	[laser1 addAction:[animator getAnimationByName:@"Laser1-LaserHit"] target:laserHit];
	[laser1 addAction:[animator getAnimationByName:@"Laser1-LaserStart"] target:laserStart];
	[laser1 addAction:
	 [CCSequence actions:
	  [BEUPlayEffect actionWithSfxName:@"Laser" onlyOne:YES],
	  [animator getAnimationByName:@"Laser1-LaserStart"],
	  [CCCallFunc actionWithTarget:self selector:@selector(laser1Complete)],
	  nil
	  ]
				 target:rightLeg];	
	
	BEUAnimation *laser3Start = [BEUAnimation animationWithName:@"laser3Start"];
	[self addCharacterAnimation:laser3Start];
	[laser3Start addAction:[animator getAnimationByName:@"Laser3Start-LeftArm"] target:leftArm];
	[laser3Start addAction:[animator getAnimationByName:@"Laser3Start-Body"] target:body];
	[laser3Start addAction:[animator getAnimationByName:@"Laser3Start-RightArm"] target:rightArm];
	[laser3Start addAction:[animator getAnimationByName:@"Laser3Start-Laser"] target:laser];
	[laser3Start addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Laser1.png"]] target:laser];	
	[laser3Start addAction:[animator getAnimationByName:@"Laser3Start-LaserHit"] target:laserHit];
	[laser3Start addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Laser3Start-LaserStart"],
	  [CCCallFunc actionWithTarget:self selector:@selector(laser3Move)],
	  nil
	  ]
			   target:laserStart];
	
	BEUAnimation *laser3Loop = [BEUAnimation animationWithName:@"laser3Loop"];
	[self addCharacterAnimation:laser3Loop];
	[laser3Loop addAction:[animator getAnimationByName:@"Laser3Loop-LeftArm"] target:leftArm];
	[laser3Loop addAction:[animator getAnimationByName:@"Laser3Loop-Body"] target:body];
	[laser3Loop addAction:[animator getAnimationByName:@"Laser3Loop-RightArm"] target:rightArm];
	[laser3Loop addAction:[animator getAnimationByName:@"Laser3Loop-Laser"] target:laser];
	[laser3Loop addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Laser1.png"]] target:laser];	
	[laser3Loop addAction:[animator getAnimationByName:@"Laser3Loop-LaserHit"] target:laserHit];
	[laser3Loop addAction:[animator getAnimationByName:@"Laser3Loop-LaserStart"] target:laserStart];
	[laser3Loop addAction:[BEUPlayEffect actionWithSfxName:@"Laser" onlyOne:YES] target: self];
	
	BEUAnimation *laser3End = [BEUAnimation animationWithName:@"laser3End"];
	[self addCharacterAnimation:laser3End];
	[laser3End addAction:[animator getAnimationByName:@"Laser3End-LeftArm"] target:leftArm];
	[laser3End addAction:[animator getAnimationByName:@"Laser3End-Body"] target:body];
	[laser3End addAction:[animator getAnimationByName:@"Laser3End-RightArm"] target:rightArm];
	[laser3End addAction:[animator getAnimationByName:@"Laser3End-Laser"] target:laser];
	[laser3End addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Laser1.png"]] target:laser];	
	[laser3End addAction:[animator getAnimationByName:@"Laser3End-LaserHit"] target:laserHit];
	[laser3End addAction:
	 [CCSequence actions:
	  
	  [animator getAnimationByName:@"Laser3End-LaserStart"],
	  [CCCallFunc actionWithTarget:self selector:@selector(laser3Complete)],
	  nil
	  ]
					target:laserStart];
	
	
	
	BEUAnimation *laser4Start = [BEUAnimation animationWithName:@"laser4Start"];
	[self addCharacterAnimation:laser4Start];
	[laser4Start addAction:[animator getAnimationByName:@"Laser4Start-LeftArm"] target:leftArm];
	[laser4Start addAction:[animator getAnimationByName:@"Laser4Start-Body"] target:body];
	[laser4Start addAction:[animator getAnimationByName:@"Laser4Start-RightArm"] target:rightArm];
	[laser4Start addAction:[animator getAnimationByName:@"Laser4Start-Laser"] target:laser];
	[laser4Start addAction:[animator getAnimationByName:@"Laser4Start-LaserCharge"] target:laserCharge];
	[laser4Start addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Laser1.png"]] target:laser];	
	[laser4Start addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LaserCharge.png"]] target:laserCharge];		
	[laser4Start addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Laser4Start-LaserStart"],
	  [CCCallFunc actionWithTarget:self selector:@selector(laser4Start)],
	  nil
	  ]
				  target:laserStart];
	
	
	BEUAnimation *laser4Loop = [BEUAnimation animationWithName:@"laser4Loop"];
	[self addCharacterAnimation:laser4Loop];
	[laser4Loop addAction:[animator getAnimationByName:@"Laser4Loop-LeftArm"] target:leftArm];
	[laser4Loop addAction:[animator getAnimationByName:@"Laser4Loop-Body"] target:body];
	[laser4Loop addAction:[animator getAnimationByName:@"Laser4Loop-RightArm"] target:rightArm];
	[laser4Loop addAction:[animator getAnimationByName:@"Laser4Loop-Laser"] target:laser];
	[laser4Loop addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Laser1.png"]] target:laser];	
	[laser4Loop addAction:[animator getAnimationByName:@"Laser4Loop-LaserStart"] target:laserStart];
	[laser4Loop addAction:[BEUPlayEffect actionWithSfxName:@"Laser" onlyOne:YES] target:self];
	
	BEUAnimation *laser4End = [BEUAnimation animationWithName:@"laser4End"];
	[self addCharacterAnimation:laser4End];
	[laser4End addAction:[animator getAnimationByName:@"Laser4End-LeftArm"] target:leftArm];
	[laser4End addAction:[animator getAnimationByName:@"Laser4End-Body"] target:body];
	[laser4End addAction:[animator getAnimationByName:@"Laser4End-RightArm"] target:rightArm];
	[laser4End addAction:[animator getAnimationByName:@"Laser4End-Laser"] target:laser];
	[laser4End addAction:[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-Laser1.png"]] target:laser];	
	[laser4End addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Laser4End-LaserStart"],
	  [CCCallFunc actionWithTarget:self selector:@selector(laser4Complete)],
	  nil
	  ]
					target:laserStart];
	
	
	BEUAnimation *attack1 = [BEUAnimation animationWithName:@"attack1"];
	[self addCharacterAnimation:attack1];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-LeftArm"] target:leftArm];
	[attack1 addAction:[animator getAnimationByName:@"Attack1-Body"] target:body];
	[attack1 addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Attack1-RightArm"],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeMove)],
	  nil
	  ]
			  target:rightArm];	
	[attack1 addAction:[CCSequence actions:
						[CCDelayTime actionWithDuration:0.866f],
						[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LeftArm3.png"]],
						[CCDelayTime actionWithDuration:0.8f],
						[BEUSetFrame actionWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-LeftArm2.png"]],
						nil
									]
				target:leftArm];
	[attack1 addAction:[CCSequence actions:
					  [CCDelayTime actionWithDuration:0.866f],
					  [CCCallFunc actionWithTarget:self selector:@selector(attack1Send)],					  
					  nil
					  ]
			  target:self];
	
	BEUAnimation *death = [BEUAnimation animationWithName:@"death"];
	[self addCharacterAnimation:death];
	[death addAction:[animator getAnimationByName:@"Death-LeftArm"] target:leftArm];
	[death addAction:[animator getAnimationByName:@"Death-Body"] target:body];
	[death addAction:
	 [CCSequence actions:
	  [animator getAnimationByName:@"Death-RightArm"],
	  [BEUPlayEffect actionWithSfxName:@"Laser" onlyOne:YES],
	  nil
	  
	  ] target:rightArm];	
	[death addAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(deathExplosion)],
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(deathExplosion)],
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(deathExplosion)],
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(deathExplosion)],
						  [CCDelayTime actionWithDuration:0.4f],
						  [CCCallFunc actionWithTarget:self selector:@selector(deathExplosion)],
						  [CCDelayTime actionWithDuration:2.0f],
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
	
	BEUCharacterAIMoveAwayToTargetZ *moveBranch = [BEUCharacterAIMoveAwayToTargetZ behavior];
	moveBranch.canRunMultipleTimesInARow = NO;
	[ai addBehavior:moveBranch];
	
	BEUCharacterAIBehavior *idleBranch = [BEUCharacterAIIdleBehavior behaviorWithMinTime:.5f maxTime:1.2f];
	idleBranch.canRunMultipleTimesInARow = NO;
	[ai addBehavior:idleBranch];
	
	BEUCharacterAIMoveToAndAttack *attackBranch = [BEUCharacterAIMoveToAndAttack behaviorWithMoves:[movesController moves]];
	attackBranch.mustBeInViewPort = NO;
	attackBranch.canRunMultipleTimesInARow = NO;
	attackBranch.canRunSameMoveAgain = NO;
	[ai addBehavior:attackBranch];
	
	ai.difficultyMultiplier = 0.5f;
}

-(void)idle
{
	
	if(!legsDestroyed)
	{
	
		if(![currentCharacterAnimation.name isEqualToString:@"idle"])
		{
			[self playCharacterAnimationWithName:@"initFrames"];
			[self playCharacterAnimationWithName:@"idle"];
		}
			
	} else {
		if([currentCharacterAnimation.name isEqualToString:@"floatMoveForwardStart"] || [currentCharacterAnimation.name isEqualToString:@"floatMoveForwardLoop"])
		{
			[self playCharacterAnimationWithName:@"initFramesFloat"];
			[self playCharacterAnimationWithName:@"floatMoveForwardStop"];
		} else if(![currentCharacterAnimation.name isEqualToString:@"floatIdle"])
		{
			[self playCharacterAnimationWithName:@"initFramesFloat"];
			[self playCharacterAnimationWithName:@"floatIdle"];
		}
	}
}

-(void)walk
{
	
	if(!legsDestroyed)
	{
		if(![currentCharacterAnimation.name isEqualToString:@"walk"])
		{
			[self playCharacterAnimationWithName:@"initFrames"];
			[self playCharacterAnimationWithName:@"walk"];
		}
	} else {
		if(![currentCharacterAnimation.name isEqualToString:@"floatMoveForwardStart"] && ![currentCharacterAnimation.name isEqualToString:@"floatMoveForwardLoop"])
		{
			[self playCharacterAnimationWithName:@"initFramesFloat"];
			[self playCharacterAnimationWithName:@"floatMoveForwardStart"];
		}
	}
}

-(void)floatMoveForwardStartComplete
{
	[self playCharacterAnimationWithName:@"floatMoveForwardLoop"];
}

-(void)floatMoveForwardStopComplete
{
	[self playCharacterAnimationWithName:@"floatIdle"];
}


-(BOOL)shoot1:(BEUMove *)move
{
	[self faceObject:orientToObject];
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"shoot1"];
	[movesController setCurrentMove:move];
	shotCount = 0;
	shotStartDist = 0;
	return YES;
}


-(void)shoot1Send
{
	if(shotStartDist == 0)
	{
		float objectDist = fabsf(orientToObject.x-x);
		
		float minStart = 400;
		float maxStart = 600;
		shotStartDist = objectDist - 60;
		if(objectDist < minStart) shotStartDist = minStart;
		if(objectDist > maxStart) shotStartDist = maxStart;
	}
		
	float xOffset = shotStartDist + 35*shotCount;
	
	CGRect hitRect = CGRectMake(x + xOffset*directionMultiplier - 25, z, 50, 60);
	
	//[[[[BEUEnvironment sharedEnvironment] debugLayer] rectsToDraw] addObject:[DebugRect rectWithRect:hitRect time:1.0f]];
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0
											   hitArea:hitRect
												zRange:ccp(z-10.0f,z+60.0f)
												 power:15.0f
												xForce:directionMultiplier*60.0f
												yForce:0.0f
												zForce:0.0f
											  relative: NO
												
						 ];
	hit.type = BEUHitTypeBlunt;
	
	[[BEUActionsController sharedController] addAction:hit];	
	
	FinalBossBulletHitEffect *effect = [[[FinalBossBulletHitEffect alloc] init]  autorelease];
	effect.x = x + xOffset*directionMultiplier;
	effect.y = 0;
	effect.z = z;
	[effect startEffect];
	
	
	shotCount++;
}


-(BOOL)shoot2:(BEUMove *)move
{
	[self faceObject:orientToObject];
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"shoot2"];
	[movesController setCurrentMove:move];
	shotCount = 0;
	shotStartDist = 0;
	return YES;
}


-(void)shoot2Send
{
	
	if(shotStartDist == 0)
	{
		float objectDist = fabsf(orientToObject.x-x);
		
		float minStart = 320;
		float maxStart = 500;
		shotStartDist = objectDist + 60;
		if(objectDist < minStart) shotStartDist = minStart;
		if(objectDist > maxStart) shotStartDist = maxStart;
	}
	
	float xOffset = shotStartDist - 35*shotCount;
	
	
	CGRect hitRect = CGRectMake(x + xOffset*directionMultiplier - 25, z, 50, 60);
	
	//[[[[BEUEnvironment sharedEnvironment] debugLayer] rectsToDraw] addObject:[DebugRect rectWithRect:hitRect time:1.0f]];
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:0
											   hitArea:hitRect
												zRange:ccp(z-10.0f,z+60.0f)
												 power:15
												xForce:directionMultiplier*60.0f
												yForce:0.0f
												zForce:0.0f
											  relative: NO
						 
						 ];
	hit.type = BEUHitTypeBlunt;
	
	[[BEUActionsController sharedController] addAction:hit];	
	
	FinalBossBulletHitEffect *effect = [[[FinalBossBulletHitEffect alloc] init]  autorelease];
	effect.x = x + xOffset*directionMultiplier;
	effect.y = 0;
	effect.z = z;
	[effect startEffect];
	
	
	shotCount++;
	
}


-(BOOL)kick1:(BEUMove *)move
{
	[self faceObject:orientToObject];
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"kick1"];
	[movesController setCurrentMove:move];
	return YES;
}


-(void)kick1Send
{
	
	
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											selector:@selector(receiveHit:)
											duration:0
											hitArea:CGRectMake(0, 0, 180, 150)
											zRange:ccp(-10.0f,60.0f)
											power:35
											xForce:directionMultiplier*450.0f
											yForce:200.0f
											zForce:0.0f
											relative: YES
	];

	hit.type = BEUHitTypeKnockdown;

	[[BEUActionsController sharedController] addAction:hit];	
	 
	 
	
}

-(BOOL)jump:(BEUMove *)move
{
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFrames"];
	[self playCharacterAnimationWithName:@"jumpStart"];
	[movesController setCurrentMove:move];
	return YES;
}

-(void)jumpMove
{
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
	checkJump = NO;
	
	[self playCharacterAnimationWithName:@"jumpLand"];
	
	BEUHitAction *landAction =  [BEUHitAction actionWithSender:self
													  selector:@selector(receiveGroundHit:)
													  duration:0.0f
													   hitArea:CGRectMake(-300.0f, -200.0f, 600.0f, 400.0f)
														zRange:ccp(-200.0f,200.0f)
														 power:30.0f
														xForce:200.0f*directionMultiplier 
														yForce:250.0f 
														zForce:0.0f
													  relative:YES];
	landAction.type = BEUHitTypeKnockdown;
	
	[[BEUActionsController sharedController] addAction:landAction];
	
	FinalBossGroundHitEffect *effect = [[[FinalBossGroundHitEffect alloc] init] autorelease];
	effect.x = x;
	effect.z = z;
	effect.y = y;
	[effect startEffect];
	
	[[BEUEnvironment sharedEnvironment] shakeScreenWithRange:5 duration:.5f];
}


-(BOOL)attack1:(BEUMove *)move
{
	[self faceObject:orientToObject];
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFramesFloat"];
	[self playCharacterAnimationWithName:@"attack1"];
	[movesController setCurrentMove:move];
	return YES;
}


-(void)attack1Send
{
	[self applyAdjForceX:300.0f];
	
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											 selector:@selector(receiveHit:)
											 duration:0.83f
											 hitArea:CGRectMake(80, 0, 210, 200)
											 zRange:ccp(-60.0f,60.0f)
											 power:40
											 xForce:directionMultiplier*460.0f
											 yForce:0.0f
											 zForce:0.0f
											 relative: YES
	 ];
	
	 
	 [[BEUActionsController sharedController] addAction:hit];	
	 
	 
	
}

-(BOOL)laser1:(BEUMove *)move
{
	[self faceObject:orientToObject];
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFramesFloat"];
	[self playCharacterAnimationWithName:@"laser1"];
	[movesController setCurrentMove:move];
	
	[laserStart runAction:
	 [CCRepeatForever actionWithAction:
	  [CCAnimate actionWithAnimation:[self animationByName:@"laserStart"]]
	  ]
	 ];
	
	[laserHit runAction:
	 [CCRepeatForever actionWithAction:
	  [CCAnimate actionWithAnimation:[self animationByName:@"laserHit"]]
	  ]
	 ];
	
	return YES;
}


-(void)laser1Send
{
	
	
	
	/*BEUHitAction *hit = [BEUHitAction actionWithSender:self
	 selector:@selector(receiveHit:)
	 duration:0
	 hitArea:CGRectMake(80, 50, 480, 10)
	 zRange:ccp(-20.0f,20.0f)
	 power:30
	 xForce:directionMultiplier*160.0f
	 yForce:0.0f
	 zForce:0.0f
	 relative: YES
	 ];
	 hit.sendsLeft = 1;
	 hit.orderByDistance = YES;
	 hit.type = BEUHitTypeBlunt;
	 
	 [[BEUActionsController sharedController] addAction:hit];	
	 
	 */
	
}

-(void)laser1Complete
{
	[self completeMove];
	[laserHit stopAllActions];
	[laserStart stopAllActions];
}

-(BOOL)laser2:(BEUMove *)move
{
	[self faceObject:orientToObject];
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFramesFloat"];
	[self playCharacterAnimationWithName:@"laser2"];
	[movesController setCurrentMove:move];
	return YES;
}


-(void)laser2Send
{
	
	
	
	/*BEUHitAction *hit = [BEUHitAction actionWithSender:self
	 selector:@selector(receiveHit:)
	 duration:0
	 hitArea:CGRectMake(80, 50, 480, 10)
	 zRange:ccp(-20.0f,20.0f)
	 power:30
	 xForce:directionMultiplier*160.0f
	 yForce:0.0f
	 zForce:0.0f
	 relative: YES
	 ];
	 hit.sendsLeft = 1;
	 hit.orderByDistance = YES;
	 hit.type = BEUHitTypeBlunt;
	 
	 [[BEUActionsController sharedController] addAction:hit];	
	 
	 */
	
}

-(BOOL)laser3:(BEUMove *)move
{
	
	
	[laserStart runAction:
	 [CCRepeatForever actionWithAction:
	  [CCAnimate actionWithAnimation:[self animationByName:@"laserStart"]]
	  ]
	 ];
	
	[laserHit runAction:
	 [CCRepeatForever actionWithAction:
	  [CCAnimate actionWithAnimation:[self animationByName:@"laserHit"]]
	  ]
	 ];
	
	[self faceObject:orientToObject];
	//canMove = NO;
	autoAnimate = NO;
	canReceiveHit = NO;
	[self playCharacterAnimationWithName:@"initFramesFloat"];
	[self playCharacterAnimationWithName:@"laser3Start"];
	[movesController setCurrentMove:move];
	
	angleToCharacter = [BEUMath angleFromPoint:ccp(x,z) toPoint:ccp(orientToObject.x,orientToObject.z)];
	
	return YES;
}

-(void)laser3Move
{
	
	[self playCharacterAnimationWithName:@"laser3Loop"];
	
	
	
	
	/*float maxAngle = CC_DEGREES_TO_RADIANS(30);
	
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
	}*/
	canMoveThroughObjectWalls = YES;
	movingAngle = angleToCharacter;
	movingPercent = 1.0f;
	
	//float minRunTime = (ccpDistance(ccp(x,z), ccp(orientToObject.x,orientToObject.z)) + 100)/movementSpeed ;
	float minTime = 2.0f;
	float maxTime = 4.0f;
	
	float runTime = minTime + (maxTime-minTime)*CCRANDOM_0_1();
	
	
	[self runAction:[CCSequence actions:
					 [CCDelayTime actionWithDuration:runTime],
					 [CCCallFunc actionWithTarget:self selector:@selector(laser3MoveComplete)],
					 nil
					 ]];
	
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											   duration:runTime
											   hitArea:CGRectMake(0, 0, 140, 400)
											    zRange:ccp(-50.0f,50.0f)
											     power:10
											    xForce:0.0f
											    yForce:0.0f
											    zForce:0.0f
											  relative: YES
						];
	hit.oncePerObject = NO;
	//hit.debug = YES;
	 
	 [[BEUActionsController sharedController] addAction:hit];	
	 
	 
}

-(void)laser3MoveComplete
{
	[self playCharacterAnimationWithName:@"laser3End"];
	canMoveThroughObjectWalls = NO;
	movingAngle = 0.0f;
	movingPercent = 0.0f;
	canReceiveHit = YES;
}

-(void)laser3Complete
{
	[self completeMove];
	[laserHit stopAllActions];
	[laserStart stopAllActions];
		
}

-(BOOL)laser4:(BEUMove *)move
{
	
	[laserStart runAction:
	 [CCRepeatForever actionWithAction:
	  [CCAnimate actionWithAnimation:[self animationByName:@"laserStart"]]
	  ]
	 ];
	
	[self faceObject:orientToObject];
	canMove = NO;
	[self playCharacterAnimationWithName:@"initFramesFloat"];
	[self playCharacterAnimationWithName:@"laser4Start"];
	[movesController setCurrentMove:move];
	return YES;
}


-(void)laser4Start
{
	[self playCharacterAnimationWithName:@"laser4Loop"];
	
	float minTime = 2.0f; 
	float maxTime = 4.0f;
	float time = (minTime + (maxTime-minTime)*CCRANDOM_0_1());
	[self schedule:@selector(laser4Stop) interval:time];
	
	BEUHitAction *hit = [BEUHitAction actionWithSender:self
											  selector:@selector(receiveHit:)
											  duration:time
											   hitArea:CGRectMake(50, 0, 1000, 200)
											    zRange:ccp(-50.0f,50.0f)
											     power:10
											    xForce:directionMultiplier*160.0f
											    yForce:0.0f
											    zForce:0.0f
											  relative: YES
						 ];
	hit.oncePerObject = NO;
	//hit.debug = YES;
	
	[[BEUActionsController sharedController] addAction:hit];
	
	
}

-(void)laser4Stop
{
	[self unschedule:@selector(laser4Stop)];
	
	[self playCharacterAnimationWithName:@"laser4End"];
}

-(void)laser4Complete
{
	[self completeMove];
	[laserHit stopAllActions];
	[laserStart stopAllActions];
}

-(void)completeMove
{
	canMove = YES;
	autoAnimate = YES;
	[self idle];
	[movesController completeCurrentMove];
}

-(void)legsBreak
{
	[self playCharacterAnimationWithName:@"legsBreak"];
	[ai cancelCurrentBehavior];
	ai.enabled = NO;
	autoAnimate = NO;
	canMove = NO;
	legsDestroyed = YES;
	canReceiveHit = NO;
	checkJump = NO;
	movementSpeed = floatSpeed;
	
	[movesController removeMove:shoot1Move];
	[movesController removeMove:shoot2Move];
	[movesController removeMove:kick1Move];
	[movesController removeMove:jumpMove];
	
	[movesController addMove:attack1Move];
	//movesController addMove:laser1Move];
	//[movesController addMove:laser2Move];
	[movesController addMove:laser3Move];
	[movesController addMove:laser4Move];
}

-(void)setLegsDestroyed:(BOOL)destroyed
{
	legsDestroyed = destroyed;
	
	if(legsDestroyed)
	{
		movementSpeed = floatSpeed;
		
		[movesController removeMove:shoot1Move];
		[movesController removeMove:shoot2Move];
		[movesController removeMove:kick1Move];
		[movesController removeMove:jumpMove];
		
		[movesController addMove:attack1Move];
		[movesController addMove:laser3Move];
		[movesController addMove:laser4Move];
	} else {
		movementSpeed = walkSpeed;
		
		[movesController addMove:shoot1Move];
		[movesController addMove:shoot2Move];
		[movesController addMove:kick1Move];
		[movesController addMove:jumpMove];
		
		[movesController removeMove:attack1Move];
		[movesController removeMove:laser3Move];
		[movesController removeMove:laser4Move];
	}
	
}

-(void)legsBreakExplosion
{
	CGRect legsRect = CGRectMake(x-70, y, 160, 150);
	
	CGPoint explosionPoint = ccp(legsRect.origin.x + legsRect.size.width*CCRANDOM_0_1(),legsRect.origin.y + legsRect.size.height*CCRANDOM_0_1());
	
	BEUEffect *effect = (arc4random()%2 == 0) ? [[[FireExplosion1 alloc] init] autorelease] : [[[FireExplosion2 alloc] init] autorelease];
	effect.x = explosionPoint.x;
	effect.z = z - 1;
	effect.y = explosionPoint.y;
	[effect startEffect];
}

-(void)legsBreakComplete
{
	ai.enabled = YES;
	canMove = YES;
	autoAnimate = YES;	
	canReceiveHit = YES;
	
	[[BEUGameManager sharedManager] checkpoint];
}

-(void)hit:(BEUAction *)action
{
	//[super hit:action];
	
	//canMove = NO;
	//ai.enabled = NO;
	//BEUHitAction *hit = (BEUHitAction *)action;
	[self runAction:[BEUPlayEffect actionWithSfxName:@"HitMetal" onlyOne:YES]];
	
	if(!legsDestroyed)
	{
		[leftLeg runAction:[CCSequence actions:
							[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
							[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
							nil]];
		[rightLeg runAction:[CCSequence actions:
							[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
							[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
							nil]];
		
	} else {
		[body runAction:[CCSequence actions:
							[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
							[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
							nil]];
		[rightArm runAction:[CCSequence actions:
							[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
							[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
							nil]];
		[leftArm runAction:[CCSequence actions:
							[CCTintTo actionWithDuration:0.05f red:255 green:0 blue:0],
							[CCTintTo actionWithDuration:0.12f red:255 green:255 blue:255],
							nil]];
		
		
	}
	
	if(life <= totalLife-neededLegsDamage && !legsDestroyed)
	{
		[self legsBreak];
	}
	
	[self updateHealthBar];
}

-(void)enableAI
{
	[super enableAI];
	
	healthBar = [[GameHUD sharedGameHUD] addBossBar:@"BossBar-Final.png"];
	[self updateHealthBar];
}

-(void)updateHealthBar
{
	if(healthBar) [healthBar.bar setPercent:(life/totalLife)];
}

-(void)death:(BEUAction *)action
{
	
	[super death:action];
	canMove = NO;
	canReceiveHit = NO;
	canMoveThroughObjectWalls = YES;
	[self playCharacterAnimationWithName:@"floatInitFrames"];
	[self playCharacterAnimationWithName:@"death"];
}

-(void)deathExplosion
{
	CGRect legsRect = CGRectMake(x-70, y+50, 160, 150);
	
	CGPoint explosionPoint = ccp(legsRect.origin.x + legsRect.size.width*CCRANDOM_0_1(),legsRect.origin.y + legsRect.size.height*CCRANDOM_0_1());
	
	BEUEffect *effect = (arc4random()%2 == 0) ? [[[FireExplosion1 alloc] init] autorelease] : [[[FireExplosion2 alloc] init] autorelease];
	effect.x = explosionPoint.x;
	effect.z = z - 1;
	effect.y = explosionPoint.y;
	[effect startEffect];
}

-(void)step:(ccTime)delta
{
	[super step:delta];
	
	if(enabled && ai.enabled && !healthBar) 
	{
		healthBar = [[GameHUD sharedGameHUD] addBossBar:@"BossBar-Final.png"];
		[self updateHealthBar];
	}
	
	if(checkJump)
	{
		[self jumpCheck];
	}
}

-(void)dealloc
{
	
	[shoot1Move release];
	[shoot2Move release];
	[kick1Move release];
	[jumpMove release];
	[attack1Move release];
	[laser1Move release];
	[laser2Move release];
	[laser3Move release];
	[laser4Move release];
	
	[gun release];
	[laserStart release];
	[laser release];
	[laserHit release];
	[leftArm release];
	[rightArm release];
	[leftLeg release];
	[rightLeg release];
	[body release];
	[boss release];
	
	[super dealloc];
}

-(NSDictionary *)save
{
	NSMutableDictionary *savedData = [NSMutableDictionary dictionaryWithDictionary:[super save]];
	[savedData setObject:[NSNumber numberWithBool:legsDestroyed] forKey:@"legsDestroyed"];
	return savedData;
}

+(id)load:(NSDictionary *)options
{
	FinalBoss *character = ((FinalBoss *)[super load:options]);
	character.life = [[options valueForKey:@"life"] floatValue];
	character.totalLife = [[options valueForKey:@"totalLife"] floatValue];
	character.legsDestroyed = [[options valueForKey:@"legsDestroyed"] boolValue];
	//[character updateHealthBar];
	[character idle];
	
	return character;
}

@end

@implementation FinalBossBulletHitEffect

-(id)init
{
	self = [super init];
	
	bulletHole = [[CCSprite alloc] init];
	bulletHole.anchorPoint = ccp(.5f,0);
	
	CCAnimation *animation = [CCAnimation animationWithName:@"hit" delay:0.056f frames:[NSArray arrayWithObjects:
																					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-BulletHit1.png"],
																					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-BulletHit2.png"],
																					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-BulletHit3.png"],
																					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-BulletHit4.png"],
																					   [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-BulletHit5.png"],
																					   nil
																					   ]
							  ];
	[self addAnimation:animation];
	[self addChild:bulletHole];
	
	isOnTopOfObjects = NO;
	
	return self;
}

-(void)startEffect
{
	[super startEffect];
	
	[bulletHole runAction:
	 [CCSequence actions:
	  [CCAnimate actionWithAnimation:[self animationByName:@"hit"] restoreOriginalFrame:NO],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
	  nil
	  ]
	 ];
}

-(void)dealloc
{
	[bulletHole release];
	[super dealloc];
}

@end

@implementation FinalBossGroundHitEffect


-(id)init
{
	self = [super init];
	
	hit = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"FinalBoss-GroundHit.png"]];
	
	hit.scale = .7;
	hit.opacity = 0;
	hit.anchorPoint = ccp(.5f,.5f);
	hit.position = ccp(hit.contentSize.width,0);
	[self addChild:hit];
	
	isOnTopOfObjects = NO;
	isBelowObjects = YES;
	//drawBoundingBoxes = YES;
	
	return self;
}

-(void)startEffect
{
	[super startEffect];
	
	[hit runAction:
	 [CCSequence actions:
		[CCSpawn actions:
		 [CCScaleTo actionWithDuration:0.4f scale:1.2f],
		 [CCSequence actions:
		  [CCFadeIn actionWithDuration:0.1f],
		  [CCFadeOut actionWithDuration:0.3f],
		  nil
		  ],
		 nil
		 ],
	  [CCCallFunc actionWithTarget:self selector:@selector(completeEffect)],
	  nil
	  ]
	 ];
	
	//hit.opacity = 255;
}


@end

